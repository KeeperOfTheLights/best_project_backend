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

  // Add new staff member
  Future<bool> addStaff({
    required String email,
    required String name,
    required String role,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newStaff = useMockApi
          ? await MockStaffService.addStaff(
              email: email,
              name: name,
              role: role,
            )
          : await StaffService.addStaff(
              email: email,
              name: name,
              role: role,
            );

      _staff.add(newStaff);
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

  // Update staff member
  Future<bool> updateStaff(StaffMember staff) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedStaff = useMockApi
          ? await MockStaffService.updateStaff(staff)
          : await StaffService.updateStaff(staff);

      final index = _staff.indexWhere((s) => s.id == staff.id);
      if (index != -1) {
        _staff[index] = updatedStaff;
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




