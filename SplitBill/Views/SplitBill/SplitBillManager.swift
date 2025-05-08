//
//  SplitBillManager.swift
//  SplitBill
//
//  Created by Reza Juliandri on 09/05/25.
//


import SwiftUI
import Foundation
import SwiftData

class SplitBillManager: ObservableObject {
    @Published var receipt: ReceiptOutput
    @Published var allAssignableItems: [AssignableBillItem] = [] // Master list of all individual item units
    
    @Published var unassignedItems: [AssignableBillItem] = []
    @Published var participants: [BillParticipant] = []
    @Published var sharedItemLogs: [SharedItemLog] = [] // Log of items being shared
    
    private var totalReceiptSubtotalForCalculation: Double = 0
    
    var displayableUnassignedItemGroups: [DisplayableUnassignedItemGroup] {
        // Group unassignedItems by their originalReceiptItemID (or name + price if originalReceiptItemID isn't always unique for item types)
        // Using originalReceiptItemID is generally safer if available and consistent.
        let groupedByOriginalID = Dictionary(grouping: unassignedItems) { $0.originalReceiptItemID }
        
        return groupedByOriginalID.map { (originalID, itemsInGroup) -> DisplayableUnassignedItemGroup in
            guard let firstItem = itemsInGroup.first else {
                // This should not happen if itemsInGroup is derived from a non-empty grouping
                fatalError("Encountered an empty group for originalReceiptItemID: \(originalID)")
            }
            return DisplayableUnassignedItemGroup(
                id: originalID, // Use the ID of the original receipt item as the group's ID
                name: firstItem.name,
                pricePerUnit: firstItem.price, // AssignableBillItem.price is already price per unit
                quantity: itemsInGroup.count,
                assignableItems: itemsInGroup // Keep a reference to the actual items
            )
        }
        .sorted { $0.name < $1.name } // Optional: Sort for consistent UI
    }
    
    init(receipt: ReceiptOutput) {
        self.receipt = receipt
        self.totalReceiptSubtotalForCalculation = Double(receipt.transaction.subtotal)
        expandReceiptItems()
    }
    
    
    
    private func expandReceiptItems() {
        var assignable: [AssignableBillItem] = []
        for item in receipt.transaction.items {
            for _ in 0..<item.quantity {
                assignable.append(
                    AssignableBillItem(
                        originalReceiptItemID: item.id,
                        name: item.name,
                        price: item.pricePerUnit
                    )
                )
            }
        }
        self.allAssignableItems = assignable
        self.unassignedItems = assignable
    }
    
    // MARK: - Participant Management
    func addParticipant(name: String) {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let newParticipant = BillParticipant(name: name)
        participants.append(newParticipant)
        recalculateAllShares() // Full recalculation
    }
    
    
    func removeParticipant(_ participantToRemove: BillParticipant) {
        guard let index = participants.firstIndex(where: { $0.id == participantToRemove.id }) else { return }
        
        // 1. Move directly assigned items back to unassigned
        unassignedItems.append(contentsOf: participantToRemove.directlyAssignedItems)
        
        // 2. Remove participant from any shared items and manage resulting shared logs
        sharedItemLogs = sharedItemLogs.compactMap { log in
            var mutableLog = log
            if mutableLog.participantIDs.contains(participantToRemove.id) {
                mutableLog.participantIDs.remove(participantToRemove.id)
                
                if mutableLog.participantIDs.isEmpty || mutableLog.participantIDs.count == 1 {
                    // If item no longer shared or only by one, move original item back to unassigned
                    if let originalItem = allAssignableItems.first(where: { $0.id == mutableLog.itemID }) {
                        // Add back to unassigned if not already there (safety check)
                        if !unassignedItems.contains(where: {$0.id == originalItem.id}) {
                            unassignedItems.append(originalItem)
                        }
                    }
                    return nil // Remove this shared log
                }
            }
            return mutableLog // Keep log if still shared by >1 people
        }
        
        participants.remove(at: index)
        recalculateAllShares()
    }
    
    func removeParticipant(at offsets: IndexSet) {
        for index in offsets.sorted(by: >) { // Sort to avoid index issues when removing multiple
            let participantToRemove = participants[index]
            removeParticipant(participantToRemove) // Call the detailed removal logic
        }
        // recalculateAllShares is called by the individual removeParticipant method
    }
    
    
    // MARK: - Item Assignment (Direct)
    func assignItemDirectly(_ item: AssignableBillItem, to participantId: UUID) {
        guard let pIndex = participants.firstIndex(where: { $0.id == participantId }),
              let itemIndex = unassignedItems.firstIndex(where: { $0.id == item.id }) else { return }
        
        let itemToAssign = unassignedItems.remove(at: itemIndex)
        participants[pIndex].directlyAssignedItems.append(itemToAssign)
        recalculateAllShares()
    }
    
