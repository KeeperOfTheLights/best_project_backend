import '../models/staff_member.dart';
import '../services/storage_service.dart';

// MockStaffService - simulates staff management operations for testing
class MockStaffService {
  // Simulate network delay
  static Future<void> _delay() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  // Mock staff storage
  static final List<StaffMember> _staff = [];
  static int _nextStaffId = 1;

  // Get all staff members
  static Future<List<StaffMember>> getStaff() async {
    await _delay();
    return List.from(_staff);
  }

  // Add new staff member
  static Future<StaffMember> addStaff({
    required String email,
    required String name,
    required String role,
  }) async {
    await _delay();

    // Check if email already exists
    if (_staff.any((s) => s.email.toLowerCase() == email.toLowerCase())) {
      throw Exception('Email already exists');
    }

    final supplierId = StorageService.getUserId() ?? '';

    final newStaff = StaffMember(
      id: '${_nextStaffId++}',
      supplierId: supplierId,
      email: email,
      name: name,
      role: role,
      isActive: true,
      createdAt: DateTime.now(),
    );

    _staff.add(newStaff);
    return newStaff;
  }

  // Update staff member
  static Future<StaffMember> updateStaff(StaffMember staff) async {
    await _delay();

    final index = _staff.indexWhere((s) => s.id == staff.id);
    if (index == -1) {
      throw Exception('Staff member not found');
    }

    final updatedStaff = StaffMember(
      id: staff.id,
      supplierId: staff.supplierId,
      email: staff.email,
      name: staff.name,
      role: staff.role,
      isActive: staff.isActive,
      createdAt: staff.createdAt,
      updatedAt: DateTime.now(),
    );

    _staff[index] = updatedStaff;
    return updatedStaff;
  }

  // Remove/deactivate staff member
  static Future<bool> removeStaff(String staffId) async {
    await _delay();

    final index = _staff.indexWhere((s) => s.id == staffId);
    if (index == -1) {
      throw Exception('Staff member not found');
    }

    _staff.removeAt(index);
    return true;
  }
}

