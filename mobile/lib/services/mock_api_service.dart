import '../models/auth_response.dart';
import '../models/user.dart';

// MockApiService - simulates backend responses for testing
// Use this when you don't have a real backend yet
class MockApiService {
  // Store mock users (email -> User data)
  // In real app, this would be in a database
  static final Map<String, User> _mockUsers = {};

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

    // Check if user exists in our mock database
    final user = _mockUsers[email.toLowerCase()];
    
    if (user == null) {
      // User doesn't exist - this simulates invalid credentials
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

    // Save user to mock database
    _mockUsers[email.toLowerCase()] = newUser;

    // Simulate successful signup
    return AuthResponse(
      token: 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
      user: newUser,
    );
  }
}

