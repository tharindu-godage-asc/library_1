import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_gradient_scaffold.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../providers/notification_providers.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncItems = ref.watch(notificationItemsProvider);

    return AppGradientScaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: asyncItems.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(
          message: 'Could not load notifications.',
          onRetry: () => ref.invalidate(notificationItemsProvider),
        ),
        data: (items) {
          if (items.isEmpty) {
            return const EmptyView(message: "You're all caught up — no notifications right now.");
          }
          final urgent = items.where((i) => i.tone != NotificationTone.info).toList();
          final recent = items.where((i) => i.tone == NotificationTone.info).toList();
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              if (urgent.isNotEmpty) ..._section('Needs Attention', urgent),
              if (recent.isNotEmpty) ..._section('Recent Activity', recent),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _section(String label, List<NotificationItem> items) {
    return [
      Text(label, style: AppTextStyles.label.copyWith(color: AppColors.primaryPressed)),
      const SizedBox(height: AppSpacing.sm),
      ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _NotificationRow(item: item),
          )),
      const SizedBox(height: AppSpacing.lg),
    ];
  }
}

class _NotificationRow extends StatelessWidget {
  const _NotificationRow({required this.item});
  final NotificationItem item;

  (IconData, Color, Color?) get _style => switch (item.tone) {
        NotificationTone.dueSoon => (Icons.access_time, AppColors.warning, AppColors.warningBg),
        NotificationTone.overdue => (Icons.warning_amber_rounded, AppColors.danger, AppColors.dangerBg),
        NotificationTone.info => (Icons.check_circle_outline, AppColors.primary, null),
      };

  @override
  Widget build(BuildContext context) {
    final (icon, fg, bg) = _style;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: bg ?? AppColors.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: fg, size: 22),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: AppTextStyles.bodyLg),
                Text(item.action, style: AppTextStyles.caption),
                Text(item.timeLabel, style: AppTextStyles.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}