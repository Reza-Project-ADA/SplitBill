//
//  Currency.swift
//  SplitBill
//
//  Created by Reza Juliandri on 09/05/25.
//
import Foundation
extension Double {
    var currency: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "id_ID")
        return formatter.string(from: NSDecimalNumber(value: self)) ?? "Rp 0"

    }
}

