//
//  CostCalculationService.swift
//  ByAbroad
//
//  Created on 22/07/2025.
//

import Foundation

// MARK: - Cost Calculation Service
@MainActor
class CostCalculationService: ObservableObject {
    
    static let shared = CostCalculationService()
    private let networkManager = NetworkManager.shared
    
    @Published var isCalculating = false
    @Published var currentCalculation: CostCalculation?
    @Published var availableForwarders: [ShippingForwarder] = []
    @Published var currentExchangeRates: [String: Double] = [:]
    
    private init() {
        loadDefaultForwarders()
    }
    
    // MARK: - Main Calculation Method
    func calculateTotalCost(
        for product: Product,
        shippingForwarder: ShippingForwarder,
        estimatedWeight: Double? = nil
    ) async throws -> CostCalculation {
        
        isCalculating = true
        defer { isCalculating = false }
        
        // Get current exchange rate
        let exchangeRate = try await getExchangeRate(from: product.currency, to: "ILS")
        
        // Calculate shipping cost
        let weight = estimatedWeight ?? product.weight ?? 1.0 // Default 1kg if not specified
        let productValueInOriginalCurrency = product.price + (product.localTax ?? 0)
        let shippingCost = shippingForwarder.calculateShippingCost(
            weight: weight,
            value: productValueInOriginalCurrency * exchangeRate
        )
        
        // Calculate Israeli import duties and taxes
        let priceInILS = productValueInOriginalCurrency * exchangeRate
        let importDuty = calculateImportDuty(priceInILS: priceInILS, category: product.category)
        
        let calculation = CostCalculation(
            productID: product.id,
            productName: product.name,
            productURL: product.productURL,
            originalPrice: product.price,
            originalCurrency: product.currency,
            localTax: product.localTax ?? 0,
            exchangeRate: exchangeRate,
            shippingForwarderName: shippingForwarder.displayName,
            shippingCost: shippingCost,
            processingFee: shippingForwarder.processingFee,
            importDuty: importDuty
        )
        
        currentCalculation = calculation
        return calculation
    }
    
    // MARK: - Multi-Forwarder Comparison
    func calculateForAllForwarders(
        for product: Product,
        estimatedWeight: Double? = nil
    ) async throws -> [CostCalculation] {
        
        var calculations: [CostCalculation] = []
        
        for forwarder in availableForwarders {
            do {
                let calculation = try await calculateTotalCost(
                    for: product,
                    shippingForwarder: forwarder,
                    estimatedWeight: estimatedWeight
                )
                calculations.append(calculation)
            } catch {
                print("Failed to calculate for \(forwarder.displayName): \(error)")
                // Continue with other forwarders
            }
        }
        
        // Sort by total cost (cheapest first)
        calculations.sort { $0.totalCostILS < $1.totalCostILS }
        
        return calculations
    }
    
    // MARK: - Exchange Rate Management
    private func getExchangeRate(from: String, to: String) async throws -> Double {
        let cacheKey = "\(from)_\(to)"
        
        // Check if we have a recent rate cached
        if let cachedRate = currentExchangeRates[cacheKey] {
            return cachedRate
        }
        
        // Fetch new rate
        let rate = try await networkManager.fetchExchangeRate(from: from, to: to)
        currentExchangeRates[cacheKey] = rate
        
        return rate
    }
    
    // MARK: - Import Duty Calculation
    private func calculateImportDuty(priceInILS: Double, category: String) -> Double {
        // Israeli import duty rates by category
        let dutyRates: [String: Double] = [
            "Electronics": 0.12,      // 12%
            "Clothing": 0.12,         // 12%
            "Home": 0.12,             // 12%
            "Beauty": 0.12,           // 12%
            "Sports": 0.12,           // 12%
            "Books": 0.0,             // Books are exempt
            "Other": 0.12             // Default 12%
        ]
        
        let rate = dutyRates[category] ?? 0.12
        
        // Import duty is only applied if the total value exceeds 75 ILS
        if priceInILS > 75 {
            return priceInILS * rate
        } else {
            return 0
        }
    }
    
    // MARK: - Price Comparison
    func compareWithIsraeliPrice(calculation: CostCalculation, israeliPrice: Double) -> (savings: Double, percentage: Double) {
        let savings = israeliPrice - calculation.totalCostILS
        let percentage = savings / israeliPrice * 100
        return (savings: savings, percentage: percentage)
    }
    
