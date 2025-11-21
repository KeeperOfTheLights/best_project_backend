import '../models/supplier.dart';
import '../models/link_request.dart';
import '../models/user.dart';
import '../services/storage_service.dart';

// MockLinkRequestService - simulates link request operations for testing
class MockLinkRequestService {
  // Simulate network delay
  static Future<void> _delay() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  // Get current user from storage
  static User? _getCurrentUser() {
    final email = StorageService.getUserEmail();
    if (email == null) return null;
    
    return User(
      id: StorageService.getUserId() ?? '',
      email: email,
      name: StorageService.getUserName() ?? '',
      role: StorageService.getUserRole() ?? '',
      businessName: StorageService.getUserBusinessName(),
      companyName: StorageService.getUserCompanyName(),
      address: StorageService.getUserAddress(),
      phone: StorageService.getUserPhone(),
    );
  }

  // Mock suppliers list for search
  static final List<Supplier> _mockSuppliers = [
    Supplier(
      id: '1',
      companyName: 'Fresh Foods Co.',
      companyType: 'Food Distributor',
      address: '123 Food Street',
      phone: '555-0101',
      email: 'info@freshfoods.com',
      description: 'Premium food products distributor',
    ),
    Supplier(
      id: '2',
      companyName: 'Quality Meats Ltd.',
      companyType: 'Meat Supplier',
      address: '456 Meat Avenue',
      phone: '555-0202',
      email: 'contact@qualitymeats.com',
      description: 'High-quality meat products',
    ),
    Supplier(
      id: '3',
      companyName: 'Green Vegetables Inc.',
      companyType: 'Vegetable Supplier',
      address: '789 Veggie Road',
      phone: '555-0303',
      email: 'sales@greenveggies.com',
      description: 'Fresh vegetables and greens',
    ),
    Supplier(
      id: '4',
      companyName: 'Dairy Delights',
      companyType: 'Dairy Products',
      address: '321 Dairy Lane',
      phone: '555-0404',
      email: 'info@dairydelights.com',
      description: 'Fresh dairy products and beverages',
    ),
  ];

  // Mock link requests storage (in real app, this would be in backend)
  static final List<LinkRequest> _mockLinkRequests = [];

  // Search suppliers by name
  static Future<List<Supplier>> searchSuppliers(String query) async {
    await _delay();

    if (query.isEmpty) {
      return [];
    }

    final lowerQuery = query.toLowerCase();
    return _mockSuppliers
        .where((supplier) =>
            supplier.companyName.toLowerCase().contains(lowerQuery) ||
            (supplier.companyType?.toLowerCase().contains(lowerQuery) ?? false))
        .toList();
  }

  // Send link request to a supplier
  static Future<LinkRequest> sendLinkRequest(String supplierId) async {
    await _delay();

    // Check if request already exists
    final existing = _mockLinkRequests.firstWhere(
      (req) => req.supplierId == supplierId && req.status == LinkRequestStatus.pending,
      orElse: () => LinkRequest(
        id: '',
        consumerId: '',
        supplierId: '',
        status: '',
        createdAt: DateTime.now(),
      ),
    );

    if (existing.id.isNotEmpty) {
      throw Exception('Link request already sent');
    }

    final supplier = _mockSuppliers.firstWhere(
      (s) => s.id == supplierId,
      orElse: () => _mockSuppliers[0],
    );

    // Get current consumer user
    final currentUser = _getCurrentUser();
    if (currentUser == null) {
      throw Exception('User not found. Please login again.');
    }

    final newRequest = LinkRequest(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      consumerId: currentUser.id,
      supplierId: supplierId,
      status: LinkRequestStatus.pending,
      createdAt: DateTime.now(),
      supplier: supplier,
      consumer: currentUser, // Include full consumer information
    );

    _mockLinkRequests.add(newRequest);
    return newRequest;
  }

  // Get all link requests for current user
  static Future<List<LinkRequest>> getLinkRequests() async {
    await _delay();
    return List.from(_mockLinkRequests);
  }

  // Approve a link request
  static Future<LinkRequest> approveLinkRequest(String requestId) async {
    await _delay();

    final index = _mockLinkRequests.indexWhere((req) => req.id == requestId);
    if (index == -1) {
      throw Exception('Link request not found');
    }

    final request = _mockLinkRequests[index];
    final updatedRequest = LinkRequest(
      id: request.id,
      consumerId: request.consumerId,
      supplierId: request.supplierId,
      status: LinkRequestStatus.approved,
      createdAt: request.createdAt,
      updatedAt: DateTime.now(),
      supplier: request.supplier,
      consumer: request.consumer,
    );

    _mockLinkRequests[index] = updatedRequest;
    return updatedRequest;
  }

  // Reject a link request
  static Future<LinkRequest> rejectLinkRequest(String requestId, {String? reason}) async {
    await _delay();

    final index = _mockLinkRequests.indexWhere((req) => req.id == requestId);
    if (index == -1) {
      throw Exception('Link request not found');
    }

    final request = _mockLinkRequests[index];
    final updatedRequest = LinkRequest(
      id: request.id,
      consumerId: request.consumerId,
      supplierId: request.supplierId,
      status: LinkRequestStatus.rejected,
      createdAt: request.createdAt,
      updatedAt: DateTime.now(),
      rejectionReason: reason,
      supplier: request.supplier,
      consumer: request.consumer,
    );

    _mockLinkRequests[index] = updatedRequest;
    return updatedRequest;
  }
}

