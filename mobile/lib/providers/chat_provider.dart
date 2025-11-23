import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/chat_room.dart';
import '../models/chat_message.dart';
import '../services/chat_service.dart';
import '../services/mock_chat_service.dart';
import '../utils/constants.dart';

// ChatProvider - manages chat state
class ChatProvider with ChangeNotifier {
  List<ChatRoom> _chatRooms = [];
  Map<String, List<ChatMessage>> _messages = {}; // chatRoomId -> messages
  bool _isLoading = false;
  String? _errorMessage;

  List<ChatRoom> get chatRooms => _chatRooms;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Get messages for a chat room
  List<ChatMessage> getMessages(String chatRoomId) {
    return _messages[chatRoomId] ?? [];
  }

  // Load all chat rooms
  // Note: Backend doesn't have a chat rooms list endpoint
  // This should be called with link requests to get chat partners
  // For now, we keep it for mock API compatibility
  Future<void> loadChatRooms() async {
    if (!useMockApi) {
      // Real backend doesn't have this endpoint
      // Chat partners should come from link requests
      _chatRooms = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final rooms = await MockChatService.getChatRooms();
      _chatRooms = rooms;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load messages for a chat with a partner
  // Backend: GET /chat/{partner_id}/
  Future<void> loadMessages(String partnerId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final messages = useMockApi
          ? await MockChatService.getChatMessages(partnerId)
          : await ChatService.getChatHistory(partnerId);

      _messages[partnerId] = messages;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Send a message to a supplier
  // Backend: POST /chat/{supplier_id}/send/
  Future<bool> sendMessage({
    required String supplierId,
    String? text,
    String? consumerId,  // Required if sender is supplier staff
    String? orderId,
    String? productId,
    String? messageType,
    File? attachment,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newMessage = useMockApi
          ? await MockChatService.sendMessage(
              chatRoomId: supplierId,
              text: text,
              orderId: orderId,
              productId: productId,
              messageType: messageType,
            )
          : await ChatService.sendMessage(
              supplierId: supplierId,
              text: text,
              consumerId: consumerId,
              orderId: orderId,
              productId: productId,
              messageType: messageType,
              attachment: attachment,
            );

      // Add to messages list using supplierId as key (or partnerId)
      final partnerId = consumerId ?? supplierId;
      if (!_messages.containsKey(partnerId)) {
        _messages[partnerId] = [];
      }
      _messages[partnerId]!.add(newMessage);

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

  // Create or get chat room - not needed with backend, chat rooms created automatically
  // Kept for mock API compatibility
  Future<ChatRoom?> createOrGetChatRoom(String otherUserId, {String? orderId}) async {
    if (!useMockApi) {
      // Backend creates chat rooms automatically when messages are sent
      // Just load messages directly
      await loadMessages(otherUserId);
      return null;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final room = await MockChatService.createOrGetChatRoom(otherUserId, orderId: orderId);
      final existingIndex = _chatRooms.indexWhere((r) => r.id == room.id);
      if (existingIndex == -1) {
        _chatRooms.add(room);
      } else {
        _chatRooms[existingIndex] = room;
      }
      await loadMessages(room.id);
      _isLoading = false;
      notifyListeners();
      return room;
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




