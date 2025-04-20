import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../services/drive_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  Future<void> _handleSignIn() async {
    setState(() => _isLoading = true);

    try {
      final signedIn = await AuthService.signInWithGoogle();
      if (!signedIn) {
        _showMessage("Sign-in cancelled or failed");
        return;
      }

      final initialized = await DriveService.initialize();
      if (!initialized) {
        _showMessage("Drive initialization failed");
        return;
      }

      // Navigate to home route
      context.go('/');
    } catch (e) {
      debugPrint('Sign-in error: $e');
      _showMessage("An error occurred: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Drive Notes", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text("Your notes, synced with Google Drive", style: TextStyle(fontSize: 16)),
              const SizedBox(height: 32),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                onPressed: _handleSignIn,
                icon: Image.network(
                  "https://img.icons8.com/?size=100&id=17949&format=png&color=000000",
                  height: 30,
                  width: 30,
                ),
                label: const Text("Sign in with Google", style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  side: const BorderSide(color: Colors.grey),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}