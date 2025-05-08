//
//  SavedSplitDetailView.swift
//  SplitBill
//
//  Created by Reza Juliandri on 09/05/25.
//


import SwiftUI
import SwiftData

struct SavedSplitDetailView: View {
    @Bindable var splitRecord: SDBillSplitRecord // Use @Bindable if you might edit, otherwise just let

    var body: some View {
        List {
            Section {
                HStack { Text("Store:"); Spacer(); Text(splitRecord.storeName) }
                HStack { Text("Order #:"); Spacer(); Text("\(splitRecord.receiptOrderNumber)") }
                HStack { Text("Date:"); Spacer(); Text(splitRecord.receiptDateTime.dayMonthFormat) }
                HStack { Text("Original Subtotal:"); Spacer(); Text(splitRecord.receiptOriginalSubtotal.currency) }
                HStack { Text("Original Tax:"); Spacer(); Text(splitRecord.receiptOriginalTax.currency) }
                HStack { Text("Original Total:"); Spacer(); Text(splitRecord.receiptOriginalTotal.currency).bold() }
                HStack { Text("Split Saved:"); Spacer(); Text(splitRecord.splitSavedAt.dayMonthFormat)}
            } header : {
                Text("Receipt Details")
            }

            if let shares = splitRecord.participantShares, !shares.isEmpty {
                Section("Participant Shares") {
                    ForEach(shares.sorted(by: { $0.participantName < $1.participantName })) { share in
                        DisclosureGroup {
                            if let items = share.itemEntries, !items.isEmpty {
                                ForEach(items.sorted(by: { $0.itemName < $1.itemName })) { itemEntry in
                                    VStack(alignment: .leading, spacing: 2) {
                                        HStack {
                                            Text(itemEntry.itemName)
                                            if itemEntry.isShared {
                                                Text("(Shared 1/\(itemEntry.numberOfSharersIfShared))")
                                                    .font(.caption2)
                                                    .foregroundColor(.secondary)
                                            }
                                            Spacer()
                                            Text(itemEntry.portionPaidByParticipant, format: .currency(code: "IDR"))
                                        }
                                        if itemEntry.isShared {
                                            Text("Original unit price: \(itemEntry.originalItemUnitPrice, format: .currency(code: "IDR"))")
                                                .font(.caption2)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    .padding(.vertical, 2)
                                }
                            } else {
                                Text("No items recorded for this participant.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Divider()
                            HStack { Text("Subtotal:").bold(); Spacer(); Text(share.calculatedSubtotal, format: .currency(code: "IDR")) }
                            HStack { Text("Tax Share:").bold(); Spacer(); Text(share.calculatedTaxShare, format: .currency(code: "IDR")) }
                            HStack { Text("Total Owed:").bold(); Spacer(); Text(share.calculatedTotalOwed, format: .currency(code: "IDR")).bold() }
                        } label: {
                            HStack {
                                Text(share.participantName)
                                    .font(.headline)
                                Spacer()
                                Text(share.calculatedTotalOwed, format: .currency(code: "IDR"))
                                    .font(.headline)
                            }
                        }
                    }
                }
            } else {
                Section {
                    Text("No participant data found for this split.")
                }
            }
        }
        .navigationTitle("Split for \(splitRecord.storeName)")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Preview for SavedSplitDetailView (requires sample data setup)
struct SavedSplitDetailView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a sample SDBillSplitRecord for previewing
        // This is a bit involved to set up correctly for a preview with relations.
        // For simplicity, you might test this by running the app and saving a split.
        // Or create a dedicated preview helper.
        
        // Example of a basic in-memory container for preview
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: SDBillSplitRecord.self, configurations: config)
        
        // Create sample data
        let sampleItem = SDAssignedItemEntry(itemName: "Preview Item", originalItemUnitPrice: 100, isShared: false, numberOfSharersIfShared: 1, portionPaidByParticipant: 100)
        let sampleShare = SDParticipantShare(participantName: "Preview Person", calculatedSubtotal: 100, calculatedTaxShare: 10, calculatedTotalOwed: 110, itemEntries: [sampleItem])
        let sampleRecord = SDBillSplitRecord(storeName: "Preview Store", receiptDateTime: Date(), receiptOrderNumber: "1", receiptOriginalSubtotal: 100, receiptOriginalTax: 10, receiptOriginalTotal: 110, participantShares: [sampleShare])
        
        // Link relationships for preview (important!)
        sampleItem.participantShare = sampleShare
        sampleShare.billSplitRecord = sampleRecord
        
        // Insert into context if needed by the preview, though @Bindable usually works directly.
        // container.mainContext.insert(sampleRecord)

        return NavigationView { // Detail view often expects to be in a NavigationView
             SavedSplitDetailView(splitRecord: sampleRecord)
        }
        .modelContainer(container) // Provide the container to the preview
    }
}
