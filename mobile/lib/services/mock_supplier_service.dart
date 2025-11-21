import '../models/supplier.dart';
import '../services/storage_service.dart';
import '../services/mock_staff_service.dart';
import '../services/mock_api_service.dart';
import '../utils/constants.dart';

// MockSupplierService - simulates supplier management operations for testing
class MockSupplierService {
  // Simulate network delay
  static Future<void> _delay() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  // Mock suppliers storage (suppliers created by Owners/Managers)
  // Key: companyId (Owner's userId), Value: List of suppliers for that company
  static final Map<String, List<Supplier>> _suppliersByCompany = {};
  static int _nextSupplierId = 1;

  // Helper to get company ID from staff member's supplierId
  // For Owner: returns their own userId
  // For Manager/Sales: returns their supplierId (which is Owner's userId)
  static Future<String> _getCompanyIdForUser() async {
    final currentUserId = StorageService.getUserId() ?? '';
    final currentRole = StorageService.getUserRole() ?? '';
    final currentEmail = StorageService.getUserEmail() ?? '';
    
    // If Owner, use their own userId
    if (currentRole == UserRole.owner) {
      return currentUserId;
    }
    
    // For Manager/Sales, find their staff record to get supplierId (owner's userId)
    try {
      // Get ALL staff to find the current user's record (without role filtering)
      final allStaff = await MockStaffService.getAllStaffForCompanyLookup();
      final staffMember = allStaff.firstWhere(
        (s) => s.email.toLowerCase() == currentEmail.toLowerCase(),
        orElse: () => throw Exception('Staff member not found'),
      );
      // Return the supplierId (which is the Owner's userId)
      final ownerId = staffMember.supplierId;
      if (ownerId.isNotEmpty) {
        return ownerId;
      }
    } catch (e) {
      // If not found in staff list, try to find Owner by matching company name
      print('Warning: Could not find staff record for company lookup: $e');
    }
    
    // Fallback: If Manager/Sales was created through Sign Up, try to find Owner by company name
    try {
      final currentCompanyName = StorageService.getUserCompanyName();
      if (currentCompanyName != null && currentCompanyName.isNotEmpty) {
        // Find Owner with matching company name
        final allUsers = await MockApiService.getAllAccounts();
        final matchingOwner = allUsers.firstWhere(
          (user) => user.role == UserRole.owner &&
              user.companyName != null &&
              user.companyName!.toLowerCase() == currentCompanyName.toLowerCase(),
          orElse: () => throw Exception('No matching owner found'),
        );
        // Use the Owner's userId as company ID
        print('Found matching owner by company name: ${matchingOwner.id}');
        return matchingOwner.id;
      }
    } catch (e) {
      print('Warning: Could not find owner by company name: $e');
    }
    
    // Final fallback: use current userId (this should rarely happen)
    return currentUserId;
  }

  // Get all suppliers for the current user's company (shared between Owner and Manager)
  static Future<List<Supplier>> getMySuppliers() async {
    await _delay();
    final companyId = await _getCompanyIdForUser();
    
    // Return all suppliers for this company
    return List.from(_suppliersByCompany[companyId] ?? []);
  }

  // Create new supplier (Sales name) - shared for Owner and Manager
  static Future<Supplier> createSupplier({
    required String companyName,
    String? companyType,
    String? address,
    String? phone,
    String? email,
    String? description,
  }) async {
    await _delay();
    
    final companyId = await _getCompanyIdForUser();

    // Check if supplier name already exists in this company
    final existingSuppliers = _suppliersByCompany[companyId] ?? [];
    if (existingSuppliers.any((s) => 
        s.companyName.toLowerCase() == companyName.toLowerCase())) {
      throw Exception('Supplier name already exists');
    }

    final newSupplier = Supplier(
      id: 'supplier_${companyId}_${_nextSupplierId++}',
      companyName: companyName,
      companyType: companyType,
      address: address,
      phone: phone,
      email: email,
      description: description,
    );

    // Store supplier under company ID
    if (!_suppliersByCompany.containsKey(companyId)) {
      _suppliersByCompany[companyId] = [];
    }
    _suppliersByCompany[companyId]!.add(newSupplier);
    
    return newSupplier;
  }

  // Update supplier - can be edited by Owner or Manager
  static Future<Supplier> updateSupplier(Supplier supplier) async {
    await _delay();
    
    final companyId = await _getCompanyIdForUser();
    final suppliers = _suppliersByCompany[companyId] ?? [];

    final index = suppliers.indexWhere((s) => s.id == supplier.id);
    if (index == -1) {
      throw Exception('Supplier not found');
    }

    suppliers[index] = supplier;
    return supplier;
  }

  // Delete supplier - can be deleted by Owner or Manager
  static Future<bool> deleteSupplier(String supplierId) async {
    await _delay();
    
    final companyId = await _getCompanyIdForUser();
    final suppliers = _suppliersByCompany[companyId] ?? [];

    final index = suppliers.indexWhere((s) => s.id == supplierId);
    if (index == -1) {
      throw Exception('Supplier not found');
    }

    suppliers.removeAt(index);
    return true;
  }
  
  // Get all suppliers for search (used by consumers)
  // This combines suppliers created through Sign Up and Sales Management
  static List<Supplier> getAllSearchableSuppliers() {
    // Return all suppliers from all companies
    final allSuppliers = <Supplier>[];
    for (final suppliers in _suppliersByCompany.values) {
      allSuppliers.addAll(suppliers);
    }
    return allSuppliers;
  }
}

