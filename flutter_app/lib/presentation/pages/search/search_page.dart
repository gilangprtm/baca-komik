import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/mahas/widget/mahas_tab.dart';
import '../../riverpod/search/search_provider.dart';
import 'widget/search_bar_widget.dart';
import 'widget/popular_tab.dart';
import 'widget/all_manga_tab.dart';
import 'widget/search_results_tab.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Comics'),
        backgroundColor: AppColors.getBackgroundColor(context),
        elevation: 0,
      ),
      body: const Column(
        children: [
          // Search bar
          SearchBarWidget(),

          // Content with tabs
          Expanded(
            child: SearchPageContent(),
          ),
        ],
      ),
    );
  }
}

class SearchPageContent extends ConsumerWidget {
  const SearchPageContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch search query to determine if we should show search results
    final searchQuery = ref.watch(
      searchProvider.select((state) => state.query),
    );
    final hasSearchQuery = searchQuery.isNotEmpty;

    // If user is searching, show search results
    if (hasSearchQuery) {
      return Column(
        children: [
          // Search results content
          const Expanded(
            child: SearchResultsTab(),
          ),
        ],
      );
    }

    // Default view with tabs
    return MahasPillTabBar(
      tabLabels: const ['Popular', 'All Comics'],
      tabViews: [
        const PopularTab(),
        const AllMangaTab(),
      ],
      borderRadius: 12,
      activeColor: AppColors.getCardColor(context),
      backgroundColor: Colors.grey.shade200,
      activeTextColor: Colors.white,
      inactiveTextColor: Colors.black87,
    );
  }
}
