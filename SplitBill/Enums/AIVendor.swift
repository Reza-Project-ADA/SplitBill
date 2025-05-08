//
//  AIVendor.swift
//  SplitBill
//
//  Created by Reza Juliandri on 09/05/25.
//
enum AIVendor: String, CaseIterable { // Ensure this enum is defined
    case openAI
    case gemini
    case deepSeek

    var displayName: String {
        switch self {
        case .openAI: return "OpenAI"
        case .gemini: return "Google Gemini"
        case .deepSeek: return "DeepSeek"
        }
    }
}
