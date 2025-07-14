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
                    Image(systemName: "receipt")
                    Text("Split Receipt")
                }
            
            SplitSessionView()
                .tabItem {
                    Image(systemName: "arrow.left.arrow.right")
                    Text("Split Session")
                }
            
            FriendsView()
                .tabItem {
                    Image(systemName: "person.3.fill")
                    Text("Friends")
                }
        }
        .tint(Color.primary)
    }
}

#Preview {
    ContentView()
}
