//
//  SplitSessionViewModel.swift
//  SplitBill
//
//  Created by Reza Juliandri on 14/07/25.
//

import SwiftUI
import Foundation

class SplitSessionViewModel: ObservableObject {
    @Published var sessionTitle: String = ""
    @Published var sessionCategory: String = ""
    @Published var sessionDate: Date = Date()
    @Published var useCustomDate: Bool = false
    @Published var expenses: [ExpenseItem] = []
    @Published var participantCount: Int = 1
    @Published var selectedFriends: [SDFriend] = []
    @Published var manualParticipants: [String] = []
    @Published var participantInputMode: ParticipantInputMode = .count
    @Published var paymentDetails: PaymentDetails = PaymentDetails()
    
    // Computed properties
    var totalCost: Double {
        expenses.reduce(0) { $0 + $1.amount }
    }
    
    var actualParticipantCount: Int {
        switch participantInputMode {
        case .count:
            return participantCount
        case .mixed:
            return selectedFriends.count + manualParticipants.count
        }
    }
    
    var rawSharePerPerson: Double {
        guard actualParticipantCount > 0 else { return 0 }
        return totalCost / Double(actualParticipantCount)
    }
    
    var roundedSharePerPerson: Double {
        return ceil(rawSharePerPerson)
    }
    
    var totalOverage: Double {
        let totalCollected = roundedSharePerPerson * Double(actualParticipantCount)
        return totalCollected - totalCost
    }
    
    // Methods
    func addExpense(description: String, amount: Double) {
        let expense = ExpenseItem(description: description, amount: amount)
        expenses.append(expense)
    }
    
    func removeExpense(at index: Int) {
        guard index < expenses.count else { return }
        expenses.remove(at: index)
    }
    
    func updateParticipantCount(_ count: Int) {
        participantCount = max(1, count)
    }
    
    func addFriend(_ friend: SDFriend) {
        if !selectedFriends.contains(where: { $0.id == friend.id }) {
            selectedFriends.append(friend)
            friend.updateLastUsed()
        }
    }
    
    func removeFriend(_ friend: SDFriend) {
        selectedFriends.removeAll { $0.id == friend.id }
    }
    
    func addManualParticipant(_ name: String) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedName.isEmpty && !manualParticipants.contains(trimmedName) {
            manualParticipants.append(trimmedName)
        }
    }
    
    func removeManualParticipant(at index: Int) {
        guard index < manualParticipants.count else { return }
        manualParticipants.remove(at: index)
    }
    
    func generateSummary() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        
        let dateToUse = useCustomDate ? sessionDate : Date()
        var summary = "Session \(formatter.string(from: dateToUse))\n\n"
        
        // Participants list
        var allParticipants: [String] = []
        switch participantInputMode {
        case .count:
            allParticipants = (1...actualParticipantCount).map { "Person \($0)" }
        case .mixed:
            allParticipants = selectedFriends.map { $0.name } + manualParticipants
        }
        
        for participant in allParticipants {
            summary += "\(participant)\n"
        }
        
        summary += "\n"
        
        // Expenses in single line format
        let expenseDescriptions = expenses.map { "\($0.description) \($0.amount.currency)" }
        summary += expenseDescriptions.joined(separator: " + ")
        
        summary += "\n\(totalCost.currency) ÷ \(actualParticipantCount) = \(roundedSharePerPerson.currency)\n"
        
        // Payment details if provided
        if !paymentDetails.accountNumber.isEmpty {
            summary += "\n\(paymentDetails.accountNumber)"
            if !paymentDetails.bankName.isEmpty {
                summary += " \(paymentDetails.bankName.lowercased())"
            }
            if !paymentDetails.accountName.isEmpty {
                summary += " \(paymentDetails.accountName)"
            }
        }
        
        return summary
    }
    
    func resetSession() {
        sessionTitle = ""
        sessionCategory = ""
        sessionDate = Date()
        useCustomDate = false
        expenses.removeAll()
        participantCount = 1
        selectedFriends.removeAll()
        manualParticipants.removeAll()
        participantInputMode = .count
        paymentDetails = PaymentDetails()
    }
}

enum ParticipantInputMode: String, CaseIterable {
    case count = "Count Only"
    case mixed = "Friends & Manual"
}

struct PaymentDetails {
    var accountNumber: String = ""
    var bankName: String = ""
    var accountName: String = ""
}

struct ExpenseItem: Identifiable {
    let id = UUID()
    let description: String
    let amount: Double
}