//
//  AssignableBillItem.swift
//  SplitBill
//
//  Created by Reza Juliandri on 09/05/25.
//
import Foundation

struct AssignableBillItem: Identifiable, Hashable {
    let id = UUID() // Unique ID for this specific assignable unit
    let originalReceiptItemID: UUID // To link back to the original ReceiptItem
    let name: String
    let price: Double // Price for this single unit
}
