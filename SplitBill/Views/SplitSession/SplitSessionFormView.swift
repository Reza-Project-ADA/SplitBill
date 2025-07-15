//
//  SplitSessionFormView.swift
//  SplitBill
//
//  Created by Reza Juliandri on 14/07/25.
//

import SwiftUI
import SwiftData

struct SplitSessionFormView: View {
    @StateObject private var viewModel = SplitSessionViewModel()
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var showingAddExpense = false
    @State private var showingSummary = false
    @State private var showingSelectFriends = false
    @State private var savedSession: SDSplitSession?
    
    var body: some View {
        NavigationView {
            List {
                sessionSetupSection
                expensesSection
                participantsSection
                paymentDetailsSection
                calculationSection
                actionsSection
            }
            .navigationTitle("New Split Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveSession()
                    }
                    .disabled(viewModel.sessionTitle.isEmpty || viewModel.expenses.isEmpty || viewModel.actualParticipantCount == 0)
                }
            }
            .sheet(isPresented: $showingAddExpense) {
                AddExpenseSheet(viewModel: viewModel)
            }
            .sheet(isPresented: $showingSummary) {
                SummaryDetailView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingSelectFriends) {
                SelectFriendsSheet(viewModel: viewModel)
            }
            .sheet(item: $savedSession) { session in
                SplitSessionDetailView(session: session)
            }
        }
    }
    
    
    private var sessionSetupSection: some View {
        Section("Session Setup") {
            TextField("Session Title (e.g., Badminton Night)", text: $viewModel.sessionTitle)
            
            TextField("Category (optional)", text: $viewModel.sessionCategory)
            
            Toggle("Use custom date & time", isOn: $viewModel.useCustomDate)
            
            if viewModel.useCustomDate {
                DatePicker("Session Date & Time", selection: $viewModel.sessionDate, displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(GraphicalDatePickerStyle())
            }
        }
    }
    
    private var expensesSection: some View {
        Section {
            if viewModel.expenses.isEmpty {
                HStack {
                    Text("No expenses")
                        .foregroundColor(.secondary)
                    Spacer()
                    Button(action: {
                        showingAddExpense = true
                    }) {
                        Label("Add", systemImage: "plus.circle.fill")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                }
            } else {
                ForEach(viewModel.expenses.indices, id: \.self) { index in
                    HStack(spacing: 12) {
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.title2)
                            .foregroundColor(.green)
                            .frame(width: 30)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(viewModel.expenses[index].description)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                            Text(viewModel.expenses[index].amount.currency)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            viewModel.removeExpense(at: index)
                        }) {
                            Image(systemName: "minus.circle.fill")
                                .foregroundColor(.red)
                        }
                    }
                }
                
                HStack {
                    Spacer()
                    Button(action: {
                        showingAddExpense = true
                    }) {
                        Label("Add Expense", systemImage: "plus.circle.fill")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                }
            }
        } header: {
            Text("Expenses")
        }
    }
    
    private var participantsSection: some View {
        Section("Participants") {
            // Input mode picker
            Picker("Input Mode", selection: $viewModel.participantInputMode) {
                ForEach(ParticipantInputMode.allCases, id: \.self) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            
            // Content based on selected mode
            switch viewModel.participantInputMode {
            case .count:
                countModeContent
            case .mixed:
                mixedModeContent
            }
        }
    }
    
    private var countModeContent: some View {
        Group {
            Stepper("Number of participants: \(viewModel.participantCount)", value: Binding(
                get: { viewModel.participantCount },
                set: { viewModel.updateParticipantCount($0) }
            ), in: 1...50)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Participants will be listed as Person 1, Person 2, etc.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("To add specific names, use 'Friends & Manual' mode instead.")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
        }
    }
    
    private var mixedModeContent: some View {
        Group {
            // Friends section
            HStack {
                Text("Friends (\(viewModel.selectedFriends.count))")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                
                Spacer()
                
                Button("Select Friends") {
                    showingSelectFriends = true
                }
                .buttonStyle(.borderedProminent)
            }
            
            if viewModel.selectedFriends.isEmpty {
                Text("No friends selected")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                ForEach(viewModel.selectedFriends, id: \.id) { friend in
                    HStack {
                        // Avatar
                        ZStack {
                            Circle()
                                .fill(Color.blue.opacity(0.2))
                                .frame(width: 30, height: 30)
                            
                            Text(String(friend.name.prefix(2).uppercased()))
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                        }
                        
                        Text(friend.name)
                            .font(.subheadline)
                        
                        Spacer()
                        
                        Button(action: {
                            viewModel.removeFriend(friend)
                        }) {
                            Image(systemName: "minus.circle.fill")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            
            // Manual participants section
            HStack {
                Text("Manual Participants (\(viewModel.manualParticipants.count))")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
                
                Spacer()
                
                Button("Add Participant") {
                    viewModel.addManualParticipant("Person \(viewModel.manualParticipants.count + 1)")
                }
                .buttonStyle(.borderedProminent)
            }
            
            if viewModel.manualParticipants.isEmpty {
                Text("No manual participants added")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                ForEach(viewModel.manualParticipants.indices, id: \.self) { index in
                    HStack {
                        TextField("Name", text: $viewModel.manualParticipants[index])
                        
                        Button(action: {
                            viewModel.removeManualParticipant(at: index)
                        }) {
                            Image(systemName: "minus.circle.fill")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            
            // Total summary
            if viewModel.actualParticipantCount > 0 {
                HStack {
                    Text("Total Participants: \(viewModel.actualParticipantCount)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    Spacer()
                    Text("(\(viewModel.selectedFriends.count) friends + \(viewModel.manualParticipants.count) manual)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
        }
    }
    
    private var paymentDetailsSection: some View {
        Section {
            TextField("Account Number", text: $viewModel.paymentDetails.accountNumber)
                .keyboardType(.numberPad)
            
            TextField("Bank Name (e.g., BCA, BNI)", text: $viewModel.paymentDetails.bankName)
            
            TextField("Account Name", text: $viewModel.paymentDetails.accountName)
        } header: {
            Text("Payment Details (Optional)")
        }
        footer: {
            Text("This information will be included in the summary for easy payment transfers.")
        }
    }
    
    private var calculationSection: some View {
        Section("Calculation") {
            HStack {
                Text("Total Cost:")
                    .fontWeight(.medium)
                Spacer()
                Text(viewModel.totalCost.currency)
                    .fontWeight(.semibold)
            }
            
            HStack {
                Text("Participants:")
                    .fontWeight(.medium)
                Spacer()
                Text("\(viewModel.actualParticipantCount)")
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
            }
            
            HStack {
                Text("Per Person:")
                    .fontWeight(.medium)
                Spacer()
                Text(viewModel.roundedSharePerPerson.currency)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
            }
            
            if viewModel.totalOverage > 0 {
                HStack {
                    Text("Overage:")
                        .fontWeight(.medium)
                    Spacer()
                    Text(viewModel.totalOverage.currency)
                        .fontWeight(.semibold)
                        .foregroundColor(.orange)
                }
            }
        }
    }
    
    private var actionsSection: some View {
        Section {
            Button("Reset Session") {
                viewModel.resetSession()
            }
            .foregroundColor(.red)
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundColor(.red)
        }
    }
    
    private func saveSession() {
        let sdExpenses = viewModel.expenses.map { expense in
            SDExpenseItem(itemDescription: expense.description, amount: expense.amount)
        }
        
        let participantNames: [String] = {
            switch viewModel.participantInputMode {
            case .count:
                return []
            case .mixed:
                return viewModel.selectedFriends.map { $0.name } + viewModel.manualParticipants
            }
        }()
        
        let generatedSummary = viewModel.generateSummary()
        
        let session = SDSplitSession(
            sessionTitle: viewModel.sessionTitle,
            sessionCategory: viewModel.sessionCategory,
            participantCount: viewModel.actualParticipantCount,
            participantNames: participantNames,
            totalCost: viewModel.totalCost,
            roundedSharePerPerson: viewModel.roundedSharePerPerson,
            totalOverage: viewModel.totalOverage,
            expenses: sdExpenses,
            paymentAccountNumber: viewModel.paymentDetails.accountNumber,
            paymentBankName: viewModel.paymentDetails.bankName,
            paymentAccountName: viewModel.paymentDetails.accountName,
            generatedSummary: generatedSummary
        )
        
        modelContext.insert(session)
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Failed to save session: \(error)")
        }
    }
}


#Preview {
    SplitSessionFormView()
}
