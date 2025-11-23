import 'package:flutter/foundation.dart';
import '../models/catalog_item.dart';
import '../services/catalog_service.dart';
import '../services/mock_catalog_service.dart';
import '../utils/constants.dart';

// CatalogProvider - manages catalog state
class CatalogProvider with ChangeNotifier {
  List<CatalogItem> _items = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _selectedCategory;

  List<CatalogItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get selectedCategory => _selectedCategory;

  // Get unique categories from items
  List<String> get categories {
    final cats = _items.map((item) => item.category).toSet().toList();
    cats.sort();
    return cats;
  }

  // Get filtered items (by category and search)
  List<CatalogItem> getFilteredItems({String? searchQuery}) {
    var filtered = _items.where((item) => item.isActive).toList();

    // Filter by category
    if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
      filtered = filtered.where(
        (item) => item.category == _selectedCategory,
      ).toList();
    }

    // Filter by search query
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where(
        (item) =>
            item.name.toLowerCase().contains(query) ||
            (item.description?.toLowerCase().contains(query) ?? false) ||
            item.category.toLowerCase().contains(query),
      ).toList();
    }

    return filtered;
  }

  // Load catalog for a specific supplier (Consumer view)
  Future<void> loadCatalogBySupplier(String supplierId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final items = useMockApi
          ? await MockCatalogService.getCatalogBySupplier(supplierId)
          : await CatalogService.getCatalogBySupplier(supplierId);

      _items = items;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load my catalog (Supplier view)
  Future<void> loadMyCatalog() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final items = useMockApi
          ? await MockCatalogService.getMyCatalog()
          : await CatalogService.getMyCatalog();

      _items = items;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create new catalog item (Supplier only)
  Future<bool> createItem(CatalogItem item) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newItem = useMockApi
          ? await MockCatalogService.createItem(item)
          : await CatalogService.createItem(item);

      // Reload catalog from backend to ensure we have the latest data
      // This is important because backend might filter products differently
      if (!useMockApi) {
        await loadMyCatalog();
      } else {
        _items.add(newItem);
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

  // Update catalog item (Supplier only)
  Future<bool> updateItem(CatalogItem item) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedItem = useMockApi
          ? await MockCatalogService.updateItem(item)
          : await CatalogService.updateItem(item);

      final index = _items.indexWhere((i) => i.id == item.id);
      if (index != -1) {
        _items[index] = updatedItem;
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

  // Delete catalog item (Supplier only)
  Future<bool> deleteItem(String itemId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = useMockApi
          ? await MockCatalogService.deleteItem(itemId)
          : await CatalogService.deleteItem(itemId);

      if (success) {
        _items.removeWhere((item) => item.id == itemId);
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

  // Toggle product status (Supplier only)
  Future<bool> toggleProductStatus(String productId, String newStatus) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedItem = useMockApi
          ? throw Exception('Toggle status not implemented in mock API')
          : await CatalogService.toggleProductStatus(productId, newStatus);

      final index = _items.indexWhere((i) => i.id == productId);
      if (index != -1) {
        _items[index] = updatedItem;
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

  // Set selected category filter
  void setCategoryFilter(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}




