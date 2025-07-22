//
//  URLParsingService.swift
//  ByAbroad
//
//  Created on 22/07/2025.
//

import Foundation

// MARK: - URL Parsing Result
struct URLParsingResult {
    let isSupported: Bool
    let storeName: String
    let storeID: String
    let product: Product?
    let error: URLParsingError?
    let requiresManualEntry: Bool
}

// MARK: - URL Parsing Error
enum URLParsingError: Error, LocalizedError {
    case invalidURL
    case unsupportedStore
    case scrapingFailed
    case productNotFound
    case networkError
    case priceNotFound
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL format"
        case .unsupportedStore:
            return "Store not supported yet"
        case .scrapingFailed:
            return "Couldn't read product information"
        case .productNotFound:
            return "Product not found on the page"
        case .networkError:
            return "Network connection error"
        case .priceNotFound:
            return "Price information not available"
        }
    }
}

// MARK: - URL Parsing Service
@MainActor
class URLParsingService: ObservableObject {
    
    static let shared = URLParsingService()
    private let networkManager = NetworkManager.shared
    private let analyticsService = AnalyticsService.shared
    
    @Published var isProcessing = false
    @Published var lastParsingResult: URLParsingResult?
    
    private init() {}
    
    // MARK: - Main URL Parsing Method
    func parseProductURL(_ urlString: String) async -> URLParsingResult {
        isProcessing = true
        defer { isProcessing = false }
        
        guard let url = URL(string: urlString),
              let host = url.host else {
            let result = URLParsingResult(
                isSupported: false,
                storeName: "Unknown",
                storeID: "unknown",
                product: nil,
                error: .invalidURL,
                requiresManualEntry: true
            )
            lastParsingResult = result
            return result
        }
        
        let domain = extractRootDomain(from: host)
        
        // Log domain request for analytics (anonymous)
        await analyticsService.logDomainRequest(domain)
        
        // Check if store is supported
        let storeInfo = identifyStore(domain: domain)
        
        if storeInfo.hasWebScraper {
            // Try to scrape the product information
            let result = await scrapeProductFromURL(urlString, storeInfo: storeInfo)
            lastParsingResult = result
            return result
        } else if storeInfo.isSupported {
            // Store is known but doesn't have scraper yet
            let result = URLParsingResult(
                isSupported: true,
                storeName: storeInfo.displayName,
                storeID: storeInfo.id,
                product: nil,
                error: .scrapingFailed,
                requiresManualEntry: true
            )
            lastParsingResult = result
            return result
        } else {
            // Unsupported store - try generic scraping
            let result = await attemptGenericScraping(urlString, domain: domain)
            lastParsingResult = result
            return result
        }
    }
    
    // MARK: - Store Identification
    private func identifyStore(domain: String) -> (id: String, displayName: String, hasWebScraper: Bool, isSupported: Bool) {
        switch domain.lowercased() {
        case "amazon.com", "amazon.co.uk", "amazon.de", "amazon.fr":
            return ("amazon_us", "Amazon", false, true) // Will implement scraper later
        case "ebay.com", "ebay.co.uk":
            return ("ebay_global", "eBay", false, true)
        case "bestbuy.com":
            return ("bestbuy_us", "Best Buy", false, true)
        case "zara.com":
            return ("zara_global", "Zara", true, true)
        case "asos.com":
            return ("asos_uk", "ASOS", true, true)
        case "hm.com":
            return ("hm_global", "H&M", true, true)
        case "nike.com":
            return ("nike_global", "Nike", true, true)
        case "adidas.com":
            return ("adidas_global", "Adidas", true, true)
        default:
            return ("unknown", domain, false, false)
        }
    }
    
