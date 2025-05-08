//
//  AIContentPart.swift
//  SplitBill
//
//  Created by Reza Juliandri on 09/05/25.
//


enum AIContentPart {
    case text(String)
    case image(base64Data: String, mimeType: String) // e.g., "image/jpeg", "image/png"

    // Helper to create a data URL string if needed by some APIs (like OpenAI)
    func asDataURLString() -> String? {
        guard case .image(let base64Data, let mimeType) = self else { return nil }
        return "data:\(mimeType);base64,\(base64Data)"
    }
}