    func unassignDirectItem(_ item: AssignableBillItem, from participantId: UUID) {
        guard let pIndex = participants.firstIndex(where: { $0.id == participantId }),
              let itemIndex = participants[pIndex].directlyAssignedItems.firstIndex(where: { $0.id == item.id }) else { return }
        
        let itemToUnassign = participants[pIndex].directlyAssignedItems.remove(at: itemIndex)
        unassignedItems.append(itemToUnassign) // Add back to unassigned
        recalculateAllShares()
    }
    
    // MARK: - Item Sharing
    func shareItem(_ item: AssignableBillItem, among participantIDs: Set<UUID>) {
        guard !participantIDs.isEmpty, // Must have at least one sharer
              let itemIndex = unassignedItems.firstIndex(where: { $0.id == item.id }) else {
            print("Cannot share: item not found in unassigned or no participants selected.")
            return
        }
        
        let validParticipantIDs = participantIDs.filter { pid in self.participants.contains(where: { $0.id == pid }) }
        guard validParticipantIDs.count > 1 else { // Meaningful sharing involves at least 2 people
            print("Cannot share: needs at least two valid participants.")
            // Optional: if validParticipantIDs.count == 1, assign directly? For now, require >1.
            // Or just let it proceed, and recalculate will handle it. For clarity, let's enforce >1 for creating NEW shared log
            // If updating an existing shared log, 1 is allowed, but it will be handled.
            return
        }
        
        let itemToShare = unassignedItems.remove(at: itemIndex)
        let newSharedLog = SharedItemLog(itemID: itemToShare.id,
                                         itemName: itemToShare.name,
                                         itemPrice: itemToShare.price,
                                         participantIDs: validParticipantIDs)
        sharedItemLogs.append(newSharedLog)
        recalculateAllShares()
    }
    
    func unshareItem(sharedLogID: UUID) {
        guard let logIndex = sharedItemLogs.firstIndex(where: { $0.id == sharedLogID }) else { return }
        
        let logToRemove = sharedItemLogs.remove(at: logIndex)
        if let originalItem = allAssignableItems.first(where: { $0.id == logToRemove.itemID }) {
            if !unassignedItems.contains(where: {$0.id == originalItem.id}) { // Avoid duplicates
                unassignedItems.append(originalItem)
            }
        }
        recalculateAllShares()
    }
    
    func updateSharers(for sharedLogID: UUID, newParticipantIDs: Set<UUID>) {
        guard let logIndex = sharedItemLogs.firstIndex(where: { $0.id == sharedLogID }) else { return }
        
        let validParticipantIDs = newParticipantIDs.filter { pid in self.participants.contains(where: { $0.id == pid }) }
        
        if validParticipantIDs.count <= 1 { // If 0 or 1 sharer, effectively unshare it
            unshareItem(sharedLogID: sharedLogID) // This moves item to unassigned
        } else {
            sharedItemLogs[logIndex].participantIDs = validParticipantIDs
            recalculateAllShares()
        }
    }
    
