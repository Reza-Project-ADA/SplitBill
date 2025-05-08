//
//  SDAssignedItemEntry.swift
//  SplitBill
//
//  Created by Reza Juliandri on 09/05/25.
//


import Foundation
import SwiftData

@Model
class SDAssignedItemEntry {
    @Attribute(.unique) var id: UUID
    var itemName: String
    var originalItemUnitPrice: Double // Price of one whole unit of this item type
    var isShared: Bool
    var numberOfSharersIfShared: Int // e.g., 2, 3... (1 if not shared or directly assigned)
    var portionPaidByParticipant: Double // The actual amount this participant contributes for this item

    var participantShare: SDParticipantShare? // Inverse relationship

    init(id: UUID = UUID(),
         itemName: String,
         originalItemUnitPrice: Double,
         isShared: Bool,
         numberOfSharersIfShared: Int,
         portionPaidByParticipant: Double) {
        self.id = id
        self.itemName = itemName
        self.originalItemUnitPrice = originalItemUnitPrice
        self.isShared = isShared
        self.numberOfSharersIfShared = numberOfSharersIfShared
        self.portionPaidByParticipant = portionPaidByParticipant
    }
}
