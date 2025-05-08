class AIProviderFactory {
    // --- API Keys Configuration ---
    // Store your API keys securely (e.g., from a config file, Keychain, or environment variables)
    // For this example, we'll hardcode them, but DON'T do this in a real app.
    // IMPORTANT: Replace "YOUR_..." with your actual keys or ensure they are loaded securely.
    private static var apiKeys: [AIVendor: String] = [ // Changed to var to allow modification in Task
//        .openAI: "YOUR_OPENAI_API_KEY",
        .openAI: ApiKeyManager.shared.openAIServiceKey ?? "AIKey",
        .gemini: "YOUR_GEMINI_API_KEY",
        .deepSeek: "YOUR_DEEPSEEK_API_KEY"
    ]

    // --- Default Text Model Names ---
    // These are model names primarily for text-based generation or as fallbacks.
    private static let modelNames: [AIVendor: String] = [
        .openAI: "gpt-4o-mini",        // Good default, can be overridden by config
        .gemini: "gemini-1.5-flash",   // Good default, can be overridden by config
        .deepSeek: "deepseek-chat"     // Good default, can be overridden by config
    ]

    // --- Default Multimodal (Vision) Model Names ---
    // Specify if different models are used for vision tasks.
    // If nil, it might fall back to the general modelName or a provider's internal default.
    private static let multimodalModelNames: [AIVendor: String] = [
        .openAI: "gpt-4o",             // Excellent for vision
        .gemini: "gemini-1.5-flash-latest", // Or "gemini-pro-vision"
        .deepSeek: "deepseek-vl-chat"  // Hypothetical, check DeepSeek's actual vision model
    ]

    static func makeProvider(vendor: AIVendor) -> AIProvider? {
        guard let apiKey = apiKeys[vendor], !apiKey.hasPrefix("YOUR_") else {
            print("⚠️ API Key for \(vendor.displayName) is not configured or is a placeholder ('\(apiKeys[vendor] ?? "nil")'). Please set it in AIProviderFactory.apiKeys.")
            return nil
        }
        
        let textModel = modelNames[vendor] // This should now be found
        let visionModel = multimodalModelNames[vendor] ?? textModel // Fallback to text model if specific vision model not set

        let config = AIProviderConfig(
            apiKey: apiKey,
            modelName: textModel,       // For general use or text-only functions
            multimodalModelName: visionModel // Specifically for multimodal functions
        )

        switch vendor {
        case .openAI:
            return OpenAIProvider(config: config)
        case .gemini:
            return GeminiProvider(config: config)
        case .deepSeek:
            // For DeepSeek, ensure 'deepseek-vl-chat' (or whatever its vision model is)
            // is appropriate if visionModel is non-nil.
            return DeepSeekProvider(config: config)
        }
    }
    
    // Optional: Overload for providing a completely custom configuration
    static func makeProvider(vendor: AIVendor, customConfig: AIProviderConfig) -> AIProvider? {
        // Basic check for API key in custom config, though the provider's init should also validate
        guard !customConfig.apiKey.isEmpty, !customConfig.apiKey.hasPrefix("YOUR_") else {
            print("⚠️ Custom config for \(vendor.displayName) has a missing or placeholder API key.")
            // Decide if you want to proceed or return nil.
            // For robustness, returning nil or throwing might be better here if apiKey is essential.
            // The provider's `isAvailable()` will also catch this.
            // return nil
            return nil
        }
        
        switch vendor {
        case .openAI:
            return OpenAIProvider(config: customConfig)
        case .gemini:
            return GeminiProvider(config: customConfig)
        case .deepSeek:
            return DeepSeekProvider(config: customConfig)
        }
    }
}
