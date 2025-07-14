//
//  AddFriendSheet.swift
//  SplitBill
//
//  Created by Reza Juliandri on 14/07/25.
//

import SwiftUI
import SwiftData

struct AddFriendSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var phoneNumber = ""
    @State private var email = ""
    @State private var notes = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Friend Information")) {
                    TextField("Name *", text: $name)
                    TextField("Phone Number (Optional)", text: $phoneNumber)
                        .keyboardType(.phonePad)
                    TextField("Email (Optional)", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    TextField("Notes (Optional)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section(footer: Text("* Required field")) {
                    EmptyView()
                }
            }
            .navigationTitle("Add Friend")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveFriend()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    private func saveFriend() {
        let friend = SDFriend(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            phoneNumber: phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines),
            email: email.trimmingCharacters(in: .whitespacesAndNewlines),
            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        
        modelContext.insert(friend)
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Failed to save friend: \(error)")
        }
    }
}

#Preview {
    AddFriendSheet()
}