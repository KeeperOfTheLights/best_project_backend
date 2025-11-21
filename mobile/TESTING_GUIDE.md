# Testing Guide for Authentication

## Quick Test Checklist

### ✅ Step 1: Test UI (No Backend Needed)

1. **Login Screen**
   - [ ] App opens to Login screen
   - [ ] Email field appears
   - [ ] Password field appears (hidden text)
   - [ ] "Login" button is visible
   - [ ] "Sign Up" link at bottom works

2. **Form Validation (Login)**
   - [ ] Try clicking "Login" with empty fields → Should show error messages
   - [ ] Enter invalid email (e.g., "test") → Should show "Please enter a valid email"
   - [ ] Enter short password (e.g., "123") → Should show "Password must be at least 6 characters"
   - [ ] Enter valid email + password → Form should accept it

3. **Sign Up Screen**
   - [ ] Click "Sign Up" → Should navigate to Sign Up screen
   - [ ] Role selection (Consumer/Supplier) works
   - [ ] When "Consumer" selected → Shows Business Name, Address, Phone fields
   - [ ] When "Supplier" selected → Shows Company Name, Company Type, Address, Phone fields
   - [ ] All required fields are marked

4. **Form Validation (Sign Up)**
   - [ ] Try submitting empty form → Should show errors
   - [ ] Enter mismatched passwords → Should show "Passwords do not match"
   - [ ] Fill all fields correctly → Form should accept

---

### ✅ Step 2: Test with Backend (Requires Backend URL)

**First, update the backend URL:**

1. Open `lib/utils/constants.dart`
2. Change line 5 from:
   ```dart
   const String baseUrl = 'http://your-backend-url.com/api';
   ```
   To your actual backend URL, for example:
   ```dart
   const String baseUrl = 'http://localhost:8000/api';
   // OR
   const String baseUrl = 'http://192.168.1.100:3000/api';
   // OR your production URL
   const String baseUrl = 'https://api.yourdomain.com/api';
   ```

**Then test:**

1. **Sign Up Test**
   - [ ] Fill Sign Up form with new user data
   - [ ] Click "Sign Up"
   - [ ] Should show loading indicator
   - [ ] If successful → Should navigate to Dashboard
   - [ ] If failed → Should show error message (red snackbar)

2. **Login Test**
   - [ ] Enter email and password of existing user
   - [ ] Click "Login"
   - [ ] Should show loading indicator
   - [ ] If successful → Should navigate to Dashboard
   - [ ] If failed → Should show error message

3. **Auto-Login Test**
   - [ ] After successful login, close the app
   - [ ] Reopen the app
   - [ ] Should automatically go to Dashboard (not Login screen)
   - [ ] Token should be saved

4. **Logout Test**
   - [ ] From Dashboard, click Logout button (top right)
   - [ ] Should return to Login screen
   - [ ] Token should be cleared

---

## Expected Backend API Format

Your backend should accept these requests:

### Sign Up Endpoint
- **URL:** `POST /api/auth/signup`
- **Body (Consumer):**
  ```json
  {
    "email": "user@example.com",
    "password": "password123",
    "name": "John Doe",
    "role": "consumer",
    "business_name": "My Restaurant",
    "address": "123 Main St",
    "phone": "1234567890"
  }
  ```
- **Body (Supplier):**
  ```json
  {
    "email": "supplier@example.com",
    "password": "password123",
    "name": "Jane Smith",
    "role": "supplier",
    "company_name": "ABC Foods",
    "company_type": "Food Distributor",
    "address": "456 Business Ave",
    "phone": "0987654321"
  }
  ```
- **Response (Success):**
  ```json
  {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "id": "123",
      "email": "user@example.com",
      "name": "John Doe",
      "role": "consumer",
      "business_name": "My Restaurant",
      "address": "123 Main St",
      "phone": "1234567890"
    }
  }
  ```

### Login Endpoint
- **URL:** `POST /api/auth/login`
- **Body:**
  ```json
  {
    "email": "user@example.com",
    "password": "password123"
  }
  ```
- **Response:** Same format as Sign Up response

---

## Troubleshooting

### "Connection error" message
- ✅ Check if backend is running
- ✅ Check if backend URL is correct in `constants.dart`
- ✅ Check if backend URL is accessible from your device/emulator
  - For localhost: Use `http://10.0.2.2:8000` on Android emulator
  - For localhost: Use `http://localhost:8000` on Chrome/web
  - For network: Use your computer's IP address (e.g., `http://192.168.1.100:8000`)

### App crashes on startup
- ✅ Run `flutter pub get` to ensure all packages are installed
- ✅ Check for any syntax errors in the code

### Login/Signup doesn't navigate to dashboard
- ✅ Check browser console (F12) for errors
- ✅ Verify backend returns correct response format
- ✅ Check if token is being saved (check browser DevTools → Application → Local Storage)

---

## Quick Test Commands

```bash
# Run on Chrome (web)
flutter run -d chrome

# Run on Windows (requires Developer Mode)
flutter run -d windows

# Check for errors
flutter analyze

# Get dependencies
flutter pub get
```




