import 'user.dart';

// ChatMessage model - represents a message in a chat
class ChatMessage {
  final String id;
  final String chatRoomId;
  final String senderId;
  final String? senderName; // From backend serializer
  final String text; // Backend uses 'text' instead of 'message'
  final DateTime createdAt; // Backend uses 'timestamp'
  final String messageType; // 'text', 'receipt', 'product_link', 'attachment'
  final String? orderId; // Optional: link to order if message is about an order
  final String? productId; // Optional: link to product if message is product link
  final String? productName; // Optional: product name
  final String? attachmentUrl; // Optional: attachment URL
  final String? attachmentName; // Optional: attachment file name
  
  // Optional: full sender object if loaded
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

  // Get message display text (for compatibility)
  String get message => text;

  // Convert JSON from backend to ChatMessage object
  // Backend MessageSerializer returns: id, room, sender, sender_name, text, timestamp, message_type, attachment, attachment_name, attachment_url, order, order_id, product, product_id, product_name
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

  // Convert ChatMessage object to JSON for sending to backend
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




