import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/app_gradient_scaffold.dart';
import '../../widgets/illustrated_state_view.dart';

/// Shown by go_router's `errorBuilder` for any unmatched route. Unlike
/// [ErrorStateView], this has no parent tab shell to sit inside, so it
/// builds its own full-screen scaffold.
class NotFoundRouteScreen extends StatelessWidget {
  const NotFoundRouteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppGradientScaffold(
      body: IllustratedStateView(
        illustrationAsset: 'assets/illustrations/illustration-not-found.png',
        heading: "We Couldn't Find That",
        message: 'This page or book may have been moved or no longer exists.',
        primaryLabel: 'Back to Home',
        onPrimary: () => context.go('/home'),
        secondaryLabel: 'Browse Books',
        onSecondary: () => context.go('/home'),
      ),
    );
  }
}
