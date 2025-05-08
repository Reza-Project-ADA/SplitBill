//
//  SDParticipantShare.swift
//  SplitBill
//
//  Created by Reza Juliandri on 09/05/25.
//


import Foundation
import SwiftData

@Model
final class SDParticipantShare {
    @Attribute(.unique) var id: UUID
    var participantName: String
    var calculatedSubtotal: Double // Sum of their item portions
    var calculatedTaxShare: Double
    var calculatedTotalOwed: Double

    @Relationship
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
