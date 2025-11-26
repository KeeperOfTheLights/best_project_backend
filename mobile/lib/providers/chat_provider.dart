import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/chat_room.dart';
import '../models/chat_message.dart';
import '../services/chat_service.dart';

class ChatProvider with ChangeNotifier {
  List<ChatRoom> _chatRooms = [];
  Map<String, List<ChatMessage>> _messages = {};
  bool _isLoading = false;
  String? _errorMessage;

  List<ChatRoom> get chatRooms => _chatRooms;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<ChatMessage> getMessages(String chatRoomId) {
    return _messages[chatRoomId] ?? [];
  }




  Future<void> loadChatRooms() async {
    _chatRooms = [];
    notifyListeners();
  }


  Future<void> loadMessages(String partnerId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final messages = await ChatService.getChatHistory(partnerId);

      _messages[partnerId] = messages;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<bool> sendMessage({
    required String supplierId,
    String? text,
    String? consumerId,
    String? orderId,
    String? productId,
    String? messageType,
    File? attachment,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newMessage = await ChatService.sendMessage(
        supplierId: supplierId,
        text: text,
        consumerId: consumerId,
        orderId: orderId,
        productId: productId,
        messageType: messageType,
        attachment: attachment,
      );

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


  Future<ChatRoom?> createOrGetChatRoom(String otherUserId, {String? orderId}) async {
    await loadMessages(otherUserId);
    return null;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}




