//
//  OpenAIErrorResponse.swift
//  SplitBill
//
//  Created by Reza Juliandri on 09/05/25.
//


struct OpenAIErrorResponse: Decodable {
    let message: String
    let type: String?
    let param: String?
    let code: String? // Sometimes this is a string like "invalid_api_key", sometimes it's null
}
