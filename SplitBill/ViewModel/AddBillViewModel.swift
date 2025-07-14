//
//  AddBillViewModel.swift
//  SplitBill
//
//  Created by Reza Juliandri on 09/05/25.
//
import Foundation
import SwiftUI

class AddBillViewModel: ObservableObject {
    @Published var billImage: UIImage?
    @Published var showingImagePicker = false
    @Published var showingActionSheet = false
    @Published var sourceType: UIImagePickerController.SourceType = .photoLibrary // Default
    @Published var isLoading: Bool = false
    @Published var isSuccess: Bool = false
    @Published var errorMessage: String = ""
    @Published var receiptData: ReceiptOutput?
    @Published var freeCredits: Int = 0
    @Published var paidCredits: Int = 0

    // Repository for handling receipt-related operations
    private let repository: ReceiptRepository

    init(repository: ReceiptRepository = ReceiptRepositoryImpl()) {
        self.repository = repository

        // Load credits from repository
        self.freeCredits = repository.getFreeCredits()
        self.paidCredits = repository.getPaidCredits()
    }

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
    func uploadImageAndProcess() async -> Bool {
        self.isLoading = true
        self.errorMessage = ""   // Clear previous errors
        // `defer` ensures isLoading is set to false regardless of how the function exits
        defer {
            self.isLoading = false
        }

        guard let image = self.billImage else {
            print("No image selected.")
            self.errorMessage = "No image selected. Please pick an image first."
            return false
        }

        print("Image selected, proceeding with processing...")

        do {
            print("Sending request to backend API via repository...")
            let result = try await repository.scanReceipt(image: image)

            // Update the view model with the results
            self.receiptData = result.receipt
            self.freeCredits = result.freeCredits
            self.paidCredits = result.paidCredits

            // Update the repository with the latest credit information
            repository.saveCredits(freeCredits: result.freeCredits, paidCredits: result.paidCredits)

            // Notify other ViewModels about balance update
            NotificationCenter.default.post(name: .balanceDidUpdate, object: nil)

            print("✅ Successfully received and decoded API response. ReceiptData is set.")

            return true // SUCCESS!
        }
        catch let apiError as APIError {
            print("\n🛑 API Error: \(apiError.localizedDescription)")
            self.errorMessage = apiError.localizedDescription
            return false
        }
        catch {
            print("\n🛑 Unexpected error during API processing: \(error)")
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
