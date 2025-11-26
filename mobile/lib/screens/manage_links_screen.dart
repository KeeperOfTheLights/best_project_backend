import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/link_request_provider.dart';
import '../providers/chat_provider.dart';
import '../models/link_request.dart';
import 'consumer_catalog_screen.dart';
import 'chat_room_screen.dart';

class ManageLinksScreen extends StatefulWidget {
  const ManageLinksScreen({super.key});

  @override
  State<ManageLinksScreen> createState() => _ManageLinksScreenState();
}

class _ManageLinksScreenState extends State<ManageLinksScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LinkRequestProvider>(context, listen: false)
          .loadLinkRequests();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Link Requests'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Pending', icon: Icon(Icons.pending)),
            Tab(text: 'Approved', icon: Icon(Icons.check_circle)),
            Tab(text: 'Rejected', icon: Icon(Icons.cancel)),
          ],
        ),
      ),
      body: Consumer<LinkRequestProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.linkRequests.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildRequestList(provider.getPendingRequests(), 'Pending'),
              _buildRequestList(provider.getApprovedRequests(), 'Approved'),
              _buildRequestList(provider.getRejectedRequests(), 'Rejected'),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRequestList(List<LinkRequest> requests, String status) {
    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              status == 'Pending'
                  ? Icons.pending
                  : status == 'Approved'
                      ? Icons.check_circle
                      : Icons.cancel,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No $status requests',
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await Provider.of<LinkRequestProvider>(context, listen: false)
            .loadLinkRequests();
      },
      child: ListView.builder(
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final request = requests[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: status == 'Approved'
                    ? Colors.green
                    : status == 'Rejected'
                        ? Colors.red
                        : Colors.orange,
                child: Icon(
                  status == 'Approved'
                      ? Icons.check
                      : status == 'Rejected'
                          ? Icons.close
                          : Icons.pending,
                  color: Colors.white,
                ),
              ),
              title: Text(
                request.supplier?.companyName ?? 'Supplier',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (request.supplier?.companyType != null)
                    Text('Type: ${request.supplier!.companyType}'),
                  Text(
                    'Requested: ${_formatDate(request.createdAt)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  if (status == 'Rejected' && request.rejectionReason != null)
                    Text(
                      'Reason: ${request.rejectionReason}',
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                ],
              ),
              trailing: status == 'Approved'
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.shopping_cart),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ConsumerCatalogScreen(
                                  supplierId: request.supplierId,
                                  supplierName: request.supplier?.companyName ?? 'Supplier',
                                ),
                              ),
                            );
                          },
                          tooltip: 'View Catalog',
                        ),
                                IconButton(
                                  icon: const Icon(Icons.chat),
                                  onPressed: () async {
                                    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
                                    final room = await chatProvider.createOrGetChatRoom(request.supplierId);
                                    if (room != null && mounted) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ChatRoomScreen(
                                            chatRoomId: room.id,
                                            otherPartyName: request.supplier?.companyName ?? 'Supplier',
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  tooltip: 'Open Chat',
                                ),
                        IconButton(
                          icon: const Icon(Icons.add_shopping_cart),
                          onPressed: () {

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Create Order feature coming soon'),
                              ),
                            );
                          },
                          tooltip: 'Create Order',
                        ),
                      ],
                    )
                  : null,
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

