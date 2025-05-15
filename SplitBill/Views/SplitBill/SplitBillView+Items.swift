//
//  SplitBillView+Items.swift
//  SplitBill
//
//  Created by Reza Juliandri on 15/05/25.
//
import SwiftUI

extension SplitBillView {
    var noItemsInReceipt: some View {
        Section {
            Text("No items on the receipt.")
                .foregroundColor(.secondary)
        } header: {
            Text("Unassigned Items")
        }
    }
    var allItemsAssigned: some View {
        Section {
            Text("All items have been assigned or shared.")
                .foregroundColor(.secondary)
        } header: {
            Text("Unassigned Items")
        }
    }
    var sharedItems: some View {
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
    var unassignedItems: some View {
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
                    Text(group.totalPrice.currency)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    
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
                                .foregroundColor(.green)
                        }
                        .disabled(manager.participants.isEmpty)
                    }
                }
            }
        }
    }
}
