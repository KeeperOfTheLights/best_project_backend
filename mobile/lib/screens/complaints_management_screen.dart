import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/complaint_provider.dart';
import '../providers/auth_provider.dart';
import '../models/complaint.dart';
import '../utils/constants.dart';
import '../utils/localization.dart';
import '../widgets/language_switcher.dart';
import 'chat_room_screen.dart';

// ComplaintsManagementScreen - allows suppliers to manage complaints
class ComplaintsManagementScreen extends StatefulWidget {
  const ComplaintsManagementScreen({super.key});

  @override
  State<ComplaintsManagementScreen> createState() =>
      _ComplaintsManagementScreenState();
}

class _ComplaintsManagementScreenState
    extends State<ComplaintsManagementScreen> {
  String _filterStatus = 'all'; // 'all', 'pending', 'resolved', 'rejected', 'escalated'
  String? _actionLoadingId; // Track which complaint is being processed

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ComplaintProvider>(context, listen: false).loadComplaints();
    });
  }

  Map<String, int> _getCounts(List<Complaint> complaints) {
    return {
      'all': complaints.length,
      'pending': complaints.where((c) => c.status == 'pending').length,
      'resolved': complaints.where((c) => c.status == 'resolved').length,
      'rejected': complaints.where((c) => c.status == 'rejected').length,
      'escalated': complaints.where((c) => c.status == 'escalated').length,
    };
  }

  List<Complaint> _getFilteredComplaints(List<Complaint> complaints) {
    if (_filterStatus == 'all') {
      return complaints;
    }
    return complaints.where((c) => c.status == _filterStatus).toList();
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'resolved':
        return 'Resolved';
      case 'rejected':
        return 'Rejected';
      case 'escalated':
        return 'Escalated';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'resolved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'escalated':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '—';
    return '${date.day}.${date.month}.${date.year}';
  }

  Future<void> _handleResolve(String complaintId) async {
    setState(() => _actionLoadingId = complaintId);
    final complaintProvider = Provider.of<ComplaintProvider>(context, listen: false);
    
    final success = await complaintProvider.resolveComplaint(complaintId);
    
    if (mounted) {
      setState(() => _actionLoadingId = null);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Complaint resolved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(complaintProvider.errorMessage ?? 'Failed to resolve complaint'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleReject(String complaintId) async {
    setState(() => _actionLoadingId = complaintId);
    final complaintProvider = Provider.of<ComplaintProvider>(context, listen: false);
    
    final success = await complaintProvider.rejectComplaint(complaintId);
    
    if (mounted) {
      setState(() => _actionLoadingId = null);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Complaint rejected'),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(complaintProvider.errorMessage ?? 'Failed to reject complaint'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleEscalate(String complaintId) async {
    setState(() => _actionLoadingId = complaintId);
    final complaintProvider = Provider.of<ComplaintProvider>(context, listen: false);
    
    final success = await complaintProvider.escalateComplaint(complaintId);
    
    if (mounted) {
      setState(() => _actionLoadingId = null);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Complaint escalated to Manager/Owner'),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(complaintProvider.errorMessage ?? 'Failed to escalate complaint'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userRole = authProvider.user?.role ?? '';
    final isSales = userRole == UserRole.sales;
    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5E6E6),
        title: Text(
          loc.text('Complaints Management'),
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
      body: Consumer<ComplaintProvider>(
        builder: (context, complaintProvider, child) {
          final complaints = complaintProvider.complaints;
          final counts = _getCounts(complaints);
          final filteredComplaints = _getFilteredComplaints(complaints);

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with subtitle and Refresh button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              loc.text('Complaints Management'),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF20232A),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isSales
                                  ? loc.text('Handle customer complaints and escalate when manager review is needed.')
                                  : loc.text('Review escalated complaints and manage order-related issues.'),
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF666666),
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: complaintProvider.isLoading
                            ? null
                            : () {
                                complaintProvider.loadComplaints();
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF61DAFB),
                          foregroundColor: Colors.white,
                        ),
                        child: complaintProvider.isLoading
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

                  // Summary Cards
                  if (isSales)
                    Row(
                      children: [
                        Expanded(
                          child: _buildSummaryCard(
                            icon: Icons.hourglass_empty,
                            count: counts['pending'] ?? 0,
                            label: loc.text('Pending'),
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSummaryCard(
                            icon: Icons.check_circle,
                            count: counts['resolved'] ?? 0,
                            label: loc.text('Resolved'),
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSummaryCard(
                            icon: Icons.cancel,
                            count: counts['rejected'] ?? 0,
                            label: loc.text('Rejected'),
                            color: Colors.red,
                          ),
                        ),
                      ],
                    )
                  else
                    _buildSummaryCard(
                      icon: Icons.trending_up,
                      count: counts['escalated'] ?? 0,
                      label: loc.text('Escalated'),
                      color: Colors.purple,
                    ),

                  const SizedBox(height: 24),

                  // Filter Tabs
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterTab(loc, 'all', counts['all'] ?? 0, _filterStatus == 'all'),
                        const SizedBox(width: 8),
                        if (isSales) ...[
                          _buildFilterTab(loc, 'pending', counts['pending'] ?? 0, _filterStatus == 'pending'),
                          const SizedBox(width: 8),
                          _buildFilterTab(loc, 'resolved', counts['resolved'] ?? 0, _filterStatus == 'resolved'),
                          const SizedBox(width: 8),
                          _buildFilterTab(loc, 'rejected', counts['rejected'] ?? 0, _filterStatus == 'rejected'),
                        ] else ...[
                          _buildFilterTab(loc, 'escalated', counts['escalated'] ?? 0, _filterStatus == 'escalated'),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Complaints List
                  if (complaintProvider.isLoading && complaints.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(48.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (complaintProvider.errorMessage != null && complaints.isEmpty)
                    Center(
                      child: Column(
                        children: [
                          const Icon(Icons.error_outline, size: 48, color: Colors.red),
                          const SizedBox(height: 16),
                            Text(complaintProvider.errorMessage!),
                          const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                complaintProvider.loadComplaints();
                              },
                              child: Text(loc.text('Retry')),
                          ),
                        ],
                      ),
                    )
                  else if (filteredComplaints.isEmpty)
                    Card(
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(48.0),
                        child: Column(
                          children: [
                            const Icon(Icons.report_problem_outlined, size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            Text(
                              loc.text('No complaints found for this status.'),
                              style: const TextStyle(color: Colors.grey, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...filteredComplaints.map((complaint) => _buildComplaintCard(complaint, userRole)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required int count,
    required String label,
    required Color color,
  }) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTab(AppLocalizations loc, String status, int count, bool isActive) {
    return InkWell(
      onTap: () {
        setState(() {
          _filterStatus = status;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF61DAFB) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? const Color(0xFF61DAFB) : Colors.grey[300]!,
          ),
        ),
        child: Text(
          '${loc.text('${status[0].toUpperCase()}${status.substring(1)}')}${count > 0 ? ' ($count)' : ''}',
          style: TextStyle(
            color: isActive ? Colors.white : const Color(0xFF20232A),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildComplaintCard(Complaint complaint, String userRole) {
    // Show Resolve/Reject buttons for pending or escalated complaints
    final canResolveOrReject = complaint.status == 'pending' || complaint.status == 'escalated';
    final isLoading = _actionLoadingId == complaint.id;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: _getStatusColor(complaint.status).withOpacity(0.3),
          width: 3,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Title and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    complaint.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF20232A),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(complaint.status).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusLabel(complaint.status),
                    style: TextStyle(
                      color: _getStatusColor(complaint.status),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Complaint Info
            Text(
              'Consumer: ${complaint.consumerName ?? complaint.accountName ?? "Unknown"}',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Order ID: #${complaint.orderId}',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              complaint.description,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF20232A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Created: ${_formatDate(complaint.createdAt)}',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF666666),
              ),
            ),
            const SizedBox(height: 12),
            // Action Buttons
            Column(
              children: [
                // Open Chat button - full width
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            // Navigate to chat with consumer
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatRoomScreen(
                                  chatRoomId: complaint.consumerId,
                                  otherPartyName: complaint.consumerName ?? complaint.accountName ?? 'Consumer',
                                  otherPartyType: 'Consumer',
                                ),
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF61DAFB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Open Chat'),
                  ),
                ),
                if (canResolveOrReject || (userRole == UserRole.sales && complaint.status == 'pending')) ...[
                  const SizedBox(height: 8),
                  // Action buttons row
                  Row(
                    children: [
                      if (canResolveOrReject) ...[
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isLoading ? null : () => _handleResolve(complaint.id),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Text('Resolve'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isLoading ? null : () => _handleReject(complaint.id),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Text('Reject'),
                          ),
                        ),
                      ],
                      // Escalate button - only for Sales Rep on pending complaints
                      if (userRole == UserRole.sales && complaint.status == 'pending') ...[
                        if (canResolveOrReject) const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isLoading ? null : () => _handleEscalate(complaint.id),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Text('Escalate'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
