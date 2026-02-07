import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:e_commerce_2/features/contactlist_screen.dart';

// Providers
final supabaseProvider = Provider<SupabaseClient>((ref) => Supabase.instance.client);

final currentUserProvider = StateProvider<User?>(
  (ref) => ref.watch(supabaseProvider).auth.currentUser,
);

final profileProvider = StateProvider<Map<String, dynamic>?>((ref) => null);

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  Future<void> _login() async {
    setState(() => _loading = true);
    try {
      await signIn(
        ref,
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) =>  ContactListScreen()),
        );
      }
    } on AuthException catch (e) {
      _showError(e.message);
    } on PostgrestException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('An unexpected error occurred');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> signIn(WidgetRef ref, String email, String password) async {
    final supabase = ref.read(supabaseProvider);

    // 1. Auth: signInWithPassword now returns an AuthResponse directly or throws
    final response = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final user = response.user;
    if (user == null) throw const AuthException('User not found after login');

    // Update Auth State
    ref.read(currentUserProvider.notifier).state = user;

    // 2. Database: .single() returns Map<String, dynamic> directly or throws
    // If no profile exists, this will throw a PostgrestException
    final profileData = await supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    // Update Profile State
    ref.read(profileProvider.notifier).state = profileData;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 20),
            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _login,
                    child: const Text('Login'),
                  ),
          ],
        ),
      ),
    );
  }
}
