//
//  FriendsView.swift
//  SplitBill
//
//  Created by Reza Juliandri on 14/07/25.
//

import SwiftUI
import SwiftData

struct FriendsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(
        filter: #Predicate<SDFriend> { !$0.isDeleted },
        sort: [SortDescriptor(\SDFriend.createdAt, order: .reverse)]
    )
    private var friends: [SDFriend]
    
    @State private var showingAddFriend = false
    @State private var selectedFriend: SDFriend?
    @State private var searchText = ""
    @State private var showingImportOptions = false
    
    var filteredFriends: [SDFriend] {
        if searchText.isEmpty {
            return friends
        } else {
            return friends.filter { friend in
                friend.name.localizedCaseInsensitiveContains(searchText) ||
                friend.phoneNumber.contains(searchText) ||
                friend.email.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background Image - consistent with other views
                background
                
                mainContentView
            }
            .navigationTitle("Friends")
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .searchable(text: $searchText, prompt: "Search friends...")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            showingAddFriend = true
                        } label: {
                            Label("Add Manually", systemImage: "plus.circle")
                        }
                        
                        Button {
                            showingImportOptions = true
                        } label: {
                            Label("Import from Contacts", systemImage: "person.crop.circle.badge.plus")
                        }
                    } label: {
                        Label("Add Friend", systemImage: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showingAddFriend) {
                AddFriendSheet()
            }
            .sheet(isPresented: $showingImportOptions) {
                ImportContactsSheet()
            }
            .sheet(item: $selectedFriend) { friend in
                FriendDetailView(friend: friend)
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
        if filteredFriends.isEmpty {
            if searchText.isEmpty {
                emptyStateView
            } else {
                searchEmptyStateView
            }
        } else {
            listView
        }
    }
    
    var emptyStateView: some View {
        ContentUnavailableView {
            Label("No Friends Added", systemImage: "person.3.fill")
        } description: {
            Text("Add your friends to make splitting bills easier.\nTap the '+' button to add your first friend!")
                .multilineTextAlignment(.center)
        }
        .offset(y: -50)
    }
    
    var searchEmptyStateView: some View {
        ContentUnavailableView {
            Label("No Results", systemImage: "magnifyingglass")
        } description: {
            Text("No friends found for '\(searchText)'")
                .multilineTextAlignment(.center)
        }
        .offset(y: -50)
    }
    
    var listView: some View {
        List {
            ForEach(filteredFriends) { friend in
                Button {
                    selectedFriend = friend
                } label: {
                    friendCardView(for: friend)
                }
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
            .onDelete(perform: deleteFriends)
        }
        .listStyle(PlainListStyle())
        .padding(.top)
    }
    
    @ViewBuilder
    func friendCardView(for friend: SDFriend) -> some View {
        HStack(spacing: 15) {
            // Avatar circle with initials
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 45, height: 45)
                
                Text(String(friend.name.prefix(2).uppercased()))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(friend.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                if !friend.phoneNumber.isEmpty {
                    HStack {
                        Image(systemName: "phone.fill")
                            .foregroundColor(.secondary)
                            .frame(width: 16)
                        Text(friend.phoneNumber)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                if !friend.email.isEmpty {
                    HStack {
                        Image(systemName: "envelope.fill")
                            .foregroundColor(.secondary)
                            .frame(width: 16)
                        Text(friend.email)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                if let lastUsed = friend.lastUsedAt {
                    HStack {
                        Image(systemName: "clock.fill")
                            .foregroundColor(.secondary)
                            .frame(width: 16)
                        Text("Last used: \(lastUsed, style: .relative)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(CardStyle.cardCornerRadius)
        .shadow(color: Color.black.opacity(0.1), radius: CardStyle.cardShadowRadius, x: 0, y: 2)
    }
    
    func deleteFriends(offsets: IndexSet) {
        withAnimation(.easeInOut) {
            offsets.map { filteredFriends[$0] }.forEach { friend in
                friend.softDelete()
            }
            try? modelContext.save()
        }
    }
}

#Preview {
    FriendsView()
}