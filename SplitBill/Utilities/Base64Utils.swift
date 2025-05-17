//
//  Base64Utils.swift
//  SplitBill
//
//  Created by Reza Juliandri on 18/05/25.
//
extension String {
    func asPNGBaseURLString() -> String {
        return "data:image/png;base64,\(self)"
    }
}
