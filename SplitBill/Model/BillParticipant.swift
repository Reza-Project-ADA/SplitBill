//
//  BillParticipant.swift
//  SplitBill
//
//  Created by Reza Juliandri on 09/05/25.
//
import Foundation

struct BillParticipant: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var directlyAssignedItems: [AssignableBillItem] = [] // Items assigned SOLELY to this participant

    // These will be calculated by the SplitBillManager
    var subtotal: Double = 0.0
    var taxShare: Double = 0.0
    var totalOwed: Double {
        // Round to 2 decimal places for currency if needed, or handle formatting in UI
        // For internal calculation, keep precision.
        (subtotal + taxShare)
    }
}
