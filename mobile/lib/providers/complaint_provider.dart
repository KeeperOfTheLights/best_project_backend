import 'package:flutter/foundation.dart';
import '../models/complaint.dart';
import '../services/complaint_service.dart';
import '../services/mock_complaint_service.dart';
import '../utils/constants.dart';

// ComplaintProvider - manages complaint state
class ComplaintProvider with ChangeNotifier {
  List<Complaint> _complaints = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Complaint> get complaints => _complaints;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Get complaints by status
  List<Complaint> getComplaintsByStatus(String status) {
    return _complaints.where((c) => c.status == status).toList();
  }

  // Get pending complaints
  List<Complaint> get pendingComplaints {
    return getComplaintsByStatus(ComplaintStatus.pending);
  }

  // Get in progress complaints
  List<Complaint> get inProgressComplaints {
    return getComplaintsByStatus(ComplaintStatus.inProgress);
  }

  // Get resolved complaints
  List<Complaint> get resolvedComplaints {
    return getComplaintsByStatus(ComplaintStatus.resolved);
  }

  // Get escalated complaints
  List<Complaint> get escalatedComplaints {
    return getComplaintsByStatus(ComplaintStatus.escalated);
  }

  // Load all complaints
  Future<void> loadComplaints() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final complaintsList = useMockApi
          ? await MockComplaintService.getComplaints()
          : await ComplaintService.getComplaints();

      _complaints = complaintsList;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create new complaint (Consumer)
  Future<bool> createComplaint({
    required String orderId,
    required String title,
    required String accountName,
    String? orderItemId,
    required String issueType,
    required String description,
    List<String>? photoUrls,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newComplaint = useMockApi
          ? await MockComplaintService.createComplaint(
              orderId: orderId,
              title: title,
              accountName: accountName,
              orderItemId: orderItemId,
              issueType: issueType,
              description: description,
              photoUrls: photoUrls,
            )
          : await ComplaintService.createComplaint(
              orderId: orderId,
              title: title,
              accountName: accountName,
              orderItemId: orderItemId,
              issueType: issueType,
              description: description,
              photoUrls: photoUrls,
            );

      _complaints.add(newComplaint);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update complaint status (Supplier)
  Future<bool> updateComplaintStatus({
    required String complaintId,
    required String status,
    String? resolutionNote,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedComplaint = useMockApi
          ? await MockComplaintService.updateComplaintStatus(
              complaintId: complaintId,
              status: status,
              resolutionNote: resolutionNote,
            )
          : await ComplaintService.updateComplaintStatus(
              complaintId: complaintId,
              status: status,
              resolutionNote: resolutionNote,
            );

      final index = _complaints.indexWhere((c) => c.id == complaintId);
      if (index != -1) {
        _complaints[index] = updatedComplaint;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Get complaint details
  Future<Complaint?> getComplaintDetails(String complaintId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final complaint = useMockApi
          ? await MockComplaintService.getComplaintDetails(complaintId)
          : await ComplaintService.getComplaintDetails(complaintId);

      // Update in list if exists
      final index = _complaints.indexWhere((c) => c.id == complaintId);
      if (index != -1) {
        _complaints[index] = complaint;
      } else {
        _complaints.add(complaint);
      }

      _isLoading = false;
      notifyListeners();
      return complaint;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

