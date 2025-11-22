import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';

// SignUpScreen - the screen where new users create an account
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // Controllers for text fields
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  // Consumer-specific fields
  final _businessNameController = TextEditingController();
  final _consumerAddressController = TextEditingController();
  final _consumerPhoneController = TextEditingController();
  
  // Supplier-specific fields
  final _companyNameController = TextEditingController();
  final _companyTypeController = TextEditingController();
  final _supplierAddressController = TextEditingController();
  final _supplierPhoneController = TextEditingController();

  String _selectedRole = UserRole.consumer; // Default role
  String? _supplierSubRole; // Owner, Manager, or Sales for suppliers

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _businessNameController.dispose();
    _consumerAddressController.dispose();
    _consumerPhoneController.dispose();
    _companyNameController.dispose();
    _companyTypeController.dispose();
    _supplierAddressController.dispose();
    _supplierPhoneController.dispose();
    super.dispose();
  }

  // Function called when user taps "Sign Up" button
  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Validate supplier sub-role if supplier is selected
    if (_selectedRole == UserRole.supplier && _supplierSubRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your supplier role (Owner, Manager, or Sales)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Use supplier sub-role if supplier is selected, otherwise use selected role
    final finalRole = _selectedRole == UserRole.supplier 
        ? _supplierSubRole! 
        : _selectedRole;

    final success = await authProvider.signup(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      name: _nameController.text.trim(),
      role: finalRole,
      businessName: _selectedRole == UserRole.consumer
          ? _businessNameController.text.trim()
          : null,
      address: _selectedRole == UserRole.consumer
          ? _consumerAddressController.text.trim()
          : _supplierAddressController.text.trim(),
      phone: _selectedRole == UserRole.consumer
          ? _consumerPhoneController.text.trim()
          : _supplierPhoneController.text.trim(),
      companyName: _selectedRole == UserRole.supplier
          ? _companyNameController.text.trim()
          : null,
      companyType: _selectedRole == UserRole.supplier
          ? _companyTypeController.text.trim()
          : null,
    );

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Signup failed'),
          backgroundColor: Colors.red,
        ),
      );
    } else if (success && mounted) {
      // Clear navigation stack and go back to root
      // AuthWrapper will automatically show the dashboard since user is now authenticated
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Role selection
                const Text(
                  'Select your role:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Consumer'),
                        value: UserRole.consumer,
                        groupValue: _selectedRole,
                        onChanged: (value) {
                          setState(() {
                            _selectedRole = value!;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Supplier'),
                        value: UserRole.supplier,
                        groupValue: _selectedRole,
                        onChanged: (value) {
                          setState(() {
                            _selectedRole = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Common fields
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    hintText: 'Enter your name',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter your email',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirm Password',
                    hintText: 'Re-enter your password',
                    prefixIcon: Icon(Icons.lock_outline),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Consumer-specific fields
                if (_selectedRole == UserRole.consumer) ...[
                  TextFormField(
                    controller: _businessNameController,
                    decoration: const InputDecoration(
                      labelText: 'Business Name',
                      hintText: 'Enter your business name',
                      prefixIcon: Icon(Icons.business),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your business name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _consumerAddressController,
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      hintText: 'Enter your address',
                      prefixIcon: Icon(Icons.location_on),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _consumerPhoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone',
                      hintText: 'Enter your phone number',
                      prefixIcon: Icon(Icons.phone),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                ],

                // Supplier-specific fields
                if (_selectedRole == UserRole.supplier) ...[
                  // Supplier role selection (Owner, Manager, Sales)
                  const Text(
                    'Select your supplier role:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  RadioListTile<String>(
                    title: const Text('Owner'),
                    subtitle: const Text('Full access to all features'),
                    value: UserRole.owner,
                    groupValue: _supplierSubRole,
                    onChanged: (value) {
                      setState(() {
                        _supplierSubRole = value;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Manager'),
                    subtitle: const Text('Can manage sales staff'),
                    value: UserRole.manager,
                    groupValue: _supplierSubRole,
                    onChanged: (value) {
                      setState(() {
                        _supplierSubRole = value;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Sales Representative'),
                    subtitle: const Text('Can view orders and chat'),
                    value: UserRole.sales,
                    groupValue: _supplierSubRole,
                    onChanged: (value) {
                      setState(() {
                        _supplierSubRole = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _companyNameController,
                    decoration: const InputDecoration(
                      labelText: 'Company Name',
                      hintText: 'Enter your company name',
                      prefixIcon: Icon(Icons.business),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your company name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _companyTypeController,
                    decoration: const InputDecoration(
                      labelText: 'Company Type',
                      hintText: 'Enter your company type',
                      prefixIcon: Icon(Icons.category),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your company type';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _supplierAddressController,
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      hintText: 'Enter your address',
                      prefixIcon: Icon(Icons.location_on),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _supplierPhoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone',
                      hintText: 'Enter your phone number',
                      prefixIcon: Icon(Icons.phone),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                ],

                // Sign Up button
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return ElevatedButton(
                      onPressed:
                          authProvider.isLoading ? null : _handleSignUp,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.grey[800],
                        foregroundColor: Colors.white,
                      ),
                      child: authProvider.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              'Sign Up',
                              style: TextStyle(fontSize: 16),
                            ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Login link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account? "),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Login'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

