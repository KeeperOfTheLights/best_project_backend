import 'package:flutter/foundation.dart';
import '../models/supplier.dart';
import '../services/supplier_service.dart';
import '../services/mock_supplier_service.dart';
import '../utils/constants.dart';

// SupplierProvider - manages supplier state (Sales Management)
class SupplierProvider with ChangeNotifier {
  List<Supplier> _suppliers = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Supplier> get suppliers => _suppliers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load all suppliers created by current user
  Future<void> loadMySuppliers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final supplierList = useMockApi
          ? await MockSupplierService.getMySuppliers()
          : await SupplierService.getMySuppliers();

      _suppliers = supplierList;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create new supplier (Sales name)
  Future<bool> createSupplier({
    required String companyName,
    String? companyType,
    String? address,
    String? phone,
    String? email,
    String? description,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newSupplier = useMockApi
          ? await MockSupplierService.createSupplier(
              companyName: companyName,
              companyType: companyType,
              address: address,
              phone: phone,
              email: email,
              description: description,
            )
          : await SupplierService.createSupplier(
              companyName: companyName,
              companyType: companyType,
              address: address,
              phone: phone,
              email: email,
              description: description,
            );

      _suppliers.add(newSupplier);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update supplier
  Future<bool> updateSupplier(Supplier supplier) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedSupplier = useMockApi
          ? await MockSupplierService.updateSupplier(supplier)
          : await SupplierService.updateSupplier(supplier);

      final index = _suppliers.indexWhere((s) => s.id == supplier.id);
      if (index != -1) {
        _suppliers[index] = updatedSupplier;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete supplier
  Future<bool> deleteSupplier(String supplierId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = useMockApi
          ? await MockSupplierService.deleteSupplier(supplierId)
          : await SupplierService.deleteSupplier(supplierId);

      if (success) {
        _suppliers.removeWhere((s) => s.id == supplierId);
      }

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

