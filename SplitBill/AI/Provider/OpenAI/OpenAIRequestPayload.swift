//
//  OpenAIRequestPayload.swift
//  SplitBill
//
//  Created by Reza Juliandri on 09/05/25.
//


struct OpenAIRequestPayload: Encodable {
    let model: String
    let messages: [OpenAIMessage]
    let max_tokens: Int?
    let temperature: Double?
    let response_format: ResponseFormat? // For JSON mode

    struct ResponseFormat: Encodable {
        let type: String // e.g., "json_object"
    }
}
