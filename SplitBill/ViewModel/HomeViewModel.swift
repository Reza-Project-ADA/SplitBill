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
    }
}
