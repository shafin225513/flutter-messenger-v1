import 'package:e_commerce_2/features/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Message {
  final String id;
  final String content;
  final String senderId;
  final DateTime createdAt;

  Message({
    required this.id,
    required this.content,
    required this.senderId,
    required this.createdAt,
  });

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'],
      content: map['content'],
      senderId: map['sender_id'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}

final scrollController = ScrollController();

final conversationsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final supabase = ref.read(supabaseProvider);
  final currentUser = ref.read(currentUserProvider)!;

  final data = await supabase
      .from('conversations')
      .select('id, user1, user2, last_message_at')
      .or(
        'user1.eq.${currentUser.id},user2.eq.${currentUser.id}',
      )
      .order(
        'last_message_at',
        ascending: false,
        nullsFirst: false, // 👈 THIS is "nulls last"
      );

  return List<Map<String, dynamic>>.from(data);
});


final messagesProvider =
    FutureProvider.family<List<Message>, String>((ref, conversationId) async {
  final supabase = ref.read(supabaseProvider);

  final data = await supabase
      .from('messages')
      .select()
      .eq('conversation_id', conversationId)
      .order('created_at',ascending: false);

      

  return data.map<Message>((e) => Message.fromMap(e)).toList();
});



class ChatScreen extends ConsumerWidget {
  final String conversationId;

  const ChatScreen({super.key, required this.conversationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messagesAsync = ref.watch(messagesProvider(conversationId));
    final currentUser = ref.read(currentUserProvider)!;

    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (messages) {
                return ListView.builder(
                  controller: scrollController,
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg.senderId == currentUser.id;

                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isMe
                              ? Colors.blue.shade200
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(msg.content),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          _MessageInput(conversationId: conversationId),
        ],
      ),
    );
  }
}


class _MessageInput extends ConsumerStatefulWidget {
  final String conversationId;

  const _MessageInput({required this.conversationId});

  @override
  ConsumerState<_MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends ConsumerState<_MessageInput> {
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final supabase = ref.read(supabaseProvider);
    final currentUser = ref.read(currentUserProvider)!;

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration:
                  const InputDecoration(hintText: 'Type a message...'),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () async {
              final text = controller.text.trim();
              if (text.isEmpty) return;

              controller.clear();

              await supabase.from('messages').insert({
                'conversation_id': widget.conversationId,
                'sender_id': currentUser.id,
                'content': text,
              });

              await supabase.from('conversations').update({
                'last_message_at': DateTime.now().toIso8601String(),
                 }).eq('id', widget.conversationId);

              // 🔄 refresh messages
              ref.invalidate(messagesProvider(widget.conversationId));
              Future.delayed(const Duration(milliseconds: 100),()
              {
                scrollController.jumpTo(0);
              }
              );
            },
          ),
        ],
      ),
    );
  }
}
