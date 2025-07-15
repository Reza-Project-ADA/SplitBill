//
//  SummaryDetailView.swift
//  SplitBill
//
//  Created by Reza Juliandri on 14/07/25.
//

import SwiftUI

struct SummaryDetailView: View {
    @ObservedObject var viewModel: SplitSessionViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Summary content
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Session info card
                        sessionInfoCard
                        
                        // Generated summary card
                        summaryCard
                    }
                    .padding()
                }
                
                // Copy button at bottom
                copyButton
            }
            .navigationTitle("Summary Generated")
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
    
    private var sessionInfoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.title2)
                
                VStack(alignment: .leading) {
                    Text("Session Saved Successfully!")
                        .font(.headline)
                        .fontWeight(.semibold)
                    Text("Your split session has been saved to history")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            Divider()
            
            HStack {
                Text("Session:")
                    .fontWeight(.medium)
                Spacer()
                Text(viewModel.sessionTitle)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text("Total Cost:")
                    .fontWeight(.medium)
                Spacer()
                Text(viewModel.totalCost.currency)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
            }
            
            HStack {
                Text("Participants:")
                    .fontWeight(.medium)
                Spacer()
                Text("\(viewModel.actualParticipantCount)")
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text("Per Person:")
                    .fontWeight(.medium)
                Spacer()
                Text(viewModel.roundedSharePerPerson.currency)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(CardStyle.cardCornerRadius)
        .shadow(color: Color.black.opacity(0.1), radius: CardStyle.cardShadowRadius, x: 0, y: 2)
    }
    
    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Generated Summary")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text("Ready to share with participants:")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(viewModel.generateSummary())
                .font(.system(.body, design: .monospaced))
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .textSelection(.enabled)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(CardStyle.cardCornerRadius)
        .shadow(color: Color.black.opacity(0.1), radius: CardStyle.cardShadowRadius, x: 0, y: 2)
    }
    
    private var copyButton: some View {
        VStack(spacing: 0) {
            Divider()
            
            Button(action: {
                UIPasteboard.general.string = viewModel.generateSummary()
                // Could add haptic feedback here
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()
            }) {
                HStack {
                    Image(systemName: "doc.on.clipboard")
                        .font(.title2)
                    Text("Copy Summary")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(0)
            }
        }
        .background(Color(.systemBackground))
    }
}

#Preview {
    SummaryDetailView(viewModel: SplitSessionViewModel())
}