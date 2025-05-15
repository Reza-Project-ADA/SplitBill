//
//  SplitBillView+BillSummary.swift
//  SplitBill
//
//  Created by Reza Juliandri on 15/05/25.
//
import SwiftUI

extension SplitBillView {
    var billSummary: some View {
        Section {
            HStack {
                Text("Receipt Subtotal:");
                Spacer();
                Text(Double(manager.receipt.transaction.subtotal).currency)
            }
            HStack {
                Text("Receipt Tax:");
                Spacer();
                Text(Double(manager.receipt.transaction.tax).currency)
            }
            HStack {
                Text("Receipt Total:")
                    .fontWeight(.bold)
                Spacer()
                Text(Double(manager.receipt.transaction.total).currency) }
            Divider()
            HStack {
                Text("Sum of Participants' Totals:")
                Spacer();
                Text(
                    manager.participants.reduce(0){ $0 + $1.totalOwed }.currency
                )
            }
            HStack {
                Text("Remaining Unassigned Value:")
                Spacer();
                Text(manager.unassignedItems.reduce(0){ $0 + $1.price }.currency)
            }
            let calculatedTotalTax = manager.participants.reduce(0) { $0 + $1.taxShare }
            let calculatedTotalSubtotal = manager.participants.reduce(0) { $0 + $1.subtotal }
            
            HStack {
                Text("Calculated Total Tax:")
                Spacer()
                Text(calculatedTotalTax, format: .currency(code: "IDR"))
            }
            HStack {
                Text("Calculated Total Subtotal:")
                Spacer()
                Text(calculatedTotalSubtotal, format: .currency(code: "IDR"))
            }
        } header: {
            Text("Bill Summary")
        }
    }
}
