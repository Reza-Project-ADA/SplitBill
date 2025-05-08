//
//  SavedSplitsListView.swift
//  SplitBill
//
//  Created by Reza Juliandri on 09/05/25.
//


import SwiftUI
import SwiftData

struct SavedSplitsListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\SDBillSplitRecord.splitSavedAt, order: .reverse)]) private var savedSplits: [SDBillSplitRecord]
    @State private var selectedSplit: SDBillSplitRecord? = nil
    
    
    var body: some View {
        NavigationView { // Important for NavigationLink if not already in one
            List {
                if savedSplits.isEmpty {
                    ContentUnavailableView(
                        "No Saved Splits",
                        systemImage: "doc.text.magnifyingglass",
                        description: Text("Splits you save will appear here.")
                    )
                } else {
//                    ForEach(savedSplits) { split in
//                        NavigationLink(destination: SavedSplitDetailView(splitRecord: split)) {
//                            VStack(alignment: .leading) {
//                                Text(split.storeName)
//                                    .font(.headline)
//                                HStack {
//                                    Text("Order: \(split.receiptOrderNumber)")
//                                    Spacer()
//                                    Text(split.receiptOriginalTotal, format: .currency(code: "IDR"))
//                                }
//                                .font(.subheadline)
//                                Text("Saved: \(split.splitSavedAt, style: . относительное)") // Relative time
//                                    .font(.caption)
//                                    .foregroundColor(.secondary)
//                            }
//                        }
//                    }
//                    .onDelete(perform: deleteSplits)
                }
            }
            .navigationTitle("Saved Bill Splits")
            .toolbar {
                if !savedSplits.isEmpty {
                    EditButton()
                }
            }
        }
    }
    
    private func deleteSplits(offsets: IndexSet) {
        withAnimation {
            offsets.map { savedSplits[$0] }.forEach(modelContext.delete)
            // SwiftData auto-saves changes in many contexts, or you can explicitly save:
            // try? modelContext.save()
        }
    }
}

struct SavedSplitsListView_Previews: PreviewProvider {
    static var previews: some View {
        SavedSplitsListView()
            .modelContainer(for: [SDBillSplitRecord.self, SDParticipantShare.self, SDAssignedItemEntry.self], inMemory: true) // Use inMemory for previews
    }
}
