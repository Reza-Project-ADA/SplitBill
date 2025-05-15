//
//  AssignItemDirectlySheet.swift
//  SplitBill
//
//  Created by Reza Juliandri on 15/05/25.
//


import SwiftUI

struct AssignItemDirectlySheet: View { // Renamed from AssignItemSheet
    let item: AssignableBillItem
    let participants: [BillParticipant]
    let onAssign: (UUID) -> Void
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section("Assign \(item.name) (\(item.price, format: .currency(code: "IDR")))") {
                    if participants.isEmpty {
                        Text("No participants to assign to.")
                    } else {
                        ForEach(participants) { participant in
                            Button(participant.name) {
                                onAssign(participant.id)
                                dismiss()
                            }
                        }
                    }
                }
            }
            .navigationTitle("Assign to Person")
            .toolbar { ToolbarItem(placement: .navigationBarLeading) { Button("Cancel") { dismiss() } } }
        }
    }
}