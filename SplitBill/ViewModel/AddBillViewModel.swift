//
//  AddBillViewModel.swift
//  SplitBill
//
//  Created by Reza Juliandri on 09/05/25.
//
import Foundation
import SwiftUI

class AddBillViewModel: ObservableObject {
    @Published  var billImage: UIImage?
    @Published  var showingImagePicker = false
    @Published  var showingActionSheet = false
    @Published  var sourceType: UIImagePickerController.SourceType = .photoLibrary // Default
    @Published var isLoading: Bool = false
    @Published var isSuccess: Bool = false
    @Published var errorMessage: String = ""
    @Published var receiptData: ReceiptOutput?
    
    var imageResize = ImageResize()
    
    func cameraButtonPressed(){
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            self.sourceType = .camera
            self.showingImagePicker = true
        } else {
            // Handle case where camera is not available (e.g., simulator or permissions)
            print("Camera not available.")
            // Optionally, show an alert to the user
        }
    }
    
    func photoLibraryButtonPressed(){
        self.sourceType = .photoLibrary
        self.showingImagePicker = true
    }
    @MainActor
        func uploadImageAndProcess() async -> Bool { // Renamed for clarity, still called by View's Button
            self.isLoading = true
            self.errorMessage = "" // Clear previous errors
            // `defer` ensures isLoading is set to false regardless of how the function exits
            defer {
                self.isLoading = false
            }

            guard let image = self.billImage else {
                print("No image selected.")
                self.errorMessage = "No image selected. Please pick an image first."
                return false
            }

            // It's good practice to ensure pngData() doesn't return nil,
            // though force unwrap implies you expect it to always succeed for a UIImage.
            guard let pngImage = image.pngData() else {
                print("Could not get PNG data from image.")
                self.errorMessage = "Invalid image format. Could not process the selected image."
                return false
            }
            
            print("Image selected, proceeding with processing...")
            
            // These operations are synchronous, so they are fine here.
            let resizedImage = imageResize.resize(imageData: pngImage)
            let base64Image = resizedImage.base64EncodedString()
            
            // AI Config
            let chosenVendor: AIVendor = .openAI // Make sure AIVendor and .openAI are defined
            // End AI Config
            
            guard let provider = AIProviderFactory.makeProvider(vendor: chosenVendor) else {
                let message = "🚫 Could not create AI provider for \(chosenVendor.displayName). Check API key setup."
                print(message)
                self.errorMessage = message
                return false
            }
            
            print("AI Provider created. Preparing content for AI...")
            let systemPrompt = ReceiptAIPrompt.createReceiptExtractionSystemPrompt()
            let userTextPrompt = ReceiptAIPrompt.createUserPromptForReceipt()
            
            let contentToProcess: [AIContentPart] = [
                .text(userTextPrompt),
                .image(base64Data: base64Image, mimeType: "image/png")
            ]
            
            do {
                print("Sending request to AI...")
                let jsonStringResponse = try await provider.generateStructuredResponse(
                    contents: contentToProcess,
                    systemPrompt: systemPrompt
                )
                print("AI Response (JSON String): \(jsonStringResponse)")

                guard let jsonData = jsonStringResponse.data(using: .utf8) else {
                    print("\n🛑 Could not convert JSON string response to Data.")
                    self.errorMessage = "AI returned an unreadable response (String to Data conversion failed)."
                    return false
                }

                let decoder = JSONDecoder()
                // Nested do-catch for decoding specifically is good for detailed error messages
                do {
                    let jsonDecode = try decoder.decode(ReceiptOutput.self, from: jsonData)
                    // Since this function is @MainActor, direct assignment is fine.
                    self.receiptData = jsonDecode
                    print("✅ Successfully decoded AI response. ReceiptData is set.")
                    // isLoading is handled by defer
                    // errorMessage remains empty (or clear it explicitly if desired on success)
                    // self.errorMessage = "" // Already cleared at the beginning
                    return true // SUCCESS!
                } catch let decodingError as DecodingError {
                    print("\n🛑 Error parsing JSON response into ReceiptOutput struct: \(decodingError)")
                    // Provide a more user-friendly message based on the decoding error
                    self.errorMessage = "Failed to understand the bill's details. \(detailedDecodingErrorMessage(decodingError))"
                    handleDecodingError(decodingError) // For console logging detailed error
                    return false
                } catch { // Catch other errors during decoding (though less common if it's not DecodingError)
                    print("\n🛑 Unexpected error during JSON decoding: \(error)")
                    self.errorMessage = "An unexpected error occurred while processing the bill details."
                    return false
                }
            }
            catch let aiError as AIError { // Catch specific AIError first
                print("\n🛑 AI Operation Error: \(aiError.localizedDescription)")
                self.errorMessage = "AI Error: \(aiError.localizedDescription)"
                return false
            } catch { // Catch any other errors from the 'await provider.generateStructuredResponse' or other 'try' calls
                print("\n🛑 Unexpected error during AI processing: \(error)")
                self.errorMessage = "An unexpected error occurred: \(error.localizedDescription)"
                return false
            }
        }

        // Helper for more detailed decoding error messages (example)
        @MainActor // If it updates @Published properties, or just keep it non-actor if it only returns a String
        private func detailedDecodingErrorMessage(_ error: DecodingError) -> String {
            switch error {
            case .typeMismatch(let type, let context):
                return "Expected type \(type) was not found at '\(context.codingPath.map {$0.stringValue}.joined(separator: "."))'. \(context.debugDescription)"
            case .valueNotFound(let type, let context):
                return "Value for type \(type) was missing at '\(context.codingPath.map {$0.stringValue}.joined(separator: "."))'. \(context.debugDescription)"
            case .keyNotFound(let key, let context):
                return "Key '\(key.stringValue)' was not found at '\(context.codingPath.map {$0.stringValue}.joined(separator: "."))'. \(context.debugDescription)"
            case .dataCorrupted(let context):
                return "Data was corrupted: \(context.debugDescription) at '\(context.codingPath.map {$0.stringValue}.joined(separator: "."))'."
            @unknown default:
                return "An unknown JSON parsing error occurred."
            }
        }
    
    @MainActor // Or ensure it's called on main if it does UI work
    // Helper to print more details about decoding errors
    func handleDecodingError(_ error: DecodingError) {
        switch error {
        case .typeMismatch(let type, let context):
            print("   TypeMismatch: \(type) in \(context.codingPath.map { $0.stringValue }.joined(separator: ".")) - \(context.debugDescription)")
        case .valueNotFound(let type, let context):
            print("   ValueNotFound: \(type) in \(context.codingPath.map { $0.stringValue }.joined(separator: ".")) - \(context.debugDescription)")
        case .keyNotFound(let key, let context):
            print("   KeyNotFound: \(key.stringValue) in \(context.codingPath.map { $0.stringValue }.joined(separator: ".")) - \(context.debugDescription)")
        case .dataCorrupted(let context):
            print("   DataCorrupted: in \(context.codingPath.map { $0.stringValue }.joined(separator: ".")) - \(context.debugDescription)")
        @unknown default:
            print("   Unknown decoding error.")
        }
    }
}
