import Foundation
import UIKit

/// Configuration for the API client
struct APIConfig {
    /// Base URL for the API
    static var baseURL: URL {
        return KeyManager.shared.apiBaseURL
    }

    /// Device ID for identifying the device
    static var deviceID: String {
        // Get the device ID from UserDefaults or generate a new one if it doesn't exist
        if let deviceID = UserDefaults.standard.string(forKey: "device_id") {
            return deviceID
        } else {
            let newDeviceID = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
            UserDefaults.standard.set(newDeviceID, forKey: "device_id")
            return newDeviceID
        }
    }

    /// App version for version checking
    static var appVersion: String {
        // Get the app version from the bundle
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }

    /// Create a new API client with the default configuration
    static func createClient() -> APIClient {
        return APIClient(baseURL: baseURL, deviceID: deviceID, appVersion: appVersion)
    }
}
