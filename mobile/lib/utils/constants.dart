// Constants file - stores important values used throughout the app

// ============================================
// MOCK MODE - Set to true to test without backend
// ============================================
const bool useMockApi = false; // Changed to false to use real backend

// Base URL for your backend API
// Backend is mounted at /api/accounts/ in main urls.py
// For local development, use: http://localhost:8000/api/accounts
// For network testing, use your computer's IP: http://192.168.1.XXX:8000/api/accounts
// For Android emulator, use: http://10.0.2.2:8000/api/accounts
const String baseUrl = 'http://127.0.0.1:8000/api/accounts';

// API endpoints - mapped to actual backend endpoints
class ApiEndpoints {
  // Auth
  static const String login = '/login/';  // Backend: /api/accounts/login/
  static const String signup = '/register/';  // Backend: /api/accounts/register/
  
  // Link Requests
  static const String searchSuppliers = '/suppliers/';  // GET - All suppliers for consumer
  static const String globalSearch = '/search/';  // GET - Global search endpoint
  static const String sendLinkRequest = '/link/send/';  // POST - Send link request
  static const String getSupplierLinkRequests = '/links/';  // GET - Supplier's link requests
  static const String getConsumerLinkRequests = '/consumer/links/';  // GET - Consumer's link requests
  static const String acceptLinkRequest = '/link';  // PUT /link/{id}/accept/
  static const String rejectLinkRequest = '/link';  // PUT /link/{id}/reject/
  static const String unlink = '/link';  // DELETE /link/{id}/
  
  // Catalog (Products)
  static const String getMyProducts = '/products/';  // GET - Supplier's own products
  static const String createProduct = '/products/';  // POST - Create product
  static const String updateProduct = '/products';  // PUT /products/{id}/
  static const String deleteProduct = '/products';  // DELETE /products/{id}/
  static const String getCatalogBySupplier = '/supplier';  // GET /supplier/{id}/catalog/
  static const String toggleProductStatus = '/products';  // PATCH /products/{id}/status/
  
  // Cart
  static const String addToCart = '/cart/add/';  // POST
  static const String getCart = '/cart/';  // GET
  static const String updateCartItem = '/cart';  // PUT /cart/{id}/
  static const String deleteCartItem = '/cart';  // DELETE /cart/{id}/
  
  // Orders
  static const String checkout = '/orders/checkout/';  // POST - Create order from cart
  static const String getMyOrders = '/orders/my/';  // GET - Consumer's orders
  static const String getSupplierOrders = '/orders/supplier/';  // GET - Supplier's orders
  static const String getOrderDetails = '/orders';  // GET /orders/{id}/
  static const String acceptOrder = '/orders';  // POST /orders/{id}/accept/
  static const String rejectOrder = '/orders';  // POST /orders/{id}/reject/
  static const String deliverOrder = '/orders';  // POST /orders/{id}/deliver/
  static const String getConsumerOrderStats = '/orders/stats/';  // GET - Consumer order statistics
  
  // Chat
  static const String getChatHistory = '/chat';  // GET /chat/{partner_id}/
  static const String sendMessage = '/chat';  // POST /chat/{supplier_id}/send/
  
  // Staff Management
  static const String getCompanyEmployees = '/company/employees/';  // GET
  static const String getUnassignedUsers = '/company/unassigned/';  // GET
  static const String assignEmployee = '/company/assign/';  // POST
  static const String removeEmployee = '/company/remove/';  // POST
  
  // Complaints
  static const String createComplaint = '/complaints';  // POST /complaints/{order_id}/create/
  static const String getMyComplaints = '/complaints/my/';  // GET - Consumer complaints
  static const String getSupplierComplaints = '/complaints/supplier/';  // GET - Supplier complaints
  static const String resolveComplaint = '/complaints';  // POST /complaints/{id}/resolve/
  static const String rejectComplaint = '/complaints';  // POST /complaints/{id}/reject/
  static const String escalateComplaint = '/complaints';  // POST /complaints/{id}/escalate/
}

// Storage keys - keys used to save data in local storage
class StorageKeys {
  static const String token = 'auth_token';
  static const String refreshToken = 'refresh_token';
  static const String userRole = 'user_role';
  static const String userId = 'user_id';
  static const String userEmail = 'user_email';
  static const String userName = 'user_name';
}

// User roles
class UserRole {
  static const String consumer = 'consumer';
  static const String supplier = 'supplier';
  static const String owner = 'owner';
  static const String manager = 'manager';
  static const String sales = 'sales';
}

