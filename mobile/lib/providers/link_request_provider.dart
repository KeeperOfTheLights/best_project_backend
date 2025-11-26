import 'package:flutter/foundation.dart';
import '../models/supplier.dart';
import '../models/link_request.dart';
import '../services/link_request_service.dart';
import '../services/storage_service.dart';

class LinkRequestProvider with ChangeNotifier {
  List<Supplier> _suppliers = [];
  List<LinkRequest> _linkRequests = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Supplier> get suppliers => _suppliers;
  List<LinkRequest> get linkRequests => _linkRequests;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<LinkRequest> getPendingRequests() {
    return _linkRequests.where((req) => req.status == LinkRequestStatus.pending).toList();
  }

  List<LinkRequest> getApprovedRequests() {
    return _linkRequests.where((req) => req.status == LinkRequestStatus.linked || req.status == LinkRequestStatus.approved).toList();
  }

  List<LinkRequest> getRejectedRequests() {
    return _linkRequests.where((req) => req.status == LinkRequestStatus.rejected).toList();
  }

  Future<void> searchSuppliers(String query) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await LinkRequestService.searchSuppliers(query);

      _suppliers = results;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> sendLinkRequest(String supplierId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await LinkRequestService.sendLinkRequest(supplierId);

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

  Future<void> loadLinkRequests() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userRole = StorageService.getUserRole() ?? '';
      final requests = await LinkRequestService.getLinkRequests(userRole: userRole);

      _linkRequests = requests;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> approveLinkRequest(String requestId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await LinkRequestService.approveLinkRequest(requestId);

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

  Future<bool> rejectLinkRequest(String requestId, {String? reason}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await LinkRequestService.rejectLinkRequest(requestId, reason: reason);

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

  Future<bool> unlinkConsumer(String linkId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await LinkRequestService.unlinkConsumer(linkId);

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

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

