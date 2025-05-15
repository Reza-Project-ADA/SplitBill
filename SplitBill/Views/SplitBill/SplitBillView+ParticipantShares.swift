//
//  SplitBillView+ParticipantShares.swift
//  SplitBill
//
//  Created by Reza Juliandri on 15/05/25.
//
import SwiftUI

extension SplitBillView {
    var participantsShares: some View {
        Section{
            if manager.participants.isEmpty {
                Text("No participants added yet.").foregroundColor(.secondary)
            }
            ForEach($manager.participants) { $participant in
                DisclosureGroup {
                    if participant.directlyAssignedItems.isEmpty && !manager.sharedItemLogs.contains(where: { $0.participantIDs.contains(participant.id) }) {
                        Text("No items yet for \(participant.name).")
                            .font(.caption).foregroundColor(.secondary)
                    }
                    
                    if !participant.directlyAssignedItems.isEmpty {
                        Text("Directly Assigned:").font(.caption.weight(.semibold)).padding(.top, 2)
                        ForEach(participant.directlyAssignedItems) { item in
                            HStack {
                                Text("  - \(item.name)")
                                Spacer()
                                Text(item.price, format: .currency(code: "IDR"))
                                Button { manager.unassignDirectItem(item, from: participant.id) } label: {
                                    Image(systemName: "minus.circle.fill").foregroundColor(.red)
                                }
                            }
                        }
                    }
                    
                    let itemsSharedByThisParticipant = manager.sharedItemLogs.filter { $0.participantIDs.contains(participant.id) }
                    if !itemsSharedByThisParticipant.isEmpty {
                        Text("Shared Items (Your Portion):").font(.caption.weight(.semibold)).padding(.top, 2)
                        ForEach(itemsSharedByThisParticipant) { sharedLog in
                            HStack {
                                Text("  - \(sharedLog.itemName) (1/\(sharedLog.participantIDs.count) of \(sharedLog.itemPrice, format: .currency(code: "IDR")))")
                                Spacer()
                                Text(sharedLog.pricePerSharer, format: .currency(code: "IDR"))
                            }
                        }
                    }
                    Divider()
                    HStack { Text("Subtotal:").bold(); Spacer(); Text(participant.subtotal, format: .currency(code: "IDR")) }
                    HStack { Text("Tax Share:").bold(); Spacer(); Text(participant.taxShare, format: .currency(code: "IDR")) }
                    HStack { Text("Total Owed:").bold(); Spacer(); Text(participant.totalOwed, format: .currency(code: "IDR")) }
                    
                } label: {
                    HStack {
                        Text(participant.name).font(.headline)
                        Spacer()
                        Text(participant.totalOwed, format: .currency(code: "IDR")).font(.headline)
                    }
                }
            }
            .onDelete(perform: manager.removeParticipant)
        } header: {
            Text("Participants & Shares")
        }
    }
}
