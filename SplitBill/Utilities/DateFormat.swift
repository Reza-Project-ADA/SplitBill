//
//  DateFormat.swift
//  SplitBill
//
//  Created by Reza Juliandri on 09/05/25.
//
import Foundation
extension Date {
    var dayMonthFormat: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
}

