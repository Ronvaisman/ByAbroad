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
    @State private var showingSearch = false
    @State private var showingURLPaste = false
    
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
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    headerSection
                    
                    // Search Bar
                    searchBarSection
                    
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
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingSearch) {
            SearchView(searchText: $searchText)
        }
        .sheet(isPresented: $showingURLPaste) {
            URLPasteView()
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
        Button(action: {
            showingSearch = true
        }) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                Text("Search products")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Image(systemName: "mic.fill")
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
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
}

// MARK: - Preview
#Preview {
    HomeView()
} 