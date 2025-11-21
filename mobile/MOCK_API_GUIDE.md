# Testing with Mock API (No Backend Needed!)

## ✅ What I've Set Up

I've created a **Mock API Service** that simulates your backend responses. This means you can test the **entire authentication flow** without needing a real backend!

## 🚀 How to Test

### Step 1: Make sure Mock API is enabled

Open `lib/utils/constants.dart` and check line 6:
```dart
const bool useMockApi = true; // ✅ Should be true
```

### Step 2: Run the app
```bash
flutter run -d chrome
```

### Step 3: Test Sign Up

1. **Click "Sign Up"** on the login screen
2. **Select a role** (Consumer or Supplier)
3. **Fill in the form:**
   - Name: Any name (e.g., "John Doe")
   - Email: Any email (e.g., "test@example.com")
   - Password: At least 6 characters (e.g., "password123")
   - Confirm Password: Same as password
   - Fill role-specific fields (Business Name for Consumer, Company Name/Type for Supplier)
4. **Click "Sign Up"**
5. **Expected Result:**
   - ✅ Loading indicator appears
   - ✅ After ~1 second, navigates to Dashboard
   - ✅ Shows welcome message with your name

### Step 4: Test Login

1. **Logout** from dashboard (click logout button top right)
2. **On Login screen**, enter:
   - Email: Any email (e.g., "test@example.com")
   - Password: Any password (at least 6 characters)
3. **Click "Login"**
4. **Expected Result:**
   - ✅ Loading indicator appears
   - ✅ After ~1 second, navigates to Dashboard
   - ✅ Shows welcome message

### Step 5: Test Auto-Login

1. **After successful login**, close the app completely
2. **Reopen the app**
3. **Expected Result:**
   - ✅ Should automatically go to Dashboard (not Login screen)
   - ✅ Token was saved and loaded

### Step 6: Test Error Cases

**Test validation errors:**
- Try submitting empty form → Should show errors
- Try invalid email → Should show error
- Try short password (< 6 chars) → Should show error
- Try mismatched passwords → Should show error

**Test mock API errors:**
- Try email: `existing@test.com` → Should show "Email already exists" error

## 🔄 Switching to Real Backend Later

When your friends finish the backend:

1. Open `lib/utils/constants.dart`
2. Change line 6:
   ```dart
   const bool useMockApi = false; // Change to false
   ```
3. Update line 10 with your real backend URL:
   ```dart
   const String baseUrl = 'http://your-actual-backend-url.com/api';
   ```
4. That's it! The app will automatically use the real API.

## 📝 What the Mock API Does

- ✅ Simulates network delay (1 second, like real API)
- ✅ Validates input (email, password length)
- ✅ Returns fake token and user data
- ✅ Saves token to device storage (so auto-login works)
- ✅ Handles different roles (Consumer/Supplier)
- ✅ Simulates some error cases

## 🎯 What You Can Test

With the mock API, you can fully test:
- ✅ Login flow
- ✅ Sign Up flow
- ✅ Form validation
- ✅ Navigation between screens
- ✅ Token storage
- ✅ Auto-login on app restart
- ✅ Logout functionality
- ✅ Role-based dashboards (Consumer vs Supplier)
- ✅ Error handling

**Everything works exactly like it will with the real backend!**




