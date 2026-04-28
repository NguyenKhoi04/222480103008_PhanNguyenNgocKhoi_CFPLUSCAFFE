import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatUserScreen extends StatefulWidget {
  const ChatUserScreen({super.key});

  @override
  State<ChatUserScreen> createState() => _ChatUserScreenState();
}

class _ChatUserScreenState extends State<ChatUserScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final SupabaseClient _client = Supabase.instance.client;

  String chatId = '';
  String userId = '';
  String userName = '';

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  Future<void> _initChat() async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    userId = user.id;
    userName = user.userMetadata?['full_name'] ??
        user.email ??
        'Khách hàng';

    try {
      /// kiểm tra chat đã tồn tại chưa
      final existing = await _client
          .from('chats')
          .select('id')
          .eq('customer_id', userId)
          .limit(1)
          .maybeSingle();

      if (existing != null) {
        chatId = existing['id'].toString();
      } else {
        final inserted = await _client
            .from('chats')
            .insert({
              'customer_id': userId,
              'admin_id': null,
              'customer_name': userName,
              'last_message': '',
              'sender_id': userId,
              'content': '',
            })
            .select()
            .single();

        chatId = inserted['id'].toString();
      }

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('Lỗi init chat: $e');
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ================== GỬI TIN NHẮN ==================
  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();

    if (text.isEmpty || chatId.isEmpty) return;

    try {
      await _client.from('chats').insert({
        'customer_id': userId,
        'admin_id': null,
        'customer_name': userName,
        'last_message': text,
        'sender_id': userId,
        'content': text,
      });

      _messageController.clear();
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi gửi tin nhắn: $e')),
      );
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ================== UI ==================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chat tư vấn',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF8B4513),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: chatId.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : StreamBuilder<List<Map<String, dynamic>>>(
                    stream: _client
                        .from('chats')
                        .stream(primaryKey: ['id'])
                        .eq('customer_id', userId)
                        .order('created_at'),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (!snapshot.hasData ||
                          snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text(
                            'Hãy gửi tin nhắn đầu tiên 👋',
                            style: TextStyle(color: Colors.grey),
                          ),
                        );
                      }

                      final messages = snapshot.data!;

                      WidgetsBinding.instance
                          .addPostFrameCallback(
                        (_) => _scrollToBottom(),
                      );

                      return ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final data = messages[index];

                          final senderId =
                              data['sender_id'] ?? '';
                          final text =
                              data['content'] ?? '';
                          final createdAt =
                              data['created_at'];

                          final isUser =
                              senderId == userId;

                          return _messageBubble(
                            text: text,
                            isUser: isUser,
                            timestamp: createdAt,
                          );
                        },
                      );
                    },
                  ),
          ),

          // Ô NHẬP TIN NHẮN
          SafeArea(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 3,
                    offset: Offset(0, -1),
                  )
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Nhập tin nhắn...',
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.send,
                      color: Color(0xFF8B4513),
                    ),
                    onPressed: _sendMessage,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================== MESSAGE BUBBLE ==================
  Widget _messageBubble({
    required String text,
    required bool isUser,
    required dynamic timestamp,
  }) {
    String timeText = '';

    if (timestamp != null) {
      try {
        final date = DateTime.parse(timestamp.toString())
            .toLocal();

        timeText = DateFormat('HH:mm').format(date);
      } catch (_) {}
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment:
            isUser
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth:
                  MediaQuery.of(context).size.width * 0.7,
            ),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isUser
                  ? const Color(0xFF8B4513)
                  : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: TextStyle(
                    color: isUser
                        ? Colors.white
                        : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  timeText,
                  style: TextStyle(
                    fontSize: 10,
                    color: isUser
                        ? Colors.white70
                        : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// class ChatUserScreen extends StatefulWidget {
//   const ChatUserScreen({super.key});

//   @override
//   State<ChatUserScreen> createState() => _ChatUserScreenState();
// }

// class _ChatUserScreenState extends State<ChatUserScreen> {
//   final TextEditingController _messageController = TextEditingController();
//   final ScrollController _scrollController = ScrollController();

//   late String chatId;
//   late String userId;
//   late String userName;

//   @override
//   void initState() {
//     super.initState();
//     _initChat();
//   }

//   Future<void> _initChat() async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) return;

//     userId = user.uid;
//     userName = user.displayName ?? 'Khách hàng';
//     chatId = "${userId}_admin";

//     /// Tạo chat nếu chưa tồn tại
//     await FirebaseFirestore.instance
//         .collection('Chats')
//         .doc(chatId)
//         .set({
//       'customerId': userId,
//       'adminId': 'admin',
//       'customerName': userName,
//       'lastMessage': '',
//       'updatedAt': FieldValue.serverTimestamp(),
//     }, SetOptions(merge: true));
//   }

//   @override
//   void dispose() {
//     _messageController.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }

//   // ================== GỬI TIN NHẮN ==================
//   Future<void> _sendMessage() async {
//     final text = _messageController.text.trim();
//     if (text.isEmpty) return;

//     try {
//       final chatRef =
//           FirebaseFirestore.instance.collection('Chats').doc(chatId);

//       // Thêm tin nhắn
//       await chatRef.collection('Messages').add({
//         'senderId': userId,
//         'text': text,
//         'createdAt': FieldValue.serverTimestamp(),
//       });

//       // Cập nhật chat list cho admin
//       await chatRef.update({
//         'lastMessage': text,
//         'updatedAt': FieldValue.serverTimestamp(),
//       });

//       _messageController.clear();
//       _scrollToBottom();
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Lỗi gửi tin nhắn: $e')),
//       );
//     }
//   }

//   void _scrollToBottom() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_scrollController.hasClients) {
//         _scrollController.animateTo(
//           _scrollController.position.maxScrollExtent,
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeOut,
//         );
//       }
//     });
//   }

//   // ================== UI ==================
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Chat tư vấn',
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         backgroundColor: const Color(0xFF8B4513),
//         foregroundColor: Colors.white,
//       ),
//       body: Column(
//         children: [
//           // DANH SÁCH TIN NHẮN
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream: FirebaseFirestore.instance
//                   .collection('Chats')
//                   .doc(chatId)
//                   .collection('Messages')
//                   .orderBy('createdAt')
//                   .snapshots(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 }

//                 if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                   return const Center(
//                     child: Text(
//                       'Hãy gửi tin nhắn đầu tiên 👋',
//                       style: TextStyle(color: Colors.grey),
//                     ),
//                   );
//                 }

//                 final messages = snapshot.data!.docs;

//                 WidgetsBinding.instance
//                     .addPostFrameCallback((_) => _scrollToBottom());

//                 return ListView.builder(
//                   controller: _scrollController,
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
//                   itemCount: messages.length,
//                   itemBuilder: (context, index) {
//                     final data =
//                         messages[index].data() as Map<String, dynamic>;

//                     final senderId = data['senderId'] ?? '';
//                     final text = data['text'] ?? '';
//                     final timestamp = data['createdAt'] as Timestamp?;

//                     final isUser = senderId == userId;

//                     return _messageBubble(
//                       text: text,
//                       isUser: isUser,
//                       timestamp: timestamp,
//                     );
//                   },
//                 );
//               },
//             ),
//           ),

//           // Ô NHẬP TIN NHẮN
//           SafeArea(
//             child: Container(
//               padding: const EdgeInsets.all(8),
//               decoration: const BoxDecoration(
//                 color: Colors.white,
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black12,
//                     blurRadius: 3,
//                     offset: Offset(0, -1),
//                   )
//                 ],
//               ),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: TextField(
//                       controller: _messageController,
//                       decoration: const InputDecoration(
//                         hintText: 'Nhập tin nhắn...',
//                         border: InputBorder.none,
//                       ),
//                       onSubmitted: (_) => _sendMessage(),
//                     ),
//                   ),
//                   IconButton(
//                     icon: const Icon(Icons.send, color: Color(0xFF8B4513)),
//                     onPressed: _sendMessage,
//                   )
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ================== MESSAGE BUBBLE ==================
//   Widget _messageBubble({
//     required String text,
//     required bool isUser,
//     required Timestamp? timestamp,
//   }) {
//     final timeText = timestamp != null
//         ? DateFormat('HH:mm').format(timestamp.toDate())
//         : '';

//     return Padding(
//       padding: const EdgeInsets.only(bottom: 6),
//       child: Row(
//         mainAxisAlignment:
//             isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
//         children: [
//           Container(
//             constraints: BoxConstraints(
//               maxWidth: MediaQuery.of(context).size.width * 0.7,
//             ),
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: isUser
//                   ? const Color(0xFF8B4513)
//                   : Colors.grey.shade200,
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: Column(
//               crossAxisAlignment:
//                   isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   text,
//                   style: TextStyle(
//                     color: isUser ? Colors.white : Colors.black87,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   timeText,
//                   style: TextStyle(
//                     fontSize: 10,
//                     color: isUser ? Colors.white70 : Colors.grey,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
