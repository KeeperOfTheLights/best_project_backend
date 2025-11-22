import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/link_request_provider.dart';
import '../models/link_request.dart';

// ManageLinkRequestsScreen - allows suppliers to view and manage incoming link requests
class ManageLinkRequestsScreen extends StatefulWidget {
  const ManageLinkRequestsScreen({super.key});

  @override
  State<ManageLinkRequestsScreen> createState() =>
      _ManageLinkRequestsScreenState();
}

class _ManageLinkRequestsScreenState extends State<ManageLinkRequestsScreen> {
  @override
  void initState() {
    super.initState();
    // Load link requests when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LinkRequestProvider>(context, listen: false)
          .loadLinkRequests();
    });
  }

  Future<void> _approveRequest(LinkRequest request) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Link Request'),
        content: Text(
          'Approve link request from ${request.consumer?.name ?? 'Consumer'}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Approve'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final provider = Provider.of<LinkRequestProvider>(context, listen: false);
      final success = await provider.approveLinkRequest(request.id);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Link request approved!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.errorMessage ?? 'Failed to approve request'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _rejectRequest(LinkRequest request) async {
    final reasonController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Link Request'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Reject link request from ${request.consumer?.name ?? 'Consumer'}?',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason (optional)',
                hintText: 'Enter rejection reason...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final provider = Provider.of<LinkRequestProvider>(context, listen: false);
      final success = await provider.rejectLinkRequest(
        request.id,
        reason: reasonController.text.trim().isEmpty
            ? null
            : reasonController.text.trim(),
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Link request rejected'),
              backgroundColor: Colors.orange,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.errorMessage ?? 'Failed to reject request'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Link Requests'),
      ),
      body: Consumer<LinkRequestProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.linkRequests.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final pendingRequests = provider.getPendingRequests();

          if (pendingRequests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.inbox, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No pending link requests',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      provider.loadLinkRequests();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await provider.loadLinkRequests();
            },
            child: ListView.builder(
              itemCount: pendingRequests.length,
              itemBuilder: (context, index) {
                final request = pendingRequests[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header row with avatar and name
                        Row(
                          children: [
                            const CircleAvatar(
                              backgroundColor: Colors.orange,
                              radius: 24,
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    request.consumer?.name ?? 'Consumer',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (request.consumer?.businessName != null)
                                    Text(
                                      request.consumer!.businessName!,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[700],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            // Action buttons
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.check_circle, color: Colors.green),
                                  onPressed: () => _approveRequest(request),
                                  tooltip: 'Approve',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.cancel, color: Colors.red),
                                  onPressed: () => _rejectRequest(request),
                                  tooltip: 'Reject',
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 8),
                        // Details section
                        if (request.consumer?.businessName != null)
                          _buildDetailRow(
                            Icons.business,
                            'Business',
                            request.consumer!.businessName!,
                          ),
                        if (request.consumer?.email != null)
                          _buildDetailRow(
                            Icons.email,
                            'Email',
                            request.consumer!.email,
                          ),
                        if (request.consumer?.phone != null)
                          _buildDetailRow(
                            Icons.phone,
                            'Phone',
                            request.consumer!.phone!,
                          ),
                        if (request.consumer?.address != null)
                          _buildDetailRow(
                            Icons.location_on,
                            'Address',
                            request.consumer!.address!,
                          ),
                        const SizedBox(height: 8),
                        const Divider(),
                        const SizedBox(height: 8),
                        // Request info
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 16, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(
                              'Requested: ${_formatDate(request.createdAt)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.info_outline, size: 16, color: Colors.orange),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'This consumer wants to access your catalog and place orders.',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                  fontStyle: FontStyle.italic,
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
        },
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

