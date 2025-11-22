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
  Future<void> loadChatRooms() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final rooms = useMockApi
          ? await MockChatService.getChatRooms()
          : await ChatService.getChatRooms();

      _chatRooms = rooms;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load messages for a chat room
  Future<void> loadMessages(String chatRoomId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final messages = useMockApi
          ? await MockChatService.getChatMessages(chatRoomId)
          : await ChatService.getChatMessages(chatRoomId);

      _messages[chatRoomId] = messages;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Send a message
  Future<bool> sendMessage({
    required String chatRoomId,
    required String message,
    String? orderId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newMessage = useMockApi
          ? await MockChatService.sendMessage(
              chatRoomId: chatRoomId,
              message: message,
              orderId: orderId,
            )
          : await ChatService.sendMessage(
              chatRoomId: chatRoomId,
              message: message,
              orderId: orderId,
            );

      // Add to messages list
      if (!_messages.containsKey(chatRoomId)) {
        _messages[chatRoomId] = [];
      }
      _messages[chatRoomId]!.add(newMessage);

      // Reload chat rooms to update last message
      await loadChatRooms();

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

  // Create or get chat room
  Future<ChatRoom?> createOrGetChatRoom(String otherUserId, {String? orderId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final room = useMockApi
          ? await MockChatService.createOrGetChatRoom(otherUserId, orderId: orderId)
          : await ChatService.createOrGetChatRoom(otherUserId, orderId: orderId);

      // Check if room already in list
      final existingIndex = _chatRooms.indexWhere((r) => r.id == room.id);
      if (existingIndex == -1) {
        _chatRooms.add(room);
      } else {
        _chatRooms[existingIndex] = room;
      }

      // Load messages for this room
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




