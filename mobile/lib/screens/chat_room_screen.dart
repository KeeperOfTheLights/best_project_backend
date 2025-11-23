import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/chat_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/order_provider.dart';
import '../providers/catalog_provider.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';
import '../models/order.dart';
import '../models/catalog_item.dart';
import '../models/chat_message.dart';
import 'orders_screen.dart';

// ChatRoomScreen - shows conversation messages with file attachments, order receipts, and product links
class ChatRoomScreen extends StatefulWidget {
  final String chatRoomId;
  final String otherPartyName;
  final String? otherPartyType;

  const ChatRoomScreen({
    super.key,
    required this.chatRoomId,
    required this.otherPartyName,
    this.otherPartyType,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _showOrderSelector = false;
  bool _showProductSelector = false;
  List<Order> _consumerOrders = [];
  List<CatalogItem> _supplierProducts = [];
  bool _loadingOrders = false;
  bool _loadingProducts = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChatProvider>(context, listen: false)
          .loadMessages(widget.chatRoomId);
      _loadOrdersOrProducts();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadOrdersOrProducts() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userRole = authProvider.user?.role ?? '';

    if (userRole == UserRole.consumer) {
      // Load consumer orders for this supplier
      setState(() => _loadingOrders = true);
      try {
        final orderProvider = Provider.of<OrderProvider>(context, listen: false);
        await orderProvider.loadOrders();
        final allOrders = orderProvider.orders;
        // Filter orders for this supplier
        _consumerOrders = allOrders
            .where((order) => order.supplierId == widget.chatRoomId)
            .toList();
      } catch (e) {
        // Handle error silently
      }
      setState(() => _loadingOrders = false);
    } else if (isSupplierSide(userRole)) {
      // Load supplier products
      setState(() => _loadingProducts = true);
      try {
        final catalogProvider = Provider.of<CatalogProvider>(context, listen: false);
        await catalogProvider.loadMyCatalog();
        _supplierProducts = catalogProvider.items;
      } catch (e) {
        // Handle error silently
      }
      setState(() => _loadingProducts = false);
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage({String? text, String? orderId, String? productId, File? attachment}) async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userRole = authProvider.user?.role ?? '';
    
    // Determine supplierId and consumerId based on role
    String? supplierId;
    String? consumerId;
    String? messageType;

    if (userRole == UserRole.consumer) {
      supplierId = widget.chatRoomId; // Consumer sends to supplier
      if (orderId != null) {
        messageType = 'receipt';
        text = text ?? 'Order Receipt #$orderId';
      }
    } else if (isSupplierSide(userRole)) {
      // For supplier, need to get company owner ID
      final userId = authProvider.user?.id ?? StorageService.getUserId() ?? '';
      supplierId = userId; // Company owner ID
      consumerId = widget.chatRoomId; // Supplier sends to consumer
      if (productId != null) {
        messageType = 'product_link';
        final product = _supplierProducts.firstWhere((p) => p.id == productId, orElse: () => _supplierProducts.first);
        text = text ?? 'Check out: ${product.name}';
      }
    }

    if (attachment != null) {
      messageType = 'attachment';
    }

    final success = await chatProvider.sendMessage(
      supplierId: supplierId ?? widget.chatRoomId,
      text: text,
      consumerId: consumerId,
      orderId: orderId,
      productId: productId,
      messageType: messageType,
      attachment: attachment,
    );

    if (success && mounted) {
      _messageController.clear();
      setState(() {
        _showOrderSelector = false;
        _showProductSelector = false;
      });
      _scrollToBottom();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(chatProvider.errorMessage ?? 'Failed to send message'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        await _sendMessage(attachment: file);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick file: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUserId = authProvider.user?.id ?? StorageService.getUserId() ?? '';
    final userRole = authProvider.user?.role ?? '';
    final isConsumer = userRole == UserRole.consumer;
    
    // Get avatar initials
    final initials = widget.otherPartyName.isNotEmpty
        ? widget.otherPartyName.substring(0, widget.otherPartyName.length > 2 ? 2 : 1).toUpperCase()
        : '?';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5E6E6),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF20232A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFF61DAFB),
              radius: 18,
              child: Text(
                initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.otherPartyName,
                    style: const TextStyle(
                      color: Color(0xFF20232A),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  if (widget.otherPartyType != null)
                    Text(
                      widget.otherPartyType!,
                      style: const TextStyle(
                        color: Color(0xFF666666),
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, child) {
                final messages = chatProvider.getMessages(widget.chatRoomId);

                if (chatProvider.isLoading && messages.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (messages.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No messages yet',
                          style: TextStyle(color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Start the conversation!',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  );
                }

                // Scroll to bottom when messages load
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == currentUserId;

                    return _buildMessageBubble(message, isMe, isConsumer);
                  },
                );
              },
            ),
          ),

          // Order/Product selector dropdowns
          if (_showOrderSelector && isConsumer) _buildOrderSelector(),
          if (_showProductSelector && !isConsumer) _buildProductSelector(),

          // Message input
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                        onSubmitted: (_) {
                          if (_messageController.text.trim().isNotEmpty) {
                            _sendMessage(text: _messageController.text.trim());
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    // File attachment button
                    IconButton(
                      icon: const Icon(Icons.attach_file, color: Color(0xFF61DAFB)),
                      onPressed: _pickFile,
                      tooltip: 'Attach file',
                    ),
                    // Order Receipt button (Consumer) or Product Link button (Supplier)
                    if (isConsumer)
                      IconButton(
                        icon: const Icon(Icons.receipt, color: Color(0xFF61DAFB)),
                        onPressed: () {
                          setState(() {
                            _showOrderSelector = !_showOrderSelector;
                            _showProductSelector = false;
                          });
                        },
                        tooltip: 'Send Receipt',
                      )
                    else
                      IconButton(
                        icon: const Icon(Icons.shopping_cart, color: Color(0xFF61DAFB)),
                        onPressed: () {
                          setState(() {
                            _showProductSelector = !_showProductSelector;
                            _showOrderSelector = false;
                          });
                        },
                        tooltip: 'Send Product Link',
                      ),
                    // Send button
                    IconButton(
                      icon: const Icon(Icons.send, color: Color(0xFF61DAFB)),
                      onPressed: () {
                        if (_messageController.text.trim().isNotEmpty) {
                          _sendMessage(text: _messageController.text.trim());
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, bool isMe, bool isConsumer) {
    final messageType = message.messageType;
    
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // Message content based on type
            // Show special message types first, then text if present
            if (messageType == 'receipt' && message.orderId != null)
              _buildOrderReceiptCard(message, isMe, isConsumer),
            if (messageType == 'product_link' && message.productId != null)
              _buildProductLinkCard(message, isMe),
            if (messageType == 'attachment' && message.attachmentUrl != null)
              _buildAttachmentCard(message, isMe),
            // Show text if present (and not already shown in special cards)
            if (message.text.isNotEmpty && 
                messageType != 'receipt' && 
                messageType != 'product_link' && 
                messageType != 'attachment')
              _buildTextBubble(message.text, isMe),
            if (message.text.isNotEmpty && 
                (messageType == 'receipt' || messageType == 'product_link' || messageType == 'attachment'))
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: _buildTextBubble(message.text, isMe),
              ),
            const SizedBox(height: 4),
            // Timestamp
            Text(
              _formatTime(message.createdAt),
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextBubble(String text, bool isMe) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isMe ? const Color(0xFF61DAFB) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isMe ? Colors.white : const Color(0xFF20232A),
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildOrderReceiptCard(ChatMessage message, bool isMe, bool isConsumer) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isMe ? const Color(0xFF61DAFB) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Receipt',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isMe ? Colors.white : const Color(0xFF20232A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Order #${message.orderId}',
            style: TextStyle(
              fontSize: 14,
              color: isMe ? Colors.white70 : const Color(0xFF666666),
            ),
          ),
          const SizedBox(height: 12),
          // Always show View Order button (matching website)
          ElevatedButton(
            onPressed: () {
              // Navigate to Orders screen (consumer or supplier)
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OrdersScreen(isConsumer: isConsumer),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isMe ? Colors.white : const Color(0xFF61DAFB),
              foregroundColor: isMe ? const Color(0xFF61DAFB) : Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text('View Order'),
          ),
        ],
      ),
    );
  }

  Widget _buildProductLinkCard(ChatMessage message, bool isMe) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isMe ? const Color(0xFF61DAFB) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Product Link',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isMe ? Colors.white : const Color(0xFF20232A),
            ),
          ),
          const SizedBox(height: 8),
          if (message.productName != null)
            Text(
              message.productName!,
              style: TextStyle(
                fontSize: 14,
                color: isMe ? Colors.white70 : const Color(0xFF666666),
              ),
            ),
          // Show text message below product name (like "Check out: PineApple")
          if (message.text.isNotEmpty && message.text != message.productName)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                message.text,
                style: TextStyle(
                  fontSize: 14,
                  color: isMe ? Colors.white70 : const Color(0xFF666666),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAttachmentCard(ChatMessage message, bool isMe) {
    return InkWell(
      onTap: () {
        // Open/download attachment
        if (message.attachmentUrl != null) {
          _openAttachment(message.attachmentUrl!);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF61DAFB) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.attach_file,
              color: isMe ? Colors.white : const Color(0xFF61DAFB),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Show attachment name (file name)
                  Text(
                    message.attachmentName ?? 'Attachment',
                    style: TextStyle(
                      color: isMe ? Colors.white : const Color(0xFF20232A),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  if (message.attachmentUrl != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Tap to open',
                        style: TextStyle(
                          color: isMe ? Colors.white70 : const Color(0xFF666666),
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openAttachment(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cannot open this attachment'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open attachment: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildOrderSelector() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select Order to Share',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () {
                    setState(() => _showOrderSelector = false);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: _loadingOrders
                ? const Center(child: CircularProgressIndicator())
                : _consumerOrders.isEmpty
                    ? const Center(
                        child: Text(
                          'No orders to share',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _consumerOrders.length,
                        itemBuilder: (context, index) {
                          final order = _consumerOrders[index];
                          return ListTile(
                            title: Text('Order #${order.id}'),
                            subtitle: Text('Total: ${order.totalAmount.toStringAsFixed(2)} ₸'),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              _sendMessage(
                                orderId: order.id,
                                text: 'Order Receipt #${order.id}',
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductSelector() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select Product to Share',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () {
                    setState(() => _showProductSelector = false);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: _loadingProducts
                ? const Center(child: CircularProgressIndicator())
                : _supplierProducts.isEmpty
                    ? const Center(
                        child: Text(
                          'No products to share',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _supplierProducts.length,
                        itemBuilder: (context, index) {
                          final product = _supplierProducts[index];
                          return ListTile(
                            title: Text(product.name),
                            subtitle: Text('${product.discountedPrice.toStringAsFixed(2)} ₸ / ${product.unit}'),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              _sendMessage(
                                productId: product.id,
                                text: 'Check out: ${product.name}',
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
