import '../models/complaint.dart';
import '../services/storage_service.dart';
import '../services/mock_order_service.dart';
import '../utils/constants.dart';

// MockComplaintService - simulates complaint operations for testing
class MockComplaintService {
  // Simulate network delay
  static Future<void> _delay() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  // Mock complaints storage
  static final List<Complaint> _complaints = [];
  static int _nextComplaintId = 1;

  // Create a new complaint (Consumer)
  static Future<Complaint> createComplaint({
    required String orderId,
    required String title,
    required String accountName,
    String? orderItemId,
    required String issueType,
    required String description,
    List<String>? photoUrls,
  }) async {
    await _delay();

    final currentUserId = StorageService.getUserId() ?? '';
    
    // Get order to find supplierId
    try {
      final order = await MockOrderService.getOrderDetails(orderId);
      final supplierId = order.supplierId;

      final newComplaint = Complaint(
        id: 'complaint_${_nextComplaintId++}',
        orderId: orderId,
        orderItemId: orderItemId,
        consumerId: currentUserId,
        supplierId: supplierId,
        title: title,
        accountName: accountName,
        issueType: issueType,
        description: description,
        photoUrls: photoUrls,
        status: ComplaintStatus.pending,
        createdAt: DateTime.now(),
        order: order,
      );

      _complaints.add(newComplaint);
      return newComplaint;
    } catch (e) {
      throw Exception('Order not found: $e');
    }
  }

  // Get all complaints for current user
  static Future<List<Complaint>> getComplaints() async {
    await _delay();
    final currentUserId = StorageService.getUserId() ?? '';
    final currentRole = StorageService.getUserRole() ?? '';

    if (currentRole == UserRole.consumer) {
      // Consumer sees their own complaints
      return _complaints
          .where((c) => c.consumerId == currentUserId)
          .toList();
    } else {
      // Supplier (Owner/Manager/Sales) sees complaints for their company
      // All suppliers can see and respond to complaints
      // In a real app, this would be filtered by company/supplier relationship
      // For mock, we'll return all complaints (in production, filter by company)
      return List.from(_complaints);
    }
  }

  // Get complaint details
  static Future<Complaint> getComplaintDetails(String complaintId) async {
    await _delay();

    final complaint = _complaints.firstWhere(
      (c) => c.id == complaintId,
      orElse: () => throw Exception('Complaint not found'),
    );

    return complaint;
  }

  // Update complaint status (Supplier: mark in progress, resolve, escalate)
  static Future<Complaint> updateComplaintStatus({
    required String complaintId,
    required String status,
    String? resolutionNote,
  }) async {
    await _delay();

    final index = _complaints.indexWhere((c) => c.id == complaintId);
    if (index == -1) {
      throw Exception('Complaint not found');
    }

    final currentUserId = StorageService.getUserId() ?? '';
    final currentRole = StorageService.getUserRole() ?? '';

    final existingComplaint = _complaints[index];
    
    // Determine escalatedBy if status is escalated
    String? escalatedBy;
    if (status == ComplaintStatus.escalated && 
        existingComplaint.status != ComplaintStatus.escalated) {
      // If Sales is escalating, set escalatedBy to their ID
      if (currentRole == UserRole.sales) {
        escalatedBy = currentUserId;
      }
    }

    final updatedComplaint = existingComplaint.copyWith(
      status: status,
      resolutionNote: resolutionNote,
      updatedAt: DateTime.now(),
      escalatedBy: escalatedBy ?? existingComplaint.escalatedBy,
    );

    _complaints[index] = updatedComplaint;
    return updatedComplaint;
  }
}

