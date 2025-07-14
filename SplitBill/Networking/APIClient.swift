import Foundation

/// API Client for communicating with the Split Bill backend
class APIClient {
    // MARK: - Properties
    
    /// Base URL for the API
    private let baseURL: URL
    
    /// URLSession for network requests
    private let session: URLSession
    
    /// Device ID for identifying the device
    private let deviceID: String
    
    /// App version for version checking
    private let appVersion: String
    
    // MARK: - Initialization
    
    /// Initialize the API client
    /// - Parameters:
    ///   - baseURL: Base URL for the API
    ///   - deviceID: Device ID for identifying the device
    ///   - appVersion: App version for version checking
    init(baseURL: URL, deviceID: String, appVersion: String) {
        self.baseURL = baseURL
        self.deviceID = deviceID
        self.appVersion = appVersion
        print(baseURL)
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30.0
        self.session = URLSession(configuration: configuration)
    }
    
    func getBalance() async throws -> (freeCredits: Int, paidCredits: Int) {
        var urlComponents = URLComponents(url: baseURL.appendingPathComponent("api/balance"), resolvingAgainstBaseURL: false)!
        urlComponents.queryItems = [URLQueryItem(name: "deviceId", value: deviceID)]
        let url = urlComponents.url!
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let (data, response) = try await session.data(for: request)
        // Check response status
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        // Handle HTTP errors
        switch httpResponse.statusCode {
        case 200:
            // Parse response
            let jsonResponse = try JSONDecoder().decode(BalanceResponse.self, from: data)
            
            // Return receipt data and credit information
            return (
                freeCredits: jsonResponse.free_credits,
                paidCredits: jsonResponse.paid_credits
            )
            
        case 402:
            // Payment required (no credits)
            let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
            throw APIError.noCredits(message: errorResponse.message)
            
        case 422:
            // Validation error
            do {
                // First try to decode as ValidationErrorResponse (Laravel's validation error format)
                let validationErrorResponse = try JSONDecoder().decode(ValidationErrorResponse.self, from: data)
                
                // Format validation errors into a user-friendly message
                var errorMessage = validationErrorResponse.message + "\n"
                
                // Add each field error
                for (_, errors) in validationErrorResponse.errors {
                    for error in errors {
                        errorMessage += "• \(error)\n"
                    }
                }
                
                throw APIError.validationError(message: errorMessage)
            } catch DecodingError.keyNotFound(let key, _) {
                // If decoding fails because of a missing key, try the simpler ErrorResponse format
                print("Validation error response missing key: \(key.stringValue)")
                let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                throw APIError.validationError(message: errorResponse.message)
            } catch let error as APIError {
                // Re-throw APIError
                throw error
            } catch {
                // If all decoding attempts fail, create a generic error message
                print("Failed to decode validation error: \(error)")
                throw APIError.validationError(message: "Validation failed. Please check your input and try again.")
            }
            
        default:
            // Other errors
            let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data)
            throw APIError.httpError(statusCode: httpResponse.statusCode, message: errorResponse?.message)
        }
    }
    
    // MARK: - API Methods
    
    /// Scan a receipt image and extract information
    /// - Parameter imageData: Base64 encoded image data
    /// - Returns: Receipt output and credit information
    func scanReceipt(imageData: String) async throws -> (receipt: ReceiptOutput, freeCredits: Int, paidCredits: Int) {
        // Create URL for the receipt scan endpoint
        let url = baseURL.appendingPathComponent("api/receipt/scan")
        
        // Create request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        // Create request body
        let body: [String: Any] = [
            "image": imageData,
            "device_id": deviceID,
            "app_version": appVersion
        ]
        
        // Serialize request body
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        // Send request
        let (data, response) = try await session.data(for: request)
        
        if let json = try? JSONSerialization.jsonObject(with: data, options: []),
           let prettyData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
           let jsonString = String(data: prettyData, encoding: .utf8) {
            print(jsonString)
        }
        
        // Check response status
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        // Handle HTTP errors
        switch httpResponse.statusCode {
        case 200:
            // Parse response
            let jsonResponse = try JSONDecoder().decode(ReceiptScanResponse.self, from: data)
            
            // Check if the response was successful
            guard jsonResponse.success else {
                throw APIError.apiError(message: jsonResponse.message ?? "Unknown error")
            }
            
            // Return receipt data and credit information
            return (
                receipt: jsonResponse.data,
                freeCredits: jsonResponse.free_credits,
                paidCredits: jsonResponse.paid_credits
            )
            
        case 402:
            // Payment required (no credits)
            let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
            throw APIError.noCredits(message: errorResponse.message)
            
        case 422:
            // Validation error
            do {
                // First try to decode as ValidationErrorResponse (Laravel's validation error format)
                let validationErrorResponse = try JSONDecoder().decode(ValidationErrorResponse.self, from: data)
                
                // Format validation errors into a user-friendly message
                var errorMessage = validationErrorResponse.message + "\n"
                
                // Add each field error
                for (field, errors) in validationErrorResponse.errors {
                    for error in errors {
                        errorMessage += "• \(error)\n"
                    }
                }
                
                throw APIError.validationError(message: errorMessage)
            } catch DecodingError.keyNotFound(let key, _) {
                // If decoding fails because of a missing key, try the simpler ErrorResponse format
                print("Validation error response missing key: \(key.stringValue)")
                let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                throw APIError.validationError(message: errorResponse.message)
            } catch let error as APIError {
                // Re-throw APIError
                throw error
            } catch {
                // If all decoding attempts fail, create a generic error message
                print("Failed to decode validation error: \(error)")
                throw APIError.validationError(message: "Validation failed. Please check your input and try again.")
            }
            
        default:
            // Other errors
            let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data)
            throw APIError.httpError(statusCode: httpResponse.statusCode, message: errorResponse?.message)
        }
    }
}


struct BalanceResponse: Decodable {
    let free_credits: Int
    let paid_credits: Int
}
// MARK: - Response Models

/// Response from the receipt scan endpoint
struct ReceiptScanResponse: Decodable {
    let success: Bool
    let data: ReceiptOutput
    let free_credits: Int
    let paid_credits: Int
    let message: String?
}

/// Error response from the API
struct ErrorResponse: Decodable {
    let success: Bool
    let message: String
}

/// Validation error response from the API
struct ValidationErrorResponse: Decodable {
    let message: String
    let errors: [String: [String]]
}

// MARK: - Errors

/// Errors that can occur when using the API
enum APIError: Error {
    case invalidResponse
    case apiError(message: String)
    case noCredits(message: String)
    case validationError(message: String)
    case httpError(statusCode: Int, message: String?)
}

extension APIError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from the server"
        case .apiError(let message):
            return message
        case .noCredits(let message):
            return message
        case .validationError(let message):
            return message
        case .httpError(let statusCode, let message):
            return message ?? "HTTP error \(statusCode)"
        }
    }
}
