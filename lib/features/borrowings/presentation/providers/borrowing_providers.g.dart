// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'borrowing_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(borrowingLocalDataSource)
final borrowingLocalDataSourceProvider = BorrowingLocalDataSourceProvider._();

final class BorrowingLocalDataSourceProvider
    extends
        $FunctionalProvider<
          BorrowingLocalDataSource,
          BorrowingLocalDataSource,
          BorrowingLocalDataSource
        >
    with $Provider<BorrowingLocalDataSource> {
  BorrowingLocalDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'borrowingLocalDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$borrowingLocalDataSourceHash();

  @$internal
  @override
  $ProviderElement<BorrowingLocalDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BorrowingLocalDataSource create(Ref ref) {
    return borrowingLocalDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BorrowingLocalDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BorrowingLocalDataSource>(value),
    );
  }
}

String _$borrowingLocalDataSourceHash() =>
    r'5e4b71babc1315fb5706d1c12e5b55b85bb07792';

@ProviderFor(borrowingRepository)
final borrowingRepositoryProvider = BorrowingRepositoryProvider._();

final class BorrowingRepositoryProvider
    extends
        $FunctionalProvider<
          BorrowingRepository,
          BorrowingRepository,
          BorrowingRepository
        >
    with $Provider<BorrowingRepository> {
  BorrowingRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'borrowingRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$borrowingRepositoryHash();

  @$internal
  @override
  $ProviderElement<BorrowingRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BorrowingRepository create(Ref ref) {
    return borrowingRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BorrowingRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BorrowingRepository>(value),
    );
  }
}

String _$borrowingRepositoryHash() =>
    r'5b41173be0c1774bebdab512a971436db1534313';

@ProviderFor(borrowBookUseCase)
final borrowBookUseCaseProvider = BorrowBookUseCaseProvider._();

final class BorrowBookUseCaseProvider
    extends $FunctionalProvider<BorrowBook, BorrowBook, BorrowBook>
    with $Provider<BorrowBook> {
  BorrowBookUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'borrowBookUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$borrowBookUseCaseHash();

  @$internal
  @override
  $ProviderElement<BorrowBook> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BorrowBook create(Ref ref) {
    return borrowBookUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BorrowBook value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BorrowBook>(value),
    );
  }
}

String _$borrowBookUseCaseHash() => r'6c55e1eefdd828effcd5c53d536979750f9f9f0a';

@ProviderFor(returnBorrowingUseCase)
final returnBorrowingUseCaseProvider = ReturnBorrowingUseCaseProvider._();

final class ReturnBorrowingUseCaseProvider
    extends
        $FunctionalProvider<ReturnBorrowing, ReturnBorrowing, ReturnBorrowing>
    with $Provider<ReturnBorrowing> {
  ReturnBorrowingUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'returnBorrowingUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$returnBorrowingUseCaseHash();

  @$internal
  @override
  $ProviderElement<ReturnBorrowing> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ReturnBorrowing create(Ref ref) {
    return returnBorrowingUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReturnBorrowing value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReturnBorrowing>(value),
    );
  }
}

String _$returnBorrowingUseCaseHash() =>
    r'c7dbd90d8400c43b826ce75b5527c6035ed4120c';

/// Re-derives memberId from the current session on every (re)build — if a
/// different member ever logs in during the same app lifetime, this
/// naturally refetches for them instead of leaking the previous
/// member's data forward.

@ProviderFor(myBorrowings)
final myBorrowingsProvider = MyBorrowingsProvider._();

/// Re-derives memberId from the current session on every (re)build — if a
/// different member ever logs in during the same app lifetime, this
/// naturally refetches for them instead of leaking the previous
/// member's data forward.

final class MyBorrowingsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Borrowing>>,
          List<Borrowing>,
          FutureOr<List<Borrowing>>
        >
    with $FutureModifier<List<Borrowing>>, $FutureProvider<List<Borrowing>> {
  /// Re-derives memberId from the current session on every (re)build — if a
  /// different member ever logs in during the same app lifetime, this
  /// naturally refetches for them instead of leaking the previous
  /// member's data forward.
  MyBorrowingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myBorrowingsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myBorrowingsHash();

  @$internal
  @override
  $FutureProviderElement<List<Borrowing>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Borrowing>> create(Ref ref) {
    return myBorrowings(ref);
  }
}

