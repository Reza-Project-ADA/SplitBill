//
//  SDBillSplitRecord.swift
//  SplitBill
//
//  Created by Reza Juliandri on 09/05/25.
//


import Foundation
import SwiftData

@Model
final class SDBillSplitRecord {
    @Attribute(.unique) var id: UUID
    var storeName: String
    var receiptDateTime: Date // Combined date and time from receipt
    var receiptOrderNumber: String
    var receiptOriginalSubtotal: Double
    var receiptOriginalTax: Double
    var receiptOriginalTotal: Double
    var splitSavedAt: Date

    @Relationship(deleteRule: .cascade, inverse: \SDParticipantShare.billSplitRecord)
    var participantShares: [SDParticipantShare]? = []

    init(id: UUID = UUID(),
         storeName: String,
         receiptDateTime: Date,
         receiptOrderNumber: String,
         receiptOriginalSubtotal: Double,
         receiptOriginalTax: Double,
         receiptOriginalTotal: Double,
         splitSavedAt: Date = Date(),
         participantShares: [SDParticipantShare] = []) {
        self.id = id
        self.storeName = storeName
        self.receiptDateTime = receiptDateTime
        self.receiptOrderNumber = receiptOrderNumber
        self.receiptOriginalSubtotal = receiptOriginalSubtotal
        self.receiptOriginalTax = receiptOriginalTax
        self.receiptOriginalTotal = receiptOriginalTotal
        self.splitSavedAt = splitSavedAt
        self.participantShares = participantShares
    }
}

@Model
final class SDParticipantShare {
    @Attribute(.unique) var id: UUID
    var participantName: String
    var calculatedSubtotal: Double // Sum of their item portions
    var calculatedTaxShare: Double
    var calculatedTotalOwed: Double

    @Relationship(deleteRule: .cascade, inverse: \SDAssignedItemEntry.participantShare)
    var itemEntries: [SDAssignedItemEntry]? = []

    var billSplitRecord: SDBillSplitRecord? // Inverse relationship

    init(id: UUID = UUID(),
         participantName: String,
         calculatedSubtotal: Double,
         calculatedTaxShare: Double,
         calculatedTotalOwed: Double,
         itemEntries: [SDAssignedItemEntry] = []) {
        self.id = id
        self.participantName = participantName
        self.calculatedSubtotal = calculatedSubtotal
        self.calculatedTaxShare = calculatedTaxShare
        self.calculatedTotalOwed = calculatedTotalOwed
        self.itemEntries = itemEntries
    }
}

@Model
final class SDAssignedItemEntry {
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
