import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import '../utils/localization.dart';
import '../widgets/language_switcher.dart';
import '../models/link_request.dart';
import '../services/link_request_service.dart';
import 'chat_room_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  List<Map<String, dynamic>> _linkedPartners = [];
  bool _isLoading = false;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLinkedPartners();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadLinkedPartners() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userRole = authProvider.user?.role ?? '';

      final linkRequests = await LinkRequestService.getLinkRequests(userRole: userRole);

      final linkedRequests = linkRequests.where((req) => req.status == LinkRequestStatus.linked).toList();

      List<Map<String, dynamic>> partners = [];
      
      if (userRole == UserRole.consumer) {

        for (var request in linkedRequests) {
          partners.add({
            'id': request.supplierId,
            'name': request.supplierName ?? 'Supplier #${request.supplierId}',
            'type': 'supplier',
            'subtitle': 'Supplier',
          });
        }
      } else if (isSupplierSide(userRole)) {

        for (var request in linkedRequests) {
          partners.add({
            'id': request.consumerId,
            'name': request.consumerName ?? 'Consumer #${request.consumerId}',
            'type': 'consumer',
            'subtitle': 'Consumer',
          });
        }
      }
      
      setState(() {
        _linkedPartners = partners;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredPartners {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      return _linkedPartners;
    }
    return _linkedPartners.where((partner) {
      return partner['name'].toString().toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isConsumer = authProvider.user?.role == UserRole.consumer;
    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5E6E6),
        title: Text(
          loc.text('Messages'),
          style: const TextStyle(
            color: Color(0xFF20232A),
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: LanguageSwitcher(),
          ),
        ],
      ),
      body: Column(
        children: [

          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: loc.text('Search conversations...'),
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 48, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(_errorMessage!),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadLinkedPartners,
                              child: Text(loc.text('Retry')),
                            ),
                          ],
                        ),
                      )
                    : _filteredPartners.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                                const SizedBox(height: 16),
                                Text(
                                  loc.text('No chats yet'),
                                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  isConsumer
                                      ? loc.text('Start chatting with your linked suppliers')
                                      : loc.text('Start chatting with your linked consumers'),
                                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadLinkedPartners,
                            child: ListView.builder(
                              itemCount: _filteredPartners.length,
                              itemBuilder: (context, index) {
                                final partner = _filteredPartners[index];
                                final partnerName = partner['name'] as String;
                                final partnerSubtitle = partner['subtitle'] as String;
                                final partnerId = partner['id'] as String;

                                final initials = partnerName.isNotEmpty
                                    ? partnerName.substring(0, partnerName.length > 2 ? 2 : 1).toUpperCase()
                                    : '?';

                                return Card(
                                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  elevation: 1,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: const Color(0xFF61DAFB),
                                      radius: 24,
                                      child: Text(
                                        initials,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      partnerName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF20232A),
                                      ),
                                    ),
                                    subtitle: Text(
                                      partnerSubtitle,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF666666),
                                      ),
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ChatRoomScreen(
                                            chatRoomId: partnerId,
                                            otherPartyName: partnerName,
                                            otherPartyType: partnerSubtitle,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}
