//
//  SplitSessionView.swift
//  SplitBill
//
//  Created by Reza Juliandri on 14/07/25.
//

import SwiftUI
import SwiftData

struct SplitSessionView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\SDSplitSession.createdAt, order: .reverse)])
    private var savedSessions: [SDSplitSession]
    
    @State private var showingCreateSession = false
    @State private var selectedSession: SDSplitSession?
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background Image - consistent with HomeView
                background
                
                mainContentView
            }
            .navigationTitle("Split Sessions")
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingCreateSession = true
                    } label: {
                        Label("New Session", systemImage: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showingCreateSession) {
                SplitSessionFormView()
            }
            .sheet(item: $selectedSession) { session in
                SplitSessionDetailView(session: session)
            }
        }
    }
    
    var background: some View {
        VStack {
            Spacer()
            Image("bottom-screen")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .opacity(0.8)
        }
        .ignoresSafeArea()
        .zIndex(-1)
    }
    
    @ViewBuilder
    var mainContentView: some View {
        if savedSessions.isEmpty {
            emptyStateView
        } else {
            listView
        }
    }
    
    var emptyStateView: some View {
        ContentUnavailableView {
            Label("No Split Sessions", systemImage: "arrow.left.arrow.right")
        } description: {
            Text("Your split sessions will appear here.\nTap the '+' button to create your first session!")
                .multilineTextAlignment(.center)
        }
        .offset(y: -50)
    }
    
    var listView: some View {
        List {
            ForEach(savedSessions) { session in
                Button {
                    selectedSession = session
                } label: {
                    sessionCardView(for: session)
                }
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
            .onDelete(perform: deleteSessions)
        }
        .listStyle(PlainListStyle())
        .padding(.top)
    }
    
    @ViewBuilder
    func sessionCardView(for session: SDSplitSession) -> some View {
        HStack(spacing: 15) {
            VStack(alignment: .leading, spacing: 6) {
                Text(session.sessionTitle)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                HStack {
                    Text("\(session.participantCount) participants")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    Spacer()
                    Text(session.totalCost.currency)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }
                
                HStack {
                    Image(systemName: "calendar.badge.clock")
                        .foregroundColor(.secondary)
                    Text(session.createdAt, style: .date)
                    Text("at \(session.createdAt, style: .time)")
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
    
    func deleteSessions(offsets: IndexSet) {
        withAnimation(.easeInOut) {
            offsets.map { savedSessions[$0] }.forEach(modelContext.delete)
            try? modelContext.save()
        }
    }
}

#Preview {
    SplitSessionView()
}