    // MARK: - Calculation
    func recalculateAllShares() {
        // Create a temporary copy to modify, then reassign to trigger @Published update
        var tempParticipants = self.participants
        
        for i in 0..<tempParticipants.count {
            var currentParticipantSubtotal: Double = 0.0
            
            // 1. Sum of directly assigned items
            currentParticipantSubtotal += tempParticipants[i].directlyAssignedItems.reduce(0) { $0 + $1.price }
            
            // 2. Sum of portions from shared items
            for sharedLog in sharedItemLogs {
                if sharedLog.participantIDs.contains(tempParticipants[i].id) {
                    currentParticipantSubtotal += sharedLog.pricePerSharer
                }
            }
            tempParticipants[i].subtotal = currentParticipantSubtotal
        }
        
        // Now calculate tax share based on the new subtotals
        let receiptTax = Double(receipt.transaction.tax)
        for i in 0..<tempParticipants.count {
            if totalReceiptSubtotalForCalculation > 0 {
                // Proportion based on the original receipt's subtotal
                let proportion = tempParticipants[i].subtotal / totalReceiptSubtotalForCalculation
                tempParticipants[i].taxShare = proportion * receiptTax
                if tempParticipants[i].taxShare < 0 { tempParticipants[i].taxShare = 0 } // Safety
            } else if !tempParticipants.isEmpty {
                // If original subtotal is 0 (e.g. all free items), split tax equally
                tempParticipants[i].taxShare = receiptTax / Double(tempParticipants.count)
            } else {
                tempParticipants[i].taxShare = 0 // No participants, no tax share
            }
        }
        
        // Assign the modified array back to the @Published property to ensure UI updates
        self.participants = tempParticipants
        
        objectWillChange.send() // Explicitly notify observers if needed for complex changes
        
        // --- Optional Debug Logging ---
        // printSummary()
    }
    // MARK: - SwiftData Saving
    func saveSplitToSwiftData(modelContext: ModelContext) {
        guard !participants.isEmpty else {
            print("Cannot save: No participants in the split.")
            // Optionally provide user feedback here (e.g., an alert)
            return
        }
        
        // Check if all items are assigned/shared (optional, but good practice)
        if !unassignedItems.isEmpty {
            print("Warning: Not all items are assigned or shared. Saving current state.")
            // Optionally, prompt the user if they want to save an incomplete split
        }
        
        let receiptDateTime = parseReceiptDateTime(
            dateString: receipt.transaction.date,
            timeString: receipt.transaction.time
        )
        
        let sdBillRecord = SDBillSplitRecord(
            storeName: receipt.store.name,
            receiptDateTime: receiptDateTime,
            receiptOrderNumber: receipt.transaction.order_number,
            receiptOriginalSubtotal: Double(receipt.transaction.subtotal),
            receiptOriginalTax: Double(receipt.transaction.tax),
            receiptOriginalTotal: Double(receipt.transaction.total)
        )
        
        var sdParticipantShares: [SDParticipantShare] = []
        
        for participant in participants {
            var sdItemEntries: [SDAssignedItemEntry] = []
            
            // 1. Directly assigned items
            for directItem in participant.directlyAssignedItems {
                let entry = SDAssignedItemEntry(
                    itemName: directItem.name,
                    originalItemUnitPrice: directItem.price, // This is already per unit
                    isShared: false,
                    numberOfSharersIfShared: 1, // Not shared, so effectively 1
                    portionPaidByParticipant: directItem.price
                )
                sdItemEntries.append(entry)
            }
            
            // 2. Shared items
            for sharedLog in sharedItemLogs {
                if sharedLog.participantIDs.contains(participant.id) {
                    // Find the original AssignableBillItem to get its unit price
                    guard let originalAssignableItem = allAssignableItems.first(where: { $0.id == sharedLog.itemID }) else {
                        print("Error: Could not find original assignable item for shared log \(sharedLog.itemName)")
                        continue // Skip this entry if original item details can't be found
                    }
                    
                    let entry = SDAssignedItemEntry(
                        itemName: sharedLog.itemName,
                        originalItemUnitPrice: originalAssignableItem.price, // Price of one unit
                        isShared: true,
                        numberOfSharersIfShared: sharedLog.participantIDs.count,
                        portionPaidByParticipant: sharedLog.pricePerSharer // Participant's cost for this share
                    )
                    sdItemEntries.append(entry)
                }
            }
            
            let sdParticipant = SDParticipantShare(
                participantName: participant.name,
                calculatedSubtotal: participant.subtotal,
                calculatedTaxShare: participant.taxShare,
                calculatedTotalOwed: participant.totalOwed,
                itemEntries: sdItemEntries
            )
            sdParticipantShares.append(sdParticipant)
        }
        
        sdBillRecord.participantShares = sdParticipantShares
        
        // Link back-references (SwiftData @Model macro might handle some of this, but explicit is safer)
        for share in sdParticipantShares {
            share.billSplitRecord = sdBillRecord
            for entry in share.itemEntries ?? [] {
                entry.participantShare = share
            }
        }
        
        modelContext.insert(sdBillRecord)
        
        // SwiftData typically auto-saves, but explicit save can be done if needed:
        // do {
        //     try modelContext.save()
        //     print("Bill split saved successfully!")
        // } catch {
        //     print("Failed to save bill split: \(error)")
        // }
        print("Bill split prepared for SwiftData insertion.")
    }
    
    func printSummary() {
        print("--- Recalculated Bill ---")
        print("Receipt Total: \(Double(receipt.transaction.total).formatted(.currency(code: "IDR"))), Tax: \(Double(receipt.transaction.tax).formatted(.currency(code: "IDR")))")
        participants.forEach { p in
            print("\(p.name): Subtotal \(p.subtotal.formatted(.currency(code: "IDR"))), Tax \(p.taxShare.formatted(.currency(code: "IDR"))), Total \(p.totalOwed.formatted(.currency(code: "IDR")))")
        }
        let sumOfIndividualTotals = participants.reduce(0){ $0 + $1.totalOwed }
        print("Sum of Participants' Totals: \(sumOfIndividualTotals.formatted(.currency(code: "IDR")))")
        if !unassignedItems.isEmpty {
            print("WARNING: \(unassignedItems.count) items still unassigned. Value: \(unassignedItems.reduce(0, { $0 + $1.price}).formatted(.currency(code: "IDR")))")
        }
        print("--------------------")
    }
    
    // Helper to get participant by ID
    func participant(by id: UUID) -> BillParticipant? {
        participants.first(where: { $0.id == id })
    }
    
    // Helper to get AssignableBillItem by ID (needed for ShareItemSheet)
    func getAssignableItem(by id: UUID) -> AssignableBillItem? {
        allAssignableItems.first(where: { $0.id == id })
    }
    // Helper function to parse date and time strings
    func parseReceiptDateTime(dateString: String, timeString: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm" // Format for "2025-05-02 20:33"
        formatter.locale = Locale(identifier: "en_US_POSIX") // Important for consistent parsing
        formatter.timeZone = TimeZone.current // Or a specific timezone if known
        
        if let date = formatter.date(from: "\(dateString) \(timeString)") {
            return date
        }
        // Fallback if parsing fails, though ideally it shouldn't with correct format
        print("Warning: Could not parse receipt date-time. Using current date.")
        return Date()
    }
}
