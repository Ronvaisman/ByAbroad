//
//  Product.swift
//  ByAbroad
//
//  Created on 22/07/2025.
//

import Foundation
import SwiftData

@Model
final class Product {
    var id: UUID
    var name: String
    var price: Double
    var currency: String
    var imageURL: String?
    var productURL: String
    var storeName: String
    var storeID: String
    var category: String
    var isAvailable: Bool
    var lastUpdated: Date
    var localTax: Double? // Store's local sales tax
    var weight: Double? // For shipping calculations
    var dimensions: String? // For shipping calculations
    
    init(
        name: String,
        price: Double,
        currency: String,
        productURL: String,
        storeName: String,
        storeID: String,
        category: String,
        imageURL: String? = nil,
        isAvailable: Bool = true,
        localTax: Double? = nil,
        weight: Double? = nil,
        dimensions: String? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.price = price
        self.currency = currency
        self.imageURL = imageURL
        self.productURL = productURL
        self.storeName = storeName
        self.storeID = storeID
        self.category = category
        self.isAvailable = isAvailable
        self.lastUpdated = Date()
        self.localTax = localTax
        self.weight = weight
        self.dimensions = dimensions
    }
}

// MARK: - Product Category Extension
extension Product {
    enum Category: String, CaseIterable {
        case electronics = "Electronics"
        case clothing = "Clothing"
        case home = "Home"
        case beauty = "Beauty"
        case sports = "Sports"
        case books = "Books"
        case other = "Other"
        
        var displayName: String {
            return self.rawValue
        }
    }
} 