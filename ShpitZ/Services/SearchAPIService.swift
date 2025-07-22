//
//  SearchAPIService.swift
//  ByAbroad
//
//  Created on 22/07/2025.
//

import Foundation
import SwiftData

// MARK: - SearchAPI Response Models
struct SearchAPIResponse: Codable {
    let searchMetadata: SearchMetadata?
    let searchParameters: SearchParameters?
    let searchInformation: SearchInformation?
    let shoppingResults: [ShoppingResult]?
    let organicResults: [OrganicResult]?
    let knowledgeGraph: KnowledgeGraph?
    
    enum CodingKeys: String, CodingKey {
        case searchMetadata = "search_metadata"
        case searchParameters = "search_parameters"
        case searchInformation = "search_information"
        case shoppingResults = "shopping_results"
        case organicResults = "organic_results"
        case knowledgeGraph = "knowledge_graph"
    }
}

struct SearchMetadata: Codable {
    let id: String
    let status: String
    let requestTimeTaken: Double?
    
    enum CodingKeys: String, CodingKey {
        case id, status
        case requestTimeTaken = "request_time_taken"
    }
}

struct SearchParameters: Codable {
    let engine: String
    let q: String
    let location: String?
    let hl: String?
    let gl: String?
}

struct SearchInformation: Codable {
    let queryDisplayed: String?
    let totalResults: Int?
    
    enum CodingKeys: String, CodingKey {
        case queryDisplayed = "query_displayed"
        case totalResults = "total_results"
    }
}

struct ShoppingResult: Codable {
    let position: Int?
    let title: String
    let link: String?
    let productLink: String?
    let productId: String?
    let serpApiProductApiLink: String?
    let source: String?
    let price: String?
    let extractedPrice: Double?
    let rating: Double?
    let ratingCount: Int?
    let delivery: String?
    let thumbnail: String?
    
    enum CodingKeys: String, CodingKey {
        case position, title, link, source, price, rating, delivery, thumbnail
        case productLink = "product_link"
        case productId = "product_id" 
        case serpApiProductApiLink = "serpapi_product_api_link"
        case extractedPrice = "extracted_price"
        case ratingCount = "rating_count"
    }
}

struct OrganicResult: Codable {
    let position: Int?
    let title: String
    let link: String
    let snippet: String?
    let displayedLink: String?
    
    enum CodingKeys: String, CodingKey {
        case position, title, link, snippet
        case displayedLink = "displayed_link"
    }
}

struct KnowledgeGraph: Codable {
    let title: String?
    let type: String?
    let description: String?
}

// MARK: - SearchAPI Service
@MainActor
class SearchAPIService: ObservableObject {
    static let shared = SearchAPIService()
    private let networkManager = NetworkManager.shared
    
    @Published var isSearching = false
    @Published var lastSearchResults: SearchAPIResponse?
    @Published var searchHistory: [String] = []
    
    private init() {}
    
    // MARK: - Main Search Method
    /// Searches for products across multiple platforms using SearchAPI
    func searchProducts(query: String, engine: String = "google_shopping", location: String = "Israel") async throws -> [Product] {
        isSearching = true
        defer { isSearching = false }
        
        // Add to search history
        if !searchHistory.contains(query) {
            searchHistory.insert(query, at: 0)
            if searchHistory.count > 10 {
                searchHistory.removeLast()
            }
        }
        
        let response = try await performSearchAPIRequest(
            query: query,
            engine: engine,
            location: location
        )
        
        lastSearchResults = response
        
        // Convert SearchAPI results to our Product model
        return convertToProducts(from: response, originalQuery: query)
    }
    
    // MARK: - Platform-Specific Searches
    /// Search Google Shopping for products
    func searchGoogleShopping(query: String) async throws -> [Product] {
        return try await searchProducts(query: query, engine: "google_shopping")
    }
    
    /// Search Amazon for products
    func searchAmazon(query: String) async throws -> [Product] {
        return try await searchProducts(query: query, engine: "amazon")
    }
    
    /// Search eBay for products
    func searchEbay(query: String) async throws -> [Product] {
        return try await searchProducts(query: query, engine: "ebay")
    }
    
    /// Search Walmart for products
    func searchWalmart(query: String) async throws -> [Product] {
        return try await searchProducts(query: query, engine: "walmart")
    }
    
    // MARK: - Private Methods
    private func performSearchAPIRequest(query: String, engine: String, location: String) async throws -> SearchAPIResponse {
        var urlComponents = URLComponents(string: APIConfiguration.SearchAPI.baseURL)!
        
        urlComponents.queryItems = [
            URLQueryItem(name: "engine", value: engine),
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "location", value: location),
            URLQueryItem(name: "hl", value: "en"),
            URLQueryItem(name: "gl", value: "il"), // Israel country code
            URLQueryItem(name: "api_key", value: APIConfiguration.SearchAPI.apiKey)
        ]
        
        guard let url = urlComponents.url else {
            throw NetworkError.invalidURL
        }
        
        print("🔍 SearchAPI Request: \(url.absoluteString)")
        
        let response: SearchAPIResponse = try await networkManager.request(
            url: url.absoluteString,
            method: .GET,
            responseType: SearchAPIResponse.self
        )
        