    // MARK: - Web Scraping Methods
    private func scrapeProductFromURL(_ urlString: String, storeInfo: (id: String, displayName: String, hasWebScraper: Bool, isSupported: Bool)) async -> URLParsingResult {
        
        do {
            let html = try await networkManager.scrapeWebpage(url: urlString)
            
            switch storeInfo.id {
            case "zara_global":
                return await scrapeZara(html: html, url: urlString, storeInfo: storeInfo)
            case "asos_uk":
                return await scrapeASOS(html: html, url: urlString, storeInfo: storeInfo)
            case "hm_global":
                return await scrapeHM(html: html, url: urlString, storeInfo: storeInfo)
            case "nike_global":
                return await scrapeNike(html: html, url: urlString, storeInfo: storeInfo)
            case "adidas_global":
                return await scrapeAdidas(html: html, url: urlString, storeInfo: storeInfo)
            default:
                return URLParsingResult(
                    isSupported: false,
                    storeName: storeInfo.displayName,
                    storeID: storeInfo.id,
                    product: nil,
                    error: .scrapingFailed,
                    requiresManualEntry: true
                )
            }
            
        } catch {
            return URLParsingResult(
                isSupported: true,
                storeName: storeInfo.displayName,
                storeID: storeInfo.id,
                product: nil,
                error: .networkError,
                requiresManualEntry: true
            )
        }
    }
    
    // MARK: - Store-Specific Scrapers
    
    // Zara Scraper
    private func scrapeZara(html: String, url: String, storeInfo: (id: String, displayName: String, hasWebScraper: Bool, isSupported: Bool)) async -> URLParsingResult {
        // Mock implementation - would contain actual scraping logic
        // Looking for specific CSS selectors or JSON-LD data
        
        if let productInfo = extractZaraProductInfo(from: html) {
            let product = Product(
                name: productInfo.name,
                price: productInfo.price,
                currency: productInfo.currency,
                productURL: url,
                storeName: storeInfo.displayName,
                storeID: storeInfo.id,
                category: "Clothing",
                imageURL: productInfo.imageURL,
                localTax: productInfo.price * 0.21, // EU VAT
                weight: 0.5 // Estimated clothing weight
            )
            
            return URLParsingResult(
                isSupported: true,
                storeName: storeInfo.displayName,
                storeID: storeInfo.id,
                product: product,
                error: nil,
                requiresManualEntry: false
            )
        } else {
            return URLParsingResult(
                isSupported: true,
                storeName: storeInfo.displayName,
                storeID: storeInfo.id,
                product: nil,
                error: .productNotFound,
                requiresManualEntry: true
            )
        }
    }
    
    // ASOS Scraper
    private func scrapeASOS(html: String, url: String, storeInfo: (id: String, displayName: String, hasWebScraper: Bool, isSupported: Bool)) async -> URLParsingResult {
        // Mock implementation for ASOS
        if let productInfo = extractASOSProductInfo(from: html) {
            let product = Product(
                name: productInfo.name,
                price: productInfo.price,
                currency: productInfo.currency,
                productURL: url,
                storeName: storeInfo.displayName,
                storeID: storeInfo.id,
                category: "Clothing",
                imageURL: productInfo.imageURL,
                localTax: productInfo.price * 0.20, // UK VAT
                weight: 0.4
            )
            
            return URLParsingResult(
                isSupported: true,
                storeName: storeInfo.displayName,
                storeID: storeInfo.id,
                product: product,
                error: nil,
                requiresManualEntry: false
            )
        } else {
            return URLParsingResult(
                isSupported: true,
                storeName: storeInfo.displayName,
                storeID: storeInfo.id,
                product: nil,
                error: .scrapingFailed,
                requiresManualEntry: true
            )
        }
    }
    
    // H&M Scraper
    private func scrapeHM(html: String, url: String, storeInfo: (id: String, displayName: String, hasWebScraper: Bool, isSupported: Bool)) async -> URLParsingResult {
        // Mock implementation for H&M
        return URLParsingResult(
            isSupported: true,
            storeName: storeInfo.displayName,
            storeID: storeInfo.id,
            product: nil,
            error: .scrapingFailed,
            requiresManualEntry: true
        )
    }
    
