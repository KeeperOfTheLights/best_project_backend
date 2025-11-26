import 'package:flutter/foundation.dart';
import '../models/staff_member.dart';
import '../services/staff_service.dart';

class StaffProvider with ChangeNotifier {
  List<StaffMember> _staff = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<StaffMember> get staff => _staff;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<StaffMember> getStaffByRole(String role) {
    return _staff.where((s) => s.role == role).toList();
  }

  List<StaffMember> get activeStaff {
    return _staff.where((s) => s.isActive).toList();
  }

  Future<void> loadStaff() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final staffList = await StaffService.getStaff();

      _staff = staffList;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<List<StaffMember>> loadUnassignedUsers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final users = await StaffService.getUnassignedUsers();
      _isLoading = false;
      notifyListeners();
      return users;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }



  Future<bool> addStaff({

    String? userId,
    String? role,

    String? email,
    String? name,
    String? password,
    String? phone,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newStaff = await StaffService.addStaff(
        userId: userId ?? '',
      );

      _staff.add(newStaff);
      await loadStaff();
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

  Future<bool> removeStaff(String staffId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await StaffService.removeStaff(staffId);

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

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}




