import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/complaint_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import '../models/complaint.dart';
import '../utils/constants.dart';
import 'order_details_screen.dart';
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ComplaintProvider>(context, listen: false).loadComplaints();
    });
  }

  void _showActionDialog(Complaint complaint) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userRole = authProvider.user?.role ?? '';

    // Determine available actions based on role and status
    final canMarkInProgress = complaint.status == ComplaintStatus.pending &&
        (userRole == UserRole.owner ||
            userRole == UserRole.manager ||
            userRole == UserRole.sales);

    final canResolve = (complaint.status == ComplaintStatus.pending ||
            complaint.status == ComplaintStatus.inProgress) &&
        (userRole == UserRole.owner || userRole == UserRole.manager);

    final canEscalate = complaint.status != ComplaintStatus.escalated &&
        complaint.status != ComplaintStatus.resolved &&
        userRole == UserRole.sales;

    if (!canMarkInProgress && !canResolve && !canEscalate) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No actions available for this complaint'),
          backgroundColor: Colors.grey,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Complaint #${complaint.id.substring(complaint.id.length - 6)}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Issue: ${IssueType.getDisplayName(complaint.issueType)}'),
            const SizedBox(height: 8),
            Text('Description: ${complaint.description}'),
            const SizedBox(height: 16),
            const Text('Select an action:'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          if (canMarkInProgress)
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _updateComplaintStatus(
                  complaint.id,
                  ComplaintStatus.inProgress,
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[800]),
              child: const Text('Mark In Progress'),
            ),
          if (canResolve)
            ElevatedButton(
              onPressed: () => _showResolveDialog(complaint),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Resolve'),
            ),
          if (canEscalate)
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _updateComplaintStatus(
                  complaint.id,
                  ComplaintStatus.escalated,
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
              child: const Text('Escalate to Manager'),
            ),
        ],
      ),
    );
  }

  void _showResolveDialog(Complaint complaint) {
    final resolutionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resolve Complaint'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Add a resolution note (optional):'),
            const SizedBox(height: 16),
            TextField(
              controller: resolutionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Resolution Note',
                hintText: 'Describe how the issue was resolved...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _updateComplaintStatus(
                complaint.id,
                ComplaintStatus.resolved,
                resolutionNote: resolutionController.text.trim().isEmpty
                    ? null
                    : resolutionController.text.trim(),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Resolve'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateComplaintStatus(
    String complaintId,
    String status, {
    String? resolutionNote,
  }) async {
    final complaintProvider =
        Provider.of<ComplaintProvider>(context, listen: false);

    bool success = false;
    
    // Use appropriate method based on status
    if (status == ComplaintStatus.resolved) {
      success = await complaintProvider.resolveComplaint(complaintId);
    } else if (status == ComplaintStatus.rejected) {
      success = await complaintProvider.rejectComplaint(complaintId);
    } else if (status == ComplaintStatus.escalated) {
      success = await complaintProvider.escalateComplaint(complaintId);
    } else {
      // For inProgress or other statuses, we might not have backend support
      // For now, just show error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This status update is not supported'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    if (mounted) {
      if (success) {
        // Reload complaints to get updated status
        await complaintProvider.loadComplaints();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Complaint status updated to ${_formatStatus(status)}'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              complaintProvider.errorMessage ?? 'Failed to update complaint',
            ),
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

    // Filter complaints based on role
    // Sales: sees complaints from assigned consumers (all for now in mock)
    // Manager: sees escalated complaints
    // Owner: sees all complaints

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Complaints Management'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'All'),
              Tab(text: 'Pending'),
              Tab(text: 'In Progress'),
              Tab(text: 'Resolved'),
            ],
          ),
        ),
        body: Consumer<ComplaintProvider>(
          builder: (context, complaintProvider, child) {
            if (complaintProvider.isLoading &&
                complaintProvider.complaints.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            // Filter complaints by role
            List<Complaint> filteredComplaints = complaintProvider.complaints;
            if (userRole == UserRole.manager) {
              // Manager sees escalated complaints
              filteredComplaints = complaintProvider.escalatedComplaints;
            } else if (userRole == UserRole.sales) {
              // Sales sees complaints from assigned consumers
              // For mock, show all non-escalated complaints
              filteredComplaints = complaintProvider.complaints
                  .where((c) => c.status != ComplaintStatus.escalated)
                  .toList();
            }
            // Owner sees all complaints

            if (complaintProvider.errorMessage != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(complaintProvider.errorMessage!),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        complaintProvider.loadComplaints();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                await complaintProvider.loadComplaints();
              },
              child: TabBarView(
                children: [
                  _buildComplaintsList(filteredComplaints, userRole),
                  _buildComplaintsList(
                    filteredComplaints
                        .where((c) => c.status == ComplaintStatus.pending)
                        .toList(),
                    userRole,
                  ),
                  _buildComplaintsList(
                    filteredComplaints
                        .where((c) => c.status == ComplaintStatus.inProgress)
                        .toList(),
                    userRole,
                  ),
                  _buildComplaintsList(
                    filteredComplaints
                        .where((c) => c.status == ComplaintStatus.resolved)
                        .toList(),
                    userRole,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildComplaintsList(List<Complaint> complaints, String userRole) {
    if (complaints.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.report_problem_outlined,
                size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No complaints',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: complaints.length,
      itemBuilder: (context, index) {
        final complaint = complaints[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getStatusColor(complaint.status),
              child: Icon(_getStatusIcon(complaint.status),
                  color: Colors.white, size: 20),
            ),
            title: Text(
              complaint.title.isNotEmpty
                  ? complaint.title
                  : 'Complaint #${complaint.id.substring(complaint.id.length - 6)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (complaint.accountName.isNotEmpty)
                  Text(
                    'From: ${complaint.accountName}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                Text('Order: #${complaint.orderId}'),
                Text('Issue: ${IssueType.getDisplayName(complaint.issueType)}'),
                if (complaint.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Description:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          complaint.description,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Text('Status: ${_formatStatus(complaint.status)}'),
                Text('Date: ${_formatDate(complaint.createdAt)}'),
                if (complaint.resolutionNote != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Resolution: ${complaint.resolutionNote}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                if (complaint.status == ComplaintStatus.escalated) ...[
                  const SizedBox(height: 4),
                  const Text(
                    'Escalated to Manager',
                    style: TextStyle(
                      color: Colors.purple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.chat),
                  onPressed: () async {
                    final chatProvider =
                        Provider.of<ChatProvider>(context, listen: false);
                    final room = await chatProvider.createOrGetChatRoom(
                      complaint.consumerId,
                      orderId: complaint.orderId,
                    );
                    if (room != null && mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatRoomScreen(
                            chatRoomId: room.id,
                            otherPartyName: complaint.accountName.isNotEmpty
                                ? complaint.accountName
                                : 'Consumer',
                          ),
                        ),
                      );
                    }
                  },
                  tooltip: 'Message Consumer',
                  color: Colors.grey[700],
                ),
                IconButton(
                  icon: const Icon(Icons.visibility),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            OrderDetailsScreen(orderId: complaint.orderId),
                      ),
                    );
                  },
                  tooltip: 'View Order',
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () => _showActionDialog(complaint),
                  tooltip: 'Actions',
                ),
              ],
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case ComplaintStatus.pending:
        return Colors.orange;
      case ComplaintStatus.inProgress:
        return Colors.grey[700]!;
      case ComplaintStatus.resolved:
        return Colors.green;
      case ComplaintStatus.escalated:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case ComplaintStatus.pending:
        return Icons.pending;
      case ComplaintStatus.inProgress:
        return Icons.hourglass_empty;
      case ComplaintStatus.resolved:
        return Icons.check_circle;
      case ComplaintStatus.escalated:
        return Icons.trending_up;
      default:
        return Icons.help_outline;
    }
  }

  String _formatStatus(String status) {
    return status.split('_').map((word) {
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

