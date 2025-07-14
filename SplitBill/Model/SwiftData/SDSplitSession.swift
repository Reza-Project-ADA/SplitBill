//
//  SDSplitSession.swift
//  SplitBill
//
//  Created by Reza Juliandri on 14/07/25.
//

import Foundation
import SwiftData

@Model
class SDSplitSession {
    var id: UUID
    var sessionTitle: String
    var sessionCategory: String
    var participantCount: Int
    var participantNames: [String]
    var totalCost: Double
    var roundedSharePerPerson: Double
    var totalOverage: Double
    var createdAt: Date
    var expenses: [SDExpenseItem]
    var paymentAccountNumber: String
    var paymentBankName: String
    var paymentAccountName: String
    var generatedSummary: String
    
    init(sessionTitle: String, sessionCategory: String, participantCount: Int, participantNames: [String], totalCost: Double, roundedSharePerPerson: Double, totalOverage: Double, expenses: [SDExpenseItem], paymentAccountNumber: String = "", paymentBankName: String = "", paymentAccountName: String = "", generatedSummary: String = "") {
        self.id = UUID()
        self.sessionTitle = sessionTitle
        self.sessionCategory = sessionCategory
        self.participantCount = participantCount
        self.participantNames = participantNames
        self.totalCost = totalCost
        self.roundedSharePerPerson = roundedSharePerPerson
        self.totalOverage = totalOverage
        self.createdAt = Date()
        self.expenses = expenses
        self.paymentAccountNumber = paymentAccountNumber
        self.paymentBankName = paymentBankName
        self.paymentAccountName = paymentAccountName
        self.generatedSummary = generatedSummary
    }
}

@Model
class SDExpenseItem {
    var id: UUID
    var itemDescription: String
    var amount: Double
    var session: SDSplitSession?
    
    init(itemDescription: String, amount: Double) {
        self.id = UUID()
        self.itemDescription = itemDescription
        self.amount = amount
    }
}