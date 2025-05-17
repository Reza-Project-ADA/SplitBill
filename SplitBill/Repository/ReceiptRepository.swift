//
//  ReceiptRepository.swift
//  SplitBill
//
//  Created by Reza Juliandri on 09/05/25.
//

import Foundation
import UIKit

/// Protocol defining the interface for receipt-related operations
protocol ReceiptRepository {
    /// Scan a receipt image and extract information
    /// - Parameter image: The receipt image to scan
    /// - Returns: A tuple containing the receipt data and credit information
    func scanReceipt(image: UIImage) async throws -> (receipt: ReceiptOutput, freeCredits: Int, paidCredits: Int)
    
    /// Get the current number of free credits
    /// - Returns: The number of free credits
    func getFreeCredits() -> Int
    
    /// Get the current number of paid credits
    /// - Returns: The number of paid credits
    func getPaidCredits() -> Int
    
    /// Save the updated credit information
    /// - Parameters:
    ///   - freeCredits: The number of free credits
    ///   - paidCredits: The number of paid credits
    func saveCredits(freeCredits: Int, paidCredits: Int)
}