import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_bottom_nav_bar.dart';
import '../../../../core/widgets/app_gradient_scaffold.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../data/datasources/book_mock_datasource.dart';
import '../../domain/repositories/book_repository_impl.dart';
import '../../domain/entities/book.dart';
import '../../domain/usecases/get_books.dart';
import '../widgets/book_card.dart';
import '../screens/book_details_screen.dart';

enum _LoadState { loading, success, empty, error }

// TEMPORARY — Borrowings and Profile screens don't exist yet, so those
// tabs just show a placeholder. Replace with real routing once those
// screens land.
const List<AppNavItem> _navItems = [
  AppNavItem(icon: Icons.menu_book_outlined, selectedIcon: Icons.menu_book, label: 'Books'),
  AppNavItem(icon: Icons.assignment_outlined, selectedIcon: Icons.assignment, label: 'Borrowings'),
  AppNavItem(icon: Icons.person_outline, selectedIcon: Icons.person, label: 'Profile'),
];

class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key});

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  // TEMPORARY manual wiring — a real composition root lands in the
  // Dependency Injection phase. Until then, every screen builds its own
  // dependencies like this, which is fine for one feature but won't
  // scale past a couple of screens without duplicating this setup.
  final GetBooks _getBooks = GetBooks(BookRepositoryImpl(BookMockDataSource()));

  _LoadState _state = _LoadState.loading;
  List<Book> _books = [];
  String? _errorMessage;
  int _selectedNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _state = _LoadState.loading);
    final result = await _getBooks();
    result.match(
      (failure) => setState(() {
        _errorMessage = 'Could not load books. Please try again.';
        _state = _LoadState.error;
      }),
      (books) => setState(() {
        _books = books;
        _state = books.isEmpty ? _LoadState.empty : _LoadState.success;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppGradientScaffold(
      body: _selectedNavIndex == 0 ? _buildBooksTab() : _buildPlaceholderTab(),
      bottomNavigationBar: AppBottomNavBar(
        items: _navItems,
        currentIndex: _selectedNavIndex,
        onTap: (i) => setState(() => _selectedNavIndex = i),
      ),
    );
  }

  Widget _buildBooksTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // TODO(auth): replace with the signed-in member's name once
        // the Auth feature provides a session.
        Text('Good Evening', style: AppTextStyles.bodyMd),
        Text('Amaya Perera', style: AppTextStyles.headingLg),
        const SizedBox(height: AppSpacing.lg),
        const AppTextField(label: '', hintText: 'Search books...'), // wiring comes in the Search phase
        const SizedBox(height: AppSpacing.lg),
        Text('All Books', style: AppTextStyles.headingMd),
        const SizedBox(height: AppSpacing.md),
        Expanded(child: _buildBody()),
      ],
    );
  }

  Widget _buildPlaceholderTab() {
    return EmptyView(message: '${_navItems[_selectedNavIndex].label} is coming soon.');
  }

  Widget _buildBody() {
    switch (_state) {
      case _LoadState.loading:
        return const LoadingView();
      case _LoadState.error:
        return ErrorView(message: _errorMessage!, onRetry: _load);
      case _LoadState.empty:
        return const EmptyView(message: 'No books available yet.');
      case _LoadState.success:
        return ListView.separated(
          itemCount: _books.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, i) {
            final book = _books[i];
            return BookCard(
              book: book,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => BookDetailsScreen(bookId: book.id)),
              ),
            );
          },
        );
    }
  }
}