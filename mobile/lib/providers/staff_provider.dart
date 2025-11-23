import 'package:flutter/foundation.dart';
import '../models/staff_member.dart';
import '../services/staff_service.dart';
import '../services/mock_staff_service.dart';
import '../utils/constants.dart';

// StaffProvider - manages staff state
class StaffProvider with ChangeNotifier {
  List<StaffMember> _staff = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<StaffMember> get staff => _staff;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Get staff by role
  List<StaffMember> getStaffByRole(String role) {
    return _staff.where((s) => s.role == role).toList();
  }

  // Get active staff
  List<StaffMember> get activeStaff {
    return _staff.where((s) => s.isActive).toList();
  }

  // Load all staff
  Future<void> loadStaff() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final staffList = useMockApi
          ? await MockStaffService.getStaff()
          : await StaffService.getStaff();

      _staff = staffList;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get unassigned users (available to be assigned as staff)
  // Note: This should be stored in a separate list or handled by the screen
  Future<List<StaffMember>> loadUnassignedUsers() async {
    if (useMockApi) return [];  // Mock API doesn't have this
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final users = await StaffService.getUnassignedUsers();
      _isLoading = false;
      notifyListeners();
      return users;  // Return the list for the screen to use
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }

  // Add new staff member
  // For mock API: creates a full login account with email/name/password
  // For real backend: assigns existing user to company with userId (role comes from user)
  Future<bool> addStaff({
    // For real backend
    String? userId,
    String? role, // Optional - used for mock API or if needed
    // For mock API
    String? email,
    String? name,
    String? password,
    String? phone,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newStaff = useMockApi
          ? await MockStaffService.addStaff(
              email: email ?? '',
              name: name ?? '',
              role: role ?? 'sales',
              password: password ?? '',
              phone: phone,
            )
          : await StaffService.addStaff(
              userId: userId ?? '',
            );

      _staff.add(newStaff);
      await loadStaff();  // Reload to get full staff list
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

  // Remove staff member
  Future<bool> removeStaff(String staffId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = useMockApi
          ? await MockStaffService.removeStaff(staffId)
          : await StaffService.removeStaff(staffId);

      if (success) {
        _staff.removeWhere((s) => s.id == staffId);
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




