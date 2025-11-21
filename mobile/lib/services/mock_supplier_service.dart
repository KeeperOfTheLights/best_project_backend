import '../models/supplier.dart';
import '../services/storage_service.dart';
import '../services/mock_staff_service.dart';
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
    
    // If Owner, use their own userId
    if (currentRole == UserRole.owner) {
      return currentUserId;
    }
    
    // For Manager/Sales, find their staff record to get supplierId (owner's userId)
    try {
      final staffList = await MockStaffService.getStaff();
      final staffMember = staffList.firstWhere(
        (s) => s.email.toLowerCase() == StorageService.getUserEmail()?.toLowerCase(),
        orElse: () => throw Exception('Staff member not found'),
      );
      // Return the supplierId (which is the Owner's userId)
      return staffMember.supplierId;
    } catch (e) {
      // If not found in staff list, it might be the Owner themselves
      return currentUserId;
    }
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

