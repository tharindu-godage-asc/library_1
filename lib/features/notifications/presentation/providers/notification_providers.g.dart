// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Reshapes existing Borrowings + Books data into notification-style
/// rows. If a real notifications endpoint ever exists (Phase 18+), this
/// file is what changes — the screen below wouldn't need to.

@ProviderFor(notificationItems)
final notificationItemsProvider = NotificationItemsProvider._();

/// Reshapes existing Borrowings + Books data into notification-style
/// rows. If a real notifications endpoint ever exists (Phase 18+), this
/// file is what changes — the screen below wouldn't need to.

final class NotificationItemsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<NotificationItem>>,
          List<NotificationItem>,
          FutureOr<List<NotificationItem>>
        >
    with
        $FutureModifier<List<NotificationItem>>,
        $FutureProvider<List<NotificationItem>> {
  /// Reshapes existing Borrowings + Books data into notification-style
  /// rows. If a real notifications endpoint ever exists (Phase 18+), this
  /// file is what changes — the screen below wouldn't need to.
  NotificationItemsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationItemsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationItemsHash();

  @$internal
  @override
  $FutureProviderElement<List<NotificationItem>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<NotificationItem>> create(Ref ref) {
    return notificationItems(ref);
  }
}

String _$notificationItemsHash() => r'036fe1c066d970373e85c01cd2b453092a8abe42';
