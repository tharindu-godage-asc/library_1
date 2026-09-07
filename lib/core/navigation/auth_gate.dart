import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/books/presentation/screens/books_screen.dart';

/// The single point where "is the user signed in?" becomes a screen.
///
/// Every auth-state change (login, register, logout) flows through
/// [authControllerProvider]; this widget just watches it and swaps
/// itself between [LoginScreen] and [BooksScreen] in place. Nothing
/// else in the app should navigate to `BooksScreen` or back to
/// `LoginScreen` imperatively — changing the controller's state is
/// enough, and it's physically impossible to land on a stale screen
/// because there's no manual route to get out of sync.
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authControllerProvider).asData?.value;
    return session != null ? const BooksScreen() : const LoginScreen();
  }
}
