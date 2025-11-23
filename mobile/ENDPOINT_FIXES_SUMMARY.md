# Mobile App Backend Connection - Endpoint Fixes Summary

## Overview
This document explains all the changes made to connect the Flutter mobile app to the Django backend and fix endpoint mismatches.

## Key Changes Made

### 1. **Updated `constants.dart`**
   - **Changed `useMockApi` to `false`** - App now uses real backend
   - **Updated `baseUrl`** - Set to `http://localhost:8000/api/accounts`
   - **Fixed all endpoint mappings** to match backend URLs

### 2. **Fixed `api_service.dart`** (Authentication)
   - **Login**: Backend returns `access` token (not `token`), and user fields directly (not nested)
   - **Signup**: Backend expects `full_name` (not `name`) and `password2` for confirmation
   - **Response transformation**: Added code to transform backend response to match app's expected format

### 3. **Fixed `link_request_service.dart`**
   - **Search Suppliers**: Now uses `/suppliers/` or `/search/` endpoint
   - **Get Link Requests**: Uses different endpoints based on role (`/consumer/links/` vs `/links/`)
   - **Approve/Reject**: Fixed to use `/link/{id}/accept/` and `/link/{id}/reject/`

### 4. **Fixed `catalog_service.dart`**
   - **Get Catalog**: Uses `/products/` for supplier's own products
   - **Get Catalog by Supplier**: Uses `/supplier/{id}/catalog/` for consumer view
   - All endpoints now properly mapped with trailing slashes

### 5. **Fixed `order_service.dart`**
   - **Create Order**: Changed to `/orders/checkout/` - backend uses cart items from DB, not request body
   - **Get Orders**: Uses `/orders/my/` (consumer) or `/orders/supplier/` (supplier)
   - **Accept/Reject/Deliver**: Changed from PUT to POST requests

### 6. **Fixed `chat_service.dart`**
   - **Backend doesn't have chat rooms list endpoint** - app should get chat partners from link requests
   - **Get Chat History**: Uses `/chat/{partner_id}/` - gets messages with specific partner
   - **Send Message**: Uses `/chat/{supplier_id}/send/` - requires `consumer_id` in body if supplier is sending

### 7. **Fixed `complaint_service.dart`**
   - **Create Complaint**: Uses `/complaints/{order_id}/create/` - order_id in URL, not body
   - **Get Complaints**: Uses `/complaints/my/` (consumer) or `/complaints/supplier/` (supplier)
   - **Resolve/Reject/Escalate**: Changed to POST requests with specific endpoints

### 8. **Fixed `staff_service.dart`**
   - **Get Staff**: Uses `/company/employees/` 
   - **Add Staff**: Uses `/company/assign/` with `user_id` and `role` in body
   - **Remove Staff**: Uses `/company/remove/` with `user_id` in body
   - **Get Unassigned**: Uses `/company/unassigned/` to see users available for assignment

## Important Backend Endpoint Mappings

### Authentication
- `POST /api/accounts/login/` → Login
- `POST /api/accounts/register/` → Signup

### Products/Catalog
- `GET /api/accounts/products/` → Get supplier's products
- `POST /api/accounts/products/` → Create product
- `PUT /api/accounts/products/{id}/` → Update product
- `DELETE /api/accounts/products/{id}/` → Delete product
- `GET /api/accounts/supplier/{id}/catalog/` → Get supplier's catalog (consumer view)

### Link Requests
- `GET /api/accounts/suppliers/` → List all suppliers
- `GET /api/accounts/search/` → Global search
- `POST /api/accounts/link/send/` → Send link request
- `GET /api/accounts/consumer/links/` → Get consumer's link requests
- `GET /api/accounts/links/` → Get supplier's link requests
- `PUT /api/accounts/link/{id}/accept/` → Approve link
- `PUT /api/accounts/link/{id}/reject/` → Reject link

### Cart
- `POST /api/accounts/cart/add/` → Add to cart
- `GET /api/accounts/cart/` → Get cart
- `PUT /api/accounts/cart/{id}/` → Update cart item
- `DELETE /api/accounts/cart/{id}/` → Remove cart item

