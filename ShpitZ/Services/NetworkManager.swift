//
//  NetworkManager.swift
//  ByAbroad
//
//  Created on 22/07/2025.
//

import Foundation
import Combine

// MARK: - Network Error Types
enum NetworkError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case serverError(Int)
    case networkUnavailable
    case timeout
    case rateLimited
    case unauthorized
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError:
            return "Failed to decode response"
        case .serverError(let code):
            return "Server error: \(code)"
        case .networkUnavailable:
            return "Network unavailable"
        case .timeout:
            return "Request timed out"
        case .rateLimited:
            return "Rate limit exceeded"
        case .unauthorized:
            return "Unauthorized access"
        }
    }
}

// MARK: - HTTP Method
enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
}

// MARK: - Network Manager
@MainActor
class NetworkManager: ObservableObject {
    static let shared = NetworkManager()
    
    private let session: URLSession
    private let decoder: JSONDecoder
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: config)
        
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
    }
    
    // MARK: - Generic Request Method
    func request<T: Codable>(
        url: String,
        method: HTTPMethod = .GET,
        headers: [String: String] = [:],
        body: Data? = nil,
        responseType: T.Type
    ) async throws -> T {
        
        guard let requestURL = URL(string: url) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = method.rawValue
        request.httpBody = body
        
        // Set default headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("ByAbroad/1.0", forHTTPHeaderField: "User-Agent")
        
        // Add custom headers
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.serverError(0)
            }
            
            // Handle HTTP status codes
            switch httpResponse.statusCode {
            case 200...299:
                break
            case 401:
                throw NetworkError.unauthorized
            case 429:
                throw NetworkError.rateLimited
            case 400...499:
                throw NetworkError.serverError(httpResponse.statusCode)
            case 500...599:
                throw NetworkError.serverError(httpResponse.statusCode)
            default:
                throw NetworkError.serverError(httpResponse.statusCode)
            }
            
            guard !data.isEmpty else {
                throw NetworkError.noData
            }
            
            do {
                let result = try decoder.decode(responseType, from: data)
                return result
            } catch {
                print("Decoding error: \(error)")
                throw NetworkError.decodingError
            }
            
        } catch {
            if error is NetworkError {
                throw error
            } else if (error as NSError).code == NSURLErrorNotConnectedToInternet {
                throw NetworkError.networkUnavailable
            } else if (error as NSError).code == NSURLErrorTimedOut {
                throw NetworkError.timeout
            } else {
                throw NetworkError.serverError(0)
            }
        }
    }
    
    // MARK: - Image Download
    func downloadImage(from urlString: String) async throws -> Data {
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NetworkError.serverError(0)
        }
        
        return data
    }
    
    // MARK: - Web Scraping Support
    func scrapeWebpage(url: String) async throws -> String {
        guard let requestURL = URL(string: url) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: requestURL)
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15", forHTTPHeaderField: "User-Agent")
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NetworkError.serverError(0)
        }
        
        guard let html = String(data: data, encoding: .utf8) else {
            throw NetworkError.decodingError
        }
        
        return html
    }
}

// MARK: - Network Manager Extensions for Specific APIs
extension NetworkManager {
    
    // Currency Exchange Rate
    func fetchExchangeRate(from: String, to: String) async throws -> Double {
        // Using a free exchange rate API (example: exchangerate-api.com)
        let url = "https://api.exchangerate-api.com/v4/latest/\(from)"
        
        struct ExchangeResponse: Codable {
            let rates: [String: Double]
        }
        
        let response: ExchangeResponse = try await request(
            url: url,
            responseType: ExchangeResponse.self
        )
        
        guard let rate = response.rates[to] else {
            throw NetworkError.noData
        }
        
        return rate
    }
} 