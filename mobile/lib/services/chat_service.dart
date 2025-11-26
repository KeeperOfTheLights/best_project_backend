import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../models/chat_message.dart';
import '../utils/constants.dart';
import 'storage_service.dart';

class ChatService {

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




  static Future<List<ChatMessage>> getChatHistory(String partnerId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl${ApiEndpoints.getChatHistory}/$partnerId/'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

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





  static Future<ChatMessage> sendMessage({
    required String supplierId,
    String? text,
    String? consumerId,
    String? orderId,
    String? productId,
    File? attachment,
    String? messageType,
  }) async {
    try {
      final token = StorageService.getToken();
      final uri = Uri.parse('$baseUrl${ApiEndpoints.sendMessage}/$supplierId/send/');

      if (attachment != null) {
        final request = http.MultipartRequest('POST', uri);

        if (token != null) {
          request.headers['Authorization'] = 'Bearer $token';
        }

        if (text != null && text.isNotEmpty) {
          request.fields['text'] = text;
        }

        if (messageType != null) {
          request.fields['message_type'] = messageType;
        }

        if (consumerId != null) {
          request.fields['consumer_id'] = consumerId;
        }

        if (orderId != null) {
          request.fields['order_id'] = orderId;
        }

        if (productId != null) {
          request.fields['product_id'] = productId;
        }

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




}




