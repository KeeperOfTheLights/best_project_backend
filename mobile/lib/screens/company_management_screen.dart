import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/staff_provider.dart';
import '../providers/auth_provider.dart';
import '../models/staff_member.dart';
import '../utils/constants.dart';
import '../utils/localization.dart';
import '../widgets/language_switcher.dart';

class CompanyManagementScreen extends StatefulWidget {
  const CompanyManagementScreen({super.key});

  @override
  State<CompanyManagementScreen> createState() => _CompanyManagementScreenState();
}

class _CompanyManagementScreenState extends State<CompanyManagementScreen> {
  List<StaffMember> _unassignedUsers = [];
  bool _isLoadingUnassigned = false;
  String? _actionLoadingId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final staffProvider = Provider.of<StaffProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      if (authProvider.user?.role != UserRole.owner) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)
                .text('Only owners can access Company Management')),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      staffProvider.loadStaff();
      _loadUnassignedUsers();
    });
  }

  Future<void> _loadUnassignedUsers() async {
    setState(() {
      _isLoadingUnassigned = true;
    });

    try {
      final staffProvider = Provider.of<StaffProvider>(context, listen: false);
      final users = await staffProvider.loadUnassignedUsers();
      setState(() {
        _unassignedUsers = users;
        _isLoadingUnassigned = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingUnassigned = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load unassigned users: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleAssign(String userId) async {
    setState(() => _actionLoadingId = userId);
    final staffProvider = Provider.of<StaffProvider>(context, listen: false);
    
    final success = await staffProvider.addStaff(
      userId: userId,
    );
    
    if (mounted) {
      setState(() => _actionLoadingId = null);
      if (success) {

        await staffProvider.loadStaff();
        await _loadUnassignedUsers();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Employee assigned successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(staffProvider.errorMessage ?? 'Failed to assign employee'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleRemove(String userId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Employee'),
        content: const Text('Are you sure you want to remove this employee from your company?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _actionLoadingId = userId);
    final staffProvider = Provider.of<StaffProvider>(context, listen: false);
    
    final success = await staffProvider.removeStaff(userId);
    
    if (mounted) {
      setState(() => _actionLoadingId = null);
      if (success) {

        await staffProvider.loadStaff();
        await _loadUnassignedUsers();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Employee removed successfully'),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(staffProvider.errorMessage ?? 'Failed to remove employee'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getRoleLabel(String role) {
    switch (role.toLowerCase()) {
      case 'manager':
        return 'Manager';
      case 'sales':
        return 'Sales Representative';
      case 'owner':
        return 'Owner';
      default:
        return role;
    }
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'owner':
        return Colors.purple;
      case 'manager':
        return Colors.blue;
      case 'sales':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5E6E6),
        title: Text(
          loc.text('Company Management'),
          style: const TextStyle(
            color: Color(0xFF20232A),
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: LanguageSwitcher(),
          ),
        ],
      ),
      body: Consumer<StaffProvider>(
        builder: (context, staffProvider, child) {
          final employees = staffProvider.staff;
          final isLoading = staffProvider.isLoading || _isLoadingUnassigned;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        loc.text('Company Management'),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF20232A),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () async {
                                await staffProvider.loadStaff();
                                await _loadUnassignedUsers();
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E3A8A),
                          foregroundColor: Colors.white,
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Text(loc.text('Refresh')),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Expanded(
                        child: Card(
                          color: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${loc.text('Current Employees')} (${employees.length})',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF20232A),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                if (isLoading && employees.isEmpty)
                                  const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(24.0),
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                                else if (employees.isEmpty)
                                  Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(24.0),
                                      child: Text(
                                        loc.text(
                                            'No employees assigned to your company yet.'),
                                        style:
                                            const TextStyle(color: Colors.grey),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  )
                                else
                                  ...employees.map((employee) => _buildEmployeeCard(
                                    employee,
                                    isUnassigned: false,
                                  )),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      Expanded(
                        child: Card(
                          color: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${loc.text('Available to Assign')} (${_unassignedUsers.length})',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF20232A),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  loc.text(
                                      'Managers and Sales Representatives who are not yet assigned to any company.'),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF666666),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                if (_isLoadingUnassigned && _unassignedUsers.isEmpty)
                                  const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(24.0),
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                                else if (_unassignedUsers.isEmpty)
                                  Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(24.0),
                                      child: Text(
                                        loc.text('No unassigned users available.'),
                                        style:
                                            const TextStyle(color: Colors.grey),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  )
                                else
                                  ..._unassignedUsers.map((user) => _buildEmployeeCard(
                                    user,
                                    isUnassigned: true,
                                  )),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmployeeCard(StaffMember employee, {required bool isUnassigned}) {
    final isLoading = _actionLoadingId == employee.id;
    final loc = AppLocalizations.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.grey[50],
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              employee.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF20232A),
              ),
            ),
            const SizedBox(height: 4),

            Text(
              employee.email,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
              ),
            ),
            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getRoleColor(employee.role).withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _getRoleLabel(employee.role),
                style: TextStyle(
                  color: _getRoleColor(employee.role),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () {
                        if (isUnassigned) {
                          _handleAssign(employee.id);
                        } else {
                          _handleRemove(employee.id);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isUnassigned ? Colors.green : Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(isUnassigned
                        ? loc.text('Assign to Company')
                        : loc.text('Remove')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

