//
//  ReceiptRepositoryImpl.swift
//  SplitBill
//
//  Created by Reza Juliandri on 09/05/25.
//

import Foundation
import UIKit

/// Implementation of the ReceiptRepository protocol
class ReceiptRepositoryImpl: ReceiptRepository {
    
    // MARK: - Properties
    
    /// API client for making network requests
    private let apiClient: APIClient
    
    /// Image resizer for processing images before sending to the API
    private let imageResize = ImageResize()
    
    /// UserDefaults keys for storing credit information
    private let freeCreditsKey = "free_credits"
    private let paidCreditsKey = "paid_credits"
    
    // MARK: - Initialization
    
    /// Initialize the repository with an API client
    /// - Parameter apiClient: The API client to use for network requests
    init(apiClient: APIClient = APIConfig.createClient()) {
        self.apiClient = apiClient
    }
    
    // MARK: - ReceiptRepository Implementation
    
    /// Scan a receipt image and extract information
    /// - Parameter image: The receipt image to scan
    /// - Returns: A tuple containing the receipt data and credit information
    func scanReceipt(image: UIImage) async throws -> (receipt: ReceiptOutput, freeCredits: Int, paidCredits: Int) {
        // Convert image to PNG data
        guard let pngImage = image.pngData() else {
            throw NSError(domain: "com.splitbill.error", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid image format. Could not process the selected image."])
        }
        
        // Resize the image
        let resizedImage = imageResize.resize(imageData: pngImage)
        
        // Convert to base64 string with proper format
        let base64Image = resizedImage.base64EncodedString().asPNGBaseURLString()
        
        // Send to API
        let result = try await apiClient.scanReceipt(imageData: base64Image)
        
        // Save the updated credit information
        saveCredits(freeCredits: result.freeCredits, paidCredits: result.paidCredits)
        
        return result
    }
    func getBalance() async throws -> (freeCredits: Int, paidCredits: Int) {
        let result = try await apiClient.getBalance()
        
        return (freeCredits: result.freeCredits, paidCredits: result.paidCredits)
    }
    
    /// Get the current number of free credits
    /// - Returns: The number of free credits
    func getFreeCredits() -> Int {
        return UserDefaults.standard.integer(forKey: freeCreditsKey)
    }
    
    /// Get the current number of paid credits
    /// - Returns: The number of paid credits
    func getPaidCredits() -> Int {
        return UserDefaults.standard.integer(forKey: paidCreditsKey)
    }
    
    /// Save the updated credit information
    /// - Parameters:
    ///   - freeCredits: The number of free credits
    ///   - paidCredits: The number of paid credits
    func saveCredits(freeCredits: Int, paidCredits: Int) {
        UserDefaults.standard.set(freeCredits, forKey: freeCreditsKey)
        UserDefaults.standard.set(paidCredits, forKey: paidCreditsKey)
    }
}
