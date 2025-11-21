import 'package:flutter/foundation.dart';
import '../models/supplier.dart';
import '../models/link_request.dart';
import '../services/link_request_service.dart';
import '../services/mock_link_request_service.dart';
import '../utils/constants.dart';

// LinkRequestProvider - manages link request state
class LinkRequestProvider with ChangeNotifier {
  List<Supplier> _suppliers = [];
  List<LinkRequest> _linkRequests = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Supplier> get suppliers => _suppliers;
  List<LinkRequest> get linkRequests => _linkRequests;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Get link requests by status
  List<LinkRequest> getPendingRequests() {
    return _linkRequests.where((req) => req.status == LinkRequestStatus.pending).toList();
  }

  List<LinkRequest> getApprovedRequests() {
    return _linkRequests.where((req) => req.status == LinkRequestStatus.approved).toList();
  }

  List<LinkRequest> getRejectedRequests() {
    return _linkRequests.where((req) => req.status == LinkRequestStatus.rejected).toList();
  }

  // Search suppliers
  Future<void> searchSuppliers(String query) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = useMockApi
          ? await MockLinkRequestService.searchSuppliers(query)
          : await LinkRequestService.searchSuppliers(query);

      _suppliers = results;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Send link request
  Future<bool> sendLinkRequest(String supplierId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await (useMockApi
          ? MockLinkRequestService.sendLinkRequest(supplierId)
          : LinkRequestService.sendLinkRequest(supplierId));

      // Add to list and refresh
      await loadLinkRequests();
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

  // Load all link requests
  Future<void> loadLinkRequests() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final requests = useMockApi
          ? await MockLinkRequestService.getLinkRequests()
          : await LinkRequestService.getLinkRequests();

      _linkRequests = requests;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Approve link request (Supplier only)
  Future<bool> approveLinkRequest(String requestId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final request = useMockApi
          ? await MockLinkRequestService.approveLinkRequest(requestId)
          : await LinkRequestService.approveLinkRequest(requestId);

      // Update in list
      final index = _linkRequests.indexWhere((req) => req.id == requestId);
      if (index != -1) {
        _linkRequests[index] = request;
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

  // Reject link request (Supplier only)
  Future<bool> rejectLinkRequest(String requestId, {String? reason}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final request = useMockApi
          ? await MockLinkRequestService.rejectLinkRequest(requestId, reason: reason)
          : await LinkRequestService.rejectLinkRequest(requestId, reason: reason);

      // Update in list
      final index = _linkRequests.indexWhere((req) => req.id == requestId);
      if (index != -1) {
        _linkRequests[index] = request;
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

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

