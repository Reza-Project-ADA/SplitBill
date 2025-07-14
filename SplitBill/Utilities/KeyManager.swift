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
            "api_base_url": "https://splitbill.laravel.cloud" as NSObject,
            "api_debug_base_url": "https://splitbill.laravel.cloud" as NSObject
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
        // Get the base URL from Remote Config based on build configuration
        #if DEBUG
            let configKey = "api_debug_base_url"
            let defaultURL = "https://dev.split-bill.example.com"
        #else
            let configKey = "api_base_url"
            let defaultURL = "https://split-bill.example.com"
        #endif

        let urlString = remoteConfig.configValue(forKey: configKey).stringValue

        // Fallback to default URL if the string is empty or invalid
        if let url = URL(string: urlString) {
            return url
        }

        return URL(string: defaultURL)!
    }
}
