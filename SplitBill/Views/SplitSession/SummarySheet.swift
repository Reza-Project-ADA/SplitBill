//
//  SummarySheet.swift
//  SplitBill
//
//  Created by Reza Juliandri on 14/07/25.
//

import SwiftUI

struct SummarySheet: View {
    @ObservedObject var viewModel: SplitSessionViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(viewModel.generateSummary())
                        .font(.system(.body, design: .monospaced))
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    
                    Button(action: {
                        UIPasteboard.general.string = viewModel.generateSummary()
                    }) {
                        Text("Copy to Clipboard")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                }
                .padding()
            }
            .navigationTitle("Summary")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SummarySheet(viewModel: SplitSessionViewModel())
}