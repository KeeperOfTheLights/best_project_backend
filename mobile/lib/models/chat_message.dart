import 'user.dart';

// ChatMessage model - represents a message in a chat
class ChatMessage {
  final String id;
  final String chatRoomId;
  final String senderId;
  final String message;
  final DateTime createdAt;
  final String? orderId; // Optional: link to order if message is about an order
  final String? fileUrl; // Optional: for future file/image support
  
  // Optional: full sender object if loaded
  final User? sender;

  ChatMessage({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.message,
    required this.createdAt,
    this.orderId,
    this.fileUrl,
    this.sender,
  });

  // Convert JSON from backend to ChatMessage object
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id']?.toString() ?? '',
      chatRoomId: json['chat_room_id']?.toString() ?? json['chatRoomId'] ?? '',
      senderId: json['sender_id']?.toString() ?? json['senderId'] ?? '',
      message: json['message'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      orderId: json['order_id'] ?? json['orderId'],
      fileUrl: json['file_url'] ?? json['fileUrl'],
      sender: json['sender'] != null
          ? User.fromJson(json['sender'])
          : null,
    );
  }

  // Convert ChatMessage object to JSON for sending to backend
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chat_room_id': chatRoomId,
      'sender_id': senderId,
      'message': message,
      'created_at': createdAt.toIso8601String(),
      'order_id': orderId,
      'file_url': fileUrl,
    };
  }
}




