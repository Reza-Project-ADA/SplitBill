//
//  GeminiProvider.swift
//  SplitBill
//
//  Created by Reza Juliandri on 09/05/25.
//


class GeminiProvider: AIProvider {
    let providerIdentifier: String = "gemini"
    let config: AIProviderConfig

    required init(config: AIProviderConfig) {
        self.config = config
    }

    func generateResponse(prompt: String) async throws -> String {
        // (Implementation from previous example)
        guard isAvailable() else { throw AIError.configurationError("Gemini API Key not set.") }
        print("GeminiProvider (text-only) processing prompt: '\(prompt)'...")
        try await Task.sleep(nanoseconds: 1_000_000_000)
        return "Gemini text response to: '\(prompt)'"
    }

    func generateStructuredResponse(contents: [AIContentPart], systemPrompt: String?) async throws -> String {
        guard isAvailable() else { throw AIError.configurationError("Gemini API Key not set.") }
        guard contents.contains(where: { if case .image = $0 { return true } else { return false } }) else {
            throw AIError.invalidInput("Image data is required for this operation.")
        }

        let visionModel = config.multimodalModelName ?? config.modelName ?? "gemini-1.5-flash" // Or "gemini-pro-vision"
        print("GeminiProvider (\(visionModel)) processing multimodal content...")

        // Construct the prompt for Gemini API
        // The actual API call would involve creating a JSON body for "generateContent" endpoint:
        // {
        //   "contents": [
        //     {
        //       "role": "user", // Or combine system prompt here or use "system_instruction"
        //       "parts": [
        //         { "text": "User's main textual prompt here. System prompt might be part of this." },
        //         { "inline_data": { "mime_type": "image/jpeg", "data": "BASE64_IMAGE_DATA" } }
        //       ]
        //     }
        //   ],
        //   "generationConfig": { "response_mime_type": "application/json" } // Request JSON output
        // }
        // If systemPrompt is used, it might be part of `system_instruction` at the top level or merged into the user text.

        var geminiParts: [[String: Any]] = []
        if let sysPrompt = systemPrompt {
             // Gemini often incorporates system instructions into the first user message or a separate field
            geminiParts.append(["text": sysPrompt])
        }

        for part in contents {
            switch part {
            case .text(let textContent):
                geminiParts.append(["text": textContent])
            case .image(let base64Data, let mimeType):
                geminiParts.append(["inline_data": ["mime_type": mimeType, "data": base64Data]])
            }
        }
        
        let geminiPayload = ["contents": [["role": "user", "parts": geminiParts]]]
        print("Simulating Gemini API call with payload: \(geminiPayload)")
        // In a real app, make the API call here.
        // Use `generationConfig: { "response_mime_type": "application/json" }`

        try await Task.sleep(nanoseconds: 2_800_000_000) // Simulate network delay

        // --- SIMULATED RESPONSE ---
        let simulatedJsonResponse = """
        {
          "store": {
            "name": "JFC KUTA (Simulated Gemini)",
            "address": "Jl. Sunset Road, Kuta"
          },
          "transaction": {
            "date": "2025-04-28",
            "time": "12:30",
            "cashier": "Gemini AI",
            "order_number": 202,
            "items": [
              { "name": "GEMINI SPECIAL", "quantity": 1, "price": 32000 },
              { "name": "AI FRIES", "quantity": 1, "price": 10000 }
            ],
            "subtotal": 42000,
            "tax": 4200,
            "total": 46200,
            "payment": { "cash": 50000, "change": 3800, "status": "Lunas" }
          }
        }
        """
        return simulatedJsonResponse
    }

    func isAvailable() -> Bool {
        return !config.apiKey.isEmpty
    }
}
