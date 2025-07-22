//
//  HomeView.swift
//  ByAbroad
//
//  Created on 22/07/2025.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var searchService = ProductSearchService.shared
    @StateObject private var urlParsingService = URLParsingService.shared
    @State private var searchText = ""
    @State private var showingURLPaste = false
    @State private var isSearching = false
    @State private var searchResults: [Product] = []
    @State private var searchTask: Task<Void, Never>?
    
    let stores = [
        ("Amazon", "amazon", Color.orange),
        ("eBay", "ebay", Color.red),
        ("Best Buy", "bestbuy", Color.blue)
    ]
    
    let electronicsItems = [
        ("Laptop", "laptopcomputer", Color.gray),
        ("Smartphone", "iphone", Color.black),
        ("Headphones", "headphones", Color.purple)
    ]
    
    let homeItems = [
        ("Home", "house.fill", Color.brown),
        ("Clothing", "tshirt.fill", Color.pink),
        ("Beauty", "sparkles", Color.cyan)
    ]
    
    let clothingItems = [
        ("Men's Fashion", "person.fill", Color.blue),
        ("Women's Fashion", "person.fill", Color.pink),
        ("Accessories", "bag.fill", Color.green)
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header and Search Bar are always visible
                VStack(spacing: 20) {
                    headerSection
                    searchBarSection
                }
                .padding(.horizontal)
                .padding(.top)
                .background(Color(.systemGroupedBackground))
                
                // Content based on search state
                if !searchText.isEmpty {
                    // Search Results View
                    searchResultsView
                } else {
                    // Main Home View
                    ScrollView {
                        VStack(spacing: 20) {
                            // Store Logos Section
                            storeLogosSection
                            
                            // Electronics Section
                            categorySection(
                                title: "Electronics",
                                items: electronicsItems,
                                backgroundColor: .gray.opacity(0.1)
                            )
                            
                            // Home Section
                            categorySection(
                                title: "Home",
                                items: homeItems,
                                backgroundColor: .brown.opacity(0.1)
                            )
                            
                            // Clothing Section
                            categorySection(
                                title: "Clothing",
                                items: clothingItems,
                                backgroundColor: .pink.opacity(0.1)
                            )
                            
                            // URL Paste Section
                            urlPasteSection
                            
                            Spacer(minLength: 100)
                        }
                        .padding(.horizontal)
                        .padding(.top)
                    }
                    .background(Color(.systemGroupedBackground))
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingURLPaste) {
            URLPasteView()
        }
        .onDisappear {
            // Cancel any ongoing search when view disappears
            searchTask?.cancel()
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("By Abroad")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Shop worldwide, know your real cost")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: {
                // Settings action
            }) {
                Image(systemName: "gearshape.fill")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 4)
    }
    
    // MARK: - Search Bar Section
    private var searchBarSection: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search products", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
                .onChange(of: searchText) { _, newValue in
                    performSearch(query: newValue)
                }
            
            if !searchText.isEmpty {
                Button(action: {
                    clearSearch()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            } else {
                Image(systemName: "mic.fill")
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    // MARK: - Store Logos Section
    private var storeLogosSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Popular Stores")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            HStack(spacing: 16) {
                ForEach(stores, id: \.0) { store in
                    storeLogoCard(name: store.0, id: store.1, color: store.2)
                }
            }
        }
    }
    
    private func storeLogoCard(name: String, id: String, color: Color) -> some View {
        Button(action: {
            // Navigate to store
        }) {
            VStack(spacing: 8) {
                Circle()
                    .fill(color)
                    .frame(width: 60, height: 60)
                    .overlay(
                        Text(String(name.prefix(1)))
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    )
                
                Text(name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Category Section
    private func categorySection(title: String, items: [(String, String, Color)], backgroundColor: Color) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("See all") {
                    // Navigate to category
                }
                .font(.subheadline)
                .foregroundColor(.blue)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(items, id: \.0) { item in
                        categoryCard(name: item.0, icon: item.1, color: item.2, backgroundColor: backgroundColor)
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }
    
    private func categoryCard(name: String, icon: String, color: Color, backgroundColor: Color) -> some View {
        Button(action: {
            // Navigate to category
        }) {
            VStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(backgroundColor)
                    .frame(width: 120, height: 80)
                    .overlay(
                        Image(systemName: icon)
                            .font(.title2)
                            .foregroundColor(color)
                    )
                
                Text(name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - URL Paste Section
    private var urlPasteSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Paste Any Product Link")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            Button(action: {
                showingURLPaste = true
            }) {
                HStack {
                    Image(systemName: "link")
                        .font(.title3)
                        .foregroundColor(.blue)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Calculate Real Cost")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        Text("Paste any product URL to get the total cost including shipping and taxes to Israel")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    // MARK: - Search Results View
    private var searchResultsView: some View {
        VStack(spacing: 0) {
            // Search status header
            HStack {
                if isSearching {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Searching...")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                } else {
                    Text("\(searchResults.count) results for \"\(searchText)\"")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 12)
            
            // Search results list
            if searchResults.isEmpty && !isSearching {
                // Empty state
                VStack(spacing: 16) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    
                    Text("No products found")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("Try searching for a different product or check your spelling")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemGroupedBackground))
            } else {
                // Results list
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(searchResults, id: \.id) { product in
                            ProductRowView(product: product)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.top, 8)
                }
                .background(Color(.systemGroupedBackground))
            }
        }
    }
    
    // MARK: - Search Actions
    private func performSearch(query: String) {
        // Cancel any existing search
        searchTask?.cancel()
        
        // Clear results immediately if query is empty
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            searchResults = []
            isSearching = false
            return
        }
        
        // Start searching with a small delay to avoid too many API calls while typing
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000) // 300ms delay
            
            // Check if task was cancelled
            guard !Task.isCancelled else { return }
            
            await MainActor.run {
                isSearching = true
            }
            
            do {
                let result = try await searchService.searchProducts(query: query.trimmingCharacters(in: .whitespacesAndNewlines))
                
                // Check if task was cancelled before updating UI
                guard !Task.isCancelled else { return }
                
                await MainActor.run {
                    searchResults = result.products
                    isSearching = false
                }
            } catch {
                // Check if task was cancelled before updating UI
                guard !Task.isCancelled else { return }
                
                await MainActor.run {
                    searchResults = []
                    isSearching = false
                }
                print("Search error: \(error.localizedDescription)")
            }
        }
    }
    
    private func clearSearch() {
        searchTask?.cancel()
        searchText = ""
        searchResults = []
        isSearching = false
    }
}

// MARK: - Product Row View
struct ProductRowView: View {
    let product: Product
    
    var body: some View {
        HStack(spacing: 12) {
            // Product Image Placeholder
            AsyncImage(url: URL(string: product.imageURL ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    )
            }
            .frame(width: 60, height: 60)
            .clipped()
            .cornerRadius(8)
            
            // Product Details
            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                Text(product.storeName)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack {
                    if product.price > 0 {
                        Text("$\(product.price, specifier: "%.2f")")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    Text(product.category)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(4)
                }
            }
            
            Spacer()
            
            // Action Button
            Button(action: {
                // Navigate to product detail or open URL
                if let url = URL(string: product.productURL) {
                    UIApplication.shared.open(url)
                }
            }) {
                Image(systemName: "arrow.up.right")
                    .font(.caption)
                    .foregroundColor(.blue)
                    .padding(8)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(6)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Preview
#Preview {
    HomeView()
} 