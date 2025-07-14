//
//  HomeView+Navigation.swift
//  SplitBill
//
//  Created by Reza Juliandri on 14/05/25.
//
import SwiftUI

extension HomeView {
    @ViewBuilder
    func navigationDestination(for screen: MainScreen) -> some View {
        // Navigation destinations remain the same
        switch screen {
        case .balance:
            BalanceView()
        case .addBill:
            AddBillView(receipt: $viewModel.receiptOutput)
                .onDisappear {
                    if viewModel.receiptOutput != nil {
                        viewModel.path = [.splitBill]
                    }
                }
        case .splitBill:
            if let receipt = viewModel.receiptOutput {
                SplitBillView(receipt: receipt)
                    .onDisappear { // Clear receipt after splitting or navigating away
                        viewModel.receiptOutput = nil
                    }
            } else {
                ContentUnavailableView("Error", systemImage: "exclamationmark.triangle", description: Text("No receipt data found to split."))
            }
        case .splitDetail:
            if let splitRecord = viewModel.selectedSplitSDRecord {
                SavedSplitDetailView(splitRecord: splitRecord)
                    .onDisappear {
                        viewModel.selectedSplitSDRecord = nil
                    }
            } else {
                ContentUnavailableView("Error", systemImage: "exclamationmark.triangle", description: Text("No split record found to display."))
            }
        }
    }
}
