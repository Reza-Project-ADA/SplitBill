//
//  OpenAIProvider.swift
//  SplitBill
//
//  Created by Reza Juliandri on 09/05/25.
//
import Foundation

class OpenAIProvider: AIProvider {
    let providerIdentifier: String = "openai"
    let config: AIProviderConfig
    private let session: URLSession
    
    required init(config: AIProviderConfig) {
        self.config = config
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 60 // 60 seconds timeout for request
        configuration.timeoutIntervalForResource = 120 // 120 seconds timeout for resource
        
        // >>>>>>>> HERE: Initialization of the session property <<<<<<<<<<
        self.session = URLSession(configuration: configuration)
    }
    
    func generateResponse(prompt: String) async throws -> String {
        // (Implementation from previous example)
        guard isAvailable() else { throw AIError.configurationError("OpenAI API Key not set.") }
        print("OpenAIProvider (text-only) processing prompt: '\(prompt)'...")
        try await Task.sleep(nanoseconds: 1_000_000_000)
        return "OpenAI text response to: '\(prompt)'"
    }
    
    func generateStructuredResponse(contents: [AIContentPart], systemPrompt: String?) async throws -> String {
        guard isAvailable() else { throw AIError.configurationError("OpenAI API Key not set.") }
        guard contents.contains(where: { if case .image = $0 { return true } else { return false } }) else {
            throw AIError.invalidInput("Image data is required for this operation.")
        }
        
        let visionModel = config.multimodalModelName ?? config.modelName ?? "gpt-4o" // Or "gpt-4-turbo" / "gpt-4-vision-preview"
        print("OpenAIProvider (\(visionModel)) processing multimodal content...")
        
        // Construct the prompt for OpenAI's Chat Completions API with vision
        // The actual API call would involve creating a JSON body like:
        // {
        //   "model": "gpt-4o",
        //   "messages": [
        //     { "role": "system", "content": systemPrompt (if provided) },
        //     {
        //       "role": "user",
        //       "content": [
        //         { "type": "text", "text": "User's main textual prompt here" },
        //         { "type": "image_url", "image_url": { "url": "data:image/jpeg;base64,..." } }
        //       ]
        //     }
        //   ],
        //   "max_tokens": 2000,
        //   "response_format": { "type": "json_object" } // For newer models that support JSON mode
        // }
        
        var openAIMessages: [OpenAIMessage] = []
        if let sysPrompt = systemPrompt, !sysPrompt.isEmpty {
            openAIMessages.append(OpenAIMessage(role: "system", content: .string(sysPrompt)))
        }
        
        
        var userContentPayloadParts: [OpenAIMessageContentPart] = []
        for part in contents {
            switch part {
            case .text(let textContent):
                userContentPayloadParts.append(.text(textContent))
            case .image(let base64Data, let mimeType):
                guard let dataURL = AIContentPart.image(base64Data: base64Data, mimeType: mimeType).asDataURLString() else {
                    throw AIError.invalidInput("Could not form data URL for image.")
                }
                userContentPayloadParts.append(.imageUrl(dataURL, detail: "high"))
            }
        }
        openAIMessages.append(OpenAIMessage(role: "user", content: .parts(userContentPayloadParts)))
        
        let payload = OpenAIRequestPayload(
            model: visionModel,
            messages: openAIMessages,
            max_tokens: 2000, // Increased for potentially larger JSON
            temperature: 0.2, // Lower temperature for more deterministic JSON output
            response_format: OpenAIRequestPayload.ResponseFormat(type: "json_object")
        )
        
        print("Making real OpenAI API call with payload for model \(visionModel)")
        return try await makeAPICall(payload: payload)
        
        //        print("Simulating OpenAI API call with messages: \(openAIMessages)")
        //        // In a real app, make the API call here.
        //        // Ensure you ask for JSON output in the prompt or use model's JSON mode if available.
        //
        //        try await Task.sleep(nanoseconds: 2_500_000_000) // Simulate network delay
        //
        //        // --- SIMULATED RESPONSE ---
        //        // This would be the actual JSON string returned by the API
        //        let simulatedJsonResponse = """
        //        {
        //          "store": {
        //            "name": "JFC TANAH KILAP (Simulated OpenAI)",
        //            "address": "Jl. Griya Anyar, Denpasar, Bali"
        //          },
        //          "transaction": {
        //            "date": "2025-04-27",
        //            "time": "11:50",
        //            "cashier": "AI Bot",
        //            "order_number": 101,
        //            "items": [
        //              { "name": "AI COMBO", "quantity": 1, "price": 30000 },
        //              { "name": "VISION JUICE", "quantity": 2, "price": 15000 }
        //            ],
        //            "subtotal": 60000,
        //            "tax": 6000,
        //            "total": 66000,
        //            "payment": { "cash": 70000, "change": 4000, "status": "Lunas" }
        //          }
        //        }
        //        """
        //        return simulatedJsonResponse
    }
    private func makeAPICall(payload: OpenAIRequestPayload) async throws -> String {
        let apiEndpoint = "https://api.openai.com/v1/chat/completions"
        guard let url = URL(string: apiEndpoint) else {
            throw AIError.networkError("Invalid API endpoint")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(config.apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let encoder = JSONEncoder()
            // encoder.outputFormatting = .prettyPrinted // For debugging request body
            request.httpBody = try encoder.encode(payload)
            if let body = request.httpBody, let bodyString = String(data: body, encoding: .utf8) {
                print("Request Body: \(bodyString)") // For debugging
            }
        } catch {
            throw AIError.encodingError(error) // Custom error for encoding issues
        }
        
        let data: Data
        let response: URLResponse
        
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw AIError.networkError(error.localizedDescription)
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AIError.networkError("Invalid HTTP response")
        }
        
        // For debugging response
        // if let responseString = String(data: data, encoding: .utf8) {
        //     print("Raw API Response (status: \(httpResponse.statusCode)): \(responseString)")
        // }
        
        do {
            let decoder = JSONDecoder()
            if (200..<300).contains(httpResponse.statusCode) {
                let openAIResponse = try decoder.decode(OpenAIResponse.self, from: data)
                guard let firstChoiceContent = openAIResponse.choices.first?.message.content else {
                    throw AIError.noResponse
                }
                return firstChoiceContent
            } else {
                // Attempt to decode OpenAI's specific error structure
                let errorResponse = try? decoder.decode(OpenAIResponse.self, from: data) // Sometimes the error is nested in the main response
                let errorMessage = errorResponse?.error?.message ?? errorResponse?.choices.first?.message.content ?? String(data: data, encoding: .utf8) ?? "Unknown API error"
                print("API Error (Status \(httpResponse.statusCode)): \(errorMessage)")
                throw AIError.apiError("API Error (Status \(httpResponse.statusCode))")
            }
        } catch let decodingError as DecodingError {
            print("Decoding Error: \(decodingError)")
            // Log the raw data for debugging if decoding fails
            if let responseString = String(data: data, encoding: .utf8) {
                print("Failed to decode response body: \(responseString)")
            }
            throw AIError.decodingError(decodingError)
        } catch { // Catch any other errors during decoding or logic
            throw error // Re-throw if it's already an AIError, or wrap if it's something else
        }
    }
    
    func isAvailable() -> Bool {
        return !config.apiKey.isEmpty
    }
    
    enum EncodingError: Error {
        case failedToEncodePayload(Error)
    }
}
extension AIError { // Add a case for encoding if not already there
    enum EncodingError: Error { case failedToEncode } // Example, if you want to be specific
    static func encodingError(_ error: Error) -> AIError {
        // You might want a specific case or just use .unknownError
        return .unknownError(error)
    }
}
