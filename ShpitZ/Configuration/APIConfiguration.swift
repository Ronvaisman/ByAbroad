//
//  APIConfiguration.swift
//  ByAbroad
//
//  Created on 22/07/2025.
//

import Foundation

/// Secure API configuration management
/// Reads credentials from environment variables or Info.plist
/// Never hardcode API keys in source code!
struct APIConfiguration {
    
    // MARK: - SerpApi (Multi-Platform Search)
    struct SerpApi {
        /// API Key for SerpApi - supports Google Shopping, Amazon, eBay, Walmart, etc.
        static var apiKey: String {
            return ProcessInfo.processInfo.environment["SERPAPI_API_KEY"] ??
                   Bundle.main.object(forInfoDictionaryKey: "SERPAPI_API_KEY") as? String ??
                   "" // Empty for development
        }
        
        /// SerpApi base URL
        static var baseURL: String { return "https://serpapi.com/search" }
        
        /// Supported search engines
        enum Engine: String, CaseIterable {
            case googleShopping = "google_shopping"
            case amazon = "amazon"
            case ebay = "ebay"
            case walmart = "walmart"
            case google = "google"
            case bingShopping = "bing_shopping"
            case yahooShopping = "yahoo_shopping"
        }
        
        /// Check if API key is configured
        static var isConfigured: Bool {
            return !apiKey.isEmpty
        }
    }
    
    // MARK: - Rainforest API (Amazon Specialist)
    struct RainforestAPI {
        /// API Key for Rainforest API - specialized Amazon data
        static var apiKey: String {
            return ProcessInfo.processInfo.environment["RAINFOREST_API_KEY"] ??
                   Bundle.main.object(forInfoDictionaryKey: "RAINFOREST_API_KEY") as? String ??
                   "" // Empty for development
        }
        
        /// Rainforest API base URL
        static var baseURL: String { return "https://api.rainforestapi.com/request" }
        
        /// Supported request types
        enum RequestType: String, CaseIterable {
            case search = "search"
            case product = "product"
            case offers = "offers"
            case reviews = "reviews"
            case category = "category"
        }
        
        /// Check if API key is configured
        static var isConfigured: Bool {
            return !apiKey.isEmpty
        }
    }
    
    // MARK: - Exchange Rate API
    struct ExchangeRate {
        /// API Key for exchange rate service
        static var apiKey: String {
            return ProcessInfo.processInfo.environment["EXCHANGE_RATE_API_KEY"] ??
                   Bundle.main.object(forInfoDictionaryKey: "EXCHANGE_RATE_API_KEY") as? String ??
                   "" // Empty for development
        }
        
        /// Exchange rate API base URL (using exchangerate-api.com)
        static var baseURL: String { return "https://v6.exchangerate-api.com/v6" }
        
        /// Check if API key is configured
        static var isConfigured: Bool {
            return !apiKey.isEmpty
        }
    }
    
    // MARK: - Configuration Status
    
    /// Print configuration status (development only)
    static func printConfigurationStatus() {
        #if DEBUG
        print("=== API Configuration Status ===")
        print("📦 SerpApi: \(SerpApi.isConfigured ? "✅ Configured" : "❌ Missing API Key")")
        print("🌧️ Rainforest API: \(RainforestAPI.isConfigured ? "✅ Configured" : "❌ Missing API Key")")
        print("💱 Exchange Rate API: \(ExchangeRate.isConfigured ? "✅ Configured" : "❌ Missing API Key")")
        print("===============================")
        #endif
    }
    
    /// Check if any API is configured
    static var hasAnyAPIConfigured: Bool {
        return SerpApi.isConfigured || RainforestAPI.isConfigured
    }
    
    /// Get configuration summary for debugging
    static var configurationSummary: [String: Bool] {
        return [
            "SerpApi": SerpApi.isConfigured,
            "RainforestAPI": RainforestAPI.isConfigured,
            "ExchangeRate": ExchangeRate.isConfigured
        ]
    }
} 