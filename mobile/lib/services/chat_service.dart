import 'dart:convert';
import 'package:http/http.dart' as http;
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

  // Get chat history with a partner
  // Backend: GET /chat/{partner_id}/ - returns messages array directly
  // Note: Backend doesn't have a "chat rooms list" endpoint
  // App should get chat partners from link requests (linked suppliers/consumers)
  static Future<List<ChatMessage>> getChatHistory(String partnerId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl${ApiEndpoints.getChatHistory}/$partnerId/'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Backend returns array of messages directly
        final List<dynamic> messagesJson = data is List ? data : (data['messages'] ?? []);
        return messagesJson.map((json) => ChatMessage.fromJson(json)).toList();
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? error['message'] ?? 'Failed to get chat history');
      }
    } catch (e) {
      throw Exception('Connection error: ${e.toString()}');
    }
  }

  // Send a message to a supplier
  // Backend: POST /chat/{supplier_id}/send/
  // For consumer: supplier_id is the partner
  // For supplier staff: supplier_id is their company owner, consumer_id must be in body
  static Future<ChatMessage> sendMessage({
    required String supplierId,
    required String message,
    String? consumerId,  // Required if sender is supplier staff
    String? orderId,
    String? productId,
  }) async {
    try {
      final body = {
        'text': message,
        if (consumerId != null) 'consumer_id': consumerId,
        if (orderId != null) 'order_id': orderId,
        if (productId != null) 'product_id': productId,
      };

      final response = await http.post(
        Uri.parse('$baseUrl${ApiEndpoints.sendMessage}/$supplierId/send/'),
        headers: _getHeaders(),
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return ChatMessage.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? error['message'] ?? 'Failed to send message');
      }
    } catch (e) {
      throw Exception('Connection error: ${e.toString()}');
    }
  }

  // Note: Backend doesn't have endpoints for:
  // - Listing chat rooms (use link requests to get chat partners)
  // - Creating chat rooms (they're created automatically when messages are sent)
  // Chat rooms are created automatically by the backend when needed
}




