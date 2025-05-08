//
//  AIError.swift
//  SplitBill
//
//  Created by Reza Juliandri on 09/05/25.
//


enum AIError: Error {
    case networkError(String)
    case apiError(String)
    case unknownError(Error?)
    case configurationError(String)
    case featureNotSupported(String)
    case invalidInput(String)
    case parsingError(String)
    case decodingError(Error)
    case noResponse
}
