# Signup Process Fix - Summary

## 🎯 Goal
Align mobile app signup with the website and backend, ensuring both use the same endpoint and data format.

## ✅ Changes Made

### 1. **Signup Screen UI** (`mobile/lib/screens/signup_screen.dart`)

**Before:**
- Complex form with Consumer/Supplier role selection
- Separate fields for business name, company name, address, phone
- Supplier sub-role selection (Owner/Manager/Sales) as a separate step

**After:**
- Simple form matching website exactly:
  - **Full Name** field
  - **Username** field (collected but not sent to backend - for UI consistency)
  - **Email Address** field
  - **Password** field
  - **Repeat Password** field
  - **Role buttons**: Consumer, Owner, Manager, Sales Rep (horizontal layout matching website)

**Key Changes:**
- Removed all extra fields (business name, company name, address, phone)
- Simplified role selection to 4 buttons matching website
- Added password strength validation (matching website requirements)
- Updated UI styling to match website design

---

### 2. **Signup Service** (`mobile/lib/services/api_service.dart`)

**Before:**
- Sent `name` (should be `full_name`)
- Sent extra fields that backend doesn't accept
- Response parsing didn't handle refresh token

**After:**
- Sends **ONLY** what backend expects (matching `RegisterSerializer`):
  ```json
  {
    "full_name": "...",
    "email": "...",
    "password": "...",
    "password2": "...",
    "role": "consumer|owner|manager|sales"
  }
  ```
- Proper error handling for field-specific errors
- Response parsing includes refresh token

**Backend Endpoint:** `POST /api/accounts/register/`

**Backend Response:**
```json
{
  "message": "User registered successfully",
  "id": 123,
  "role": "consumer",
  "token": "access_token_here",
  "refresh": "refresh_token_here"
}
```

---

### 3. **Auth Response Model** (`mobile/lib/models/auth_response.dart`)

**Added:**
- `refreshToken` field to store refresh token from backend
- Proper parsing of `refresh` field from backend response

---

### 4. **Storage Service** (`mobile/lib/services/storage_service.dart`)

**Added:**
- `saveRefreshToken()` method
- `getRefreshToken()` method

---

### 5. **Storage Keys** (`mobile/lib/utils/constants.dart`)

**Added:**
- `refreshToken` key for storing refresh token

---

### 6. **Auth Provider** (`mobile/lib/providers/auth_provider.dart`)

**Updated:**
- Both `login()` and `signup()` methods now save refresh token
- Ensures refresh token is available for token renewal

---

## 🔄 Data Flow

### Signup Process:

1. **User fills form** → Full Name, Username, Email, Password, Repeat Password, Role
2. **Mobile app validates:**
   - All fields required
   - Passwords match
   - Password strength (min 6 chars, uppercase, number, special char)
3. **Mobile app sends to backend:**
   ```json
   {
     "full_name": "John Doe",
     "email": "john@example.com",
     "password": "Password123!",
     "password2": "Password123!",
     "role": "consumer"
   }
   ```
4. **Backend validates and creates user:**
   - Validates password match
   - Creates user in database
   - Auto-creates company if role is "owner"
   - Returns tokens
5. **Mobile app receives:**
   ```json
   {
     "message": "User registered successfully",
     "id": 123,
     "role": "consumer",
     "token": "access_token",
     "refresh": "refresh_token"
   }
   ```
6. **Mobile app saves:**
   - Access token
   - Refresh token
   - User data (id, email, name, role)
7. **User is logged in** → Navigated to appropriate dashboard

---

## 🧪 Testing Checklist

### Test 1: Create Account in Mobile → Login on Website
- [ ] Fill signup form in mobile app
- [ ] Submit with valid data
- [ ] Verify account created successfully
- [ ] Open website and login with same credentials
- [ ] ✅ Should login successfully

### Test 2: Create Account on Website → Login in Mobile
- [ ] Fill signup form on website
- [ ] Submit with valid data
- [ ] Verify account created successfully
- [ ] Open mobile app and login with same credentials
- [ ] ✅ Should login successfully

### Test 3: Password Validation
- [ ] Try password < 6 characters → Should show error
- [ ] Try password without uppercase → Should show error
- [ ] Try password without number → Should show error
- [ ] Try password without special char → Should show error
- [ ] Try passwords that don't match → Should show error
- [ ] Try valid password → Should work

### Test 4: Role Selection
- [ ] Select Consumer → Should work
- [ ] Select Owner → Should work (auto-creates company)
- [ ] Select Manager → Should work
- [ ] Select Sales Rep → Should work

### Test 5: Error Handling
- [ ] Try duplicate email → Should show backend error
- [ ] Try invalid email format → Should show validation error
- [ ] Try missing fields → Should show validation error

---

## 🔍 Key Points

1. **Backend doesn't use username** - It's collected in the UI for consistency with website, but not sent to backend
2. **Only 5 fields sent to backend**: `full_name`, `email`, `password`, `password2`, `role`
3. **Role values**: `consumer`, `owner`, `manager`, `sales` (not `supplier`)
4. **Password requirements**: Min 6 chars, uppercase, number, special character
5. **Refresh token**: Now properly saved for token renewal
6. **Synchronization**: Both mobile and website use same endpoint → same database → fully synchronized

---

## 📝 Files Modified

1. `mobile/lib/screens/signup_screen.dart` - Complete UI redesign
2. `mobile/lib/services/api_service.dart` - Updated signup method
3. `mobile/lib/models/auth_response.dart` - Added refresh token support
4. `mobile/lib/services/storage_service.dart` - Added refresh token storage
5. `mobile/lib/utils/constants.dart` - Added refresh token key
6. `mobile/lib/providers/auth_provider.dart` - Save refresh token on login/signup

---

## 🚀 Next Steps

1. **Test the signup flow** end-to-end
2. **Verify synchronization** between mobile and website
3. **Test all role types** (consumer, owner, manager, sales)
4. **Test error cases** (duplicate email, invalid data, etc.)

---

## ⚠️ Important Notes

- **Username field**: Collected but not sent to backend (backend doesn't use it)
- **Extra fields removed**: Business name, company name, address, phone are NOT sent during registration
- **Role values**: Must be exactly `consumer`, `owner`, `manager`, or `sales` (lowercase)
- **Password confirmation**: Backend requires `password2` field matching `password`
- **Company creation**: Backend automatically creates company for "owner" role users

---

**Status:** ✅ Signup process now fully aligned with backend and website!


