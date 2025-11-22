import 'package:flutter/foundation.dart';
import '../models/auth_response.dart';
import '../models/user.dart';

// MockApiService - simulates backend responses for testing
// Use this when you don't have a real backend yet
class MockApiService {
  // Store mock users (email -> User data)
  // In real app, this would be in a database
  static final Map<String, User> _mockUsers = {};
  
  // Store passwords for mock users (email -> password)
  // In real app, passwords would be hashed and stored securely
  static final Map<String, String> _mockPasswords = {};
  
  // Store deleted accounts to prevent login
  static final Set<String> _deletedAccounts = <String>{};

  // Simulate network delay (like real API)
  static Future<void> _delay() async {
    await Future.delayed(const Duration(seconds: 1));
  }

  // Mock login - simulates successful login
  static Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    await _delay(); // Simulate network delay

    // Simulate validation
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Email and password are required');
    }

    if (password.length < 6) {
      throw Exception('Password must be at least 6 characters');
    }

    final emailKey = email.toLowerCase().trim();
    
    // Debug: Print available users (remove in production)
    if (kDebugMode) {
      print('Attempting login for: $emailKey');
      print('Available users: ${_mockUsers.keys.toList()}');
      print('Available passwords: ${_mockPasswords.keys.toList()}');
    }
    
    // Check if account was deleted
    if (_deletedAccounts.contains(emailKey)) {
      throw Exception('Invalid email or password');
    }

    // Check if user exists in our mock database
    final user = _mockUsers[emailKey];
    
    if (user == null) {
      // User doesn't exist - this simulates invalid credentials
      if (kDebugMode) {
        print('User not found for email: $emailKey');
      }
      throw Exception('Invalid email or password');
    }
    
    // Check password
    final storedPassword = _mockPasswords[emailKey];
    if (storedPassword == null) {
      if (kDebugMode) {
        print('Password not found for email: $emailKey');
      }
      throw Exception('Invalid email or password');
    }
    
    if (storedPassword != password) {
      if (kDebugMode) {
        print('Password mismatch for email: $emailKey');
        print('Stored password: $storedPassword');
        print('Provided password: $password');
      }
      throw Exception('Invalid email or password');
    }

    // Return the user's actual data (with their real role from signup)
    return AuthResponse(
      token: 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
      user: user,
    );
  }

  // Mock signup - simulates successful signup
  static Future<AuthResponse> signup({
    required String email,
    required String password,
    required String name,
    required String role,
    String? businessName,
    String? companyName,
    String? companyType,
    String? address,
    String? phone,
  }) async {
    await _delay(); // Simulate network delay

    // Simulate validation
    if (email.isEmpty || password.isEmpty || name.isEmpty) {
      throw Exception('Required fields are missing');
    }

    if (password.length < 6) {
      throw Exception('Password must be at least 6 characters');
    }

    // Simulate checking if email already exists
    if (_mockUsers.containsKey(email.toLowerCase())) {
      throw Exception('Email already exists');
    }

    // Create new user and store in mock database
    final newUser = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      email: email,
      name: name,
      role: role,
      businessName: businessName,
      companyName: companyName,
      companyType: companyType,
      address: address,
      phone: phone,
    );

    final emailKey = email.toLowerCase();

    // Save user to mock database
    _mockUsers[emailKey] = newUser;
    
    // Save password (in real app, this would be hashed)
    _mockPasswords[emailKey] = password;

    // Simulate successful signup
    return AuthResponse(
      token: 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
      user: newUser,
    );
  }
  
  // Create staff account (called by Owner when creating staff)
  // This creates a full login account that can be used immediately
  static Future<AuthResponse> createStaffAccount({
    required String email,
    required String password,
    required String name,
    required String role,
    String? phone,
    String? supplierId,
  }) async {
    await _delay(); // Simulate network delay

    // Simulate validation
    if (email.isEmpty || password.isEmpty || name.isEmpty) {
      throw Exception('Required fields are missing');
    }

    if (password.length < 6) {
      throw Exception('Password must be at least 6 characters');
    }

    final emailKey = email.toLowerCase().trim();
    
    // Debug: Print creation attempt
    if (kDebugMode) {
      print('Creating staff account for: $emailKey');
      print('Role: $role');
    }
    
    // Simulate checking if email already exists
    if (_mockUsers.containsKey(emailKey)) {
      throw Exception('Email already exists');
    }

    // Create new staff user account
    final newUser = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      email: email.trim(),
      name: name.trim(),
      role: role,
      phone: phone?.trim(),
      companyName: null, // Staff accounts don't have company name
    );

    // Save user to mock database
    _mockUsers[emailKey] = newUser;
    
    // Save password (in real app, this would be hashed)
    _mockPasswords[emailKey] = password;
    
    // Remove from deleted accounts if it was there
    _deletedAccounts.remove(emailKey);

    // Debug: Confirm creation
    if (kDebugMode) {
      print('Staff account created successfully for: $emailKey');
      print('User saved: ${_mockUsers.containsKey(emailKey)}');
      print('Password saved: ${_mockPasswords.containsKey(emailKey)}');
    }

    // Simulate successful account creation
    return AuthResponse(
      token: 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
      user: newUser,
    );
  }
  
  // Delete account - prevents login with this email/password
  static Future<bool> deleteAccount(String email) async {
    await _delay(); // Simulate network delay
    
    final emailKey = email.toLowerCase();
    
    // Check if account exists
    if (!_mockUsers.containsKey(emailKey)) {
      throw Exception('Account not found');
    }
    
    // Remove user and password from active accounts
    _mockUsers.remove(emailKey);
    _mockPasswords.remove(emailKey);
    
    // Mark as deleted to prevent any future login attempts
    _deletedAccounts.add(emailKey);
    
    return true;
  }
  
  // Get all accounts (for owner to see all accounts they can delete)
  static Future<List<User>> getAllAccounts() async {
    await _delay();
    return _mockUsers.values.toList();
  }
}

