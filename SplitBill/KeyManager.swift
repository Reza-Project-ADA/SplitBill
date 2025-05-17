//
//  KeyManager.swift
//  SplitBill
//
//  Created by Reza Juliandri on 09/05/25.
//
import Foundation
import FirebaseRemoteConfig

class KeyManager {
    static let shared = KeyManager()
    private let remoteConfig: RemoteConfig

    private init() {
        // Initialize Remote Config
        remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        // Set minimum fetch interval to 0 for development
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings

        // Set default values
        remoteConfig.setDefaults([
            "api_base_url": "https://split-bill.example.com" as NSObject
        ])

        // Fetch and activate remote config values
        fetchRemoteConfig()
    }

    private func fetchRemoteConfig() {
        remoteConfig.fetch { [weak self] status, error in
            if status == .success {
                print("Remote config fetched successfully")
                self?.remoteConfig.activate { _, _ in
                    // Remote config values activated
                }
            } else {
                print("Remote config fetch failed with error: \(error?.localizedDescription ?? "unknown error")")
            }
        }
    }

    var apiBaseURL: URL {
        // Get the base URL from Remote Config
        let urlString = remoteConfig.configValue(forKey: "api_base_url").stringValue

        // Fallback to default URL if the string is empty or invalid
        if let url = URL(string: urlString) {
            return url
        }

        return URL(string: "https://split-bill.example.com")!
    }
}
