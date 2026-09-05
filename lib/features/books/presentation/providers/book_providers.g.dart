// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(bookLocalDataSource)
final bookLocalDataSourceProvider = BookLocalDataSourceProvider._();

final class BookLocalDataSourceProvider
    extends
        $FunctionalProvider<
          BookLocalDataSource,
          BookLocalDataSource,
          BookLocalDataSource
        >
    with $Provider<BookLocalDataSource> {
  BookLocalDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bookLocalDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bookLocalDataSourceHash();

  @$internal
  @override
  $ProviderElement<BookLocalDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BookLocalDataSource create(Ref ref) {
    return bookLocalDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BookLocalDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BookLocalDataSource>(value),
    );
  }
}

String _$bookLocalDataSourceHash() =>
    r'dd3c20b9a9012e4b388962f1918112d77adaba7b';

@ProviderFor(bookRepository)
final bookRepositoryProvider = BookRepositoryProvider._();

final class BookRepositoryProvider
    extends $FunctionalProvider<BookRepository, BookRepository, BookRepository>
    with $Provider<BookRepository> {
  BookRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bookRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bookRepositoryHash();

  @$internal
  @override
  $ProviderElement<BookRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BookRepository create(Ref ref) {
    return bookRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BookRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BookRepository>(value),
    );
  }
}

String _$bookRepositoryHash() => r'e8ab2fc6c704ebad56aaae5ce45e927d51733f29';

@ProviderFor(getBooksUseCase)
final getBooksUseCaseProvider = GetBooksUseCaseProvider._();

final class GetBooksUseCaseProvider
    extends $FunctionalProvider<GetBooks, GetBooks, GetBooks>
    with $Provider<GetBooks> {
  GetBooksUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getBooksUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getBooksUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetBooks> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GetBooks create(Ref ref) {
    return getBooksUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetBooks value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetBooks>(value),
    );
  }
}

String _$getBooksUseCaseHash() => r'ee11cd824425080f2ce5d3acf4fa3a5ea0132ba2';

@ProviderFor(getBookByIdUseCase)
final getBookByIdUseCaseProvider = GetBookByIdUseCaseProvider._();

final class GetBookByIdUseCaseProvider
    extends $FunctionalProvider<GetBookById, GetBookById, GetBookById>
    with $Provider<GetBookById> {
  GetBookByIdUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getBookByIdUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getBookByIdUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetBookById> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GetBookById create(Ref ref) {
    return getBookByIdUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetBookById value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetBookById>(value),
    );
  }
}

String _$getBookByIdUseCaseHash() =>
    r'9736b9250ea09876d047a7221f58e2a6907893a4';

/// AsyncNotifier because it's the generated-code equivalent of the old
/// FutureProvider — `build()` runs once, result is cached, and
/// `ref.invalidateSelf()` (or `ref.invalidate(bookListProvider)` from
/// outside) re-runs it. `.match()` unwraps the Either right here so
/// nothing downstream has to think about Left/Right — the UI only ever
/// sees a plain AsyncValue<List<Book>>, same as before this change.

@ProviderFor(BookList)
final bookListProvider = BookListProvider._();

/// AsyncNotifier because it's the generated-code equivalent of the old
/// FutureProvider — `build()` runs once, result is cached, and
/// `ref.invalidateSelf()` (or `ref.invalidate(bookListProvider)` from
/// outside) re-runs it. `.match()` unwraps the Either right here so
/// nothing downstream has to think about Left/Right — the UI only ever
/// sees a plain AsyncValue<List<Book>>, same as before this change.
final class BookListProvider
    extends $AsyncNotifierProvider<BookList, List<Book>> {
  /// AsyncNotifier because it's the generated-code equivalent of the old
  /// FutureProvider — `build()` runs once, result is cached, and
  /// `ref.invalidateSelf()` (or `ref.invalidate(bookListProvider)` from
  /// outside) re-runs it. `.match()` unwraps the Either right here so
  /// nothing downstream has to think about Left/Right — the UI only ever
  /// sees a plain AsyncValue<List<Book>>, same as before this change.
  BookListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bookListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bookListHash();

  @$internal
  @override
  BookList create() => BookList();
}

String _$bookListHash() => r'52ce048fc9bca2b243f4b51c67b094ecf35f8a0e';

/// AsyncNotifier because it's the generated-code equivalent of the old
/// FutureProvider — `build()` runs once, result is cached, and
/// `ref.invalidateSelf()` (or `ref.invalidate(bookListProvider)` from
/// outside) re-runs it. `.match()` unwraps the Either right here so
/// nothing downstream has to think about Left/Right — the UI only ever
/// sees a plain AsyncValue<List<Book>>, same as before this change.

abstract class _$BookList extends $AsyncNotifier<List<Book>> {
  FutureOr<List<Book>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Book>>, List<Book>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Book>>, List<Book>>,
              AsyncValue<List<Book>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(bookById)
final bookByIdProvider = BookByIdFamily._();

final class BookByIdProvider
    extends $FunctionalProvider<AsyncValue<Book>, Book, FutureOr<Book>>
    with $FutureModifier<Book>, $FutureProvider<Book> {
  BookByIdProvider._({
    required BookByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'bookByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$bookByIdHash();

  @override
  String toString() {
    return r'bookByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Book> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Book> create(Ref ref) {
    final argument = this.argument as String;
    return bookById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is BookByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$bookByIdHash() => r'62c450d3585a67cd654b86a6d532ac9d1a8a5cb8';

final class BookByIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Book>, String> {
  BookByIdFamily._()
    : super(
        retry: null,
        name: r'bookByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  BookByIdProvider call(String id) =>
      BookByIdProvider._(argument: id, from: this);

  @override
  String toString() => r'bookByIdProvider';
}
