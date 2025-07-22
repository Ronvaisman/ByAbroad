//
//  ProductSearchService.swift
//  ByAbroad
//
//  Created on 22/07/2025.
//

import Foundation
import SwiftData

// MARK: - Search Result
struct SearchResult {
    let products: [Product]
    let totalResults: Int
    let searchQuery: String
    let searchDate: Date
}

// MARK: - Product Search Service
@MainActor
class ProductSearchService: ObservableObject {
    
    static let shared = ProductSearchService()
    private let networkManager = NetworkManager.shared
    
    @Published var isSearching = false
    @Published var lastSearchResults: SearchResult?
    @Published var searchHistory: [String] = []
    
    private init() {}
    
    // MARK: - Multi-Store Search
    func searchProducts(query: String, category: String? = nil) async throws -> SearchResult {
        isSearching = true
        defer { isSearching = false }
        
        // Add to search history
        if !searchHistory.contains(query) {
            searchHistory.insert(query, at: 0)
            searchHistory = Array(searchHistory.prefix(10)) // Keep last 10 searches
        }
        
        var allProducts: [Product] = []
        
        // For now, we'll use mock data since we don't have API keys yet
        // This will be replaced with actual API calls when credentials are obtained
        
        let mockProducts = await generateMockSearchResults(query: query, category: category)
        allProducts.append(contentsOf: mockProducts)
        
        let result = SearchResult(
            products: allProducts,
            totalResults: allProducts.count,
            searchQuery: query,
            searchDate: Date()
        )
        
        lastSearchResults = result
        return result
    }
    
    // MARK: - Store-Specific Search Methods
    
    // Amazon Search (to be implemented when API key is available)
    private func searchAmazon(query: String, category: String?) async throws -> [Product] {
        // TODO: Implement Amazon Product Advertising API
        // This will require Amazon Associates account and API credentials
        
        // For now, return empty array
        return []
    }
    
    // eBay Search (to be implemented when API key is available)
    private func searchEbay(query: String, category: String?) async throws -> [Product] {
        // TODO: Implement eBay Finding API
        // This will require eBay Developer account and API credentials
        
        // For now, return empty array
        return []
    }
    
    // Best Buy Search (to be implemented when API key is available)
    private func searchBestBuy(query: String, category: String?) async throws -> [Product] {
        // TODO: Implement Best Buy API
        // This will require Best Buy Developer account and API credentials
        
        // For now, return empty array
        return []
    }
    
    // MARK: - Mock Data Generation (for development)
    private func generateMockSearchResults(query: String, category: String?) async -> [Product] {
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        let mockProducts = [
            Product(
                name: "iPhone 15 Pro",
                price: 999.00,
                currency: "USD",
                productURL: "https://amazon.com/iphone-15-pro",
                storeName: "Amazon",
                storeID: "amazon_us",
                category: "Electronics",
                imageURL: "https://example.com/iphone.jpg",
                localTax: 79.92,
                weight: 0.2
            ),
            Product(
                name: "Samsung Galaxy S24",
                price: 899.00,
                currency: "USD",
                productURL: "https://bestbuy.com/samsung-galaxy-s24",
                storeName: "Best Buy",
                storeID: "bestbuy_us",
                category: "Electronics",
                imageURL: "https://example.com/galaxy.jpg",
                localTax: 71.92,
                weight: 0.18
            ),
            Product(
                name: "MacBook Air M3",
                price: 1299.00,
                currency: "USD",
                productURL: "https://amazon.com/macbook-air-m3",
                storeName: "Amazon",
                storeID: "amazon_us",
                category: "Electronics",
                imageURL: "https://example.com/macbook.jpg",
                localTax: 103.92,
                weight: 1.2
            )
        ]
        
        // Filter by query (simple contains check)
        return mockProducts.filter { product in
            product.name.localizedCaseInsensitiveContains(query) ||
            query.localizedCaseInsensitiveContains(product.name.components(separatedBy: " ").first ?? "")
        }
    }
    
    // MARK: - Search Suggestions
    func getSearchSuggestions(for text: String) -> [String] {
        let commonProducts = [
            "iPhone", "Samsung Galaxy", "MacBook", "iPad", "AirPods",
            "Nike Shoes", "Adidas Sneakers", "Sony Headphones",
            "Canon Camera", "PlayStation", "Xbox", "Nintendo Switch",
            "Zara Jacket", "H&M Dress", "Levi's Jeans"
        ]
        
        if text.isEmpty {
            return Array(searchHistory.prefix(5))
        }
        
        return commonProducts.filter { $0.localizedCaseInsensitiveContains(text) }
    }
}

// MARK: - API Response Models (for future implementation)

// Amazon API Response Model
struct AmazonSearchResponse: Codable {
    let searchResult: AmazonSearchResult
}

struct AmazonSearchResult: Codable {
    let totalResultCount: Int
    let searchURL: String
    let items: [AmazonItem]?
}

struct AmazonItem: Codable {
    let ASIN: String
    let itemInfo: AmazonItemInfo?
    let offers: AmazonOffers?
    let images: AmazonImages?
}

struct AmazonItemInfo: Codable {
    let title: AmazonTitle?
    let features: AmazonFeatures?
}

struct AmazonTitle: Codable {
    let displayValue: String
}

struct AmazonFeatures: Codable {
    let displayValues: [String]
}

struct AmazonOffers: Codable {
    let listings: [AmazonListing]?
}

struct AmazonListing: Codable {
    let price: AmazonPrice?
}

struct AmazonPrice: Codable {
    let amount: Double
    let currency: String
}

struct AmazonImages: Codable {
    let primary: AmazonImage?
}

struct AmazonImage: Codable {
    let large: AmazonImageSize?
}

struct AmazonImageSize: Codable {
    let URL: String
    let height: Int
    let width: Int
}

// eBay API Response Model
struct EbaySearchResponse: Codable {
    let findItemsByKeywordsResponse: [EbayFindResponse]
}

struct EbayFindResponse: Codable {
    let searchResult: [EbaySearchResult]
    let paginationOutput: [EbayPagination]
}

struct EbaySearchResult: Codable {
    let item: [EbayItem]
}

struct EbayItem: Codable {
    let itemId: [String]
    let title: [String]
    let sellingStatus: [EbaySellingStatus]
    let galleryURL: [String]?
    let viewItemURL: [String]
}

struct EbaySellingStatus: Codable {
    let currentPrice: [EbayPrice]
}

struct EbayPrice: Codable {
    let value: String
    let currencyId: String
}

struct EbayPagination: Codable {
    let totalEntries: [String]
} 