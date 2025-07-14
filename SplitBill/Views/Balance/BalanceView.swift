//
//  BalanceView.swift
//  SplitBill
//
//  Created by Reza Juliandri on 09/06/25.
//
import SwiftUI

struct CreditPackage {
    let id = UUID()
    let name: String
    let unit: Int
    let credits: Int
    let price: Int // in Rupiah
    let originalPrice: Int
    let badge: String?
    let description: String
    let color: Color
    
    var discountPercentage: Int? {
        guard originalPrice > price else { return nil }
        return Int(((Double(originalPrice - price) / Double(originalPrice)) * 100).rounded())
    }
    
    var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "id_ID")
        return "Rp\(formatter.string(from: NSNumber(value: price)) ?? "\(price)")"
    }
}

struct BalanceView: View {
    @State private var selectedPackage: CreditPackage?
    @State private var showingPurchase = false
    @StateObject var viewModel: BalanceViewModel = BalanceViewModel() // Use new name
    
    let creditPackages = [
        CreditPackage(
            name: "Starter",
            unit: 10,
            credits: 10,
            price: 10000,
            originalPrice: 10000,
            badge: nil,
            description: "Perfect for trying out",
            color: .green
        ),
        CreditPackage(
            name: "Popular",
            unit: 25,
            credits: 25,
            price: 23000,
            originalPrice: 25000,
            badge: "POPULAR",
            description: "Most chosen package",
            color: .blue
        ),
        CreditPackage(
            name: "Value",
            unit: 50,
            credits: 50,
            price: 40000,
            originalPrice: 50000,
            badge: "BEST VALUE",
            description: "Great for regular users",
            color: .purple
        ),
        CreditPackage(
            name: "Premium",
            unit: 100,
            credits: 100,
            price: 70000,
            originalPrice: 100000,
            badge: "PREMIUM",
            description: "For power users",
            color: .orange
        )
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Balance Display Section
                VStack(spacing: 16) {
                    HStack(alignment: .center, spacing: 8) {
                        Image(systemName: "dollarsign.circle.fill")
                            .foregroundStyle(.yellow.gradient)
                            .font(.system(size: 50, weight: .medium))
                            .shadow(color: .yellow.opacity(0.3), radius: 8, x: 0, y: 4)
                        
                        Text("\(viewModel.totalCredits)")
                            .font(.system(size: 52, weight: .bold, design: .rounded))
                            .foregroundStyle(.yellow.gradient)
                            .shadow(color: .yellow.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    
                    Text("Tap to refresh")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 20)
                .padding(.horizontal, 32)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(.yellow.opacity(0.3), lineWidth: 1)
                        )
                ).onTapGesture {
                    Task {
                        await viewModel.getBalance()
                    }
                }
                
                // Credit Plans Section
                VStack(spacing: 16) {
                    Text("Choose Your Plan")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 8),
                        GridItem(.flexible(), spacing: 8)
                    ], spacing: 12) {
                        ForEach(creditPackages, id: \.id) { package in
                            CreditPackageCard(
                                package: package,
                                isSelected: selectedPackage?.id == package.id
                            ) {
                                selectedPackage = package
                                showingPurchase = true
                            }
                        }
                    }
                    // Description Section
                    VStack(spacing: 12) {
                        Text("How Credits Work")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text("Use credits to split bills with AI-powered processing. Each bill split costs 1 credit. Credits help cover the computational costs of our smart splitting algorithms.")
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.horizontal, 8)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 32)
        }
        .background(
            LinearGradient(
                colors: [
                    Color(.systemBackground),
                    Color(.systemGray6).opacity(0.3)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .sheet(isPresented: $showingPurchase) {
            Group {
                if let package = selectedPackage,
                   let deviceId = UIDevice.current.identifierForVendor?.uuidString {
                    
                    let payload = [
                        "unit": "\(package.unit)",
                        "description": "\(deviceId)",
                        "disableDescription": "true"
                    ]
                    
                    let urlComponents = {
                        var components = URLComponents(string: "https://arxist.id/splitbill/tip")
                        components?.queryItems = payload.map { URLQueryItem(name: $0.key, value: $0.value) }
                        return components
                    }()
                    
                    if let url = urlComponents?.url {
                        SafariView(url: url)
                    } else {
                        Text("Error creating URL")
                    }
                } else {
                    Text("Package or Device ID not available")
                }
            }
        }
        .onAppear {
            Task {
                await viewModel.getBalance()
            }
        }
    }
    func objectToURLEncoded(_ object: [String: Any]) -> String {
        var components = URLComponents()
        components.queryItems = object.compactMap { key, value in
            URLQueryItem(name: key, value: String(describing: value))
        }
        return components.percentEncodedQuery ?? ""
    }
}

struct CreditPackageCard: View {
    let package: CreditPackage
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                // Badge
                if let badge = package.badge {
                    Text(badge)
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(package.color.gradient)
                        .clipShape(Capsule())
                }
                
                // Credits
                VStack(spacing: 4) {
                    Text("\(package.credits)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(package.color.gradient)
                    
                    Text("Credits")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
                
                // Price
                VStack(spacing: 2) {
                    Text(package.formattedPrice)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    if let discount = package.discountPercentage {
                        Text("\(discount)% OFF")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(package.color)
                    }
                }
                
                // Description
                Text(package.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isSelected ? package.color : Color.clear,
                                lineWidth: isSelected ? 2 : 0
                            )
                    )
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
#Preview {
    BalanceView()
        .preferredColorScheme(.light)
}
