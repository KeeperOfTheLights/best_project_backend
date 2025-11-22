import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/staff_provider.dart';
import '../providers/auth_provider.dart';
import '../models/staff_member.dart';
import '../utils/constants.dart';

// StaffManagementScreen - allows Owner/Manager to manage staff
class StaffManagementScreen extends StatefulWidget {
  final bool isSalesManagement; // If true, only show sales staff (for Manager)

  const StaffManagementScreen({
    super.key,
    this.isSalesManagement = false,
  });

  @override
  State<StaffManagementScreen> createState() => _StaffManagementScreenState();
}

class _StaffManagementScreenState extends State<StaffManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StaffProvider>(context, listen: false).loadStaff();
    });
  }

  void _showAddStaffDialog() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentRole = authProvider.user?.role ?? '';

    // Determine which roles can be added based on Requirements.md
    List<String> availableRoles = [];
    if (currentRole == UserRole.owner) {
      // Owner: Add Manager, Add Sales
      availableRoles = [UserRole.manager, UserRole.sales];
    } else if (currentRole == UserRole.manager || widget.isSalesManagement) {
      // Manager: Add Sales only
      availableRoles = [UserRole.sales];
    }

    if (availableRoles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You do not have permission to add staff'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final phoneController = TextEditingController();
    String selectedRole = availableRoles[0];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Staff Member'),
          content: SingleChildScrollView(
            child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                    labelText: 'Full Name *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                    labelText: 'Email *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password *',
                    hintText: 'Min. 6 characters',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedRole,
                decoration: const InputDecoration(
                    labelText: 'Role *',
                  border: OutlineInputBorder(),
                ),
                items: availableRoles.map((role) {
                  return DropdownMenuItem(
                    value: role,
                    child: Text(role.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  setDialogState(() {
                    selectedRole = value!;
                  });
                },
              ),
            ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty || 
                    emailController.text.isEmpty || 
                    passwordController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill all required fields'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                
                if (passwordController.text.length < 6) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password must be at least 6 characters'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final staffProvider =
                    Provider.of<StaffProvider>(context, listen: false);
                
                // For real backend, we need userId (user must register first)
                // Show message and return early
                if (!useMockApi) {
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('To add staff: User must register first, then select them from "Unassigned Users" to assign to your company. Use the "Load Unassigned Users" button to see available users.'),
                        backgroundColor: Colors.orange,
                        duration: Duration(seconds: 6),
                      ),
                    );
                  }
                  return;
                }
                
                // Mock API: create staff with email/name/password
                final success = await staffProvider.addStaff(
                  email: emailController.text.trim(),
                  name: nameController.text.trim(),
                  role: selectedRole,
                  password: passwordController.text,
                  phone: phoneController.text.trim().isEmpty 
                      ? null 
                      : phoneController.text.trim(),
                );

                if (mounted) {
                  Navigator.pop(context);
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Staff member added successfully. They can now login with their email and password.'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 3),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          staffProvider.errorMessage ?? 'Failed to add staff',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showRemoveStaffDialog(StaffMember staff) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Staff Account'),
        content: Text(
          'Are you sure you want to delete ${staff.name}\'s account? '
          'This will permanently delete their account and they will no longer be able to login.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final staffProvider =
                  Provider.of<StaffProvider>(context, listen: false);
              final success = await staffProvider.removeStaff(staff.id);

              if (mounted) {
                Navigator.pop(context);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Account deleted. They can no longer login.'),
                      backgroundColor: Colors.orange,
                      duration: Duration(seconds: 3),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        staffProvider.errorMessage ?? 'Failed to delete account',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentRole = authProvider.user?.role ?? '';

    // Check permissions
    final canAddStaff = currentRole == UserRole.owner || currentRole == UserRole.manager;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isSalesManagement ? 'Sales Management' : 'Staff Management'),
        actions: [
          if (canAddStaff)
            IconButton(
              icon: const Icon(Icons.person_add),
              onPressed: _showAddStaffDialog,
              tooltip: 'Add Staff',
            ),
        ],
      ),
      body: Consumer<StaffProvider>(
        builder: (context, staffProvider, child) {
          if (staffProvider.isLoading && staffProvider.staff.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (staffProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(staffProvider.errorMessage!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      staffProvider.loadStaff();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Filter staff based on role and screen type
          List<StaffMember> displayStaff = staffProvider.activeStaff;
          
          // If Sales Management screen (Manager view), only show Sales staff
          if (widget.isSalesManagement) {
            displayStaff = staffProvider.getStaffByRole(UserRole.sales);
          }

          if (displayStaff.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.people_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No staff members',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  if (canAddStaff) ...[
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _showAddStaffDialog,
                      icon: const Icon(Icons.person_add),
                      label: const Text('Add Staff Member'),
                    ),
                  ],
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await staffProvider.loadStaff();
            },
            child: ListView.builder(
              itemCount: displayStaff.length,
              itemBuilder: (context, index) {
                final staff = displayStaff[index];
                final canManage = StaffMember.canManage(currentRole, staff.role);

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getRoleColor(staff.role),
                      child: Text(
                        staff.name[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      staff.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Email: ${staff.email}'),
                        if (staff.phone != null && staff.phone!.isNotEmpty)
                          Text('Phone: ${staff.phone}'),
                        const SizedBox(height: 4),
                        Chip(
                          label: Text(
                            staff.role.toUpperCase(),
                            style: const TextStyle(fontSize: 10),
                          ),
                          backgroundColor: _getRoleColor(staff.role).withOpacity(0.2),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                    trailing: canManage
                        ? IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _showRemoveStaffDialog(staff),
                            tooltip: 'Remove',
                          )
                        : null,
                    isThreeLine: true,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case UserRole.owner:
        return Colors.purple;
      case UserRole.manager:
        return Colors.grey[700]!;
      case UserRole.sales:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

