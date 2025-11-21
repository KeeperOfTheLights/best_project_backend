import '../models/catalog_item.dart';
import '../services/mock_supplier_service.dart';

// MockCatalogService - simulates catalog operations for testing
class MockCatalogService {
  // Simulate network delay
  static Future<void> _delay() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  // Mock catalog items storage (in real app, this would be in backend)
  // Key: supplierId (the Sales Management supplier ID), Value: List of catalog items
  static final Map<String, List<CatalogItem>> _supplierCatalogs = {};
  static int _nextItemId = 1;

  // Initialize with some sample data
  static void _initializeSampleData() {
    if (_supplierCatalogs.isEmpty) {
      final supplierId = '1'; // Mock supplier ID
      _supplierCatalogs[supplierId] = [
        CatalogItem(
          id: '${_nextItemId++}',
          supplierId: supplierId,
          name: 'Fresh Tomatoes',
          description: 'Premium quality tomatoes',
          category: 'Vegetables',
          unit: 'kg',
          price: 5.99,
          stockQuantity: 100,
          isActive: true,
        ),
        CatalogItem(
          id: '${_nextItemId++}',
          supplierId: supplierId,
          name: 'Organic Carrots',
          description: 'Fresh organic carrots',
          category: 'Vegetables',
          unit: 'kg',
          price: 4.50,
          stockQuantity: 80,
          isActive: true,
        ),
        CatalogItem(
          id: '${_nextItemId++}',
          supplierId: supplierId,
          name: 'Premium Beef',
          description: 'High quality beef cuts',
          category: 'Meat',
          unit: 'kg',
          price: 25.99,
          stockQuantity: 50,
          isActive: true,
        ),
        CatalogItem(
          id: '${_nextItemId++}',
          supplierId: supplierId,
          name: 'Fresh Milk',
          description: 'Whole milk, 1 liter',
          category: 'Dairy',
          unit: 'box',
          price: 3.99,
          stockQuantity: 200,
          isActive: true,
        ),
      ];
    }
  }

  // Get catalog items for a specific supplier
  // This uses supplierId which is the Sales Management supplier ID
  static Future<List<CatalogItem>> getCatalogBySupplier(String supplierId) async {
    await _delay();
    _initializeSampleData();
    
    // Get all catalog items for all suppliers in the company (if supplierId belongs to company)
    // First check if supplierId exists directly
    if (_supplierCatalogs.containsKey(supplierId)) {
      return List.from(_supplierCatalogs[supplierId] ?? []);
    }
    
    // If not found, it might be that the supplier was created in a different session
    // Return empty list - in production this would query by company
    return [];
  }

  // Get all catalog items for current supplier
  // Returns all items for all suppliers in the company (shared between Owner and Manager)
  static Future<List<CatalogItem>> getMyCatalog() async {
    await _delay();
    _initializeSampleData();
    
    // Get all suppliers for the company
    final suppliers = await MockSupplierService.getMySuppliers();
    
    // Get all catalog items for all suppliers in this company
    final allItems = <CatalogItem>[];
    for (final supplier in suppliers) {
      final items = _supplierCatalogs[supplier.id] ?? [];
      allItems.addAll(items);
    }
    
    return allItems;
  }

  // Create new catalog item - can be created by Owner or Manager
  static Future<CatalogItem> createItem(CatalogItem item) async {
    await _delay();
    _initializeSampleData();
    
    // Verify that the supplierId belongs to the user's company
    final suppliers = await MockSupplierService.getMySuppliers();
    
    // Check if supplier belongs to this company
    final supplierExists = suppliers.any((s) => s.id == item.supplierId);
    if (!supplierExists) {
      throw Exception('Supplier not found or does not belong to your company');
    }
    
    final newItem = item.copyWith(id: '${_nextItemId++}');
    final supplierId = item.supplierId;
    
    if (!_supplierCatalogs.containsKey(supplierId)) {
      _supplierCatalogs[supplierId] = [];
    }
    
    _supplierCatalogs[supplierId]!.add(newItem);
    return newItem;
  }

  // Update catalog item - can be updated by Owner or Manager
  static Future<CatalogItem> updateItem(CatalogItem item) async {
    await _delay();
    _initializeSampleData();
    
    // Verify that the supplierId belongs to the user's company
    final suppliers = await MockSupplierService.getMySuppliers();
    
    final supplierExists = suppliers.any((s) => s.id == item.supplierId);
    if (!supplierExists) {
      throw Exception('Supplier not found or does not belong to your company');
    }
    
    final supplierId = item.supplierId;
    final items = _supplierCatalogs[supplierId] ?? [];
    final index = items.indexWhere((i) => i.id == item.id);
    
    if (index == -1) {
      throw Exception('Item not found');
    }
    
    items[index] = item;
    return item;
  }

  // Delete catalog item - can be deleted by Owner or Manager
  static Future<bool> deleteItem(String itemId) async {
    await _delay();
    _initializeSampleData();
    
    // Get all suppliers for the company
    final suppliers = await MockSupplierService.getMySuppliers();
    final supplierIds = suppliers.map((s) => s.id).toSet();
    
    // Only delete from suppliers in this company
    for (final supplierId in supplierIds) {
      final catalog = _supplierCatalogs[supplierId] ?? [];
      final index = catalog.indexWhere((item) => item.id == itemId);
      if (index != -1) {
        catalog.removeAt(index);
        return true;
      }
    }
    
    throw Exception('Item not found');
  }
}