### Orders
- `POST /api/accounts/orders/checkout/` → Create order from cart
- `GET /api/accounts/orders/my/` → Consumer's orders
- `GET /api/accounts/orders/supplier/` → Supplier's orders
- `GET /api/accounts/orders/{id}/` → Order details
- `POST /api/accounts/orders/{id}/accept/` → Accept order
- `POST /api/accounts/orders/{id}/reject/` → Reject order
- `POST /api/accounts/orders/{id}/deliver/` → Mark as delivered

### Chat
- `GET /api/accounts/chat/{partner_id}/` → Get chat history with partner
- `POST /api/accounts/chat/{supplier_id}/send/` → Send message

### Complaints
- `POST /api/accounts/complaints/{order_id}/create/` → Create complaint
- `GET /api/accounts/complaints/my/` → Consumer's complaints
- `GET /api/accounts/complaints/supplier/` → Supplier's complaints
- `POST /api/accounts/complaints/{id}/resolve/` → Resolve complaint
- `POST /api/accounts/complaints/{id}/reject/` → Reject complaint
- `POST /api/accounts/complaints/{id}/escalate/` → Escalate complaint

### Staff Management
- `GET /api/accounts/company/employees/` → Get company employees
- `GET /api/accounts/company/unassigned/` → Get unassigned users
- `POST /api/accounts/company/assign/` → Assign user to company
- `POST /api/accounts/company/remove/` → Remove user from company

## How to Use

### 1. Update Backend URL
In `mobile/lib/utils/constants.dart`, update the `baseUrl`:
```dart
// For local development
const String baseUrl = 'http://localhost:8000/api/accounts';

// For network testing (use your computer's IP)
const String baseUrl = 'http://192.168.1.XXX:8000/api/accounts';

// For Android emulator
const String baseUrl = 'http://10.0.2.2:8000/api/accounts';
```

### 2. Ensure Mock Mode is Off
In `mobile/lib/utils/constants.dart`:
```dart
const bool useMockApi = false;  // Already set
```

### 3. Run Backend
Make sure your Django backend is running on port 8000:
```bash
python manage.py runserver
```

### 4. Test Connection
1. Run the mobile app
2. Try logging in with existing credentials
3. Check if data loads correctly

## Known Issues & Notes

### 1. Chat Rooms List
- **Issue**: Backend doesn't have an endpoint to list all chat rooms
- **Solution**: App should get chat partners from link requests (linked suppliers/consumers)
- **Workaround**: Use link requests to determine who you can chat with

### 2. Order Creation
- **Issue**: Backend checkout endpoint uses cart items from database, not request body
- **Solution**: Ensure items are added to cart first, then call checkout
- **Note**: Checkout doesn't accept items in request body

### 3. Staff Management
- **Issue**: Staff are created as separate users first, then assigned to company
- **Solution**: 
  1. Create manager/sales user via registration
  2. Use `/company/unassigned/` to find them
  3. Use `/company/assign/` to assign them to your company

### 4. Response Format Differences
- **Login**: Backend returns `access` token and flat user fields
- **Signup**: Backend returns `token` (inconsistent with login)
- **Solution**: api_service.dart transforms both to expected format

## Testing Checklist

- [ ] Login works with backend credentials
- [ ] Signup creates new user
- [ ] Can search and send link requests
- [ ] Can view catalog items
- [ ] Can add items to cart
- [ ] Can checkout and create order
- [ ] Can view orders (consumer and supplier)
- [ ] Can send/receive chat messages
- [ ] Can create complaints
- [ ] Can manage staff (owner only)

## Error Handling

All services now properly handle:
- **Backend errors**: Extracts `detail` or `message` from error response
- **Connection errors**: Shows user-friendly error messages
- **Empty responses**: Handles both array and object responses

## Next Steps

1. Test all features with real backend
2. Update providers if needed (some may need `userRole` parameter)
3. Test on physical device or emulator
4. Verify all endpoints work correctly
5. Check CORS settings if accessing from web

## Questions?

If you encounter issues:
1. Check backend logs for error details
2. Verify endpoint URLs match exactly
3. Check authentication token is being sent
4. Verify user role matches endpoint requirements

