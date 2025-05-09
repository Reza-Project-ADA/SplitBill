//
//  SplitBillApp.swift
//  SplitBill
//
//  Created by Reza Juliandri on 09/05/25.
//

import SwiftUI
import SwiftData

@main
struct SplitBillApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            SDBillSplitRecord.self, SDParticipantShare.self, SDAssignedItemEntry.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
