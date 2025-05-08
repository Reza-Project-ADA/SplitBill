//
//  SharedItemLog.swift
//  SplitBill
//
//  Created by Reza Juliandri on 09/05/25.
//
import Foundation


struct SharedItemLog: Identifiable, Hashable {
    let id = UUID() // Unique ID for this sharing instance
    let itemID: UUID // ID of the AssignableBillItem being shared (links to allAssignableItems)
    let itemName: String
    let itemPrice: Double // Total price of the item being shared
    var participantIDs: Set<UUID> // IDs of participants sharing this item

    var pricePerSharer: Double {
        guard !participantIDs.isEmpty else { return 0 }
        // Ensure division by zero is handled, though participantIDs shouldn't be empty in a valid log
        return itemPrice / Double(participantIDs.count)
    }
}
