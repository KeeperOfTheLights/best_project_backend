import 'package:flutter/foundation.dart';
import '../models/supplier.dart';
import '../models/link_request.dart';
import '../services/link_request_service.dart';
import '../services/mock_link_request_service.dart';
import '../services/storage_service.dart';
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
    return _linkRequests.where((req) => req.status == LinkRequestStatus.linked || req.status == LinkRequestStatus.approved).toList();
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
      final userRole = StorageService.getUserRole() ?? '';
      final requests = useMockApi
          ? await MockLinkRequestService.getLinkRequests()
          : await LinkRequestService.getLinkRequests(userRole: userRole);

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
      if (useMockApi) {
        await MockLinkRequestService.approveLinkRequest(requestId);
      } else {
        await LinkRequestService.approveLinkRequest(requestId);
      }

      // Backend doesn't return updated object, so reload the list
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

  // Reject link request (Supplier only)
  Future<bool> rejectLinkRequest(String requestId, {String? reason}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (useMockApi) {
        await MockLinkRequestService.rejectLinkRequest(requestId, reason: reason);
      } else {
        await LinkRequestService.rejectLinkRequest(requestId, reason: reason);
      }

      // Backend doesn't return updated object, so reload the list
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

  // Unlink consumer (Supplier only)
  Future<bool> unlinkConsumer(String linkId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (useMockApi) {
        // Mock implementation would go here
        throw Exception('Unlink not implemented in mock API');
      } else {
        await LinkRequestService.unlinkConsumer(linkId);
      }

      // Backend doesn't return updated object, so reload the list
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

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

