import 'user.dart';

class ChatMessage {
  final String id;
  final String chatRoomId;
  final String senderId;
  final String? senderName;
  final String text;
  final DateTime createdAt;
  final String messageType;
  final String? orderId;
  final String? productId;
  final String? productName;
  final String? attachmentUrl;
  final String? attachmentName;

  final User? sender;

  ChatMessage({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    this.senderName,
    required this.text,
    required this.createdAt,
    this.messageType = 'text',
    this.orderId,
    this.productId,
    this.productName,
    this.attachmentUrl,
    this.attachmentName,
    this.sender,
  });

  String get message => text;


  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id']?.toString() ?? '',
      chatRoomId: json['room']?.toString() ?? json['chat_room_id']?.toString() ?? '',
      senderId: json['sender']?.toString() ?? json['sender_id']?.toString() ?? '',
      senderName: json['sender_name'],
      text: json['text'] ?? json['message'] ?? '',
      createdAt: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : (json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : DateTime.now()),
      messageType: json['message_type'] ?? 'text',
      orderId: json['order_id']?.toString() ?? (json['order']?.toString()),
      productId: json['product_id']?.toString() ?? (json['product']?.toString()),
      productName: json['product_name'],
      attachmentUrl: json['attachment_url'],
      attachmentName: json['attachment_name'],
      sender: json['sender'] != null && json['sender'] is Map
          ? User.fromJson(json['sender'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'room': chatRoomId,
      'sender': senderId,
      'text': text,
      'timestamp': createdAt.toIso8601String(),
      'message_type': messageType,
      if (orderId != null) 'order_id': orderId,
      if (productId != null) 'product_id': productId,
      if (attachmentUrl != null) 'attachment_url': attachmentUrl,
    };
  }
}




