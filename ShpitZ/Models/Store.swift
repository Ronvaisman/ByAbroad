//
//  Store.swift
//  ByAbroad
//
//  Created on 22/07/2025.
//

import Foundation
import SwiftData

@Model
final class Store {
    var id: String
    var name: String
    var displayName: String
    var logoURL: String?
    var baseURL: String
    var countryCode: String
    var currency: String
    var hasAPI: Bool
    var hasWebScraper: Bool
    var isActive: Bool
    var salesTaxRate: Double // Local sales tax rate
    var supportedCategories: [String]
    var lastUpdated: Date
    
    init(
        id: String,
        name: String,
        displayName: String,
        baseURL: String,
        countryCode: String,
        currency: String,
        hasAPI: Bool = false,
        hasWebScraper: Bool = false,
        logoURL: String? = nil,
        salesTaxRate: Double = 0.0,
        supportedCategories: [String] = []
    ) {
        self.id = id
        self.name = name
        self.displayName = displayName
        self.logoURL = logoURL
        self.baseURL = baseURL
        self.countryCode = countryCode
        self.currency = currency
        self.hasAPI = hasAPI
        self.hasWebScraper = hasWebScraper
        self.isActive = true
        self.salesTaxRate = salesTaxRate
        self.supportedCategories = supportedCategories
        self.lastUpdated = Date()
    }
}

// MARK: - Predefined Stores
extension Store {
    static let amazon = Store(
        id: "amazon_us",
        name: "amazon",
        displayName: "Amazon",
        baseURL: "https://amazon.com",
        countryCode: "US",
        currency: "USD",
        hasAPI: true,
        salesTaxRate: 0.08, // Average US sales tax
        supportedCategories: ["Electronics", "Home", "Books", "Sports", "Beauty"]
    )
    
    static let ebay = Store(
        id: "ebay_global",
        name: "ebay",
        displayName: "eBay",
        baseURL: "https://ebay.com",
        countryCode: "US",
        currency: "USD",
        hasAPI: true,
        salesTaxRate: 0.08,
        supportedCategories: ["Electronics", "Clothing", "Home", "Sports"]
    )
    
    static let bestBuy = Store(
        id: "bestbuy_us",
        name: "bestbuy",
        displayName: "Best Buy",
        baseURL: "https://bestbuy.com",
        countryCode: "US",
        currency: "USD",
        hasAPI: true,
        salesTaxRate: 0.08,
        supportedCategories: ["Electronics"]
    )
    
    static let zara = Store(
        id: "zara_global",
        name: "zara",
        displayName: "Zara",
        baseURL: "https://zara.com",
        countryCode: "ES",
        currency: "EUR",
        hasWebScraper: true,
        salesTaxRate: 0.21, // EU VAT
        supportedCategories: ["Clothing"]
    )
    
    static let asos = Store(
        id: "asos_uk",
        name: "asos",
        displayName: "ASOS",
        baseURL: "https://asos.com",
        countryCode: "UK",
        currency: "GBP",
        hasWebScraper: true,
        salesTaxRate: 0.20, // UK VAT
        supportedCategories: ["Clothing", "Beauty"]
    )
} 