    // Nike Scraper
    private func scrapeNike(html: String, url: String, storeInfo: (id: String, displayName: String, hasWebScraper: Bool, isSupported: Bool)) async -> URLParsingResult {
        // Mock implementation for Nike
        return URLParsingResult(
            isSupported: true,
            storeName: storeInfo.displayName,
            storeID: storeInfo.id,
            product: nil,
            error: .scrapingFailed,
            requiresManualEntry: true
        )
    }
    
    // Adidas Scraper
    private func scrapeAdidas(html: String, url: String, storeInfo: (id: String, displayName: String, hasWebScraper: Bool, isSupported: Bool)) async -> URLParsingResult {
        // Mock implementation for Adidas
        return URLParsingResult(
            isSupported: true,
            storeName: storeInfo.displayName,
            storeID: storeInfo.id,
            product: nil,
            error: .scrapingFailed,
            requiresManualEntry: true
        )
    }
    
    // MARK: - Generic Scraping
    private func attemptGenericScraping(_ urlString: String, domain: String) async -> URLParsingResult {
        do {
            let html = try await networkManager.scrapeWebpage(url: urlString)
            
            // Try to extract basic product information using common patterns
            if let productInfo = extractGenericProductInfo(from: html) {
                let product = Product(
                    name: productInfo.name,
                    price: productInfo.price,
                    currency: productInfo.currency,
                    productURL: urlString,
                    storeName: domain,
                    storeID: "generic_\(domain)",
                    category: "Other",
                    imageURL: productInfo.imageURL
                )
                
                return URLParsingResult(
                    isSupported: false,
                    storeName: domain,
                    storeID: "generic_\(domain)",
                    product: product,
                    error: nil,
                    requiresManualEntry: false
                )
            } else {
                return URLParsingResult(
                    isSupported: false,
                    storeName: domain,
                    storeID: "generic_\(domain)",
                    product: nil,
                    error: .scrapingFailed,
                    requiresManualEntry: true
                )
            }
        } catch {
            return URLParsingResult(
                isSupported: false,
                storeName: domain,
                storeID: "generic_\(domain)",
                product: nil,
                error: .networkError,
                requiresManualEntry: true
            )
        }
    }
    
    // MARK: - Helper Methods
    
    private func extractRootDomain(from host: String) -> String {
        let components = host.components(separatedBy: ".")
        if components.count >= 2 {
            return "\(components[components.count - 2]).\(components[components.count - 1])"
        }
        return host
    }
    
    // Mock extraction methods (would contain actual HTML parsing logic)
    private func extractZaraProductInfo(from html: String) -> (name: String, price: Double, currency: String, imageURL: String?)? {
        // This would contain actual HTML parsing using regex or HTML parser
        // For now, return mock data for testing
        return ("Zara Mock Product", 49.99, "EUR", nil)
    }
    
    private func extractASOSProductInfo(from html: String) -> (name: String, price: Double, currency: String, imageURL: String?)? {
        // Mock ASOS product extraction
        return ("ASOS Mock Product", 35.00, "GBP", nil)
    }
    
    private func extractGenericProductInfo(from html: String) -> (name: String, price: Double, currency: String, imageURL: String?)? {
        // Generic product info extraction using common patterns
        // Look for meta tags, JSON-LD, microdata, etc.
        return nil
    }
}

// MARK: - Analytics Service for Domain Logging
@MainActor
class AnalyticsService: ObservableObject {
    static let shared = AnalyticsService()
    
    private var domainRequests: [String: Int] = [:]
    
    private init() {}
    
    func logDomainRequest(_ domain: String) async {
        // Increment counter for the domain
        domainRequests[domain, default: 0] += 1
        
        // In a real implementation, this would be sent to an analytics backend
        print("Domain requested: \(domain) (Total: \(domainRequests[domain] ?? 0))")
    }
    
    func getMostRequestedDomains() -> [(String, Int)] {
        return domainRequests.sorted { $0.value > $1.value }
    }
} 