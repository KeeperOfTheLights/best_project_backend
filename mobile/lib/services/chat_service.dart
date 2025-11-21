import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat_room.dart';
import '../models/chat_message.dart';
import '../utils/constants.dart';
import 'storage_service.dart';

// ChatService - handles chat operations
class ChatService {
  // Helper method to get headers with authentication token
  static Map<String, String> _getHeaders() {
    final token = StorageService.getToken();
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // Get all chat rooms for current user
  static Future<List<ChatRoom>> getChatRooms() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl${ApiEndpoints.getChatRooms}'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> roomsJson = data['chat_rooms'] ?? data;
        return roomsJson.map((json) => ChatRoom.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get chat rooms');
      }
    } catch (e) {
      throw Exception('Connection error: ${e.toString()}');
    }
  }

  // Get messages for a specific chat room
  static Future<List<ChatMessage>> getChatMessages(String chatRoomId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl${ApiEndpoints.getChatMessages}?chat_room_id=$chatRoomId'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> messagesJson = data['messages'] ?? data;
        return messagesJson.map((json) => ChatMessage.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get messages');
      }
    } catch (e) {
      throw Exception('Connection error: ${e.toString()}');
    }
  }

  // Send a message
  static Future<ChatMessage> sendMessage({
    required String chatRoomId,
    required String message,
    String? orderId,
  }) async {
    try {
      final body = {
        'chat_room_id': chatRoomId,
        'message': message,
        if (orderId != null) 'order_id': orderId,
      };

      final response = await http.post(
        Uri.parse('$baseUrl${ApiEndpoints.sendMessage}'),
        headers: _getHeaders(),
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return ChatMessage.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to send message');
      }
    } catch (e) {
      throw Exception('Connection error: ${e.toString()}');
    }
  }

  // Create or get chat room with a supplier/consumer
  static Future<ChatRoom> createOrGetChatRoom(String otherUserId, {String? orderId}) async {
    try {
      final body = {
        'other_user_id': otherUserId,
        if (orderId != null) 'order_id': orderId,
      };

      final response = await http.post(
        Uri.parse('$baseUrl${ApiEndpoints.createChatRoom}'),
        headers: _getHeaders(),
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return ChatRoom.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to create chat room');
      }
    } catch (e) {
      throw Exception('Connection error: ${e.toString()}');
    }
  }
}




