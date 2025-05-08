//
//  OpenAIMessageContentPart.swift
//  SplitBill
//
//  Created by Reza Juliandri on 09/05/25.
//


struct OpenAIMessageContentPart: Encodable {
    let type: String // "text" or "image_url"
    let text: String?
    let image_url: ImageURLDetail?

    struct ImageURLDetail: Encodable {
        let url: String
        let detail: String? // "auto", "low", "high"
    }

    // Convenience initializers
    static func text(_ textContent: String) -> OpenAIMessageContentPart {
        return OpenAIMessageContentPart(type: "text", text: textContent, image_url: nil)
    }

    static func imageUrl(_ urlString: String, detail: String? = "auto") -> OpenAIMessageContentPart {
        return OpenAIMessageContentPart(type: "image_url", text: nil, image_url: ImageURLDetail(url: urlString, detail: detail))
    }
}
