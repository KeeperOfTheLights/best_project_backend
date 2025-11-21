import '../models/staff_member.dart';
import '../services/storage_service.dart';
import '../services/mock_api_service.dart';
import '../utils/constants.dart';

// MockStaffService - simulates staff management operations for testing
class MockStaffService {
  // Simulate network delay
  static Future<void> _delay() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  // Mock staff storage (staff created through Staff Management)
  static final List<StaffMember> _staff = [];
  static int _nextStaffId = 1;

  // Get all staff members (includes staff created through Staff Management and Sign Up)
  static Future<List<StaffMember>> getStaff() async {
    await _delay();
    
    final currentUserId = StorageService.getUserId() ?? '';
    final currentRole = StorageService.getUserRole() ?? '';
    final currentCompanyName = StorageService.getUserCompanyName();
    
    // Get staff created through Staff Management
    final staffFromManagement = List<StaffMember>.from(_staff);
    
    // Only include staff that belongs to current user's company
    final filteredStaff = staffFromManagement.where((s) {
      // If current user is Owner, show staff with their userId as supplierId
      if (currentRole == UserRole.owner) {
        return s.supplierId == currentUserId;
      }
      // If current user is Manager, show sales staff with same supplierId
      if (currentRole == UserRole.manager) {
        // Manager can only see sales staff
        return s.supplierId == currentUserId && s.role == UserRole.sales;
      }
      // Sales can't see any staff
      return false;
    }).toList();
    
    // Also get users created through Sign Up with role manager/sales
    // In a real app, these would be properly linked to companies
    // For mock, we'll include them if they could belong to the company
    try {
      final allUsers = await MockApiService.getAllAccounts();
      final ownerCompanyName = currentCompanyName;
      
      // Convert users with manager/sales role to StaffMember
      for (final user in allUsers) {
        // Only include manager or sales roles
        if (user.role != UserRole.manager && user.role != UserRole.sales) {
          continue;
        }
        
        // Skip if already in staff list
        if (filteredStaff.any((s) => s.email.toLowerCase() == user.email.toLowerCase())) {
          continue;
        }
        
        // Determine if this user should be included
        // For mock: Owner sees all manager/sales from Sign Up
        // In a real app, this would be properly linked via company ID
        bool shouldInclude = false;
        
        if (currentRole == UserRole.owner) {
          // Owner can see all manager and sales accounts from Sign Up
          // In a real app, this would be filtered by company ID
          shouldInclude = true;
        } else if (currentRole == UserRole.manager) {
          // Manager can only see sales staff from Sign Up
          // Check if they might belong to same company (by company name if available)
          if (user.role == UserRole.sales) {
            if (ownerCompanyName != null && user.companyName != null) {
              shouldInclude = ownerCompanyName.toLowerCase() == user.companyName!.toLowerCase();
            } else {
              // If company name not available, include all sales for mock
              shouldInclude = true;
            }
          }
        }
        
        if (shouldInclude) {
          // Convert User to StaffMember
          // Use a placeholder supplierId - in real app this would be properly set
          final staffFromSignUp = StaffMember(
            id: 'signup_${user.id}',
            supplierId: currentRole == UserRole.owner ? currentUserId : currentUserId,
            email: user.email,
            name: user.name,
            role: user.role,
            phone: user.phone,
            isActive: true,
            createdAt: DateTime.now(),
          );
          
          filteredStaff.add(staffFromSignUp);
        }
      }
    } catch (e) {
      // If error getting users, just return staff from management
      print('Warning: Failed to get accounts from Sign Up: $e');
    }
    
    return filteredStaff;
  }

  // Add new staff member - creates a full login account
  static Future<StaffMember> addStaff({
    required String email,
    required String name,
    required String role,
    required String password,
    String? phone,
  }) async {
    await _delay();

    // Check if email already exists in staff list
    if (_staff.any((s) => s.email.toLowerCase() == email.toLowerCase())) {
      throw Exception('Email already exists');
    }

    final supplierId = StorageService.getUserId() ?? '';

    // Create a full login account using the mock API service
    // This ensures the account can be used for login immediately
    await MockApiService.createStaffAccount(
      email: email,
      password: password,
      name: name,
      role: role,
      phone: phone,
      supplierId: supplierId,
    );

    final newStaff = StaffMember(
      id: '${_nextStaffId++}',
      supplierId: supplierId,
      email: email,
      name: name,
      role: role,
      phone: phone,
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

  // Remove/deactivate staff member - also deletes the login account
  static Future<bool> removeStaff(String staffId) async {
    await _delay();

    // Check if staff is from Staff Management (in _staff list)
    final index = _staff.indexWhere((s) => s.id == staffId);
    
    String? emailToDelete;
    
    if (index != -1) {
      // Staff member created through Staff Management
      final staff = _staff[index];
      emailToDelete = staff.email;
      _staff.removeAt(index);
    } else {
      // Staff member might be from Sign Up (starts with 'signup_')
      if (staffId.startsWith('signup_')) {
        // Get the user ID from the staff ID
        final userId = staffId.replaceFirst('signup_', '');
        
        // Get all users and find the one with this ID
        try {
          final allUsers = await MockApiService.getAllAccounts();
          final user = allUsers.firstWhere(
            (u) => u.id == userId,
            orElse: () => throw Exception('User not found'),
          );
          emailToDelete = user.email;
        } catch (e) {
          throw Exception('Staff member not found');
        }
      } else {
        throw Exception('Staff member not found');
      }
    }
    
    // Delete the login account so they can't login anymore
    // emailToDelete is guaranteed to be set at this point (either from _staff list or Sign Up)
    try {
      await MockApiService.deleteAccount(emailToDelete);
    } catch (e) {
      // If account deletion fails, log the error
      print('Warning: Failed to delete account for $emailToDelete: $e');
    }

    return true;
  }
  
  // Get all accounts (for Owner to see all accounts they can delete)
  // This includes accounts created through Sign Up
  static Future<List<Map<String, dynamic>>> getAllAccounts() async {
    await _delay();
    
    try {
      final users = await MockApiService.getAllAccounts();
      
      // Filter to show all accounts that can be managed by the owner
      // In a real app, this would be filtered by the backend
      return users.map((user) => {
        'id': user.id,
        'email': user.email,
        'name': user.name,
        'role': user.role,
        'phone': user.phone,
      }).toList();
    } catch (e) {
      throw Exception('Failed to get accounts: $e');
    }
  }
  
  // Delete any account by email (Owner can delete accounts created through Sign Up)
  static Future<bool> deleteAccount(String email) async {
    await _delay();
    
    // Delete from staff list if it exists there
    _staff.removeWhere((s) => s.email.toLowerCase() == email.toLowerCase());
    
    // Delete the login account
    return await MockApiService.deleteAccount(email);
  }
}

