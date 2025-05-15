//
//  HomeView+EmptyState.swift
//  SplitBill
//
//  Created by Reza Juliandri on 14/05/25.
//
import SwiftUI

extension HomeView {
    var emptyStateView: some View {
        ContentUnavailableView {
            Label("No Saved Splits", systemImage: "doc.text.magnifyingglass")
        } description: {
            Text("Your saved bill splits will appear here.\nTap the '+' button to add your first bill!")
                .multilineTextAlignment(.center)
        }
        .offset(y: -50) // Adjust position slightly if needed
    }
}
