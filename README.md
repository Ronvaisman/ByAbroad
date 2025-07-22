# 🌍 By Abroad

**Shop worldwide, know your real cost**

An iOS app for Israelis to discover, price, and purchase products from international online stores with transparent final cost calculations including shipping, taxes, and Israeli import duties.

[![iOS](https://img.shields.io/badge/iOS-18.5+-blue.svg)](https://developer.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-5.0-orange.svg)](https://swift.org/)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-✓-green.svg)](https://developer.apple.com/swiftui/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

## 📱 Screenshots

*Beautiful, modern iOS interface designed for iPhone 16 Pro*

## ✨ Features

### 🔍 **Multi-Store Product Search**
- Search across Amazon, eBay, and Best Buy
- Smart suggestions and search history
- Category-based browsing (Electronics, Clothing, Home, Beauty)
- Real-time results with product images and pricing

### 🔗 **Universal Link Calculator**
- **Supported Stores**: Amazon, eBay, Best Buy, Zara, ASOS
- Automatic price detection and parsing
- Manual entry fallback for unsupported stores
- Store detection with support indicators

### 💰 **Israeli Cost Calculator**
- Complete cost breakdown including:
  - Item price + local sales tax
  - Currency conversion (real-time exchange rates)
  - Shipping forwarder fees (UShops, DealTas, Shipito)
  - Israeli import duties and VAT (17%)
  - Customs handling fees
- Compare multiple shipping forwarders
- Savings tips and recommendations

### 🎯 **Smart Features**
- Anonymous domain logging for feature prioritization
- Clipboard URL detection
- Search history and popular suggestions
- Offline cost calculation review

## 🏗️ Architecture

### **Modern iOS Stack**
- **SwiftUI** - Declarative UI framework
- **SwiftData** - Core Data successor for persistence
- **Async/Await** - Modern concurrency
- **MVVM Pattern** - Clean architecture

### **Core Components**
```
├── Models/
│   ├── Product.swift          # Product data model
│   ├── Store.swift            # Retailer information
│   ├── CostCalculation.swift  # Cost breakdown storage
│   └── ShippingForwarder.swift # Shipping company data
├── Services/
│   ├── NetworkManager.swift        # HTTP client & API calls
│   ├── ProductSearchService.swift  # Multi-store search
│   ├── URLParsingService.swift     # Web scraping & parsing
│   ├── CostCalculationService.swift # Israeli tax calculations
│   └── AnalyticsService.swift      # Anonymous usage tracking
└── Views/
    ├── HomeView.swift         # Main interface
    ├── SearchView.swift       # Search & results
    └── URLPasteView.swift     # Link calculator
```

## 🚀 Getting Started

### **Prerequisites**
- Xcode 16.0+
- iOS 18.5+ deployment target
- iPhone 16 Pro for optimal testing

### **Installation**
1. Clone the repository:
   ```bash
   git clone https://github.com/Ronvaisman/ByAbroad.git
   cd ByAbroad
   ```

2. Open in Xcode:
   ```bash
   open ShpitZ.xcodeproj
   ```

3. Build and run on iPhone 16 Pro simulator

### **API Setup** (Coming Soon)
The app is designed to work with:
- Amazon Product Advertising API
- eBay Browse API  
- Best Buy Products API

*Currently uses mock data for development*

## 📋 Development Status

### ✅ **Phase 1: Foundation & Core Architecture** 
*Completed July 22, 2025*
- [x] SwiftData models and architecture
- [x] Network layer with error handling
- [x] Core services implementation
- [x] iPhone 16 Pro compatibility

### ✅ **Phase 2: Main UI Implementation**
*Completed July 22, 2025*
- [x] Beautiful HomeView with modern design
- [x] Advanced SearchView with suggestions
- [x] Professional URLPasteView with store detection
- [x] Responsive layouts and animations

### 🔄 **Phase 3: API Integration** 
*Next Priority*
- [ ] Amazon Product API integration
- [ ] eBay Browse API integration  
- [ ] Best Buy Products API integration
- [ ] Real-time product search

### 🔄 **Phase 4: URL Calculator**
*In Progress*
- [ ] Web scraping for supported stores
- [ ] Generic scraping fallback
- [ ] Product information extraction
- [ ] Error handling improvements

### 🔄 **Phase 5: Cost Calculation Engine**
- [ ] Real-time exchange rates
- [ ] Shipping forwarder API integration
- [ ] Israeli customs calculator
- [ ] Tax optimization suggestions

## 🛠️ Technical Features

### **Network Layer**
- Modern URLSession with async/await
- Comprehensive error handling
- Retry logic and timeout management
- Image caching and download

### **Data Persistence**
- SwiftData for local storage
- Calculation history
- Search history and preferences
- Offline-first approach

### **Security & Privacy**
- Anonymous domain logging only
- No personal data collection
- Privacy Policy compliant
- Israeli GDPR considerations

## 🧪 Testing

The app includes comprehensive testing:
- Unit tests for all service classes
- Data model validation tests
- Cost calculation algorithm tests
- UI testing for critical flows

**Test on iPhone 16 Pro for optimal experience**

## 🤝 Contributing

We follow strict development rules for quality:

1. **Documentation**: Update plan.md with progress
2. **Testing**: Test on iPhone 16 Pro simulator
3. **Code Quality**: Unit tests for all new code
4. **Architecture**: Maintain MVVM pattern
5. **Scope**: Stick to PRD requirements

See [rules.md](rules.md) for complete development guidelines.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Designed for the Israeli shopping community
- Built with modern iOS development best practices
- Focused on transparency and user trust

---

**📧 Questions?** Open an issue or contact the development team.

**🌟 Like the project?** Give it a star and share with fellow international shoppers! 