//
//  FriendDetailView.swift
//  SplitBill
//
//  Created by Reza Juliandri on 14/07/25.
//

import SwiftUI

struct FriendDetailView: View {
    let friend: SDFriend
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var isEditing = false
    @State private var name: String
    @State private var phoneNumber: String
    @State private var email: String
    @State private var notes: String
    
    init(friend: SDFriend) {
        self.friend = friend
        self._name = State(initialValue: friend.name)
        self._phoneNumber = State(initialValue: friend.phoneNumber)
        self._email = State(initialValue: friend.email)
        self._notes = State(initialValue: friend.notes)
    }
    
    var body: some View {
        NavigationView {
            Form {
                profileSection
                informationSection
                
                if !friend.notes.isEmpty || isEditing {
                    notesSection
                }
                
                if let lastUsed = friend.lastUsedAt {
                    lastUsedSection(lastUsed)
                }
            }
            .navigationTitle(friend.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditing ? "Save" : "Edit") {
                        if isEditing {
                            saveFriend()
                        } else {
                            isEditing = true
                        }
                    }
                }
            }
        }
    }
    
    private var profileSection: some View {
        Section {
            VStack(spacing: 16) {
                // Avatar circle with initials
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 80, height: 80)
                    
                    Text(String(friend.name.prefix(2).uppercased()))
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
                
                if isEditing {
                    TextField("Name", text: $name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.title2)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                } else {
                    Text(friend.name)
                        .font(.title2)
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
    }
    
    private var informationSection: some View {
        Section("Contact Information") {
            if isEditing {
                HStack {
                    Image(systemName: "phone.fill")
                        .foregroundColor(.secondary)
                        .frame(width: 20)
                    TextField("Phone Number", text: $phoneNumber)
                        .keyboardType(.phonePad)
                }
                
                HStack {
                    Image(systemName: "envelope.fill")
                        .foregroundColor(.secondary)
                        .frame(width: 20)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
            } else {
                if !friend.phoneNumber.isEmpty {
                    HStack {
                        Image(systemName: "phone.fill")
                            .foregroundColor(.secondary)
                            .frame(width: 20)
                        Text(friend.phoneNumber)
                            .foregroundColor(.primary)
                        Spacer()
                    }
                }
                
                if !friend.email.isEmpty {
                    HStack {
                        Image(systemName: "envelope.fill")
                            .foregroundColor(.secondary)
                            .frame(width: 20)
                        Text(friend.email)
                            .foregroundColor(.primary)
                        Spacer()
                    }
                }
                
                if friend.phoneNumber.isEmpty && friend.email.isEmpty {
                    Text("No contact information")
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                }
            }
        }
    }
    
    private var notesSection: some View {
        Section("Notes") {
            if isEditing {
                TextField("Notes", text: $notes, axis: .vertical)
                    .lineLimit(3...6)
            } else {
                if !friend.notes.isEmpty {
                    Text(friend.notes)
                        .foregroundColor(.primary)
                        .font(.subheadline)
                } else {
                    Text("No notes")
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                }
            }
        }
    }
    
    private func lastUsedSection(_ lastUsed: Date) -> some View {
        Section("Activity") {
            HStack {
                Image(systemName: "clock.fill")
                    .foregroundColor(.secondary)
                    .frame(width: 20)
                Text("Last used: \(lastUsed, style: .relative)")
                    .foregroundColor(.secondary)
                    .font(.subheadline)
                Spacer()
            }
        }
    }
    
    private func saveFriend() {
        friend.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        friend.phoneNumber = phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        friend.email = email.trimmingCharacters(in: .whitespacesAndNewlines)
        friend.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        
        do {
            try modelContext.save()
            isEditing = false
        } catch {
            print("Failed to save friend: \(error)")
        }
    }
}

#Preview {
    let friend = SDFriend(name: "John Doe", phoneNumber: "+1234567890", email: "john@example.com", notes: "Friend from college")
    return FriendDetailView(friend: friend)
}
