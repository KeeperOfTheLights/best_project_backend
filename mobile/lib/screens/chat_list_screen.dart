import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import 'chat_room_screen.dart';

// ChatListScreen - shows all chat rooms (suppliers for Consumer, consumers for Supplier)
class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChatProvider>(context, listen: false).loadChatRooms();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isConsumer = authProvider.user?.role == UserRole.consumer;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
      ),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          if (chatProvider.isLoading && chatProvider.chatRooms.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (chatProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(chatProvider.errorMessage!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      chatProvider.loadChatRooms();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (chatProvider.chatRooms.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No chats yet',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isConsumer
                        ? 'Start chatting with your linked suppliers'
                        : 'Start chatting with your linked consumers',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await chatProvider.loadChatRooms();
            },
            child: ListView.builder(
              itemCount: chatProvider.chatRooms.length,
              itemBuilder: (context, index) {
                final room = chatProvider.chatRooms[index];
                
                // Determine the other party's name
                String otherPartyName;
                String? otherPartySubtitle;
                
                if (isConsumer) {
                  otherPartyName = room.supplier?.companyName ?? 'Supplier';
                  otherPartySubtitle = room.supplier?.companyType;
                } else {
                  otherPartyName = room.consumer?.name ?? 'Consumer';
                  otherPartySubtitle = room.consumer?.businessName;
                }

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Text(
                        otherPartyName[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      otherPartyName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (otherPartySubtitle != null)
                          Text(
                            otherPartySubtitle,
                            style: const TextStyle(fontSize: 12),
                          ),
                        if (room.lastMessage != null)
                          Text(
                            room.lastMessage!.message,
                            style: const TextStyle(fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        else
                          const Text(
                            'No messages yet',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                      ],
                    ),
                    trailing: room.unreadCount > 0
                        ? Badge(
                            label: Text('${room.unreadCount}'),
                            child: const Icon(Icons.chat_bubble),
                          )
                        : const Icon(Icons.chat_bubble_outline),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatRoomScreen(
                            chatRoomId: room.id,
                            otherPartyName: otherPartyName,
                          ),
                        ),
                      );
                    },
                    isThreeLine: true,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}




