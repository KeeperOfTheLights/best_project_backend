// Constants file - stores important values used throughout the app

// ============================================
// MOCK MODE - Set to true to test without backend
// ============================================
const bool useMockApi = true; // Change to false when you have real backend

// Base URL for your backend API
// TODO: Replace with your actual backend URL when useMockApi is false
const String baseUrl = 'http://your-backend-url.com/api';

// API endpoints
class ApiEndpoints {
  // Auth
  static const String login = '/auth/login';
  static const String signup = '/auth/signup';
  static const String logout = '/auth/logout';
  
  // Link Requests
  static const String searchSuppliers = '/suppliers/search';
  static const String sendLinkRequest = '/link-requests';
  static const String getLinkRequests = '/link-requests';
  static const String approveLinkRequest = '/link-requests';
  static const String rejectLinkRequest = '/link-requests';
  
  // Catalog
  static const String getCatalog = '/catalog';
  static const String getCatalogBySupplier = '/catalog/supplier';
  static const String createCatalogItem = '/catalog';
  static const String updateCatalogItem = '/catalog';
  static const String deleteCatalogItem = '/catalog';
  
  // Orders
  static const String createOrder = '/orders';
  static const String getOrders = '/orders';
  static const String getOrderDetails = '/orders';
  static const String acceptOrder = '/orders';
  static const String rejectOrder = '/orders';
  static const String updateOrderStatus = '/orders';
  
  // Chat
  static const String getChatRooms = '/chat/rooms';
  static const String getChatMessages = '/chat/messages';
  static const String sendMessage = '/chat/messages';
  static const String createChatRoom = '/chat/rooms';
  
  // Staff Management
  static const String getStaff = '/staff';
  static const String addStaff = '/staff';
  static const String updateStaff = '/staff';
  static const String removeStaff = '/staff';
  
  // Complaints
  static const String createComplaint = '/complaints';
  static const String getComplaints = '/complaints';
  static const String getComplaintDetails = '/complaints';
  static const String updateComplaintStatus = '/complaints';
}

// Storage keys - keys used to save data in local storage
class StorageKeys {
  static const String token = 'auth_token';
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

