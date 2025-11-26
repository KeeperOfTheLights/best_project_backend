import 'package:flutter/foundation.dart';
import '../models/catalog_item.dart';
import '../services/catalog_service.dart';

class CatalogProvider with ChangeNotifier {
  List<CatalogItem> _items = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _selectedCategory;

  List<CatalogItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get selectedCategory => _selectedCategory;

  List<String> get categories {
    final cats = _items.map((item) => item.category).toSet().toList();
    cats.sort();
    return cats;
  }

  List<CatalogItem> getFilteredItems({String? searchQuery}) {
    var filtered = _items.where((item) => item.isActive).toList();

    if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
      filtered = filtered.where(
        (item) => item.category == _selectedCategory,
      ).toList();
    }

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

  Future<void> loadCatalogBySupplier(String supplierId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final items = await CatalogService.getCatalogBySupplier(supplierId);

      _items = items;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMyCatalog() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final items = await CatalogService.getMyCatalog();

      _items = items;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createItem(CatalogItem item) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await CatalogService.createItem(item);
      await loadMyCatalog();
      
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

  Future<bool> updateItem(CatalogItem item) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedItem = await CatalogService.updateItem(item);

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

  Future<bool> deleteItem(String itemId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await CatalogService.deleteItem(itemId);

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

  Future<bool> toggleProductStatus(String productId, String newStatus) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedItem = await CatalogService.toggleProductStatus(productId, newStatus);

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

  void setCategoryFilter(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}




