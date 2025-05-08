//
//  AIProvider.swift
//  SplitBill
//
//  Created by Reza Juliandri on 09/05/25.
//


protocol AIProvider {
    var providerIdentifier: String { get }
    var config: AIProviderConfig { get }

    init(config: AIProviderConfig)

    // Existing text-only generation
    func generateResponse(prompt: String) async throws -> String

    // New multimodal generation
    // Takes an array of content parts and a specific prompt about the desired output structure
    func generateStructuredResponse(
        contents: [AIContentPart],
        systemPrompt: String? // General instructions for the AI's role or output format
    ) async throws -> String // Returns the JSON string

    func isAvailable() -> Bool
}
