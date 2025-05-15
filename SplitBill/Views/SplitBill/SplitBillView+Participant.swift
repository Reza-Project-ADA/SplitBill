//
//  SplitBillView+Participant.swift
//  SplitBill
//
//  Created by Reza Juliandri on 15/05/25.
//
import SwiftUI
extension SplitBillView {
    var addParticipant: some View {
        Section("Add Participant") {
            HStack {
                TextField("Participant Name", text: $newParticipantName)
                Button {
                    manager.addParticipant(name: newParticipantName)
                    newParticipantName = ""
                } label : {
                    Text("Add")
                }
                .disabled(newParticipantName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }
}
