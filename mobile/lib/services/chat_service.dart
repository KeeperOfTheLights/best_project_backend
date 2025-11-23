import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../models/chat_message.dart';
import '../utils/constants.dart';
import 'storage_service.dart';

// ChatService - handles chat operations
class ChatService {
  // Helper method to get headers with authentication token
  static Map<String, String> _getHeaders({bool includeContentType = true}) {
    final token = StorageService.getToken();
    Map<String, String> headers = {};
    if (includeContentType) {
      headers['Content-Type'] = 'application/json';
    }
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
  // Supports text messages, file attachments, order receipts, and product links
  static Future<ChatMessage> sendMessage({
    required String supplierId,
    String? text,
    String? consumerId,  // Required if sender is supplier staff
    String? orderId,
    String? productId,
    File? attachment,  // File to upload
    String? messageType,  // 'text', 'receipt', 'product_link', 'attachment'
  }) async {
    try {
      final token = StorageService.getToken();
      final uri = Uri.parse('$baseUrl${ApiEndpoints.sendMessage}/$supplierId/send/');

      // If there's an attachment, use multipart/form-data
      if (attachment != null) {
        final request = http.MultipartRequest('POST', uri);
        
        // Add headers
        if (token != null) {
          request.headers['Authorization'] = 'Bearer $token';
        }

        // Add text if provided
        if (text != null && text.isNotEmpty) {
          request.fields['text'] = text;
        }

        // Add message type
        if (messageType != null) {
          request.fields['message_type'] = messageType;
        }

        // Add consumer_id if provided (for supplier staff)
        if (consumerId != null) {
          request.fields['consumer_id'] = consumerId;
        }

        // Add order_id if provided
        if (orderId != null) {
          request.fields['order_id'] = orderId;
        }

        // Add product_id if provided
        if (productId != null) {
          request.fields['product_id'] = productId;
        }

        // Add attachment file
        final fileStream = http.ByteStream(attachment.openRead());
        final fileLength = await attachment.length();
        final fileName = attachment.path.split('/').last;
        final multipartFile = http.MultipartFile(
          'attachment',
          fileStream,
          fileLength,
          filename: fileName,
        );
        request.files.add(multipartFile);

        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 200 || response.statusCode == 201) {
          final data = jsonDecode(response.body);
          return ChatMessage.fromJson(data);
        } else {
          final error = jsonDecode(response.body);
          throw Exception(error['detail'] ?? error['message'] ?? 'Failed to send message');
        }
      } else {
        // Regular JSON request for text messages, order receipts, or product links
        final body = <String, dynamic>{};
        
        if (text != null && text.isNotEmpty) {
          body['text'] = text;
        }
        
        if (consumerId != null) {
          body['consumer_id'] = consumerId;
        }
        
        if (orderId != null) {
          body['order_id'] = orderId;
        }
        
        if (productId != null) {
          body['product_id'] = productId;
        }
        
        if (messageType != null) {
          body['message_type'] = messageType;
        }

        final response = await http.post(
          uri,
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




