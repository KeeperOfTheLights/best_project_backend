# Step-by-Step Testing Guide

## Prerequisites

Before testing, make sure you have:
- ✅ Django backend code in the project root
- ✅ Flutter SDK installed
- ✅ Python and Django installed
- ✅ PostgreSQL database running (or SQLite if configured)

---

## Step 1: Start the Django Backend

### 1.1 Open a Terminal/PowerShell Window

Open a **new** PowerShell or Command Prompt window (keep this open - you'll need it running).

### 1.2 Navigate to Project Root

```powershell
cd C:\Users\islam\best_project_backend
```

### 1.3 Activate Virtual Environment (if you have one)

If you're using a virtual environment:
```powershell
# Example (adjust path if different):
.\venv\Scripts\Activate.ps1
```

### 1.4 Start Django Server

```powershell
python manage.py runserver
```

**Expected Output:**
```
Starting development server at http://127.0.0.1:8000/
Quit the server with CTRL-BREAK.
```

✅ **Success Indicator:** You should see "Starting development server at http://127.0.0.1:8000/"

**⚠️ Keep this terminal window open!** The backend must stay running.

---

## Step 2: Verify Backend is Running

### 2.1 Test Backend in Browser

Open your web browser and go to:
```
http://localhost:8000/api/accounts/
```

**Expected Result:**
- You might see an error page (this is OK - it means the server is running)
- Or you might see a JSON response
- **Important:** You should NOT see "This site can't be reached" or connection errors

### 2.2 Test Login Endpoint (Optional)

You can test the login endpoint using curl or Postman:
```powershell
# In a new PowerShell window
curl -X POST http://localhost:8000/api/accounts/login/ -H "Content-Type: application/json" -d '{\"email\":\"test@test.com\",\"password\":\"test123\"}'
```

**Expected Result:**
- If user exists: JSON response with token
- If user doesn't exist: Error message (this is OK)

---

## Step 3: Configure Mobile App Base URL

### 3.1 Open Constants File

Open: `mobile/lib/utils/constants.dart`

### 3.2 Verify Base URL

Make sure the base URL is set correctly:

```dart
const String baseUrl = 'http://localhost:8000/api/accounts';
```

**For Different Scenarios:**

- **Local Testing (Windows Desktop/Web):**
  ```dart
  const String baseUrl = 'http://localhost:8000/api/accounts';
  ```

- **Android Emulator:**
  ```dart
  const String baseUrl = 'http://10.0.2.2:8000/api/accounts';
  ```

- **Physical Device on Same Network:**
  ```dart
  const String baseUrl = 'http://192.168.1.XXX:8000/api/accounts';
  ```
  (Replace XXX with your computer's IP address - find it with `ipconfig`)

### 3.3 Verify Mock Mode is OFF

Make sure this line says `false`:
```dart
const bool useMockApi = false;
```

---

## Step 4: Run the Mobile App

### 4.1 Open a NEW Terminal/PowerShell Window

Open a **second** PowerShell window (keep the backend running in the first one).

### 4.2 Navigate to Mobile Directory

```powershell
cd C:\Users\islam\best_project_backend\mobile
```

### 4.3 Run Flutter App

**Option A: Run on Chrome (Recommended for Testing)**
```powershell
flutter run -d chrome
```

**Option B: Run on Windows Desktop**
```powershell
flutter run -d windows
```

**Option C: Let Flutter Choose**
```powershell
flutter run
```
Then select from the list (Chrome is usually easiest for testing).

**Expected Output:**
```
Launching lib\main.dart on Chrome in debug mode...
Building app for the web...
```

✅ **Success Indicator:** App should open in browser/desktop window

---

## Step 5: Test Login

### 5.1 Open the App

The app should open showing the **Login Screen**.

### 5.2 Test with Existing User

If you have a user account in your backend:

1. Enter email
2. Enter password
3. Click "Login"

**Expected Results:**

✅ **Success:**
- Loading indicator appears briefly
- App navigates to Dashboard (Consumer or Supplier)
- No error messages

❌ **Failure:**
- Red error message appears
- Stays on login screen
- Check backend terminal for error details

### 5.3 Test with Invalid Credentials

Try logging in with wrong password:

**Expected Result:**
- Error message: "Login failed: Invalid email or password"
- Stays on login screen

### 5.4 Check Backend Terminal

Look at your backend terminal window. You should see:
```
POST /api/accounts/login/ HTTP/1.1" 200 OK
```
or
```
POST /api/accounts/login/ HTTP/1.1" 400 BAD REQUEST
```

This confirms the app is connecting to the backend!

---

## Step 6: Test Sign Up (Create New User)

### 6.1 Go to Sign Up Screen

Click "Sign Up" link on login screen.

### 6.2 Fill Sign Up Form

**For Consumer:**
- Email: `testconsumer@test.com`
- Password: `password123`
- Name: `Test Consumer`
- Role: Select "Consumer"
- Business Name: `Test Restaurant`
- Address: `123 Test St`
- Phone: `1234567890`

**For Supplier:**
- Email: `testsupplier@test.com`
- Password: `password123`
- Name: `Test Supplier`
- Role: Select "Supplier"
- Company Name: `Test Company`
- Company Type: `Food Distributor`
- Address: `456 Business Ave`
- Phone: `0987654321`

### 6.3 Submit Form

Click "Sign Up" button.

**Expected Results:**

✅ **Success:**
- Loading indicator appears
- Navigates to Dashboard
- User is logged in automatically

❌ **Failure:**
- Error message appears
- Check backend terminal for details
- Common issues:
  - Email already exists
  - Password too short
  - Missing required fields

### 6.4 Check Backend Terminal

You should see:
```
POST /api/accounts/register/ HTTP/1.1" 201 CREATED
```

---

## Step 7: Test Core Features

### 7.1 Test Dashboard

**For Consumer:**
- Should show linked suppliers (if any)
- Quick action buttons visible
- If no suppliers: Message about sending link request

**For Supplier:**
- Should show pending link requests (if any)
- Quick action buttons visible
- Company information displayed

### 7.2 Test Link Requests (Consumer)

1. Click "Search Suppliers" or "Manage Links"
2. Search for suppliers
3. Send a link request to a supplier

**Check Backend Terminal:**
```
POST /api/accounts/link/send/ HTTP/1.1" 201 CREATED
```

### 7.3 Test Link Requests (Supplier)

1. As supplier, go to "Manage Link Requests"
2. See pending requests
3. Approve or reject a request

**Check Backend Terminal:**
```
PUT /api/accounts/link/{id}/accept/ HTTP/1.1" 200 OK
```

### 7.4 Test Catalog (Consumer)

1. After link is approved, go to "View Catalogs"
2. Select a supplier
3. View products
4. Add items to cart

**Check Backend Terminal:**
```
GET /api/accounts/supplier/{id}/catalog/ HTTP/1.1" 200 OK
```

### 7.5 Test Cart

1. Go to Cart screen
2. See items you added
3. Update quantities
4. Remove items

**Check Backend Terminal:**
```
GET /api/accounts/cart/ HTTP/1.1" 200 OK
POST /api/accounts/cart/add/ HTTP/1.1" 201 CREATED
```

### 7.6 Test Checkout

1. From cart, click "Checkout"
2. Fill delivery details
3. Submit order

**Check Backend Terminal:**
```
POST /api/accounts/orders/checkout/ HTTP/1.1" 201 CREATED
```

### 7.7 Test Orders

**Consumer:**
1. Go to "My Orders"
2. See list of orders
3. View order details

**Supplier:**
1. Go to "Orders"
2. See incoming orders
3. Accept or reject orders

**Check Backend Terminal:**
```
GET /api/accounts/orders/my/ HTTP/1.1" 200 OK
POST /api/accounts/orders/{id}/accept/ HTTP/1.1" 200 OK
```

---

## Step 8: Test Chat (If Implemented)

1. Go to Chat screen
2. Select a linked supplier/consumer
3. Send a message

**Check Backend Terminal:**
```
GET /api/accounts/chat/{partner_id}/ HTTP/1.1" 200 OK
POST /api/accounts/chat/{supplier_id}/send/ HTTP/1.1" 201 CREATED
```

---

## Step 9: Test Complaints (If Implemented)

**Consumer:**
1. Go to an order
2. Click "Create Complaint"
3. Fill complaint form
4. Submit

**Supplier:**
1. Go to Complaints screen
2. See complaints
3. Resolve or escalate

**Check Backend Terminal:**
```
POST /api/accounts/complaints/{order_id}/create/ HTTP/1.1" 201 CREATED
POST /api/accounts/complaints/{id}/resolve/ HTTP/1.1" 200 OK
```

---

## Troubleshooting

### Problem: "Connection error" in App

**Solutions:**
1. ✅ Check backend is running: `http://localhost:8000`
2. ✅ Check base URL in `constants.dart`
3. ✅ Check backend terminal for errors
4. ✅ Try Chrome instead of Windows desktop
5. ✅ Check firewall isn't blocking port 8000

### Problem: "401 Unauthorized" or "403 Forbidden"

**Solutions:**
1. ✅ User might not be logged in - try logging in again
2. ✅ Token might be expired - logout and login again
3. ✅ Check user role matches endpoint requirements

### Problem: "404 Not Found"

**Solutions:**
1. ✅ Check endpoint URL in `constants.dart`
2. ✅ Verify backend has that endpoint
3. ✅ Check backend `urls.py` for correct paths

### Problem: Backend Shows Errors

**Check Backend Terminal:**
- Look for Python tracebacks
- Check database connection
- Verify CORS settings allow your app origin

### Problem: App Crashes on Startup

**Solutions:**
1. ✅ Check Flutter console for error messages
2. ✅ Run `flutter pub get` in mobile directory
3. ✅ Check for syntax errors in modified files

---

## Success Checklist

After testing, you should have verified:

- [ ] Backend starts without errors
- [ ] App connects to backend (no connection errors)
- [ ] Login works with existing user
- [ ] Sign up creates new user
- [ ] Dashboard loads correctly
- [ ] Link requests can be sent/approved
- [ ] Catalog items can be viewed
- [ ] Cart operations work
- [ ] Orders can be created and viewed
- [ ] Chat works (if implemented)
- [ ] Complaints work (if implemented)

---

## Next Steps

Once basic testing passes:

1. **Test on Android Emulator** (if needed)
   - Change base URL to `http://10.0.2.2:8000/api/accounts`
   - Run: `flutter run`

2. **Test on Physical Device** (if needed)
   - Find your computer's IP: `ipconfig` in PowerShell
   - Change base URL to `http://YOUR_IP:8000/api/accounts`
   - Make sure phone and computer are on same WiFi

3. **Test All User Roles**
   - Consumer
   - Supplier (Owner)
   - Manager
   - Sales Representative

4. **Test Error Scenarios**
   - Invalid credentials
   - Network disconnection
   - Backend down
   - Invalid data submission

---

## Quick Reference Commands

```powershell
# Start Backend (Terminal 1)
cd C:\Users\islam\best_project_backend
python manage.py runserver

# Run App (Terminal 2)
cd C:\Users\islam\best_project_backend\mobile
flutter run -d chrome

# Check Backend Logs
# Look at Terminal 1 for HTTP requests

# Stop Backend
# Press CTRL+C in Terminal 1

# Stop App
# Press 'q' in Terminal 2 or close the app window
```

---

**Good luck with testing! 🚀**
