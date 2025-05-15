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
    let order_number: String
    let items: [ReceiptItem]
    let subtotal: Int
    let tax: Int
    let service_fee: Int
    let delivery_fee: Int
    let other_fee: Int
    let total: Int
    let payment: ReceiptPayment

    enum CodingKeys: String, CodingKey {
        case date, time, cashier
        case order_number = "order_number"
        case items, subtotal, tax, service_fee, delivery_fee, other_fee, total, payment
    }
}
