//
//  HomeView+SubView.swift
//  SplitBill
//
//  Created by Reza Juliandri on 14/05/25.
//
import SwiftUI
extension HomeView {
    var background : some View {
        VStack {
            Spacer()
            Image("bottom-screen")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .opacity(0.8) // Slightly reduce opacity if it's too dominant
        }
        .ignoresSafeArea()
        .zIndex(-1) // Ensure it's behind everything
    }
    @ViewBuilder
    var mainContentView: some View {
        if savedSplits.isEmpty {
            emptyStateView
        } else {
            listView
        }
    }
}
