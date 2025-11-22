import 'user.dart';
import 'supplier.dart';
import 'chat_message.dart';

// ChatRoom model - represents a chat conversation
class ChatRoom {
  final String id;
  final String consumerId;
  final String supplierId;
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  // Optional: full objects if loaded
  final User? consumer;
  final Supplier? supplier;
  final ChatMessage? lastMessage;
  final int unreadCount;

  ChatRoom({
    required this.id,
    required this.consumerId,
    required this.supplierId,
    required this.createdAt,
    this.updatedAt,
    this.consumer,
    this.supplier,
    this.lastMessage,
    this.unreadCount = 0,
  });

  // Convert JSON from backend to ChatRoom object
  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['id']?.toString() ?? '',
      consumerId: json['consumer_id']?.toString() ?? json['consumerId'] ?? '',
      supplierId: json['supplier_id']?.toString() ?? json['supplierId'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      consumer: json['consumer'] != null
          ? User.fromJson(json['consumer'])
          : null,
      supplier: json['supplier'] != null
          ? Supplier.fromJson(json['supplier'])
          : null,
      lastMessage: json['last_message'] != null || json['lastMessage'] != null
          ? ChatMessage.fromJson(json['last_message'] ?? json['lastMessage'])
          : null,
      unreadCount: json['unread_count'] ?? json['unreadCount'] ?? 0,
    );
  }

  // Convert ChatRoom object to JSON for sending to backend
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'consumer_id': consumerId,
      'supplier_id': supplierId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}




