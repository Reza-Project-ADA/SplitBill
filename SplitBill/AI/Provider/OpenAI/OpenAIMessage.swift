//
//  OpenAIMessage.swift
//  SplitBill
//
//  Created by Reza Juliandri on 09/05/25.
//

struct OpenAIMessage: Encodable {
    let role: String // "system", "user", "assistant"
    let content: AnyContent

    // To handle both simple string content and array of content parts (for vision)
    enum AnyContent: Encodable {
        case string(String)
        case parts([OpenAIMessageContentPart])

        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .string(let text):
                try container.encode(text)
            case .parts(let partsArray):
                try container.encode(partsArray)
            }
        }
    }
}
