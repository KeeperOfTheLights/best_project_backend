import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'signup_screen.dart';

// LoginScreen - the screen where users enter email and password to login
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controllers for text fields (to get the text user types)
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // For form validation

  @override
  void dispose() {
    // Clean up controllers when screen is closed
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Function called when user taps "Login" button
  Future<void> _handleLogin() async {
    // Validate form (check if fields are filled correctly)
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Get the AuthProvider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Call login function
    final success = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    // Show error message if login failed
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Login failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
    // If successful, navigation will happen automatically via Consumer
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFBFB7B7), // Light gray background matching website
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Container(
                // White card matching website design
                padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 32.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                width: 360, // Fixed width matching website
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                    // Logo from assets
                    Center(
                      child: Image.asset(
                        'assets/images/Logo.png',
                        width: 60,
                        height: 60,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Title - "Welcome Back"
                  const Text(
                      'Welcome Back',
                    style: TextStyle(
                        fontSize: 28,
                      fontWeight: FontWeight.bold,
                        color: Color(0xFF20232A), // Black text matching website
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                    // Subtitle - "Log in to continue"
                  const Text(
                      'Log in to continue',
                    style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF20232A), // Gray text matching website
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // Error message (shown if login fails)
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        if (authProvider.errorMessage != null && authProvider.errorMessage!.isNotEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF1F0), // Light red background
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFFF4D4F)),
                            ),
                            child: Text(
                              authProvider.errorMessage!,
                              style: const TextStyle(
                                color: Color(0xFFFF4D4F), // Red text
                                fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),

                    // Email Address field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'Email Address',
                        filled: true,
                        fillColor: const Color(0xFFB5B5B5), // Gray background matching website
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF9B9A9A)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF9B9A9A)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF61DAFB)), // Light blue focus
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                        if (!value.contains('@') || !value.contains('.')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password field
                  TextFormField(
                    controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        filled: true,
                        fillColor: const Color(0xFFB5B5B5), // Gray background matching website
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF9B9A9A)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF9B9A9A)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF61DAFB)), // Light blue focus
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                    // Log In button
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return ElevatedButton(
                        onPressed: authProvider.isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: const Color(0xFF61DAFB), // Light blue matching website
                            foregroundColor: const Color(0xFF20232A), // Black text
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                        ),
                        child: authProvider.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFF20232A),
                                  ),
                                ),
                              )
                            : const Text(
                                  'Log In',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                              ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                    // Footer - "Don't have an account yet? Sign Up"
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        const Text(
                          "Don't have an account yet? ",
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF20232A),
                          ),
                        ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignUpScreen(),
                            ),
                          );
                        },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF61DAFB), // Light blue link
                              decoration: TextDecoration.underline,
                            ),
                          ),
                      ),
                    ],
                  ),
                ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}




