import '../models/catalog_item.dart';

// MockCatalogService - simulates catalog operations for testing
class MockCatalogService {
  // Simulate network delay
  static Future<void> _delay() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  // Mock catalog items storage (in real app, this would be in backend)
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
  static Future<List<CatalogItem>> getCatalogBySupplier(String supplierId) async {
    await _delay();
    _initializeSampleData();
    return List.from(_supplierCatalogs[supplierId] ?? []);
  }

  // Get all catalog items for current supplier
  static Future<List<CatalogItem>> getMyCatalog() async {
    await _delay();
    _initializeSampleData();
    // In mock, assume current supplier is '1'
    return List.from(_supplierCatalogs['1'] ?? []);
  }

  // Create new catalog item
  static Future<CatalogItem> createItem(CatalogItem item) async {
    await _delay();
    _initializeSampleData();
    
    final newItem = item.copyWith(id: '${_nextItemId++}');
    final supplierId = item.supplierId;
    
    if (!_supplierCatalogs.containsKey(supplierId)) {
      _supplierCatalogs[supplierId] = [];
    }
    
    _supplierCatalogs[supplierId]!.add(newItem);
    return newItem;
  }

  // Update catalog item
  static Future<CatalogItem> updateItem(CatalogItem item) async {
    await _delay();
    _initializeSampleData();
    
    final supplierId = item.supplierId;
    final items = _supplierCatalogs[supplierId] ?? [];
    final index = items.indexWhere((i) => i.id == item.id);
    
    if (index == -1) {
      throw Exception('Item not found');
    }
    
    items[index] = item;
    return item;
  }

  // Delete catalog item
  static Future<bool> deleteItem(String itemId) async {
    await _delay();
    _initializeSampleData();
    
    for (final catalog in _supplierCatalogs.values) {
      final index = catalog.indexWhere((item) => item.id == itemId);
      if (index != -1) {
        catalog.removeAt(index);
        return true;
      }
    }
    
    throw Exception('Item not found');
  }
}




