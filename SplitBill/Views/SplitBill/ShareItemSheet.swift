//
//  ShareItemSheet.swift
//  SplitBill
//
//  Created by Reza Juliandri on 09/05/25.
//


import SwiftUI

struct ShareItemSheet: View {
    let itemToShare: AssignableBillItem // The item being considered for sharing
    let allParticipants: [BillParticipant]
    let currentSharerIDs: Set<UUID> // Pass current sharers if editing an existing shared item
    let onConfirm: (Set<UUID>) -> Void // Callback with selected participant IDs

    @State private var selectedParticipantIDs: Set<UUID>
    @Environment(\.dismiss) var dismiss

    init(item: AssignableBillItem, participants: [BillParticipant], currentSharers: Set<UUID> = Set(), onConfirm: @escaping (Set<UUID>) -> Void) {
        self.itemToShare = item
        self.allParticipants = participants
        self.currentSharerIDs = currentSharers
        self._selectedParticipantIDs = State(initialValue: currentSharers) // Initialize with current sharers
        self.onConfirm = onConfirm
    }

    var body: some View {
        NavigationView {
            VStack {
                List {
                    Section("Who is sharing \(itemToShare.name) (\(itemToShare.price, format: .currency(code: "IDR")))?") {
                        if allParticipants.isEmpty {
                            Text("No participants available. Add participants on the main screen.")
                        } else {
                            ForEach(allParticipants) { participant in
                                Button {
                                    if selectedParticipantIDs.contains(participant.id) {
                                        selectedParticipantIDs.remove(participant.id)
                                    } else {
                                        selectedParticipantIDs.insert(participant.id)
                                    }
                                } label: {
                                    HStack {
                                        Text(participant.name)
                                        Spacer()
                                        if selectedParticipantIDs.contains(participant.id) {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.blue)
                                        } else {
                                            Image(systemName: "circle")
                                                .foregroundColor(.gray)
                                        }
                                    }
                                }
                                .foregroundColor(.primary) // Make button text normal color
                            }
                        }
                    }
                }

                Button(action: {
                    onConfirm(selectedParticipantIDs)
                    dismiss()
                }) {
                    Text(selectedParticipantIDs.count > 1 ? "Confirm \(selectedParticipantIDs.count) Sharers" : (selectedParticipantIDs.count == 1 ? "Confirm 1 Sharer (will be assigned directly)" : "Confirm (Unshare)"))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(selectedParticipantIDs.isEmpty && currentSharerIDs.isEmpty ? Color.gray.opacity(0.5) : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
                // Allow "Confirm" even if 0 selected if it was previously shared (to unshare)
                // Or if 1 selected (manager will handle logic - might assign directly or revert)
                .disabled(selectedParticipantIDs.isEmpty && currentSharerIDs.isEmpty && allParticipants.isEmpty)
            }
            .navigationTitle("Share Item")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}
