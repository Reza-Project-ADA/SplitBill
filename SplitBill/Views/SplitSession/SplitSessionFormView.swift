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
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background Image - consistent with HomeView
                background
                
                ScrollView {
                    VStack(spacing: 20) {
                        sessionSetupSection
                        expensesSection
                        participantsSection
                        paymentDetailsSection
                        calculationSection
                        actionsSection
                    }
                    .padding()
                }
            }
            .navigationTitle("New Split Session")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
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
        }
    }
    
    var background: some View {
        VStack {
            Spacer()
            Image("bottom-screen")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .opacity(0.8)
        }
        .ignoresSafeArea()
        .zIndex(-1)
    }
    
    private var sessionSetupSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Session Setup")
                .font(.headline)
                .fontWeight(.semibold)
            
            TextField("Session Title (e.g., Badminton Night)", text: $viewModel.sessionTitle)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            TextField("Category (optional)", text: $viewModel.sessionCategory)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Toggle("Use custom date & time", isOn: $viewModel.useCustomDate)
            
            if viewModel.useCustomDate {
                DatePicker("Session Date & Time", selection: $viewModel.sessionDate, displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(GraphicalDatePickerStyle())
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(CardStyle.cardCornerRadius)
        .shadow(color: Color.black.opacity(0.1), radius: CardStyle.cardShadowRadius, x: 0, y: 2)
    }
    
    private var expensesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Expenses")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: {
                    showingAddExpense = true
                }) {
                    Label("Add", systemImage: "plus.circle.fill")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }
            
            if viewModel.expenses.isEmpty {
                ContentUnavailableView {
                    Label("No expenses", systemImage: "dollarsign.circle")
                } description: {
                    Text("Tap 'Add' to add your first expense")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(height: 80)
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
                    .padding(.vertical, 4)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(CardStyle.cardCornerRadius)
        .shadow(color: Color.black.opacity(0.1), radius: CardStyle.cardShadowRadius, x: 0, y: 2)
    }
    
    private var participantsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Participants")
                .font(.headline)
                .fontWeight(.semibold)
            
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
        .padding()
        .background(Color.white)
        .cornerRadius(CardStyle.cardCornerRadius)
        .shadow(color: Color.black.opacity(0.1), radius: CardStyle.cardShadowRadius, x: 0, y: 2)
    }
    
    private var countModeContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            Stepper("Number of participants: \(viewModel.participantCount)", value: Binding(
                get: { viewModel.participantCount },
                set: { viewModel.updateParticipantCount($0) }
            ), in: 1...50)
            
            Text("Participants will be listed as Person 1, Person 2, etc.")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text("To add specific names, use 'Friends & Manual' mode instead.")
                .font(.caption)
                .foregroundColor(.blue)
        }
    }
    
    private var mixedModeContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Friends section
            VStack(alignment: .leading, spacing: 12) {
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
                        .padding(.vertical, 4)
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
                        .padding(.vertical, 2)
                    }
                }
            }
            
            Divider()
            
            // Manual participants section
            VStack(alignment: .leading, spacing: 12) {
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
                        .padding(.vertical, 4)
                } else {
                    ForEach(viewModel.manualParticipants.indices, id: \.self) { index in
                        HStack {
                            TextField("Name", text: $viewModel.manualParticipants[index])
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Button(action: {
                                viewModel.removeManualParticipant(at: index)
                            }) {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                        .padding(.vertical, 2)
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
                .padding(.top, 8)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
        }
    }
    
    private var paymentDetailsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Payment Details (Optional)")
                .font(.headline)
                .fontWeight(.semibold)
            
            TextField("Account Number", text: $viewModel.paymentDetails.accountNumber)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)
            
            TextField("Bank Name (e.g., BCA, BNI)", text: $viewModel.paymentDetails.bankName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            TextField("Account Name", text: $viewModel.paymentDetails.accountName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Text("This information will be included in the summary for easy payment transfers.")
                .font(.caption)
                .foregroundColor(.secondary)
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
        .padding()
        .background(Color.white)
        .cornerRadius(CardStyle.cardCornerRadius)
        .shadow(color: Color.black.opacity(0.1), radius: CardStyle.cardShadowRadius, x: 0, y: 2)
    }
    
    private var actionsSection: some View {
        VStack(spacing: 12) {
            Button(action: {
                generateAndSaveSession()
            }) {
                Label("Save Session", systemImage: "checkmark.circle.fill")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(CardStyle.cardCornerRadius)
            }
            .disabled(viewModel.expenses.isEmpty || viewModel.sessionTitle.isEmpty || viewModel.actualParticipantCount == 0)
            
            Button(action: {
                viewModel.resetSession()
            }) {
                Label("Reset Session", systemImage: "arrow.counterclockwise")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(CardStyle.cardCornerRadius)
            }
        }
    }
    
    private func generateAndSaveSession() {
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
            showingSummary = true
        } catch {
            print("Failed to save session: \(error)")
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