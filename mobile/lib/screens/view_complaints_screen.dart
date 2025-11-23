import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/complaint_provider.dart';
import '../providers/order_provider.dart';
import '../models/complaint.dart';
import '../models/order.dart';
import 'chat_room_screen.dart';

// ViewComplaintsScreen - allows consumers to view and create complaints
class ViewComplaintsScreen extends StatefulWidget {
  const ViewComplaintsScreen({super.key});

  @override
  State<ViewComplaintsScreen> createState() => _ViewComplaintsScreenState();
}

class _ViewComplaintsScreenState extends State<ViewComplaintsScreen> {
  String _filterStatus = 'all'; // 'all', 'pending', 'resolved', 'rejected', 'escalated'
  bool _showForm = false;
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedOrderId;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ComplaintProvider>(context, listen: false).loadComplaints();
      Provider.of<OrderProvider>(context, listen: false).loadOrders();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5E6E6),
        title: const Text(
          'My Complaints',
          style: TextStyle(
            color: Color(0xFF20232A),
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),
      body: Consumer2<ComplaintProvider, OrderProvider>(
        builder: (context, complaintProvider, orderProvider, child) {
          final complaints = complaintProvider.complaints;
          final counts = _getCounts(complaints);
          final filteredComplaints = _getFilteredComplaints(complaints);

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with New Complaint button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'My Complaints',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF20232A),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _showForm = !_showForm;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _showForm ? Colors.grey : const Color(0xFF61DAFB),
                          foregroundColor: Colors.white,
                        ),
                        child: Text(_showForm ? 'Cancel' : 'New Complaint'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Create Complaint Form
                  if (_showForm)
                    Card(
                      color: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: _buildComplaintForm(orderProvider, complaintProvider),
                      ),
                    ),

                  if (_showForm) const SizedBox(height: 16),

                  // Filter Tabs
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterTab('all', counts['all'] ?? 0, _filterStatus == 'all'),
                        const SizedBox(width: 8),
                        _buildFilterTab('pending', counts['pending'] ?? 0, _filterStatus == 'pending'),
                        const SizedBox(width: 8),
                        _buildFilterTab('resolved', counts['resolved'] ?? 0, _filterStatus == 'resolved'),
                        const SizedBox(width: 8),
                        _buildFilterTab('rejected', counts['rejected'] ?? 0, _filterStatus == 'rejected'),
                        const SizedBox(width: 8),
                        _buildFilterTab('escalated', counts['escalated'] ?? 0, _filterStatus == 'escalated'),
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
                            child: const Text('Retry'),
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
                            const Text(
                              'No complaints found for this status.',
                              style: TextStyle(color: Colors.grey, fontSize: 16),
                            ),
                            if (complaints.isEmpty) ...[
                              const SizedBox(height: 8),
                              const Text(
                                'Create a complaint by clicking "New Complaint" above.',
                                style: TextStyle(color: Colors.grey, fontSize: 14),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ],
                        ),
                      ),
                    )
                  else
                    ...filteredComplaints.map((complaint) => _buildComplaintCard(complaint)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterTab(String status, int count, bool isActive) {
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
          '${status[0].toUpperCase()}${status.substring(1)}${count > 0 ? ' ($count)' : ''}',
          style: TextStyle(
            color: isActive ? Colors.white : const Color(0xFF20232A),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildComplaintForm(OrderProvider orderProvider, ComplaintProvider complaintProvider) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Submit a New Complaint',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF20232A),
            ),
          ),
          const SizedBox(height: 16),
          // Order Selector
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Select Order',
              border: OutlineInputBorder(),
            ),
            value: _selectedOrderId,
            items: [
              const DropdownMenuItem(
                value: null,
                child: Text('-- Select an order --'),
              ),
              ...orderProvider.orders.map((order) {
                return DropdownMenuItem(
                  value: order.id,
                  child: Text('Order #${order.id} - ${order.supplierName ?? "Unknown"} - ${_formatDate(order.createdAt)}'),
                );
              }),
            ],
            onChanged: (value) {
              setState(() {
                _selectedOrderId = value;
              });
            },
            validator: (value) {
              if (value == null) {
                return 'Please select an order';
              }
              return null;
            },
          ),
          // Order Details Preview
          if (_selectedOrderId != null) ...[
            const SizedBox(height: 12),
            Builder(
              builder: (context) {
                final order = orderProvider.orders.firstWhere(
                  (o) => o.id == _selectedOrderId,
                  orElse: () => Order(
                    id: _selectedOrderId!,
                    consumerId: '',
                    supplierId: '',
                    status: '',
                    deliveryType: '',
                    totalAmount: 0,
                    createdAt: DateTime.now(),
                  ),
                );
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Supplier: ${order.supplierName ?? "Unknown"}'),
                      Text('Total: ${order.totalAmount.toStringAsFixed(2)} ₸'),
                    ],
                  ),
                );
              },
            ),
          ],
          const SizedBox(height: 16),
          // Complaint Title
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Complaint Title',
              hintText: 'e.g., Late delivery, Wrong product, etc.',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a complaint title';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          // Description
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description',
              hintText: 'Describe your complaint in detail...',
              border: OutlineInputBorder(),
            ),
            maxLines: 5,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a description';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _showForm = false;
                    _titleController.clear();
                    _descriptionController.clear();
                    _selectedOrderId = null;
                  });
                },
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: complaintProvider.isLoading
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate() && _selectedOrderId != null) {
                          final success = await complaintProvider.createComplaint(
                            orderId: _selectedOrderId!,
                            title: _titleController.text.trim(),
                            description: _descriptionController.text.trim(),
                          );

                          if (mounted) {
                            if (success) {
                              setState(() {
                                _showForm = false;
                                _titleController.clear();
                                _descriptionController.clear();
                                _selectedOrderId = null;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Complaint submitted successfully'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(complaintProvider.errorMessage ?? 'Failed to submit complaint'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        }
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
                    : const Text('Submit Complaint'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComplaintCard(Complaint complaint) {
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
              'Supplier: ${complaint.supplierName ?? "Unknown"}',
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
            // Open Chat Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to chat with supplier
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatRoomScreen(
                        chatRoomId: complaint.supplierId,
                        otherPartyName: complaint.supplierName ?? 'Supplier',
                        otherPartyType: 'Supplier',
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
          ],
        ),
      ),
    );
  }
}
