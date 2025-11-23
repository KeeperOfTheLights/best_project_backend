import 'package:flutter/foundation.dart';
import '../models/complaint.dart';
import '../services/complaint_service.dart';
import '../services/mock_complaint_service.dart';
import '../services/storage_service.dart';
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
      final userRole = StorageService.getUserRole() ?? '';
      final complaintsList = useMockApi
          ? await MockComplaintService.getComplaints()
          : await ComplaintService.getComplaints(userRole: userRole);

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
    required String description,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newComplaint = useMockApi
          ? await MockComplaintService.createComplaint(
              orderId: orderId,
              title: title,
              accountName: '',
              orderItemId: null,
              issueType: 'other',
              description: description,
              photoUrls: null,
            )
          : await ComplaintService.createComplaint(
              orderId: orderId,
              title: title,
              description: description,
            );

      // Reload complaints to get the latest data from backend
      await loadComplaints();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Resolve complaint (Supplier)
  Future<bool> resolveComplaint(String complaintId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedComplaint = useMockApi
          ? await MockComplaintService.updateComplaintStatus(
              complaintId: complaintId,
              status: 'resolved',
            )
          : await ComplaintService.resolveComplaint(complaintId);

      // Reload complaints to get updated data from backend
      await loadComplaints();

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

  // Reject complaint (Supplier)
  Future<bool> rejectComplaint(String complaintId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedComplaint = useMockApi
          ? await MockComplaintService.updateComplaintStatus(
              complaintId: complaintId,
              status: 'rejected',
            )
          : await ComplaintService.rejectComplaint(complaintId);

      // Reload complaints to get updated data from backend
      await loadComplaints();

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

  // Escalate complaint (Supplier Sales -> Manager)
  // Note: User requested NOT to add Escalate button yet
  Future<bool> escalateComplaint(String complaintId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedComplaint = useMockApi
          ? await MockComplaintService.updateComplaintStatus(
              complaintId: complaintId,
              status: 'escalated',
            )
          : await ComplaintService.escalateComplaint(complaintId);

      // Reload complaints to get updated data from backend
      await loadComplaints();

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

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

