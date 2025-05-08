//
//  SplitBillView.swift
//  SplitBill
//
//  Created by Reza Juliandri on 09/05/25.
//
import SwiftUI

// Keep your AssignItemSheet for direct assignment (or rename for clarity)
struct AssignItemDirectlySheet: View { // Renamed from AssignItemSheet
    let item: AssignableBillItem
    let participants: [BillParticipant]
    let onAssign: (UUID) -> Void
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section("Assign \(item.name) (\(item.price, format: .currency(code: "IDR")))") {
                    if participants.isEmpty {
                        Text("No participants to assign to.")
                    } else {
                        ForEach(participants) { participant in
                            Button(participant.name) {
                                onAssign(participant.id)
                                dismiss()
                            }
                        }
                    }
                }
            }
            .navigationTitle("Assign to Person")
            .toolbar { ToolbarItem(placement: .navigationBarLeading) { Button("Cancel") { dismiss() } } }
        }
    }
}


struct SplitBillView: View {
    @StateObject var manager: SplitBillManager
    @Environment(\.modelContext) private var modelContext // Access ModelContext
    @State private var newParticipantName: String = ""
    
    // States for sheets
    @State private var itemForDirectAssignment: AssignableBillItem? = nil
    @State private var itemForSharing: AssignableBillItem? = nil
    @State private var sharedLogForEditing: SharedItemLog? = nil
    @State private var showSaveConfirmation = false
    @State private var showSavedSplits = false
    
    init(receipt: ReceiptOutput) {
        _manager = StateObject(wrappedValue: SplitBillManager(receipt: receipt))
    }
    
