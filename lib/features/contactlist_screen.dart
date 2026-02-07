import 'package:e_commerce_2/features/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:e_commerce_2/features/chat_screen.dart';

// Provider to fetch all users (contacts) + their conversation info
final contactsProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final supabase = ref.read(supabaseProvider);
  final currentUser = supabase.auth.currentUser;
  if (currentUser == null) return [];

  // 1️⃣ Fetch all other users
  final allProfiles = await supabase
      .from('profiles')
      .select('id, username')
      .neq('id', currentUser.id);

  // 2️⃣ Fetch all conversations of current user, order by last_message_at
  final convos = await supabase
      .from('conversations')
      .select()
      .or('user1.eq.${currentUser.id},user2.eq.${currentUser.id}')
      .order('last_message_at', ascending: false, nullsFirst: false);

  // 3️⃣ Map conversation by other user id
  final Map<String, Map<String, dynamic>> convosMap = {};
  for (var c in convos) {
    final otherId = c['user1'] == currentUser.id ? c['user2'] : c['user1'];
    convosMap[otherId] = {
      'conversation_id': c['id'],
      'last_message_at': c['last_message_at'] as String?,
    };
  }

  // 4️⃣ Merge profiles + conversation info
  final merged = allProfiles.map((p) {
    final convo = convosMap[p['id']];
    return {
      'other_user_id': p['id'],
      'username': (p['username'] as String?) ?? 'Unknown',
      'conversation_id': convo?['conversation_id'],
      'last_message_at': convo?['last_message_at'],
    };
  }).toList();

  // 5️⃣ Sort: first by last_message_at desc (nulls last), then remaining users
  merged.sort((a, b) {
    final aTime = a['last_message_at'] as String?;
    final bTime = b['last_message_at'] as String?;

    if (aTime == null && bTime == null) return 0;
    if (aTime == null) return 1;
    if (bTime == null) return -1;
    return bTime.compareTo(aTime); // newest first
  });

  return merged;
});

// Utility to get or create conversation
Future<String> getOrCreateConversation({
  required SupabaseClient supabase,
  required String currentUserId,
  required String otherUserId,
}) async {
  final user1 = currentUserId.compareTo(otherUserId) < 0
      ? currentUserId
      : otherUserId;
  final user2 = currentUserId.compareTo(otherUserId) < 0
      ? otherUserId
      : currentUserId;

  final existing = await supabase
      .from('conversations')
      .select()
      .eq('user1', user1)
      .eq('user2', user2)
      .maybeSingle();

  if (existing != null) return existing['id'] as String;

  final created = await supabase
      .from('conversations')
      .insert({'user1': user1, 'user2': user2})
      .select()
      .single();

  return created['id'] as String;
}

class ContactListScreen extends ConsumerWidget {
  const ContactListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactsAsync = ref.watch(contactsProvider);
    final supabase = ref.read(supabaseProvider);
    final currentUser = supabase.auth.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Contacts')),
      body: contactsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (contacts) {
          if (contacts.isEmpty) return const Center(child: Text('No contacts found.'));

          return ListView.builder(
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              final contact = contacts[index];
              final username = contact['username'] as String;
              final lastMsg = contact['last_message_at'] as String?;

              return ListTile(
                leading: CircleAvatar(
                  child: Text(username[0].toUpperCase()),
                ),
                title: Text(username),
                subtitle: Text(lastMsg != null ? 'Last message: $lastMsg' : 'No messages yet'),
                onTap: () async {
                  if (currentUser == null) return;

                  final conversationId = contact['conversation_id'] != null
                      ? contact['conversation_id'] as String
                      : await getOrCreateConversation(
                          supabase: supabase,
                          currentUserId: currentUser.id,
                          otherUserId: contact['other_user_id'] as String,
                        );

                  // Navigate to ChatScreen
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(conversationId: conversationId),
                    ),
                  );

                  // Refresh contacts after sending a message
                  ref.invalidate(contactsProvider);
                },
              );
            },
          );
        },
      ),
    );
  }
}
