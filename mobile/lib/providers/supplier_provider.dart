import 'package:flutter/foundation.dart';
import '../models/supplier.dart';
import '../services/supplier_service.dart';

class SupplierProvider with ChangeNotifier {
  List<Supplier> _suppliers = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Supplier> get suppliers => _suppliers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadMySuppliers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final supplierList = await SupplierService.getMySuppliers();

      _suppliers = supplierList;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

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
      final newSupplier = await SupplierService.createSupplier(
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

  Future<bool> updateSupplier(Supplier supplier) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedSupplier = await SupplierService.updateSupplier(supplier);

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

  Future<bool> deleteSupplier(String supplierId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await SupplierService.deleteSupplier(supplierId);

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

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}



