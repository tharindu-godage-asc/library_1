import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Thin wrapper around Material 3's SearchBar — theming lives centrally
/// in AppTheme.light (searchBarTheme), not here. This wrapper's only job
/// is the leading/trailing icon composition so it isn't repeated at
/// every call site (Books search, and later Admin book/member search).
class AppSearchField extends StatelessWidget {
  const AppSearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.hintText = 'Search...',
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return SearchBar(
      controller: controller,
      onChanged: onChanged,
      hintText: hintText,
      leading: const Icon(Icons.search, color: AppColors.textSecondary, size: 20),
      trailing: [
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, _) {
            if (value.text.isEmpty) return const SizedBox.shrink();
            return IconButton(
              icon: const Icon(Icons.close, size: 20),
              color: AppColors.textSecondary,
              onPressed: () {
                controller.clear();
                onChanged('');
              },
            );
          },
        ),
      ],
    );
  }
}