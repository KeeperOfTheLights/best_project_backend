import 'dart:io';

String getApiBaseUrl() {
  if (Platform.isAndroid) {
    return 'http://10.0.2.2:8000/api/accounts';
  } else if (Platform.isIOS) {
    return 'http://localhost:8000/api/accounts';
  } else {
    return 'http://127.0.0.1:8000/api/accounts';
  }
}

String get baseUrl => getApiBaseUrl();

class ApiEndpoints {
  static const String login = '/login/';
  static const String signup = '/register/';
  static const String searchSuppliers = '/suppliers/';
  static const String globalSearch = '/search/';
  static const String sendLinkRequest = '/link/send/';
  static const String getSupplierLinkRequests = '/links/';
  static const String getConsumerLinkRequests = '/consumer/links/';
  static const String acceptLinkRequest = '/link';
  static const String rejectLinkRequest = '/link';
  static const String unlink = '/link';
  static const String getMyProducts = '/products/';
  static const String createProduct = '/products/';
  static const String updateProduct = '/products';
  static const String deleteProduct = '/products';
  static const String getCatalogBySupplier = '/supplier';
  static const String toggleProductStatus = '/products';
  static const String addToCart = '/cart/add/';
  static const String getCart = '/cart/';
  static const String updateCartItem = '/cart';
  static const String deleteCartItem = '/cart';
  static const String checkout = '/orders/checkout/';
  static const String getMyOrders = '/orders/my/';
  static const String getSupplierOrders = '/orders/supplier/';
  static const String getOrderDetails = '/orders';
  static const String acceptOrder = '/orders';
  static const String rejectOrder = '/orders';
  static const String deliverOrder = '/orders';
  static const String getConsumerOrderStats = '/orders/stats/';
  static const String getSupplierOrderStats = '/orders/supplier/stats/';
  static const String getChatHistory = '/chat';
  static const String sendMessage = '/chat';
  static const String getCompanyEmployees = '/company/employees/';
  static const String getUnassignedUsers = '/company/unassigned/';
  static const String assignEmployee = '/company/assign/';
  static const String removeEmployee = '/company/remove/';
  static const String createComplaint = '/complaints';
  static const String getMyComplaints = '/complaints/my/';
  static const String getSupplierComplaints = '/complaints/supplier/';
  static const String resolveComplaint = '/complaints';
  static const String rejectComplaint = '/complaints';
  static const String escalateComplaint = '/complaints';
}

class StorageKeys {
  static const String token = 'auth_token';
  static const String refreshToken = 'refresh_token';
  static const String userRole = 'user_role';
  static const String userId = 'user_id';
  static const String userEmail = 'user_email';
  static const String userName = 'user_name';
}

class UserRole {
  static const String consumer = 'consumer';
  static const String supplier = 'supplier';
  static const String owner = 'owner';
  static const String manager = 'manager';
  static const String sales = 'sales';
}

bool isSupplierSide(String role) {
  return role == UserRole.owner || role == UserRole.manager || role == UserRole.sales || role == UserRole.supplier;
}
