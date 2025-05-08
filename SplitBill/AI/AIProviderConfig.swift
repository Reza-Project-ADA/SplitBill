//
//  AIProviderConfig.swift
//  SplitBill
//
//  Created by Reza Juliandri on 09/05/25.
//


struct AIProviderConfig {
    let apiKey: String
    let modelName: String?
    let timeout: Double = 30.0
    var providerSpecificSettings: [String: Any]? = nil
    var multimodalModelName: String? // Optional: if a different model is used for vision
}
