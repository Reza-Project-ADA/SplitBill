//
//  SDFriend.swift
//  SplitBill
//
//  Created by Reza Juliandri on 14/07/25.
//

import Foundation
import SwiftData

@Model
class SDFriend {
    var id: UUID
    var name: String
    var phoneNumber: String
    var email: String
    var notes: String
    var createdAt: Date
    var lastUsedAt: Date?
    var isDeleted: Bool
    var deletedAt: Date?
    
    init(name: String, phoneNumber: String = "", email: String = "", notes: String = "") {
        self.id = UUID()
        self.name = name
        self.phoneNumber = phoneNumber
        self.email = email
        self.notes = notes
        self.createdAt = Date()
        self.lastUsedAt = nil
        self.isDeleted = false
        self.deletedAt = nil
    }
    
    func updateLastUsed() {
        self.lastUsedAt = Date()
    }
    
    func softDelete() {
        self.isDeleted = true
        self.deletedAt = Date()
    }
    
    func restore() {
        self.isDeleted = false
        self.deletedAt = nil
    }
}