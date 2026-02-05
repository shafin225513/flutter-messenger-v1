import 'package:e_commerce_2/features/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// 1. Define Supabase Provider
final supabaseProvider = Provider<SupabaseClient>((ref) => Supabase.instance.client);

// 2. StateNotifier to manage Sign Up logic and loading/error states
class SignUpNotifier extends StateNotifier<AsyncValue<void>> {
  final SupabaseClient supabase;
  SignUpNotifier(this.supabase) : super(const AsyncValue.data(null));

  Future<void> signUp({
    required String email,
    required String password,
    required String username,
    required Function(String) onError,
    required Function() onSuccess,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      try {
        final response = await supabase.auth.signUp(
          email: email.trim(),
          password: password,
        );

        if (response.user == null) {
          throw Exception('Sign up failed');
        }

        await supabase.from('profiles').insert({
          'id': response.user!.id,
          'email': response.user!.email,
          'username': username.trim(),
        });

        onSuccess();
      } catch (e, stackTrace) {
        onError(e.toString());
        state = AsyncValue.error(e, stackTrace);
      }
    });
  }
}

// 3. Provider for the Sign Up Notifier
final signUpProvider = StateNotifierProvider<SignUpNotifier, AsyncValue<void>>((ref) {
  return SignUpNotifier(ref.watch(supabaseProvider));
});

// 4. UI Layer using ConsumerWidget
class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final signUpState = ref.watch(signUpProvider);
    final isLoading = signUpState.isLoading;

    // Listen for errors
    ref.listen<AsyncValue<void>>(signUpProvider, (previous, next) {
      next.whenOrNull(
        error: (error, _) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        ),
      );
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: _usernameController, decoration: const InputDecoration(labelText: 'Username')),
            TextField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'Password')),
            const SizedBox(height: 20),
            isLoading
                ? const CircularProgressIndicator()
                : Column(
                  children: [
                    ElevatedButton(
                    onPressed: () {
                      ref.read(signUpProvider.notifier).signUp(
                            email: _emailController.text,
                            password: _passwordController.text,
                            username: _usernameController.text,
                            onError: (msg) {}, // Error handled by ref.listen
                            onSuccess: () => ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Sign up successful!')),
                            ),
                          );
                    },
                    child: const Text('Sign Up'),
                   ),
                   const SizedBox(height: 10,),
                   TextButton(
                    onPressed: () {
                      Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                          );
                     }, 
                    child: const Text('Already have an account? Login'),
                   )

                  ],
                )
          ],
        ),
      ),
    );
  }
}
