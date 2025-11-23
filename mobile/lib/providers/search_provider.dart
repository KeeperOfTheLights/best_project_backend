import 'package:flutter/foundation.dart';
import '../models/supplier.dart';
import '../models/catalog_item.dart';
import '../services/search_service.dart';

class SearchProvider with ChangeNotifier {
  List<Supplier> _suppliers = [];
  List<String> _categories = [];
  List<CatalogItem> _products = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _query = '';
  bool _hasLinkedSuppliers = true; // Assume true by default, will check on init

  List<Supplier> get suppliers => _suppliers;
  List<String> get categories => _categories;
  List<CatalogItem> get products => _products;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get query => _query;
  bool get hasLinkedSuppliers => _hasLinkedSuppliers;
  bool get hasResults => _suppliers.isNotEmpty || _categories.isNotEmpty || _products.isNotEmpty;

  // Check if consumer has linked suppliers
  Future<void> checkLinkedSuppliers() async {
    try {
      _hasLinkedSuppliers = await SearchService.hasLinkedSuppliers();
      notifyListeners();
    } catch (e) {
      _hasLinkedSuppliers = false;
      notifyListeners();
    }
  }

  // Perform search
  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      _query = '';
      _suppliers = [];
      _categories = [];
      _products = [];
      _errorMessage = null;
      notifyListeners();
      return;
    }

    _query = query.trim();
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await SearchService.search(_query);
      _suppliers = results['suppliers'] as List<Supplier>;
      _categories = results['categories'] as List<String>;
      _products = results['products'] as List<CatalogItem>;
      _errorMessage = null;
    } catch (e) {
      _suppliers = [];
      _categories = [];
      _products = [];
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear search results
  void clearSearch() {
    _query = '';
    _suppliers = [];
    _categories = [];
    _products = [];
    _errorMessage = null;
    notifyListeners();
  }
}

