//
//  AddExpenseSheet.swift
//  SplitBill
//
//  Created by Reza Juliandri on 14/07/25.
//

import SwiftUI

struct AddExpenseSheet: View {
    @ObservedObject var viewModel: SplitSessionViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var description = ""
    @State private var amount = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Expense Details")) {
                    TextField("Description (e.g., Court fee)", text: $description)
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("Add Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        if let amountValue = Double(amount), !description.isEmpty {
                            viewModel.addExpense(description: description, amount: amountValue)
                            dismiss()
                        }
                    }
                    .disabled(description.isEmpty || amount.isEmpty)
                }
            }
        }
    }
}

#Preview {
    AddExpenseSheet(viewModel: SplitSessionViewModel())
}