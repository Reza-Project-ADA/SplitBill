//
//  SDBillSplitRecord.swift
//  SplitBill
//
//  Created by Reza Juliandri on 09/05/25.
//


import Foundation
import SwiftData

@Model
class SDBillSplitRecord {
    @Attribute(.unique) var id: UUID
    var storeName: String
    var receiptDateTime: Date // Combined date and time from receipt
    var receiptOrderNumber: String
    var receiptOriginalSubtotal: Double
    var receiptOriginalTax: Double
    var receiptOriginalTotal: Double
    var splitSavedAt: Date

    @Relationship
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




