//
//  ImportContactsSheet.swift
//  SplitBill
//
//  Created by Reza Juliandri on 14/07/25.
//

import SwiftUI
import SwiftData
import Contacts

struct ImportContactsSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var contacts: [CNContact] = []
    @State private var selectedContacts: Set<String> = []
    @State private var isLoading = false
    @State private var permissionDenied = false
    @State private var searchText = ""
    
    var filteredContacts: [CNContact] {
        if searchText.isEmpty {
            return contacts
        } else {
            return contacts.filter { contact in
                contact.givenName.localizedCaseInsensitiveContains(searchText) ||
                contact.familyName.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            Group {
                if permissionDenied {
                    permissionDeniedView
                } else if isLoading {
                    loadingView
                } else {
                    contactsListView
                }
            }
            .navigationTitle("Import Contacts")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Import") {
                        importSelectedContacts()
                    }
                    .disabled(selectedContacts.isEmpty)
                }
            }
            .searchable(text: $searchText, prompt: "Search contacts...")
            .onAppear {
                requestContactsPermission()
            }
        }
    }
    
    private var permissionDeniedView: some View {
        ContentUnavailableView {
            Label("Contacts Access Denied", systemImage: "person.crop.circle.badge.exclamationmark")
        } description: {
            Text("To import contacts, please enable Contacts access in Settings.")
        } actions: {
            Button("Open Settings") {
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL)
                }
            }
        }
    }
    
    private var loadingView: some View {
        VStack {
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading contacts...")
                .font(.headline)
                .padding(.top)
        }
    }
    
    private var contactsListView: some View {
        List {
            ForEach(filteredContacts, id: \.identifier) { contact in
                ContactRow(
                    contact: contact,
                    isSelected: selectedContacts.contains(contact.identifier)
                ) {
                    toggleSelection(for: contact)
                }
            }
        }
        .listStyle(PlainListStyle())
    }
    
    private func requestContactsPermission() {
        let store = CNContactStore()
        
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .authorized:
            loadContacts()
        case .denied, .restricted:
            permissionDenied = true
        case .notDetermined:
            store.requestAccess(for: .contacts) { granted, _ in
                DispatchQueue.main.async {
                    if granted {
                        loadContacts()
                    } else {
                        permissionDenied = true
                    }
                }
            }
        default:
            permissionDenied = true
        }
    }
    
    private func loadContacts() {
        isLoading = true
        
        let store = CNContactStore()
        let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey, CNContactEmailAddressesKey] as [CNKeyDescriptor]
        let request = CNContactFetchRequest(keysToFetch: keys)
        
        var loadedContacts: [CNContact] = []
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try store.enumerateContacts(with: request) { contact, _ in
                    if !contact.givenName.isEmpty || !contact.familyName.isEmpty {
                        loadedContacts.append(contact)
                    }
                }
                
                DispatchQueue.main.async {
                    self.contacts = loadedContacts.sorted { 
                        ($0.givenName + " " + $0.familyName) < ($1.givenName + " " + $1.familyName)
                    }
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.permissionDenied = true
                }
            }
        }
    }
    
    private func toggleSelection(for contact: CNContact) {
        if selectedContacts.contains(contact.identifier) {
            selectedContacts.remove(contact.identifier)
        } else {
            selectedContacts.insert(contact.identifier)
        }
    }
    
    private func importSelectedContacts() {
        let contactsToImport = contacts.filter { selectedContacts.contains($0.identifier) }
        
        for contact in contactsToImport {
            let name = "\(contact.givenName) \(contact.familyName)".trimmingCharacters(in: .whitespaces)
            let phoneNumber = contact.phoneNumbers.first?.value.stringValue ?? ""
            let email = contact.emailAddresses.first?.value as String? ?? ""
            
            let friend = SDFriend(
                name: name,
                phoneNumber: phoneNumber,
                email: email
            )
            
            modelContext.insert(friend)
        }
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Failed to save imported contacts: \(error)")
        }
    }
}

struct ContactRow: View {
    let contact: CNContact
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onTap) {
                HStack {
                    // Selection indicator
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isSelected ? .blue : .secondary)
                        .font(.title2)
                    
                    // Avatar
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.2))
                            .frame(width: 40, height: 40)
                        
                        Text(getInitials(for: contact))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    }
                    
                    // Contact info
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(contact.givenName) \(contact.familyName)")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        if let phoneNumber = contact.phoneNumbers.first?.value.stringValue {
                            Text(phoneNumber)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        if let email = contact.emailAddresses.first?.value as String? {
                            Text(email)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.vertical, 4)
    }
    
    private func getInitials(for contact: CNContact) -> String {
        let firstName = contact.givenName.isEmpty ? "" : String(contact.givenName.prefix(1))
        let lastName = contact.familyName.isEmpty ? "" : String(contact.familyName.prefix(1))
        return (firstName + lastName).uppercased()
    }
}

#Preview {
    ImportContactsSheet()
}
