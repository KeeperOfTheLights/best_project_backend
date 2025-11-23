import '../models/chat_room.dart';
import '../models/chat_message.dart';
import '../services/storage_service.dart';

// MockChatService - simulates chat operations for testing
class MockChatService {
  // Simulate network delay
  static Future<void> _delay() async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  // Mock chat rooms storage
  static final List<ChatRoom> _chatRooms = [];
  // Mock messages storage (chatRoomId -> messages)
  static final Map<String, List<ChatMessage>> _messages = {};
  static int _nextRoomId = 1;
  static int _nextMessageId = 1;

  // Get all chat rooms for current user
  static Future<List<ChatRoom>> getChatRooms() async {
    await _delay();
    return List.from(_chatRooms);
  }

  // Get messages for a specific chat room
  static Future<List<ChatMessage>> getChatMessages(String chatRoomId) async {
    await _delay();
    return List.from(_messages[chatRoomId] ?? []);
  }

  // Send a message
  static Future<ChatMessage> sendMessage({
    required String chatRoomId,
    String? text,
    String? orderId,
    String? productId,
    String? messageType,
  }) async {
    await _delay();

    final currentUserId = StorageService.getUserId() ?? '';
    
    final newMessage = ChatMessage(
      id: '${_nextMessageId++}',
      chatRoomId: chatRoomId,
      senderId: currentUserId,
      text: text ?? '',
      createdAt: DateTime.now(),
      messageType: messageType ?? 'text',
      orderId: orderId,
      productId: productId,
    );

    // Add to messages list
    if (!_messages.containsKey(chatRoomId)) {
      _messages[chatRoomId] = [];
    }
    _messages[chatRoomId]!.add(newMessage);

    // Update chat room's last message
    final roomIndex = _chatRooms.indexWhere((r) => r.id == chatRoomId);
    if (roomIndex != -1) {
      final room = _chatRooms[roomIndex];
      _chatRooms[roomIndex] = ChatRoom(
        id: room.id,
        consumerId: room.consumerId,
        supplierId: room.supplierId,
        createdAt: room.createdAt,
        updatedAt: DateTime.now(),
        consumer: room.consumer,
        supplier: room.supplier,
        lastMessage: newMessage,
        unreadCount: room.unreadCount,
      );
    }

    return newMessage;
  }

  // Create or get chat room
  static Future<ChatRoom> createOrGetChatRoom(String otherUserId, {String? orderId}) async {
    await _delay();

    final currentUserId = StorageService.getUserId() ?? '';
    final currentUserRole = StorageService.getUserRole() ?? '';

    // Check if room already exists
    ChatRoom? existingRoom;
    if (currentUserRole == 'consumer') {
      existingRoom = _chatRooms.firstWhere(
        (r) => r.consumerId == currentUserId && r.supplierId == otherUserId,
        orElse: () => ChatRoom(
          id: '',
          consumerId: '',
          supplierId: '',
          createdAt: DateTime.now(),
        ),
      );
    } else {
      existingRoom = _chatRooms.firstWhere(
        (r) => r.supplierId == currentUserId && r.consumerId == otherUserId,
        orElse: () => ChatRoom(
          id: '',
          consumerId: '',
          supplierId: '',
          createdAt: DateTime.now(),
        ),
      );
    }

    if (existingRoom.id.isNotEmpty) {
      return existingRoom;
    }

    // Create new room
    final newRoom = ChatRoom(
      id: '${_nextRoomId++}',
      consumerId: currentUserRole == 'consumer' ? currentUserId : otherUserId,
      supplierId: currentUserRole == 'consumer' ? otherUserId : currentUserId,
      createdAt: DateTime.now(),
    );

    _chatRooms.add(newRoom);
    _messages[newRoom.id] = [];

    return newRoom;
  }
}

