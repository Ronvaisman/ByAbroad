# API Credentials Setup Guide - Unified Search Strategy

This guide will walk you through obtaining API credentials for **SerpApi** and **Rainforest API** to enable real product search across multiple platforms in ByAbroad.

## 🛡️ Security First

**⚠️ NEVER commit API credentials to Git!**

All credentials should be stored in:
- Environment variables (recommended for production)
- Info.plist entries (for development, add to .gitignore)
- External configuration files (not in repository)

## 📋 Prerequisites

Before starting, ensure you have:
- Valid email addresses for API registration
- Understanding of API usage terms and rate limits
- Development environment set up

---

## 🔍 SerpApi (Multi-Platform Search Engine)

### Why SerpApi?
SerpApi provides unified access to **50+ search engines** including:
- Google Shopping
- Amazon Search
- eBay Search  
- Walmart Search
- Bing Shopping
- Yahoo Shopping
- And many more!

### Step 1: Create SerpApi Account
1. Go to [SerpApi.com](https://serpapi.com/)
2. Click **"Sign Up"** 
3. Choose your plan:
   - **Free**: 100 searches/month
   - **Starter**: $28/month (10,000 searches)
   - **Grow**: $130/month (50,000 searches)

### Step 2: Get Your API Key
1. After registration, go to your **Dashboard**
2. Find **"Your Private API Key"**
3. Copy the key (format: `1234567890abcdef...`)

### Step 3: Configure in Your App
Add your SerpApi key to your environment:

```bash
export SERPAPI_API_KEY="your-serpapi-key-here"
```

Or add to your `Info.plist` (for development):
```xml
<key>SERPAPI_API_KEY</key>
<string>your-serpapi-key-here</string>
```

### Step 4: Test Your Setup
SerpApi provides multiple search engines in one API:

```bash
# Test Google Shopping search
curl "https://serpapi.com/search?engine=google_shopping&q=smartphone&api_key=YOUR_KEY"

# Test Amazon search
curl "https://serpapi.com/search?engine=amazon&q=smartphone&api_key=YOUR_KEY"

# Test eBay search  
curl "https://serpapi.com/search?engine=ebay&q=smartphone&api_key=YOUR_KEY"
```

---

## 🌧️ Rainforest API (Amazon Specialist)

### Why Rainforest API?
Rainforest API provides **deep Amazon data** including:
- Detailed product information
- Real-time pricing
- Product reviews and ratings
- Multiple marketplace support
- ASIN-based lookup

### Step 1: Request Rainforest API Access
1. Go to [RainforestAPI.com](https://rainforestapi.com/)
2. Click **"Get API Access"**
3. Fill out the application form
4. Describe your use case (price comparison for Israeli consumers)

### Step 2: Choose Your Plan
After approval, select a plan:
- **Starter**: $49/month (10,000 requests)
- **Growth**: $199/month (50,000 requests) 
- **Scale**: $599/month (250,000 requests)

### Step 3: Get Your API Key
1. Access your **Rainforest Dashboard**
2. Find **"API Credentials"**
3. Copy your API key

### Step 4: Configure in Your App
Add your Rainforest API key:

```bash
export RAINFOREST_API_KEY="your-rainforest-key-here"
```

Or add to your `Info.plist`:
```xml
<key>RAINFOREST_API_KEY</key>
<string>your-rainforest-key-here</string>
```

### Step 5: Test Your Setup
```bash
# Test Amazon product search
curl "https://api.rainforestapi.com/request?api_key=YOUR_KEY&type=search&amazon_domain=amazon.com&search_term=smartphone"

# Test specific product lookup
curl "https://api.rainforestapi.com/request?api_key=YOUR_KEY&type=product&asin=B08N5WRWNW&amazon_domain=amazon.com"
```

---

## 💱 Exchange Rate API (Optional but Recommended)

### Step 1: Choose Exchange Rate Service
We recommend [ExchangeRate-API.com](https://exchangerate-api.com/):
- **Free**: 1,500 requests/month
- **Basic**: $9/month (100,000 requests)

### Step 2: Get API Key
1. Sign up at ExchangeRate-API.com
2. Verify your email
3. Get your API key from the dashboard

### Step 3: Configure in Your App
```bash
export EXCHANGE_RATE_API_KEY="your-exchange-rate-key-here"
```

---

## 🚀 Quick Start Strategy

### Development Phase (Free/Low Cost)
1. **SerpApi Free Plan**: 100 searches/month for testing
2. **No Rainforest API**: Use SerpApi Amazon engine initially  
3. **Free Exchange Rate API**: 1,500 requests/month

**Total Cost**: $0/month

### Production Phase (Recommended)
1. **SerpApi Starter**: $28/month (10,000 searches)
2. **Rainforest API Growth**: $199/month (50,000 requests)
3. **Exchange Rate API Basic**: $9/month (100,000 requests)

**Total Cost**: $236/month for robust multi-platform search

### Scale Phase
1. **SerpApi Grow**: $130/month (50,000 searches)
2. **Rainforest API Scale**: $599/month (250,000 requests)
3. **Exchange Rate API Basic**: $9/month

**Total Cost**: $738/month for high-volume operations

---

## 🔧 Testing Your Setup

After configuring your APIs, test with our app:

1. **Build and run** the ByAbroad app
2. **Check console output** for API configuration status
3. **Try searches** to verify each API is working
4. **Monitor usage** in each API dashboard

## 📊 API Comparison: Why This Strategy Wins

| Feature | Individual APIs | SerpApi + Rainforest |
|---------|-----------------|---------------------|
| **Platforms Covered** | 4 separate integrations | 50+ platforms unified |
| **Setup Complexity** | High (4 different systems) | Low (2 unified systems) |
| **Maintenance** | High (4 different breaking changes) | Low (centralized updates) |
| **Cost Efficiency** | Variable | Predictable |
| **Rate Limits** | 4 different limits to manage | 2 clear limits |
| **Data Quality** | Inconsistent across platforms | Standardized JSON |

## 🎯 Benefits for ByAbroad

1. **Faster Development**: One integration = multiple platforms
2. **Better Data Quality**: Standardized, clean JSON responses  
3. **Easier Maintenance**: Fewer API changes to track
4. **Broader Coverage**: Access to platforms we couldn't get directly
5. **Cost Predictability**: Clear pricing tiers
6. **Israeli Localization**: Global location support built-in

## ⚠️ Important Notes

- **Start Small**: Use free tiers for development and testing
- **Monitor Usage**: Both APIs provide detailed usage dashboards
- **Rate Limiting**: Implement proper caching to stay within limits
- **Error Handling**: Both APIs have comprehensive error documentation
- **Backup Strategy**: SerpApi can cover Amazon searches if Rainforest API is down

## 🆘 Getting Help

- **SerpApi Support**: support@serpapi.com
- **Rainforest API Support**: Available through their dashboard
- **Documentation**: Both APIs have excellent docs and examples

This unified approach gives us the power of multiple e-commerce platforms through just two well-designed APIs, making our development faster, more reliable, and easier to maintain. 