    var body: some View {
        NavigationView {
            List {
                // Add Participant Section (same as before)
                Section("Add Participant") {
                    HStack {
                        TextField("Participant Name", text: $newParticipantName)
                        Button("Add") {
                            manager.addParticipant(name: newParticipantName)
                            newParticipantName = ""
                        }
                        .disabled(newParticipantName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
                
                // Unassigned Items Section
                if !manager.displayableUnassignedItemGroups.isEmpty { // Use the new computed property
                    Section("Unassigned Items") {
                        // Iterate over the groups
                        ForEach(manager.displayableUnassignedItemGroups) { group in
                            HStack {
                                Text(group.name)
                                if group.quantity > 1 {
                                    Text("(Qty: \(group.quantity))") // Display quantity if more than 1
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                // Display total price for the group (pricePerUnit * quantity)
                                Text(group.totalPrice, format: .currency(code: "IDR"))
                                
                                // Menu actions will operate on ONE item from the group
                                if let itemToActOn = group.firstAssignableItem { // Get one item from the group
                                    Menu {
                                        Button("Assign One to Person") {
                                            itemForDirectAssignment = itemToActOn
                                        }
                                        Button("Share This One") {
                                            itemForSharing = itemToActOn
                                        }
                                        // You could add "Assign All (Qty)" or "Share All (Qty)" features here later
                                        // but they would require more complex logic in the manager.
                                        // For now, "One" is clear and uses existing manager functions.
                                    } label: {
                                        Image(systemName: "plus.circle.fill")
                                            .accessibilityLabel("Assign or share one \(group.name)")
                                    }
                                    .disabled(manager.participants.isEmpty)
                                }
                            }
                        }
                    }
                } else if manager.allAssignableItems.isEmpty && manager.sharedItemLogs.isEmpty { // Edge case if receipt was empty
                    Section("Unassigned Items") {
                        Text("No items on the receipt.")
                            .foregroundColor(.secondary)
                    }
                } else if manager.unassignedItems.isEmpty { // All items assigned/shared
                    Section("Unassigned Items") {
                        Text("All items have been assigned or shared.")
                            .foregroundColor(.secondary)
                    }
                }
                
                // Shared Items Section
                if !manager.sharedItemLogs.isEmpty {
                    Section("Shared Items") {
                        ForEach(manager.sharedItemLogs) { sharedLog in
                            VStack(alignment: .leading) {
                                HStack {
                                    Text(sharedLog.itemName)
                                        .font(.headline)
                                    Spacer()
                                    Text("Total: \(sharedLog.itemPrice, format: .currency(code: "IDR"))")
                                }
                                Text("Shared by: \(sharedLog.participantIDs.compactMap { manager.participant(by: $0)?.name }.sorted().joined(separator: ", "))")
                                    .font(.caption)
                                Text("Cost per sharer: \(sharedLog.pricePerSharer, format: .currency(code: "IDR"))")
                                    .font(.caption)
                                HStack {
                                    Spacer()
                                    Button("Edit Sharers") { sharedLogForEditing = sharedLog }
                                    Button("Unshare") { manager.unshareItem(sharedLogID: sharedLog.id) }
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                }
                
                // Participants & Shares Section
                Section("Participants & Shares") {
                    if manager.participants.isEmpty {
                        Text("No participants added yet.").foregroundColor(.secondary)
                    }
                    ForEach($manager.participants) { $participant in
                        DisclosureGroup {
                            if participant.directlyAssignedItems.isEmpty && !manager.sharedItemLogs.contains(where: { $0.participantIDs.contains(participant.id) }) {
                                Text("No items yet for \(participant.name).")
                                    .font(.caption).foregroundColor(.secondary)
                            }
                            
                            if !participant.directlyAssignedItems.isEmpty {
                                Text("Directly Assigned:").font(.caption.weight(.semibold)).padding(.top, 2)
                                ForEach(participant.directlyAssignedItems) { item in
                                    HStack {
                                        Text("  - \(item.name)")
                                        Spacer()
                                        Text(item.price, format: .currency(code: "IDR"))
                                        Button { manager.unassignDirectItem(item, from: participant.id) } label: {
                                            Image(systemName: "minus.circle.fill").foregroundColor(.red)
                                        }
                                    }
                                }
                            }
                            
                            let itemsSharedByThisParticipant = manager.sharedItemLogs.filter { $0.participantIDs.contains(participant.id) }
                            if !itemsSharedByThisParticipant.isEmpty {
                                Text("Shared Items (Your Portion):").font(.caption.weight(.semibold)).padding(.top, 2)
                                ForEach(itemsSharedByThisParticipant) { sharedLog in
                                    HStack {
                                        Text("  - \(sharedLog.itemName) (1/\(sharedLog.participantIDs.count) of \(sharedLog.itemPrice, format: .currency(code: "IDR")))")
                                        Spacer()
                                        Text(sharedLog.pricePerSharer, format: .currency(code: "IDR"))
                                    }
                                }
                            }
                            Divider()
                            HStack { Text("Subtotal:").bold(); Spacer(); Text(participant.subtotal, format: .currency(code: "IDR")) }
                            HStack { Text("Tax Share:").bold(); Spacer(); Text(participant.taxShare, format: .currency(code: "IDR")) }
                            HStack { Text("Total Owed:").bold(); Spacer(); Text(participant.totalOwed, format: .currency(code: "IDR")) }
                            
                        } label: {
                            HStack {
                                Text(participant.name).font(.headline)
                                Spacer()
                                Text(participant.totalOwed, format: .currency(code: "IDR")).font(.headline)
                            }
                        }
                    }
                    .onDelete(perform: manager.removeParticipant)
                }
                
                // Bill Summary Section (same as before)
                Section("Bill Summary") {
                    HStack { Text("Receipt Subtotal:"); Spacer(); Text(Double(manager.receipt.transaction.subtotal), format: .currency(code: "IDR")) }
                    HStack { Text("Receipt Tax:"); Spacer(); Text(Double(manager.receipt.transaction.tax), format: .currency(code: "IDR")) }
                    HStack { Text("Receipt Total:").bold(); Spacer(); Text(Double(manager.receipt.transaction.total), format: .currency(code: "IDR")).bold() }
                    Divider()
                    HStack { Text("Sum of Participants' Totals:"); Spacer(); Text(manager.participants.reduce(0){ $0 + $1.totalOwed }, format: .currency(code: "IDR")) }
                    HStack { Text("Remaining Unassigned Value:"); Spacer(); Text(manager.unassignedItems.reduce(0){ $0 + $1.price }, format: .currency(code: "IDR")) }
                    let calculatedTotalTax = manager.participants.reduce(0) { $0 + $1.taxShare }
                    let calculatedTotalSubtotal = manager.participants.reduce(0) { $0 + $1.subtotal }
                    HStack { Text("Calculated Total Tax:"); Spacer(); Text(calculatedTotalTax, format: .currency(code: "IDR"))}
                    HStack { Text("Calculated Total Subtotal:"); Spacer(); Text(calculatedTotalSubtotal, format: .currency(code: "IDR"))}
                }
                
            }
            .navigationTitle("\(manager.receipt.store.name) Split")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    EditButton()
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    // Button to navigate to Saved Splits List
                    Button {
                        showSavedSplits = true
                    } label: {
                        Label("View Saved", systemImage: "list.bullet.rectangle.portrait")
                    }
                    
                    Button {
                        manager.saveSplitToSwiftData(modelContext: modelContext)
                        showSaveConfirmation = true // Show confirmation
                    } label: {
                        Label("Save Split", systemImage: "square.and.arrow.down")
                    }
                    .disabled(manager.participants.isEmpty || !manager.unassignedItems.isEmpty) // Example: Enable only if participants exist and all items handled
                }
            }
            .alert("Split Saved", isPresented: $showSaveConfirmation) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("The bill split has been saved successfully.")
            }
            .sheet(isPresented: $showSavedSplits) { // Or use NavigationLink for push
                SavedSplitsListView() // Present as a sheet
            }
            .sheet(item: $itemForDirectAssignment) { item in
                AssignItemDirectlySheet(item: item, participants: manager.participants) { participantId in
                    manager.assignItemDirectly(item, to: participantId)
                }
            }
            .sheet(item: $itemForSharing) { item in
                ShareItemSheet(item: item, participants: manager.participants) { selectedIDs in
                    if selectedIDs.count > 1 { // Only create a share log if more than 1 person
                        manager.shareItem(item, among: selectedIDs)
                    } else if selectedIDs.count == 1, let singleParticipantID = selectedIDs.first {
                        // If only one person selected, assign directly to them
                        manager.assignItemDirectly(item, to: singleParticipantID)
                    }
                    // If 0 selected, do nothing (item remains unassigned)
                }
            }
            .sheet(item: $sharedLogForEditing) { sharedLog in
                // Need to find the original AssignableBillItem for the sheet
                if let originalItem = manager.getAssignableItem(by: sharedLog.itemID) {
                    ShareItemSheet(item: originalItem,
                                   participants: manager.participants,
                                   currentSharers: sharedLog.participantIDs) { updatedIDs in
                        manager.updateSharers(for: sharedLog.id, newParticipantIDs: updatedIDs)
                    }
                } else {
                    // Fallback or error view if original item not found (should not happen)
                    Text("Error: Original item for sharing not found.")
                }
            }
        }
        .onChange(of: manager.participants) { manager.printSummary()
        } // For debugging
        .onChange(of: manager.sharedItemLogs) { manager.printSummary()
        } // For debugging
        .onChange(of: manager.unassignedItems) { manager.printSummary()
        } // For debugging
        
        
    }
}


// MARK: - Preview
struct SplitBillView_Previews: PreviewProvider {
    static let sampleReceipt = ReceiptOutput(
        store: ReceiptStore(name: "SOLARIA", address: "N/A"),
        transaction: ReceiptTransaction(
            date: "2025-05-02", time: "20:33", cashier: "Anastasya Sabna Wardani", order_number: "393",
            items: [
                ReceiptItem(name: "Kwetiau Sapi Goreng", quantity: 1, price: 63638),
                ReceiptItem(name: "Crispy Mini Wonton", quantity: 1, price: 24546),
                ReceiptItem(name: "Air Mineral Botol", quantity: 1, price: 14546),
                ReceiptItem(name: "Es Teh Manis", quantity: 2, price: 27274) // 13637 each
            ],
            subtotal: 130004, tax: 13000, total: 143000,
            payment: ReceiptPayment(cash: 143000, change: 0, status: "Lunas")
        )
    )
    
    static var previews: some View {
        SplitBillView(receipt: sampleReceipt)
    }
}