    // MARK: - Cost Breakdown for Display
    func getDetailedBreakdown(for calculation: CostCalculation) -> [(String, String, String)] {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2
        
        var breakdown: [(String, String, String)] = []
        
        // Original price
        formatter.currencyCode = calculation.originalCurrency
        let originalPriceFormatted = formatter.string(from: NSNumber(value: calculation.originalPrice)) ?? "0"
        breakdown.append(("Product Price", originalPriceFormatted, ""))
        
        // Local tax
        if calculation.localTax > 0 {
            let localTaxFormatted = formatter.string(from: NSNumber(value: calculation.localTax)) ?? "0"
            breakdown.append(("Local Tax", localTaxFormatted, ""))
        }
        
        // Exchange rate
        formatter.currencyCode = "ILS"
        let priceInILS = formatter.string(from: NSNumber(value: calculation.priceInILS)) ?? "0"
        breakdown.append(("Price in ILS", priceInILS, "Rate: \(String(format: "%.3f", calculation.exchangeRate))"))
        
        // Shipping
        let shippingFormatted = formatter.string(from: NSNumber(value: calculation.shippingCost)) ?? "0"
        breakdown.append(("Shipping (\(calculation.shippingForwarderName))", shippingFormatted, ""))
        
        // Processing fee
        if calculation.processingFee > 0 {
            let processingFormatted = formatter.string(from: NSNumber(value: calculation.processingFee)) ?? "0"
            breakdown.append(("Processing Fee", processingFormatted, ""))
        }
        
        // Import duty
        if calculation.importDuty > 0 {
            let dutyFormatted = formatter.string(from: NSNumber(value: calculation.importDuty)) ?? "0"
            breakdown.append(("Import Duty", dutyFormatted, ""))
        }
        
        // Israeli VAT
        let vatFormatted = formatter.string(from: NSNumber(value: calculation.israeliVAT)) ?? "0"
        breakdown.append(("Israeli VAT (17%)", vatFormatted, ""))
        
        // Customs handling
        let customsFormatted = formatter.string(from: NSNumber(value: calculation.customsHandlingFee)) ?? "0"
        breakdown.append(("Customs Handling", customsFormatted, ""))
        
        // Total
        let totalFormatted = formatter.string(from: NSNumber(value: calculation.totalCostILS)) ?? "0"
        breakdown.append(("Total Cost", totalFormatted, ""))
        
        return breakdown
    }
    
    // MARK: - Shipping Forwarder Management
    private func loadDefaultForwarders() {
        availableForwarders = [
            .uShops,
            .dealTas,
            .shipito
        ]
    }
    
    func addCustomForwarder(_ forwarder: ShippingForwarder) {
        if !availableForwarders.contains(where: { $0.id == forwarder.id }) {
            availableForwarders.append(forwarder)
        }
    }
    
    func removeForwarder(withID id: String) {
        availableForwarders.removeAll { $0.id == id }
    }
    
    // MARK: - Savings Tips
    func getSavingsTips(for calculation: CostCalculation) -> [String] {
        var tips: [String] = []
        
        // High shipping cost tip
        if calculation.shippingCost > 100 {
            tips.append("💡 Consider consolidating multiple orders to reduce shipping cost per item")
        }
        
        // Weight optimization
        let weight = Double(calculation.productName.count) / 10
        if weight > 2 { // Mock weight calculation
            tips.append("📦 Package consolidation could save up to ₪50 on shipping")
        }
        
        // Import duty threshold
        if calculation.importDuty == 0 && calculation.priceInILS > 50 {
            tips.append("🎯 You're under the ₪75 import duty threshold - great savings!")
        }
        
        // Better forwarder suggestion
        if calculation.shippingCost > availableForwarders.min(by: { $0.baseRate < $1.baseRate })?.baseRate ?? 0 {
            tips.append("💰 Check other shipping forwarders for potential savings")
        }
        
        // Currency timing
        tips.append("📈 Monitor exchange rates for 2-3 days for potential savings")
        
        return tips
    }
    
    // MARK: - Manual Entry Support
    func createManualCalculation(
        productName: String,
        productURL: String,
        price: Double,
        currency: String,
        estimatedWeight: Double,
        storeName: String,
        category: String
    ) async throws -> [CostCalculation] {
        
        let manualProduct = Product(
            name: productName,
            price: price,
            currency: currency,
            productURL: productURL,
            storeName: storeName,
            storeID: "manual_entry",
            category: category,
            weight: estimatedWeight
        )
        
        return try await calculateForAllForwarders(for: manualProduct, estimatedWeight: estimatedWeight)
    }
}

// MARK: - Extensions for Testing
extension CostCalculationService {
    
    func createMockCalculation() -> CostCalculation {
        return CostCalculation(
            productID: UUID(),
            productName: "iPhone 15 Pro",
            productURL: "https://amazon.com/iphone-15-pro",
            originalPrice: 999.00,
            originalCurrency: "USD",
            localTax: 79.92,
            exchangeRate: 3.7,
            shippingForwarderName: "UShops",
            shippingCost: 85.0,
            processingFee: 15.0,
            importDuty: 432.0
        )
    }
} 