import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screens/login_screen.dart';
import '../screens/home_screen.dart';
import '../screens/note_screen.dart';
import '../services/auth_service.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) async {
      // Check if user is signed in
      final isSignedIn = await AuthService.isSignedIn();

      // If the user is not signed in and is not on the login page, redirect to login
      if (!isSignedIn && state.uri.toString() != '/login') {
        return '/login';
      }

      // If the user is signed in and is on the login page, redirect to home
      if (isSignedIn && state.uri.toString() == '/login') {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => MyHomePage(),
      ),
      GoRoute(
        path: '/note/:id',
        builder: (context, state) {
          final noteId = state.pathParameters['id'];
          return NoteScreen(noteId: noteId);
        },
      ),
    ],
  );
});