//
//  ReceiptPayment.swift
//  SplitBill
//
//  Created by Reza Juliandri on 09/05/25.
//


struct ReceiptPayment: Codable {
    let cash: Int
    let change: Int
    let status: String
}