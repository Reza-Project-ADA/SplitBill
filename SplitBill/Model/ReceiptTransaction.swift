//
//  ReceiptTransaction.swift
//  SplitBill
//
//  Created by Reza Juliandri on 09/05/25.
//

import Foundation

struct ReceiptTransaction: Codable {
    let id = UUID()
    let date: String // Format "YYYY-MM-DD"
    let time: String // Format "HH:MM"
    let cashier: String
    let order_number: String // Changed from orderNumber for JSON convention
    let items: [ReceiptItem]
    let subtotal: Int
    let tax: Int
    let total: Int
    let payment: ReceiptPayment

    // For JSON keys to match the example (e.g., order_number)
    enum CodingKeys: String, CodingKey {
        case date, time, cashier
        case order_number = "order_number" // Map Swift orderNumber to JSON order_number
        case items, subtotal, tax, total, payment
    }
}
