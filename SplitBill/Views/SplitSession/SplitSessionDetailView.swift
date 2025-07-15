//
//  SplitSessionDetailView.swift
//  SplitBill
//
//  Created by Reza Juliandri on 14/07/25.
//

import SwiftUI
import SwiftData

struct SplitSessionDetailView: View {
    let session: SDSplitSession
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(
        filter: #Predicate<SDFriend> { !$0.isDeleted },
        sort: [SortDescriptor(\SDFriend.name)]
    )
    private var friends: [SDFriend]
    
    @State private var showingAddFriendConfirmation = false
    @State private var participantToAdd: String = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    sessionInfoSection
                    expensesSection
                    participantsSection
                    calculationSection
                    summarySection
                }
                .padding()
            }
            .navigationTitle(session.sessionTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .confirmationDialog(
                "Add to Friends",
                isPresented: $showingAddFriendConfirmation,
                titleVisibility: .visible
            ) {
                Button("Add \(participantToAdd) to Friends") {
                    addParticipantToFriends(participantToAdd)
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Do you want to add \(participantToAdd) to your friends list?")
            }
        }
    }
    
    private var sessionInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Session Information")
                .font(.headline)
                .fontWeight(.semibold)
            
            if !session.sessionCategory.isEmpty {
                HStack {
                    Text("Category:")
                        .fontWeight(.medium)
                    Spacer()
                    Text(session.sessionCategory)
                        .foregroundColor(.secondary)
                }
            }
            
            HStack {
                Text("Created:")
                    .fontWeight(.medium)
                Spacer()
                Text(session.createdAt, style: .date)
                Text("at \(session.createdAt, style: .time)")
            }
            .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(CardStyle.cardCornerRadius)
        .shadow(color: Color.black.opacity(0.1), radius: CardStyle.cardShadowRadius, x: 0, y: 2)
    }
    
    private var expensesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Expenses")
                .font(.headline)
                .fontWeight(.semibold)
            
            ForEach(session.expenses, id: \.id) { expense in
                HStack(spacing: 12) {
                    Image(systemName: "dollarsign.circle.fill")
                        .font(.title2)
                        .foregroundColor(.green)
                        .frame(width: 30)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(expense.itemDescription)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        Text(expense.amount.currency)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(CardStyle.cardCornerRadius)
        .shadow(color: Color.black.opacity(0.1), radius: CardStyle.cardShadowRadius, x: 0, y: 2)
    }
    
    private var participantsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Participants")
                .font(.body)
                .fontWeight(.semibold)
            
            Text("\(session.participantCount) Participants")
                .foregroundColor(.secondary)
            
            
            if !session.participantNames.isEmpty {
                ForEach(session.participantNames, id: \.self) { name in
                    HStack(spacing: 12) {
                        // Profile image with add to friends functionality
                        Button(action: {
                            if !isParticipantInFriends(name) {
                                participantToAdd = name
                                showingAddFriendConfirmation = true
                            }
                        }) {
                            ZStack {
                                if isParticipantInFriends(name) {
                                    Image(systemName: "person.crop.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.green)
                                } else {
                                    Image(systemName: "person.crop.circle.fill.badge.plus")
                                        .font(.title2)
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        .disabled(isParticipantInFriends(name))
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(name)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                            
                            if isParticipantInFriends(name) {
                                Text("Already in friends")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            } else {
                                Text("Tap to add to friends")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        Text(session.roundedSharePerPerson.currency)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                    }
                    .padding(.vertical, 6)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(CardStyle.cardCornerRadius)
        .shadow(color: Color.black.opacity(0.1), radius: CardStyle.cardShadowRadius, x: 0, y: 2)
    }
    
    private var calculationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Calculation")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack {
                Text("Total Cost:")
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(session.totalCost.currency)
                    .fontWeight(.semibold)
            }
            
            HStack {
                Text("Per Person:")
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(session.roundedSharePerPerson.currency)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
            }
            
            if session.totalOverage > 0 {
                HStack {
                    Text("Overage:")
                        .fontWeight(.medium)
                    Spacer()
                    Text(session.totalOverage.currency)
                        .fontWeight(.semibold)
                        .foregroundColor(.orange)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(CardStyle.cardCornerRadius)
        .shadow(color: Color.black.opacity(0.1), radius: CardStyle.cardShadowRadius, x: 0, y: 2)
    }
    
    private var summarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Summary")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(generateSummary())
                .font(.system(.body, design: .monospaced))
                .padding()
                .cornerRadius(8)
            
            Button(action: {
                UIPasteboard.general.string = generateSummary()
            }) {
                Label("Copy to Clipboard", systemImage: "doc.on.clipboard")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(CardStyle.cardCornerRadius)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(CardStyle.cardCornerRadius)
        .shadow(color: Color.black.opacity(0.1), radius: CardStyle.cardShadowRadius, x: 0, y: 2)
    }
    
    private func generateSummary() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        
        var summary = "Session \(formatter.string(from: session.createdAt))\n\n"
        
        // Participants list
        if !session.participantNames.isEmpty {
            // Mixed mode - show individual names
            for name in session.participantNames {
                summary += "\(name)\n"
            }
            summary += "\n"
        } else {
            // Count only mode - show participant count
            summary += "\(session.participantCount) People\n\n"
        }
        
        // Expenses in single line format
        let expenseDescriptions = session.expenses.map { "\($0.itemDescription) \($0.amount.currency)" }
        summary += expenseDescriptions.joined(separator: " + ")
        
        summary += "\n\(session.totalCost.currency)÷\(session.participantCount) = \(session.roundedSharePerPerson.currency)\n"
        
        // Payment details if provided
        if !session.paymentAccountNumber.isEmpty {
            summary += "\n\(session.paymentAccountNumber)"
            if !session.paymentBankName.isEmpty {
                summary += " \(session.paymentBankName.lowercased())"
            }
            if !session.paymentAccountName.isEmpty {
                summary += " \(session.paymentAccountName)"
            }
        }
        
        return summary
    }
    
    private func isParticipantInFriends(_ participantName: String) -> Bool {
        return friends.contains { $0.name.lowercased() == participantName.lowercased() }
    }
    
    private func addParticipantToFriends(_ participantName: String) {
        let newFriend = SDFriend(name: participantName)
        modelContext.insert(newFriend)
        
        do {
            try modelContext.save()
        } catch {
            print("Failed to save new friend: \(error)")
        }
    }
}

#Preview {
    let session = SDSplitSession(
        sessionTitle: "Test Session",
        sessionCategory: "Food",
        participantCount: 3,
        participantNames: ["Alice", "Bob", "Charlie"],
        totalCost: 150000,
        roundedSharePerPerson: 50000,
        totalOverage: 0,
        expenses: [
            SDExpenseItem(itemDescription: "Pizza", amount: 100000),
            SDExpenseItem(itemDescription: "Drinks", amount: 50000)
        ]
    )
    return SplitSessionDetailView(session: session)
}
