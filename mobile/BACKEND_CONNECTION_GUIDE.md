# Backend Connection Guide

## How Mobile App Connects to Backend

### Simple Explanation

Your mobile app and your friends' website both connect to the **same backend server** which stores all data in one database. This means:

- ✅ When they add a supplier/product on the website → It's saved in the database
- ✅ When you open your mobile app → It requests data from the same database
- ✅ **Result: Data is automatically synchronized!**

### How It Works

```
Website → Backend → Database
                        ↓
Mobile App ← Backend ← Database
```

**Example Flow:**
1. Friend adds "Pizza Supplier" on website
2. Website sends data to backend → Backend saves to database
3. You open "Search Suppliers" in mobile app
4. App requests: `GET /suppliers/search`
5. Backend reads from database → Returns list including "Pizza Supplier"
6. You see "Pizza Supplier" in your app! 🎉

---

## Steps to Connect Your App to Real Backend

### Step 1: Get Backend URL from Your Friends

Ask them for the backend URL. Examples:
- Local testing: `http://localhost:8000/api`
- Same network: `http://192.168.1.100:3000/api`
- Deployed: `https://api.yourproject.com/api`

### Step 2: Update Your App Settings

Open `lib/utils/constants.dart` and change:

```dart
// Change this:
const bool useMockApi = true;

// To this:
const bool useMockApi = false;

// And update the URL:
const String baseUrl = 'http://your-friends-backend-url.com/api';
```

### Step 3: Verify Endpoint Names Match

Your app expects these endpoints:
- `/auth/login`
- `/auth/signup`
- `/suppliers/search`
- `/catalog`
- `/orders`
- `/chat/rooms`
- `/staff`
- `/complaints`
- `/link-requests`

**Ask your friends if their endpoint names match.** If different, we need to update them.

---

## Current App Structure

### API Services
Your app has separate service files for each feature:
- `api_service.dart` - Authentication (login/signup)
- `catalog_service.dart` - Product catalog
- `order_service.dart` - Orders
- `chat_service.dart` - Chat messages
- `link_request_service.dart` - Supplier-consumer linking
- `staff_service.dart` - Staff management
- `complaint_service.dart` - Complaints
- `supplier_service.dart` - Supplier management

### How Services Work

All services:
1. Get authentication token from `StorageService`
2. Send HTTP request to backend with token in header: `Authorization: Bearer <token>`
3. Receive response from backend
4. Convert JSON response to Dart models
5. Return data to providers

### Mock vs Real API

Your app uses a smart switch system:
- When `useMockApi = true` → Uses mock services (fake data for testing)
- When `useMockApi = false` → Uses real API services (connects to backend)

**All providers automatically switch** - you just change one flag!

---

## Data Synchronization

### How Data Stays in Sync

**Option 1: On-Demand Sync (Current Setup)**
- When user opens a screen → App requests fresh data from backend
- Example: Opening catalog screen fetches latest products
- Pull-to-refresh also fetches latest data

**Option 2: Real-Time Sync (If Backend Supports)**
- Backend sends updates immediately when data changes
- Requires WebSocket or similar technology
- Not currently implemented, but can be added later

### Example: Adding a Product

1. **On Website:**
   - Supplier adds "New Pizza" product
   - Website sends: `POST /catalog` with product data
   - Backend saves to database

2. **On Mobile App:**
   - Consumer opens catalog screen
   - App sends: `GET /catalog/supplier/{supplierId}`
   - Backend returns all products including "New Pizza"
   - Consumer sees "New Pizza" in app

---

## Testing the Connection

### Before Connecting:
- [ ] Get backend URL from friends
- [ ] Verify endpoint names match
- [ ] Test login endpoint first
- [ ] Check authentication token format matches

### Testing Steps:

1. **Test Login First:**
   - Set `useMockApi = false`
   - Update `baseUrl`
   - Try logging in with a test account
   - If login works → Connection is good! ✅

2. **Test Other Features:**
   - Try searching suppliers
   - Try viewing catalog
   - Try creating an order
   - Check if data matches website

### Common Issues:

**Problem:** "Connection error"
- **Solution:** Check if backend URL is correct
- **Solution:** Check if backend server is running
- **Solution:** Check internet connection

**Problem:** "401 Unauthorized"
- **Solution:** Token might be expired - try logging in again
- **Solution:** Check if token format matches backend expectations

**Problem:** "404 Not Found"
- **Solution:** Endpoint name might be wrong - check with friends
- **Solution:** Check if endpoint path is correct

---

## What Your Friends Need to Know

### Authentication
- Your app sends: `Authorization: Bearer <token>` header
- Token is received after login/signup
- Token is stored locally and sent with every request

### Request Format
- All requests use JSON format
- Headers include: `Content-Type: application/json`
- POST/PUT requests send data in request body

### Response Format
- Backend should return JSON
- Success: Status code 200 or 201
- Error: Status code 4xx or 5xx with error message

### Expected Data Formats

**Login Response:**
```json
{
  "token": "abc123...",
  "user": {
    "id": "user123",
    "email": "user@example.com",
    "name": "John Doe",
    "role": "consumer"
  }
}
```

**Catalog Items:**
```json
[
  {
    "id": "item1",
    "name": "Product Name",
    "description": "Description",
    "price": 10.99,
    "stock": 100,
    "category": "Food",
    "unit": "kg"
  }
]
```

---

## Quick Reference

### File to Update:
- `lib/utils/constants.dart` - Change `useMockApi` and `baseUrl`

### Key Files:
- `lib/services/api_service.dart` - Authentication
- `lib/services/catalog_service.dart` - Products
- `lib/services/order_service.dart` - Orders
- All other service files in `lib/services/`

### How to Switch:
1. Open `lib/utils/constants.dart`
2. Set `useMockApi = false`
3. Set `baseUrl = 'your-backend-url'`
4. Done! App will use real backend

---

## Need Help?

If endpoints don't match or you encounter issues:
1. Check endpoint names with your friends
2. Verify request/response formats match
3. Test with a simple endpoint first (like login)
4. Check error messages for clues

---

**Created:** Based on conversation about connecting mobile app to backend
**Last Updated:** Today

