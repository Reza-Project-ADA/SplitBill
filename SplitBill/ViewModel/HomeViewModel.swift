//
//  HomeViewModel.swift
//  SplitBill
//
//  Created by Reza Juliandri on 14/05/25.
//


import SwiftUI
import SwiftData

class HomeViewModel: ObservableObject { // Renamed for clarity, standard practice
    @Published var path: [MainScreen] = []
    @Published var receiptOutput: ReceiptOutput?
    @Published var selectedSplitSDRecord: SDBillSplitRecord?
    
    @Published var cardBackgroundColor = Color(.systemGray6) // Adaptable for light/dark mode
    @Published var cardCornerRadius: CGFloat = 12
    @Published var cardShadowRadius: CGFloat = 5
    @Published var freeCredits: Int = 0
    @Published var paidCredits: Int = 0
    @Published var totalCredits: Int = 0
    
    private let receiptRepository: ReceiptRepository
    init(receiptRepository: ReceiptRepository = ReceiptRepositoryImpl()) {
        self.receiptRepository = receiptRepository

        // Load credits from repository
        self.freeCredits = receiptRepository.getFreeCredits()
        self.paidCredits = receiptRepository.getPaidCredits()
        self.totalCredits = self.freeCredits + self.paidCredits
        
        // Listen for balance updates
        NotificationCenter.default.addObserver(
            forName: .balanceDidUpdate,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.loadBalanceFromRepository()
        }
    }
    
    @MainActor
    func refreshBalance() async {
        do {
            let result = try await receiptRepository.getBalance()
            self.freeCredits = result.freeCredits
            self.paidCredits = result.paidCredits
            self.totalCredits = self.freeCredits + self.paidCredits
            receiptRepository.saveCredits(freeCredits: result.freeCredits, paidCredits: result.paidCredits)
            
            // Notify other ViewModels about balance update
            NotificationCenter.default.post(name: .balanceDidUpdate, object: nil)
        } catch {
            print("Failed to refresh balance: \(error)")
        }
    }
    
    private func loadBalanceFromRepository() {
        self.freeCredits = receiptRepository.getFreeCredits()
        self.paidCredits = receiptRepository.getPaidCredits()
        self.totalCredits = self.freeCredits + self.paidCredits
    }
}