String _$myBorrowingsHash() => r'7845832e57ec6620049487970dd3668ac2c1c6a3';

@ProviderFor(borrowingById)
final borrowingByIdProvider = BorrowingByIdFamily._();

final class BorrowingByIdProvider
    extends
        $FunctionalProvider<
          AsyncValue<Borrowing>,
          Borrowing,
          FutureOr<Borrowing>
        >
    with $FutureModifier<Borrowing>, $FutureProvider<Borrowing> {
  BorrowingByIdProvider._({
    required BorrowingByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'borrowingByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$borrowingByIdHash();

  @override
  String toString() {
    return r'borrowingByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Borrowing> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Borrowing> create(Ref ref) {
    final argument = this.argument as String;
    return borrowingById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is BorrowingByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$borrowingByIdHash() => r'17cf3880565ce55ad7d80f11966bc80dd9556f69';

final class BorrowingByIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Borrowing>, String> {
  BorrowingByIdFamily._()
    : super(
        retry: null,
        name: r'borrowingByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  BorrowingByIdProvider call(String id) =>
      BorrowingByIdProvider._(argument: id, from: this);

  @override
  String toString() => r'borrowingByIdProvider';
}

/// One-shot action state for the Confirm Borrowing screen. Deliberately
/// plain @riverpod (autoDispose) — unlike the data-holding providers
/// above, fresh state each time you open Confirm for a different book is
/// exactly what's wanted here, not a bug to guard against.

@ProviderFor(BorrowActionController)
final borrowActionControllerProvider = BorrowActionControllerProvider._();

/// One-shot action state for the Confirm Borrowing screen. Deliberately
/// plain @riverpod (autoDispose) — unlike the data-holding providers
/// above, fresh state each time you open Confirm for a different book is
/// exactly what's wanted here, not a bug to guard against.
final class BorrowActionControllerProvider
    extends $AsyncNotifierProvider<BorrowActionController, Borrowing?> {
  /// One-shot action state for the Confirm Borrowing screen. Deliberately
  /// plain @riverpod (autoDispose) — unlike the data-holding providers
  /// above, fresh state each time you open Confirm for a different book is
  /// exactly what's wanted here, not a bug to guard against.
  BorrowActionControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'borrowActionControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$borrowActionControllerHash();

  @$internal
  @override
  BorrowActionController create() => BorrowActionController();
}

String _$borrowActionControllerHash() =>
    r'4ffd1438557aa0c0c9cb80ed5eff67af18e413d2';

/// One-shot action state for the Confirm Borrowing screen. Deliberately
/// plain @riverpod (autoDispose) — unlike the data-holding providers
/// above, fresh state each time you open Confirm for a different book is
/// exactly what's wanted here, not a bug to guard against.

abstract class _$BorrowActionController extends $AsyncNotifier<Borrowing?> {
  FutureOr<Borrowing?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Borrowing?>, Borrowing?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Borrowing?>, Borrowing?>,
              AsyncValue<Borrowing?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(ReturnActionController)
final returnActionControllerProvider = ReturnActionControllerProvider._();

final class ReturnActionControllerProvider
    extends $AsyncNotifierProvider<ReturnActionController, Borrowing?> {
  ReturnActionControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'returnActionControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$returnActionControllerHash();

  @$internal
  @override
  ReturnActionController create() => ReturnActionController();
}

String _$returnActionControllerHash() =>
    r'eb8d12e5dce9df0c5b8ad79deab69e1ad813f70a';

abstract class _$ReturnActionController extends $AsyncNotifier<Borrowing?> {
  FutureOr<Borrowing?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Borrowing?>, Borrowing?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Borrowing?>, Borrowing?>,
              AsyncValue<Borrowing?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
