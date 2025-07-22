//
//  ShippingForwarder.swift
//  ByAbroad
//
//  Created on 22/07/2025.
//

import Foundation
import SwiftData

@Model
final class ShippingForwarder {
    var id: String
    var name: String
    var displayName: String
    var logoURL: String?
    var websiteURL: String
    var calculatorURL: String? // URL to their shipping calculator
    
    // Shipping details
    var countryCode: String // Where they're based (usually US)
    var baseRate: Double // Base shipping rate in ILS
    var perKgRate: Double // Rate per kilogram
    var processingFee: Double // Fixed processing fee
    var insuranceFee: Double // Insurance fee percentage
    var estimatedDays: Int // Delivery time estimate
    
    // Service features
    var hasConsolidation: Bool // Can combine multiple packages
    var hasInsurance: Bool
    var hasTracking: Bool
    var acceptsReturns: Bool
    
    // Address information
    var usAddress: String? // US warehouse address for users
    var phoneNumber: String?
    var emailSupport: String?
    
    var isActive: Bool
    var lastUpdated: Date
    
    init(
        id: String,
        name: String,
        displayName: String,
        websiteURL: String,
        countryCode: String = "US",
        baseRate: Double,
        perKgRate: Double,
        processingFee: Double = 0,
        insuranceFee: Double = 0.02, // 2%
        estimatedDays: Int = 7,
        hasConsolidation: Bool = true,
        hasInsurance: Bool = true,
        hasTracking: Bool = true,
        acceptsReturns: Bool = false,
        calculatorURL: String? = nil,
        logoURL: String? = nil,
        usAddress: String? = nil,
        phoneNumber: String? = nil,
        emailSupport: String? = nil
    ) {
        self.id = id
        self.name = name
        self.displayName = displayName
        self.logoURL = logoURL
        self.websiteURL = websiteURL
        self.calculatorURL = calculatorURL
        self.countryCode = countryCode
        self.baseRate = baseRate
        self.perKgRate = perKgRate
        self.processingFee = processingFee
        self.insuranceFee = insuranceFee
        self.estimatedDays = estimatedDays
        self.hasConsolidation = hasConsolidation
        self.hasInsurance = hasInsurance
        self.hasTracking = hasTracking
        self.acceptsReturns = acceptsReturns
        self.usAddress = usAddress
        self.phoneNumber = phoneNumber
        self.emailSupport = emailSupport
        self.isActive = true
        self.lastUpdated = Date()
    }
}

// MARK: - Shipping Calculation
extension ShippingForwarder {
    
    /// Calculate shipping cost for a given weight and value
    func calculateShippingCost(weight: Double, value: Double) -> Double {
        let shippingCost = baseRate + (weight * perKgRate)
        let insurance = hasInsurance ? (value * insuranceFee) : 0
        return shippingCost + processingFee + insurance
    }
    
    /// Generate shipping address for user
    func generateShippingAddress(userID: String) -> String {
        guard let address = usAddress else {
            return "Address not available"
        }
        
        return """
        \(userID) - Your Name
        \(address)
        
        Phone: \(phoneNumber ?? "N/A")
        Email: \(emailSupport ?? "N/A")
        """
    }
}

// MARK: - Predefined Shipping Forwarders
extension ShippingForwarder {
    static let uShops = ShippingForwarder(
        id: "ushops",
        name: "ushops",
        displayName: "UShops",
        websiteURL: "https://ushops.co.il",
        baseRate: 45.0, // Base rate in ILS
        perKgRate: 25.0, // Per kg in ILS
        processingFee: 15.0,
        estimatedDays: 5,
        calculatorURL: "https://ushops.co.il/calculator"
    )
    
    static let dealTas = ShippingForwarder(
        id: "dealtas",
        name: "dealtas",
        displayName: "DealTas",
        websiteURL: "https://dealtas.com",
        baseRate: 50.0,
        perKgRate: 28.0,
        processingFee: 20.0,
        estimatedDays: 7,
        calculatorURL: "https://dealtas.com/shipping-calculator"
    )
    
    static let shipito = ShippingForwarder(
        id: "shipito",
        name: "shipito",
        displayName: "Shipito",
        websiteURL: "https://shipito.com",
        baseRate: 55.0,
        perKgRate: 30.0,
        processingFee: 10.0,
        estimatedDays: 6,
        hasConsolidation: true,
        acceptsReturns: true
    )
} 