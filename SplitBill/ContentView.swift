//
//  ContentView.swift
//  SplitBill
//
//  Created by Reza Juliandri on 09/05/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
        }
        .tint(Color.primary)
    }
}

#Preview {
    ContentView()
}
