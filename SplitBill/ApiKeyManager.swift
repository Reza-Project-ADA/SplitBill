//
//  ApiKeyManager.swift
//  SplitBill
//
//  Created by Reza Juliandri on 09/05/25.
//
import Foundation

class ApiKeyManager {
    static let shared = ApiKeyManager()
    private init() {} // Singleton

    var openAIServiceKey: String? {
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "SplitBillOpenAIKey") as? String else {
            assertionFailure("API Key for MyService not found in Info.plist")
            return nil
        }
        // Basic check to prevent shipping placeholder values accidentally
        if apiKey.lowercased().contains("your_") || apiKey.lowercased().contains("_api_key_") || apiKey.isEmpty {
             assertionFailure("Potential placeholder API key detected. Check your .xcconfig setup!")
             return nil // Or handle appropriately, e.g., return a default or throw an error
        }
        return apiKey
    }
}
