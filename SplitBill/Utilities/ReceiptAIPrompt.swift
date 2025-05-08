//
//  ReceiptAIPrompt.swift
//  SplitBill
//
//  Created by Reza Juliandri on 09/05/25.
//
import Foundation

struct ReceiptAIPrompt {
    static func createReceiptExtractionSystemPrompt() -> String {
        // Get an example JSON string from our Codable structs
        // This helps the AI understand the exact desired structure.
        let exampleStore = ReceiptStore(name: "EXAMPLE STORE NAME", address: "123 Example St, City")
        let exampleItem = ReceiptItem(name: "EXAMPLE ITEM", quantity: 1, price: 10000)
        let examplePayment = ReceiptPayment(cash: 50000, change: 5000, status: "Lunas")
        let exampleTransaction = ReceiptTransaction(date: "YYYY-MM-DD",
                                                    time: "HH:MM",
                                                    cashier: "Cashier Name",
                                                    order_number: "12345",
                                                    items: [exampleItem],
                                                    subtotal: 10000,
                                                    tax: 1000,
                                                    total: 11000,
                                                    payment: examplePayment)
        let exampleOutput = ReceiptOutput(store: exampleStore, transaction: exampleTransaction)
        
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .prettyPrinted
        var exampleJsonString = "{ \"error\": \"Could not generate example JSON\" }"
        if let jsonData = try? jsonEncoder.encode(exampleOutput),
           let jsonStr = String(data: jsonData, encoding: .utf8) {
            exampleJsonString = jsonStr
        }

        return """
        You are an intelligent assistant that extracts information from receipt images and accompanying text.
        Your task is to populate a JSON object based on the provided image and text.
        The output MUST be a single, valid JSON object adhering to the following structure and nothing else.
        Do not include any explanatory text before or after the JSON.

        JSON Structure:
        \(exampleJsonString)

        Key considerations:
        - "date" should be in "YYYY-MM-DD" format.
        - "time" should be in "HH:MM" (24-hour) format.
        - "price", "subtotal", "tax", "total", "cash", "change" should be integers (e.g., representing cents or smallest currency unit).
        - If tax is not explicitly mentioned but a subtotal and total are, calculate it. If only subtotal, assume a 10% tax rate if not otherwise determinable.
        - Ensure all fields in the provided JSON structure are populated. If information is missing from the receipt for a specific field, use a sensible placeholder like "N/A", 0, or an empty array [] for items if appropriate, but try your best to infer or calculate. For numerical fields, 0 is preferred over "N/A".
        - The "order_number" is important.
        - For "items", list each item with its "name", "quantity", and "price". If there are two prices, the one on the left is the unit price, and the one on the right is the total after multiplying by the quantity. If there is only one price, it represents the total price after quantity multiplication.        
        - The "status" in "payment" is usually "Lunas" (Paid) or similar.
        - If there is no ID but the sample has one, please generate a UUID yourself.
        """
    }

    static func createUserPromptForReceipt() -> String {
        return "Please extract the transaction details from the provided receipt image and structure it as JSON according to the system instructions."
    }
}
