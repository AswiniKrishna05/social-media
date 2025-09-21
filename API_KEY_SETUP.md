# API Key Setup Guide

## 🔑 **Current Status: NO API KEY REQUIRED**

The current implementation uses **mock/simulated data** and doesn't require any API key.

## 🚀 **To Use Real API with Authentication**

### **Option 1: Simple API Key Setup**

1. **Edit `lib/services/api_config.dart`**:
```dart
static const String _apiKey = 'your-actual-api-key-here';
static const String _baseUrl = 'https://your-api-endpoint.com/api/v1';
```

2. **Replace the mock service** in your ViewModel:
```dart
// In api_post_viewmodel.dart, replace:
// return _getMockApiPosts();
// With:
return RealApiService.fetchPosts();
```

### **Option 2: Environment Variables (Recommended)**

1. **Create `.env` file** in project root:
```env
API_KEY=your-actual-api-key-here
API_BASE_URL=https://your-api-endpoint.com/api/v1
```

2. **Add flutter_dotenv dependency**:
```yaml
dependencies:
  flutter_dotenv: ^5.1.0
```

3. **Load environment variables**:
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

static String get apiKey => dotenv.env['API_KEY'] ?? '';
static String get baseUrl => dotenv.env['API_BASE_URL'] ?? '';
```

### **Option 3: Secure Storage (Most Secure)**

1. **Add flutter_secure_storage**:
```yaml
dependencies:
  flutter_secure_storage: ^9.0.0
```

2. **Store API key securely**:
```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

static const _storage = FlutterSecureStorage();

static Future<String> getApiKey() async {
  return await _storage.read(key: 'api_key') ?? '';
}
```

## 🔧 **API Key Types Supported**

### **Bearer Token Authentication**
```dart
static Map<String, String> get authHeaders => {
  'Authorization': 'Bearer $_apiKey',
  'Content-Type': 'application/json',
};
```

### **API Key Header**
```dart
static Map<String, String> get authHeaders => {
  'X-API-Key': _apiKey,
  'Content-Type': 'application/json',
};
```

### **Query Parameter**
```dart
static String getPostsUrl() {
  return '${_baseUrl}/posts?api_key=$_apiKey';
}
```

## 📋 **Popular API Services**

### **Firebase (Google)**
- **API Key**: Found in Firebase Console → Project Settings
- **Base URL**: `https://firestore.googleapis.com/v1/projects/{project-id}`
- **Auth**: Bearer token from Firebase Auth

### **Supabase**
- **API Key**: Found in Supabase Dashboard → Settings → API
- **Base URL**: `https://your-project.supabase.co/rest/v1`
- **Auth**: `apikey` header

### **AWS API Gateway**
- **API Key**: Generated in AWS Console
- **Base URL**: Your API Gateway endpoint
- **Auth**: `x-api-key` header

### **Custom REST API**
- **API Key**: Provided by your backend team
- **Base URL**: Your server endpoint
- **Auth**: As specified by your API documentation

## 🛡️ **Security Best Practices**

### **1. Never Commit API Keys**
```gitignore
# Add to .gitignore
.env
.env.local
.env.production
```

### **2. Use Different Keys for Different Environments**
```dart
static String get apiKey {
  if (kDebugMode) {
    return 'development-api-key';
  } else {
    return 'production-api-key';
  }
}
```

### **3. Validate API Key Configuration**
```dart
static bool get isApiKeyConfigured {
  return _apiKey.isNotEmpty && _apiKey != 'YOUR_API_KEY_HERE';
}
```

## 🚀 **Quick Setup for Testing**

### **Step 1: Choose Your API**
- **JSONPlaceholder** (free, no key needed): `https://jsonplaceholder.typicode.com`
- **ReqRes** (free, no key needed): `https://reqres.in`
- **Your own API**: Set up your backend

### **Step 2: Update Configuration**
```dart
// In api_config.dart
static const String _baseUrl = 'https://jsonplaceholder.typicode.com';
static const String _apiKey = ''; // No key needed for JSONPlaceholder
```

### **Step 3: Test API Connection**
```dart
// Test in your app
final isHealthy = await RealApiService.checkApiHealth();
print('API Health: $isHealthy');
```

## 📱 **Current Implementation**

The app currently works with **mock data** and doesn't require any API key. To switch to real API:

1. **Set your API key** in `api_config.dart`
2. **Update base URL** to your API endpoint
3. **Replace mock service calls** with real API calls
4. **Test the connection** using the health check

## ✅ **Ready to Use**

The API infrastructure is ready - just add your API key and endpoint! 🚀
