//
//  DeepSeekProvider.swift
//  SplitBill
//
//  Created by Reza Juliandri on 09/05/25.
//


class DeepSeekProvider: AIProvider {
    let providerIdentifier: String = "deepseek"
    let config: AIProviderConfig

    required init(config: AIProviderConfig) {
        self.config = config
    }
    
    func generateResponse(prompt: String) async throws -> String {
        guard isAvailable() else { throw AIError.configurationError("DeepSeek API Key not set.") }
        print("DeepSeekProvider (text-only) processing prompt: '\(prompt)'...")
        try await Task.sleep(nanoseconds: 1_000_000_000)
        return "DeepSeek text response to: '\(prompt)'"
    }

    func generateStructuredResponse(contents: [AIContentPart], systemPrompt: String?) async throws -> String {
        guard isAvailable() else { throw AIError.configurationError("DeepSeek API Key not set.") }
        // Check if DeepSeek model supports vision, this is a placeholder
        // You'll need to consult DeepSeek's API documentation for multimodal input.
        // For this example, we'll assume it works somewhat like OpenAI/Gemini.

        let visionModel = config.multimodalModelName ?? config.modelName ?? "deepseek-vl-chat" // Hypothetical
        print("DeepSeekProvider (\(visionModel)) processing multimodal content...")
        
        // --- SIMULATED RESPONSE ---
        try await Task.sleep(nanoseconds: 2_000_000_000)
        print("DeepSeek: Simulating multimodal processing. Actual API details would be needed.")
        
        // Assume DeepSeek can also be prompted for JSON.
        let simulatedJsonResponse = """
        {
          "store": {
            "name": "JFC SEMINYAK (Simulated DeepSeek)",
            "address": "Jl. Kayu Aya, Seminyak"
          },
          "transaction": {
            "date": "2025-04-29",
            "time": "13:00",
            "cashier": "DeepSeek Bot",
            "order_number": 303,
            "items": [
              { "name": "DEEP FRIED CHICKEN", "quantity": 2, "price": 18000 },
              { "name": "SEEKER COLA", "quantity": 1, "price": 7000 }
            ],
            "subtotal": 43000,
            "tax": 4300,
            "total": 47300,
            "payment": { "cash": 50000, "change": 2700, "status": "Lunas" }
          }
        }
        """
        return simulatedJsonResponse
    }

    func isAvailable() -> Bool {
        return false
//        return !config.apiKey.isEmpty
    }
}
