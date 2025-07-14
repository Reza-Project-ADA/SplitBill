//
//  BalanceViewModel.swift
//  SplitBill
//
//  Created by Reza Juliandri on 10/06/25.
//
import Foundation

class BalanceViewModel: ObservableObject {
    @Published var errorMessage: String = ""
    @Published var freeCredits: Int = 0
    @Published var paidCredits: Int = 0
    @Published var totalCredits: Int = 0
    
    private let repository: ReceiptRepository
    
    init(repository: ReceiptRepository = ReceiptRepositoryImpl()) {
        self.repository = repository

        // Load credits from repository
        self.freeCredits = repository.getFreeCredits()
        self.paidCredits = repository.getPaidCredits()
        self.totalCredits = self.freeCredits + self.paidCredits
    }

    @MainActor
    func getBalance() async -> Bool {
        do {
            let result = try await repository.getBalance()
            self.freeCredits = result.freeCredits
            self.paidCredits = result.paidCredits
            self.totalCredits = self.freeCredits + self.paidCredits
            repository.saveCredits(freeCredits: result.freeCredits, paidCredits: result.paidCredits)
            
            // Notify other ViewModels about balance update
            NotificationCenter.default.post(name: .balanceDidUpdate, object: nil)
            
            return true
        } catch let apiError as APIError {
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
}

