//
//  DisplayableUnassignedItemGroup.swift
//  SplitBill
//
//  Created by Reza Juliandri on 09/05/25.
//
import Foundation

struct DisplayableUnassignedItemGroup: Identifiable, Hashable {
    let id: UUID // Typically the originalReceiptItemID from the first item in the group
    let name: String
    let pricePerUnit: Double
    var quantity: Int // How many units of this item are unassigned
    var totalPrice: Double { pricePerUnit * Double(quantity) }
    
    // Store the actual individual AssignableBillItems that make up this group.
    // This is important for picking one to assign/share.
    var assignableItems: [AssignableBillItem]

    // Helper to get the first available item from this group for an action
    var firstAssignableItem: AssignableBillItem? {
        assignableItems.first
    }
}
