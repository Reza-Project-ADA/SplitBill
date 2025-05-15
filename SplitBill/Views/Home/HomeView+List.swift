//
//  HomeView+List.swift
//  SplitBill
//
//  Created by Reza Juliandri on 14/05/25.
//
import SwiftUI

extension HomeView {
    var listView: some View {
        List {
            ForEach(savedSplits) { split in
                Button {
                    viewModel.selectedSplitSDRecord = split
                    viewModel.path.append(.splitDetail)
                } label: {
                    splitCardView(for: split)
                }
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)) // Padding around cards
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear) // Make row background transparent
            }
            .onDelete(perform: deleteSplits)
        }
        .listStyle(PlainListStyle()) // PlainListStyle is good for custom row backgrounds
        .padding(.top) // Give some space from the navigation bar
    }
    
    @ViewBuilder
    func splitCardView(for split: SDBillSplitRecord) -> some View {
        HStack(spacing: 15) {
//            Image(systemName: "creditcard.fill") // Or "creditcard.fill" / "doc.plaintext.fill"
//                .font(.title2)
//                .foregroundColor(.accentColor)
//                .frame(width: 30) // Fixed width for alignment
            
            VStack(alignment: .leading, spacing: 6) {
                Text(split.storeName)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                HStack {
                    Text(split.receiptOrderNumber.isEmpty ? "N/A" : split.receiptOrderNumber)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    Spacer()
                    Text(split.receiptOriginalTotal.currency) // Assuming you have currencyCode
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.green) // Or your app's accent color
                }
                
                HStack {
                    Image(systemName: "calendar.badge.clock")
                        .foregroundColor(.secondary)
                    Text(split.splitSavedAt, style: .date)
                    Text("at \(split.splitSavedAt, style: .time)")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(CardStyle.cardBackgroundColor)
        .cornerRadius(CardStyle.cardCornerRadius)
        .shadow(color: Color.black.opacity(0.1), radius: CardStyle.cardShadowRadius, x: 0, y: 2)
    }
    
    func deleteSplits(offsets: IndexSet) {
        withAnimation(.easeInOut) { // Smooth animation
            offsets.map { savedSplits[$0] }.forEach(modelContext.delete)
            // SwiftData auto-saves changes in many contexts, or you can explicitly save:
            try? modelContext.save()
        }
    }
}
