//
//  OpenAIResponse.swift
//  SplitBill
//
//  Created by Reza Juliandri on 09/05/25.
//



struct OpenAIResponse: Decodable {
    let id: String?
    let object: String?
    let created: Int?
    let model: String?
    let choices: [Choice]
    let usage: Usage?
    let error: OpenAIErrorResponse? // For API errors

    struct Choice: Decodable {
        let index: Int?
        let message:ResponseMessage
        let finish_reason: String?
    }

    struct ResponseMessage: Decodable {
        let role: String
        let content: String? // Content can be null if function call is used, or if there's an error during streaming that gets cut off
    }

    struct Usage: Decodable {
        let prompt_tokens: Int?
        let completion_tokens: Int?
        let total_tokens: Int?
    }
}
