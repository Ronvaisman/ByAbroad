//
//  SearchView.swift
//  ByAbroad
//
//  Created on 22/07/2025.
//

import SwiftUI

struct SearchView: View {
    @Binding var searchText: String
    @StateObject private var searchService = ProductSearchService.shared
    @Environment(\.dismiss) private var dismiss
    @State private var isSearching = false
    @State private var searchResults: [Product] = []
    @State private var showingSuggestions = true
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                searchBarSection
                
                if showingSuggestions {
                    // Search Suggestions
                    suggestionsSection
                } else {
                    // Search Results
                    resultsSection
                }
                
                Spacer()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Search Products")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                // Auto-focus search field
            }
        }
    }
    
    // MARK: - Search Bar Section
    private var searchBarSection: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search for products...", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
                .onSubmit {
                    performSearch()
                }
                .onChange(of: searchText) { _, newValue in
                    showingSuggestions = newValue.isEmpty
                    if !newValue.isEmpty && newValue.count > 2 {
                        // Could trigger live search here
                    }
                }
            
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                    showingSuggestions = true
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
            
            Button(action: {
                // Voice search
            }) {
                Image(systemName: "mic.fill")
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .padding(.horizontal)
        .padding(.top)
    }
    
    // MARK: - Suggestions Section
    private var suggestionsSection: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if !searchService.searchHistory.isEmpty {
                    recentSearchesSection
                }
                
                popularSearchesSection
                
                categoriesSection
            }
            .padding()
        }
    }
    
    private var recentSearchesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Searches")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("Clear") {
                    // Clear search history
                }
                .font(.subheadline)
                .foregroundColor(.blue)
            }
            
            ForEach(searchService.searchHistory.prefix(5), id: \.self) { query in
                Button(action: {
                    searchText = query
                    performSearch()
                }) {
                    HStack {
                        Image(systemName: "clock.arrow.circlepath")
                            .foregroundColor(.secondary)
                        
                        Text(query)
                            .foregroundColor(.primary)
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    private var popularSearchesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Popular Searches")
                .font(.headline)
                .fontWeight(.semibold)
            
            let popularSearches = ["iPhone", "MacBook", "AirPods", "Nike Shoes", "Samsung TV", "PlayStation"]
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 8) {
                ForEach(popularSearches, id: \.self) { query in
                    Button(action: {
                        searchText = query
                        performSearch()
                    }) {
                        Text(query)
                            .font(.subheadline)
                            .foregroundColor(.blue)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(16)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
    
    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Browse Categories")
                .font(.headline)
                .fontWeight(.semibold)
            
            let categories = [
                ("Electronics", "laptopcomputer", Color.blue),
                ("Clothing", "tshirt.fill", Color.pink),
                ("Home & Garden", "house.fill", Color.green),
                ("Beauty", "sparkles", Color.purple),
                ("Sports", "figure.run", Color.orange),
                ("Books", "book.fill", Color.brown)
            ]
            
            ForEach(categories, id: \.0) { category in
                Button(action: {
                    // Browse category
                }) {
                    HStack {
                        Image(systemName: category.1)
                            .foregroundColor(category.2)
                            .frame(width: 24)
                        
                        Text(category.0)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                    .padding(.vertical, 12)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    // MARK: - Results Section
    private var resultsSection: some View {
        Group {
            if isSearching {
                VStack {
                    ProgressView()
                        .scaleEffect(1.2)
                    
                    Text("Searching...")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.top)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if searchResults.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    
                    Text("No results found")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("Try searching for something else")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                // Search Results List
                List(searchResults) { product in
                    ProductRowView(product: product)
                }
                .listStyle(PlainListStyle())
            }
        }
    }
    
    // MARK: - Actions
    private func performSearch() {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        showingSuggestions = false
        isSearching = true
        
        Task {
            do {
                let result = try await searchService.searchProducts(query: searchText)
                await MainActor.run {
                    self.searchResults = result.products
                    self.isSearching = false
                }
            } catch {
                await MainActor.run {
                    self.isSearching = false
                    // Handle error
                }
            }
        }
    }
}

// MARK: - Product Row View
struct ProductRowView: View {
    let product: Product
    
    var body: some View {
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
                
                Text(product.storeName)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack {
                    Text("$\(product.price, specifier: "%.2f")")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(product.currency)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Button(action: {
                // Calculate cost
            }) {
                Text("Calculate")
                    .font(.caption)
                    .foregroundColor(.blue)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    SearchView(searchText: .constant(""))
} 