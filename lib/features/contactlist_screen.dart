import 'package:e_commerce_2/features/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//import 'package:supabase_flutter/supabase_flutter.dart';
//import 'package:e_commerce_2/main.dart'; 

class ContactListScreen extends ConsumerWidget {
  const ContactListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supabase = ref.read(supabaseProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Contacts')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        // 1. Removed .execute(), returns the list directly
        future: supabase.from('profiles').select(), 
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            // 2. Errors are caught directly by the FutureBuilder
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // 3. snapshot.data is now exactly List<Map<String, dynamic>>
          final data = snapshot.data ?? [];

          if (data.isEmpty) {
            return const Center(child: Text('No contacts found.'));
          }

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final profile = data[index];
              return ListTile(
                leading: CircleAvatar(
                  child: Text(profile['username']?[0]?.toUpperCase() ?? '?'),
                ),
                title: Text(profile['username'] ?? 'No name'),
                subtitle: Text(profile['email'] ?? 'No email provided'),
                onTap: () {
                  // Navigate to conversation screen
                },
              );
            },
          );
        },
      ),
    );
  }
}
