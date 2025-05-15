//
//  SplitBillView.swift
//  SplitBill
//
//  Created by Reza Juliandri on 09/05/25.
//
import SwiftUI

// Keep your AssignItemSheet for direct assignment (or rename for clarity)



struct SplitBillView: View {
    @StateObject var manager: SplitBillManager
    @Environment(\.modelContext) private var modelContext // Access ModelContext
    @State internal var newParticipantName: String = ""
    
    // States for sheets
    @State internal var itemForDirectAssignment: AssignableBillItem? = nil
    @State internal var itemForSharing: AssignableBillItem? = nil
    @State internal var sharedLogForEditing: SharedItemLog? = nil
    @State internal var showSaveConfirmation = false
    
    init(receipt: ReceiptOutput) {
        _manager = StateObject(wrappedValue: SplitBillManager(receipt: receipt))
    }
    
    var contentSection: some View {
        Group {
            if !manager.displayableUnassignedItemGroups.isEmpty {
                unassignedItems
            } else if manager.allAssignableItems.isEmpty && manager.sharedItemLogs.isEmpty {
                noItemsInReceipt
            } else if manager.unassignedItems.isEmpty {
                allItemsAssigned
            }
            if !manager.sharedItemLogs.isEmpty {
                sharedItems
            }
            participantsShares
            billSummary
        }
    }
    
    var body: some View {
        List {
            addParticipant
            contentSection
        }
        .navigationTitle("\(manager.receipt.store.name) Split")
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                EditButton()
            }
            ToolbarItemGroup(placement: .navigationBarTrailing) {
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
        
        .onChange(of: manager.participants) {
            manager.printSummary()
        }
        .onChange(of: manager.sharedItemLogs) {
            manager.printSummary()
        }
        .onChange(of: manager.unassignedItems) {
            manager.printSummary()
        }
    }
}


// MARK: - Preview
struct SplitBillView_Previews: PreviewProvider {
    static let sampleReceipt = ReceiptOutput(
        store: ReceiptStore(name: "SOLARIA", address: "N/A", branch: "N/A", phone: "08123456789"),
        transaction: ReceiptTransaction(
            date: "2025-05-02", time: "20:33", cashier: "Anastasya Sabna Wardani", order_number: "393",
            items: [
                ReceiptItem(name: "Kwetiau Sapi Goreng", quantity: 1, price: 63638),
                ReceiptItem(name: "Crispy Mini Wonton", quantity: 1, price: 24546),
                ReceiptItem(name: "Air Mineral Botol", quantity: 1, price: 14546),
                ReceiptItem(name: "Es Teh Manis", quantity: 2, price: 27274) // 13637 each
            ],
            subtotal: 130004, tax: 13000, service_fee: 0, delivery_fee: 0,
            other_fee: 0, total: 143000,
            payment: ReceiptPayment(cash: 143000, change: 0, status: "Lunas")
        )
    )
    
    static var previews: some View {
        SplitBillView(receipt: sampleReceipt)
    }
}