        print("✅ SearchAPI Response: \(response.searchMetadata?.status ?? "Unknown")")
        
        return response
    }
    
    private func convertToProducts(from response: SearchAPIResponse, originalQuery: String) -> [Product] {
        var products: [Product] = []
        
        // Convert shopping results
        if let shoppingResults = response.shoppingResults {
            for result in shoppingResults {
                let product = Product(
                    name: result.title,
                    price: result.extractedPrice ?? 0.0,
                    currency: "USD", // Default, can be enhanced later
                    productURL: result.productLink ?? result.link ?? "",
                    storeName: result.source ?? "Unknown Store",
                    storeID: determineStoreID(from: result.source ?? ""),
                    category: categorizeProduct(name: result.title, query: originalQuery),
                    imageURL: result.thumbnail
                )
                
                // Set additional properties if available
                if let rating = result.rating {
                    // Could add rating to Product model later
                }
                
                products.append(product)
            }
        }
        
        // Convert organic results if no shopping results found
        if products.isEmpty, let organicResults = response.organicResults {
            for result in organicResults.prefix(5) { // Limit to first 5 organic results
                let product = Product(
                    name: result.title,
                    price: 0.0, // Price needs to be scraped from the page
                    currency: "USD",
                    productURL: result.link,
                    storeName: extractStoreName(from: result.link),
                    storeID: determineStoreID(from: extractStoreName(from: result.link)),
                    category: categorizeProduct(name: result.title, query: originalQuery),
                    imageURL: nil
                )
                products.append(product)
            }
        }
        
        return products
    }
    
    private func determineStoreID(from source: String) -> String {
        let lowercasedSource = source.lowercased()
        
        if lowercasedSource.contains("amazon") { return "amazon" }
        if lowercasedSource.contains("ebay") { return "ebay" }
        if lowercasedSource.contains("walmart") { return "walmart" }
        if lowercasedSource.contains("target") { return "target" }
        if lowercasedSource.contains("bestbuy") || lowercasedSource.contains("best buy") { return "bestbuy" }
        if lowercasedSource.contains("zara") { return "zara" }
        if lowercasedSource.contains("asos") { return "asos" }
        if lowercasedSource.contains("h&m") || lowercasedSource.contains("hm") { return "hm" }
        
        return "unknown"
    }
    
    private func extractStoreName(from url: String) -> String {
        guard let urlComponents = URLComponents(string: url),
              let host = urlComponents.host else {
            return "Unknown Store"
        }
        
        // Remove www. prefix and extract main domain
        let domain = host.replacingOccurrences(of: "www.", with: "")
        let components = domain.components(separatedBy: ".")
        
        if components.count > 0 {
            return components[0].capitalized
        }
        
        return "Unknown Store"
    }
    
    private func categorizeProduct(name: String, query: String) -> String {
        let lowercasedName = name.lowercased()
        let lowercasedQuery = query.lowercased()
        
        // Electronics keywords
        let electronicsKeywords = ["iphone", "samsung", "laptop", "computer", "headphones", "speaker", "tv", "tablet", "smartwatch", "camera", "gaming", "console", "monitor"]
        
        // Clothing keywords  
        let clothingKeywords = ["shirt", "dress", "pants", "jeans", "jacket", "shoes", "sneakers", "boots", "hat", "bag", "handbag", "clothing", "apparel"]
        
        // Home keywords
        let homeKeywords = ["furniture", "chair", "table", "bed", "sofa", "lamp", "kitchen", "bathroom", "home", "decor"]
        
        // Beauty keywords
        let beautyKeywords = ["makeup", "skincare", "perfume", "cosmetics", "beauty", "cream", "serum", "lipstick"]
        
        // Sports keywords
        let sportsKeywords = ["fitness", "gym", "sports", "exercise", "running", "workout", "athletic"]
        
        let allText = "\(lowercasedName) \(lowercasedQuery)"
        
        for keyword in electronicsKeywords {
            if allText.contains(keyword) { return Product.Category.electronics.rawValue }
        }
        
        for keyword in clothingKeywords {
            if allText.contains(keyword) { return Product.Category.clothing.rawValue }
        }
        
        for keyword in homeKeywords {
            if allText.contains(keyword) { return Product.Category.home.rawValue }
        }
        
        for keyword in beautyKeywords {
            if allText.contains(keyword) { return Product.Category.beauty.rawValue }
        }
        
        for keyword in sportsKeywords {
            if allText.contains(keyword) { return Product.Category.sports.rawValue }
        }
        
        return Product.Category.other.rawValue
    }
}

// MARK: - Search Suggestions
extension SearchAPIService {
    /// Get search suggestions based on search history and popular queries
    func getSearchSuggestions() -> [String] {
        var suggestions = searchHistory
        
        // Add popular suggestions if history is empty
        if suggestions.isEmpty {
            suggestions = [
                "iPhone 16",
                "MacBook Pro",
                "Nike Air Max",
                "Samsung TV",
                "Sony Headphones",
                "Zara Jacket",
                "ASOS Dress",
                "Kitchen Mixer",
                "Gaming Chair",
                "Smart Watch"
            ]
        }
        
        return Array(suggestions.prefix(8))
    }
    
    /// Clear search history
    func clearSearchHistory() {
        searchHistory.removeAll()
    }
} 