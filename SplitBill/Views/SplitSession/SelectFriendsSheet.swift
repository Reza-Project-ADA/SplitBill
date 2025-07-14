//
//  SelectFriendsSheet.swift
//  SplitBill
//
//  Created by Reza Juliandri on 14/07/25.
//

import SwiftUI
import SwiftData

struct SelectFriendsSheet: View {
    @ObservedObject var viewModel: SplitSessionViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @Query(
        filter: #Predicate<SDFriend> { !$0.isDeleted },
        sort: [SortDescriptor(\SDFriend.name, order: .forward)]
    )
    private var friends: [SDFriend]
    
    @State private var searchText = ""
    
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
        NavigationView {
            List {
                ForEach(filteredFriends) { friend in
                    FriendSelectionRow(
                        friend: friend,
                        isSelected: viewModel.selectedFriends.contains(where: { $0.id == friend.id })
                    ) {
                        toggleSelection(for: friend)
                    }
                }
            }
            .navigationTitle("Select Friends")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Search friends...")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func toggleSelection(for friend: SDFriend) {
        if viewModel.selectedFriends.contains(where: { $0.id == friend.id }) {
            viewModel.removeFriend(friend)
        } else {
            viewModel.addFriend(friend)
        }
    }
}

struct FriendSelectionRow: View {
    let friend: SDFriend
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                // Avatar
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Text(String(friend.name.prefix(2).uppercased()))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
                
                // Friend info
                VStack(alignment: .leading, spacing: 4) {
                    Text(friend.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    if !friend.phoneNumber.isEmpty {
                        Text(friend.phoneNumber)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    } else if !friend.email.isEmpty {
                        Text(friend.email)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Selection indicator
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .blue : .secondary)
                    .font(.title2)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.vertical, 4)
    }
}

#Preview {
    SelectFriendsSheet(viewModel: SplitSessionViewModel())
}