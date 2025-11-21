import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/complaint_provider.dart';
import '../models/complaint.dart';
import 'order_details_screen.dart';

// ViewComplaintsScreen - allows consumers to view their complaints
class ViewComplaintsScreen extends StatefulWidget {
  const ViewComplaintsScreen({super.key});

  @override
  State<ViewComplaintsScreen> createState() => _ViewComplaintsScreenState();
}

class _ViewComplaintsScreenState extends State<ViewComplaintsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ComplaintProvider>(context, listen: false).loadComplaints();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
      appBar: AppBar(
        title: const Text('My Complaints'),
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
                  _buildComplaintsList(complaintProvider.complaints),
                  _buildComplaintsList(complaintProvider.pendingComplaints),
                  _buildComplaintsList(complaintProvider.inProgressComplaints),
                  _buildComplaintsList(complaintProvider.resolvedComplaints),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildComplaintsList(List<Complaint> complaints) {
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
                  Text('Account: ${complaint.accountName}'),
                Text('Order: #${complaint.orderId}'),
                Text('Issue: ${IssueType.getDisplayName(complaint.issueType)}'),
                Text('Status: ${_formatStatus(complaint.status)}'),
                Text('Date: ${_formatDate(complaint.createdAt)}'),
                if (complaint.resolutionNote != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Resolution: ${complaint.resolutionNote}',
                    style: TextStyle(
                      color: Colors.green,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OrderDetailsScreen(orderId: complaint.orderId),
                ),
              );
            },
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
        return Colors.blue;
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

