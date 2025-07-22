//
//  CostCalculation.swift
//  ByAbroad
//
//  Created on 22/07/2025.
//

import Foundation
import SwiftData

@Model
final class CostCalculation {
    var id: UUID
    var productID: UUID
    var productName: String
    var productURL: String
    
    // Original pricing
    var originalPrice: Double
    var originalCurrency: String
    var localTax: Double // Store's local sales tax
    
    // Currency conversion
    var exchangeRate: Double
    var exchangeRateDate: Date
    var priceInILS: Double // (originalPrice + localTax) * exchangeRate
    
    // Shipping costs
    var shippingForwarderName: String
    var shippingCost: Double
    var processingFee: Double
    
    // Israeli import costs
    var importDuty: Double
    var israeliVAT: Double // 17%
    var customsHandlingFee: Double
    
    // Final totals
    var totalCostILS: Double
    var totalCostUSD: Double
    
    var calculationDate: Date
    var isActive: Bool
    
    init(
        productID: UUID,
        productName: String,
        productURL: String,
        originalPrice: Double,
        originalCurrency: String,
        localTax: Double,
        exchangeRate: Double,
        shippingForwarderName: String,
        shippingCost: Double,
        processingFee: Double = 0,
        importDuty: Double = 0,
        customsHandlingFee: Double = 50 // Default customs handling fee
    ) {
        // Initialize all stored properties first (required by SwiftData)
        self.id = UUID()
        self.productID = productID
        self.productName = productName
        self.productURL = productURL
        self.originalPrice = originalPrice
        self.originalCurrency = originalCurrency
        self.localTax = localTax
        self.exchangeRate = exchangeRate
        self.exchangeRateDate = Date()
        self.shippingForwarderName = shippingForwarderName
        self.shippingCost = shippingCost
        self.processingFee = processingFee
        self.importDuty = importDuty
        self.customsHandlingFee = customsHandlingFee
        self.calculationDate = Date()
        self.isActive = true
        
        // Initialize derived properties with default values
        self.priceInILS = 0
        self.israeliVAT = 0
        self.totalCostILS = 0
        self.totalCostUSD = 0
        
        // Now calculate the actual derived values
        self.calculateDerivedValues()
    }
    
    // MARK: - Private Calculation Methods
    private func calculateDerivedValues() {
        self.priceInILS = (originalPrice + localTax) * exchangeRate
        self.israeliVAT = (self.priceInILS + importDuty) * 0.17 // 17% VAT
        self.totalCostILS = self.priceInILS + shippingCost + processingFee + importDuty + israeliVAT + customsHandlingFee
        self.totalCostUSD = self.totalCostILS / exchangeRate
    }
}

// MARK: - Cost Calculation Extensions
extension CostCalculation {
    
    /// Updates the calculation with new exchange rate
    func updateExchangeRate(_ newRate: Double) {
        self.exchangeRate = newRate
        self.exchangeRateDate = Date()
        self.calculateDerivedValues()
    }
    
    /// Recalculates all derived values (useful when any base value changes)
    func recalculate() {
        self.calculateDerivedValues()
    }
    
    /// Formatted breakdown for display
    var costBreakdown: [(String, Double, String)] {
        return [
            ("Product Price", originalPrice, originalCurrency),
            ("Local Tax", localTax, originalCurrency),
            ("Price in ILS", priceInILS, "ILS"),
            ("Shipping Cost", shippingCost, "ILS"),
            ("Processing Fee", processingFee, "ILS"),
            ("Import Duty", importDuty, "ILS"),
            ("Israeli VAT (17%)", israeliVAT, "ILS"),
            ("Customs Handling", customsHandlingFee, "ILS"),
            ("Total Cost", totalCostILS, "ILS")
        ]
    }
    
    /// Savings compared to Israeli retail (if applicable)
    func potentialSavings(israeliRetailPrice: Double) -> Double {
        return max(0, israeliRetailPrice - totalCostILS)
    }
} 