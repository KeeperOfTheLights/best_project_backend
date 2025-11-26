import 'package:flutter/foundation.dart';
import '../models/complaint.dart';
import '../services/complaint_service.dart';
import '../services/storage_service.dart';

class ComplaintProvider with ChangeNotifier {
  List<Complaint> _complaints = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Complaint> get complaints => _complaints;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<Complaint> getComplaintsByStatus(String status) {
    return _complaints.where((c) => c.status == status).toList();
  }

  List<Complaint> get pendingComplaints {
    return getComplaintsByStatus(ComplaintStatus.pending);
  }

  List<Complaint> get inProgressComplaints {
    return getComplaintsByStatus(ComplaintStatus.inProgress);
  }

  List<Complaint> get resolvedComplaints {
    return getComplaintsByStatus(ComplaintStatus.resolved);
  }

  List<Complaint> get escalatedComplaints {
    return getComplaintsByStatus(ComplaintStatus.escalated);
  }

  Future<void> loadComplaints() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userRole = StorageService.getUserRole() ?? '';
      final complaintsList = await ComplaintService.getComplaints(userRole: userRole);

      _complaints = complaintsList;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createComplaint({
    required String orderId,
    required String title,
    required String description,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newComplaint = await ComplaintService.createComplaint(
        orderId: orderId,
        title: title,
        description: description,
      );

      await loadComplaints();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> resolveComplaint(String complaintId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedComplaint = await ComplaintService.resolveComplaint(complaintId);

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

  Future<bool> rejectComplaint(String complaintId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedComplaint = await ComplaintService.rejectComplaint(complaintId);

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


  Future<bool> escalateComplaint(String complaintId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedComplaint = await ComplaintService.escalateComplaint(complaintId);

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

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

