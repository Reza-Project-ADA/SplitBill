//
//  ReceiptItem.swift
//  SplitBill
//
//  Created by Reza Juliandri on 09/05/25.
//
import Foundation

struct ReceiptItem: Codable {
    var id: UUID
    var name: String
    let quantity: Int
    let price: Int // Assuming price is in cents or smallest currency unit if no decimals
    var pricePerUnit: Double { Double(price) / Double(quantity) }
    
    enum CodingKeys: String, CodingKey {
        case id, name, quantity, price
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Try decoding UUID, if fails, generate a new one
        if let rawID = try? container.decode(String.self, forKey: .id),
           let parsedUUID = UUID(uuidString: rawID) {
            self.id = parsedUUID
        } else {
            self.id = UUID()
        }
        
        self.name = try container.decode(String.self, forKey: .name)
        self.quantity = try container.decode(Int.self, forKey: .quantity)
        self.price = try container.decode(Int.self, forKey: .price)
    }
    init(name: String, quantity: Int, price: Int){
        self.id = UUID()
        self.name = name
        self.quantity = quantity
        self.price = price
    }
}
