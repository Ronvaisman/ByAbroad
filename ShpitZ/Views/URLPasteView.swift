//
//  URLPasteView.swift
//  ByAbroad
//
//  Created on 22/07/2025.
//

import SwiftUI

struct URLPasteView: View {
    @StateObject private var urlParsingService = URLParsingService.shared
    @Environment(\.dismiss) private var dismiss
    @State private var urlText = ""
    @State private var isProcessing = false
    @State private var parsingResult: URLParsingResult?
    @State private var showingManualEntry = false
    @State private var showingCostCalculation = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerSection
                    
                    // URL Input Section
                    urlInputSection
                    
                    // Result Section
                    if let result = parsingResult {
                        resultSection(result)
                    }
                    
                    // Manual Entry Option
                    if parsingResult?.requiresManualEntry == true {
                        manualEntrySection
                    }
                    
                    // Instructions
                    instructionsSection
                    
                    Spacer(minLength: 100)
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Paste Product Link")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                if urlParsingService.isProcessing {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        ProgressView()
                            .scaleEffect(0.8)
                    }
                }
            }
        }
        .sheet(isPresented: $showingManualEntry) {
            ManualEntryView()
        }
        .onAppear {
            checkClipboard()
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "link.circle.fill")
                .font(.system(size: 48))
                .foregroundColor(.blue)
            
            Text("Calculate Real Cost")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Paste any product link from Amazon, eBay, Zara, ASOS, and more to get the complete cost including shipping and Israeli taxes")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    // MARK: - URL Input Section
    private var urlInputSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Product URL")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            VStack(spacing: 12) {
                TextField("https://...", text: $urlText, axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .lineLimit(3...6)
                    .onSubmit {
                        processURL()
                    }
                
                HStack {
                    Button("Paste from Clipboard") {
                        pasteFromClipboard()
                    }
                    .font(.subheadline)
                    .foregroundColor(.blue)
                    
                    Spacer()
                    
                    Button("Clear") {
                        urlText = ""
                        parsingResult = nil
                    }
                    .font(.subheadline)
                    .foregroundColor(.red)
                    .opacity(urlText.isEmpty ? 0.5 : 1.0)
                    .disabled(urlText.isEmpty)
                }
            }
            
            Button(action: processURL) {
                HStack {
                    if isProcessing {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "calculator")
                    }
                    
                    Text(isProcessing ? "Processing..." : "Calculate Cost")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(urlText.isEmpty ? Color.gray.opacity(0.3) : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(urlText.isEmpty || isProcessing)
        }
    }
    
    // MARK: - Result Section
    private func resultSection(_ result: URLParsingResult) -> some View {
        VStack(spacing: 16) {
            HStack {
                Text("Analysis Result")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            VStack(spacing: 12) {
                // Store Detection
                HStack {
                    Image(systemName: result.isSupported ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                        .foregroundColor(result.isSupported ? .green : .orange)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Store: \(result.storeName)")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Text(result.isSupported ? "Supported" : "Limited support")
                            .font(.caption)
                            .foregroundColor(result.isSupported ? .green : .orange)
                    }
                    
                    Spacer()
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                
                // Product Information
                if let product = result.product {
                    productInfoCard(product)
                } else if let error = result.error {
                    errorCard(error)
                }
            }
        }
    }
    
    private func productInfoCard(_ product: Product) -> some View {
        VStack(spacing: 12) {
            HStack {
                AsyncImage(url: URL(string: product.imageURL ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                        )
                }
                .frame(width: 60, height: 60)
                .cornerRadius(8)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .lineLimit(2)
                    
                    HStack {
                        Text("\(product.price, specifier: "%.2f") \(product.currency)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                    }
                }
                
                Spacer()
            }
            
            Button(action: {
                showingCostCalculation = true
            }) {
                HStack {
                    Image(systemName: "calculator")
                    Text("Calculate Final Cost")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
    
    private func errorCard(_ error: URLParsingError) -> some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Could not read automatically")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text(error.localizedDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            Text("Don't worry! You can still calculate the cost by entering the price manually.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(12)
    }
    
    // MARK: - Manual Entry Section
    private var manualEntrySection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Manual Entry")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            Button(action: {
                showingManualEntry = true
            }) {
                HStack {
                    Image(systemName: "pencil.circle.fill")
                        .foregroundColor(.blue)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Enter Product Details Manually")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        Text("Enter price, currency, and estimated weight")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    // MARK: - Instructions Section
    private var instructionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Supported Stores")
                .font(.headline)
                .fontWeight(.semibold)
            
            let supportedStores = [
                ("Amazon", "Full support with automatic price detection", Color.orange),
                ("eBay", "Full support with automatic price detection", Color.red),
                ("Best Buy", "Full support with automatic price detection", Color.blue),
                ("Zara", "Automatic price detection", Color.black),
                ("ASOS", "Automatic price detection", Color.pink)
            ]
            
            ForEach(supportedStores, id: \.0) { store in
                HStack {
                    Circle()
                        .fill(store.2)
                        .frame(width: 12, height: 12)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(store.0)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Text(store.1)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
            }
            
            Text("More stores coming soon! For unsupported stores, use manual entry.")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top, 8)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
    
    // MARK: - Actions
    private func checkClipboard() {
        if let clipboardString = UIPasteboard.general.string,
           clipboardString.hasPrefix("http") {
            // Could suggest to paste
        }
    }
    
    private func pasteFromClipboard() {
        if let clipboardString = UIPasteboard.general.string {
            urlText = clipboardString
        }
    }
    
    private func processURL() {
        guard !urlText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        isProcessing = true
        parsingResult = nil
        
        Task {
            let result = await urlParsingService.parseProductURL(urlText)
            await MainActor.run {
                self.parsingResult = result
                self.isProcessing = false
            }
        }
    }
}

// MARK: - Manual Entry View
struct ManualEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var productName = ""
    @State private var price = ""
    @State private var currency = "USD"
    @State private var weight = ""
    @State private var storeName = ""
    
    let currencies = ["USD", "EUR", "GBP", "CAD", "AUD"]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Product Information") {
                    TextField("Product Name", text: $productName)
                    TextField("Store Name", text: $storeName)
                }
                
                Section("Pricing") {
                    HStack {
                        TextField("Price", text: $price)
                            .keyboardType(.decimalPad)
                        
                        Picker("Currency", selection: $currency) {
                            ForEach(currencies, id: \.self) { currency in
                                Text(currency).tag(currency)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }
                
                Section("Shipping") {
                    TextField("Weight (kg)", text: $weight)
                        .keyboardType(.decimalPad)
                }
                
                Section {
                    Button("Calculate Cost") {
                        // Calculate cost
                        dismiss()
                    }
                    .disabled(productName.isEmpty || price.isEmpty)
                }
            }
            .navigationTitle("Manual Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    URLPasteView()
} 