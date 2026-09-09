// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(memberLocalDataSource)
final memberLocalDataSourceProvider = MemberLocalDataSourceProvider._();

final class MemberLocalDataSourceProvider
    extends
        $FunctionalProvider<
          MemberLocalDataSource,
          MemberLocalDataSource,
          MemberLocalDataSource
        >
    with $Provider<MemberLocalDataSource> {
  MemberLocalDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'memberLocalDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$memberLocalDataSourceHash();

  @$internal
  @override
  $ProviderElement<MemberLocalDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MemberLocalDataSource create(Ref ref) {
    return memberLocalDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MemberLocalDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MemberLocalDataSource>(value),
    );
  }
}

String _$memberLocalDataSourceHash() =>
    r'0dfebab44665bce4b175d9b621d17d6f2358ae63';

@ProviderFor(memberRepository)
final memberRepositoryProvider = MemberRepositoryProvider._();

final class MemberRepositoryProvider
    extends
        $FunctionalProvider<
          MemberRepository,
          MemberRepository,
          MemberRepository
        >
    with $Provider<MemberRepository> {
  MemberRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'memberRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$memberRepositoryHash();

  @$internal
  @override
  $ProviderElement<MemberRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MemberRepository create(Ref ref) {
    return memberRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MemberRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MemberRepository>(value),
    );
  }
}

String _$memberRepositoryHash() => r'53f11bd683eff9f008f0c5160de3e91675ce5e70';

@ProviderFor(getMemberUseCase)
final getMemberUseCaseProvider = GetMemberUseCaseProvider._();

final class GetMemberUseCaseProvider
    extends $FunctionalProvider<GetMember, GetMember, GetMember>
    with $Provider<GetMember> {
  GetMemberUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getMemberUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getMemberUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetMember> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GetMember create(Ref ref) {
    return getMemberUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetMember value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetMember>(value),
    );
  }
}

String _$getMemberUseCaseHash() => r'090bc18ea3f3be0ab9b72f408c7b53f422286d2d';

@ProviderFor(updateMemberUseCase)
final updateMemberUseCaseProvider = UpdateMemberUseCaseProvider._();

final class UpdateMemberUseCaseProvider
    extends $FunctionalProvider<UpdateMember, UpdateMember, UpdateMember>
    with $Provider<UpdateMember> {
  UpdateMemberUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updateMemberUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updateMemberUseCaseHash();

  @$internal
  @override
  $ProviderElement<UpdateMember> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UpdateMember create(Ref ref) {
    return updateMemberUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpdateMember value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpdateMember>(value),
    );
  }
}

String _$updateMemberUseCaseHash() =>
    r'c2fe2a2d8a3207fd9e8a6b4a5e1fd4e95fab8ba5';

/// The signed-in user's own profile — Admin or Member alike, same
/// provider, since the mobile app treats both identically per the scope
/// we settled on. Re-derives from the current session, same pattern as
/// myBorrowingsProvider.

@ProviderFor(myProfile)
final myProfileProvider = MyProfileProvider._();

/// The signed-in user's own profile — Admin or Member alike, same
/// provider, since the mobile app treats both identically per the scope
/// we settled on. Re-derives from the current session, same pattern as
/// myBorrowingsProvider.

final class MyProfileProvider
    extends $FunctionalProvider<AsyncValue<Member?>, Member?, FutureOr<Member?>>
    with $FutureModifier<Member?>, $FutureProvider<Member?> {
  /// The signed-in user's own profile — Admin or Member alike, same
  /// provider, since the mobile app treats both identically per the scope
  /// we settled on. Re-derives from the current session, same pattern as
  /// myBorrowingsProvider.
  MyProfileProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myProfileProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myProfileHash();

  @$internal
  @override
  $FutureProviderElement<Member?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Member?> create(Ref ref) {
    return myProfile(ref);
  }
}

String _$myProfileHash() => r'e9deb19a9b4a085db50f0ff68b5c528d888f48bc';

@ProviderFor(EditProfileController)
final editProfileControllerProvider = EditProfileControllerProvider._();

final class EditProfileControllerProvider
    extends $AsyncNotifierProvider<EditProfileController, Member?> {
  EditProfileControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'editProfileControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$editProfileControllerHash();

  @$internal
  @override
  EditProfileController create() => EditProfileController();
}

String _$editProfileControllerHash() =>
    r'0e9283b752ff04551949ea280754b133d0dee37d';

abstract class _$EditProfileController extends $AsyncNotifier<Member?> {
  FutureOr<Member?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Member?>, Member?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Member?>, Member?>,
              AsyncValue<Member?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
