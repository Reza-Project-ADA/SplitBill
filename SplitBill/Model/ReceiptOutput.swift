//
//  ReceiptOutput.swift
//  SplitBill
//
//  Created by Reza Juliandri on 09/05/25.
//


struct ReceiptOutput: Codable {
    let store: ReceiptStore
    let transaction: ReceiptTransaction
}
