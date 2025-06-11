import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/mahas/widget/mahas_tab.dart';
import '../../riverpod/search/search_provider.dart';
import 'widget/search_bar_widget.dart';
import 'widget/search_tab_grid.dart';

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

class SearchPageContent extends StatelessWidget {
  const SearchPageContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
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
              Expanded(
                child: SearchTabGrid(
                  config: SearchTabConfigs.searchResults(ref),
                ),
              ),
            ],
          );
        }

        // Default view with tabs
        return MahasPillTabBar(
          tabLabels: const ['Popular', 'All Comics'],
          tabViews: [
            SearchTabGrid(
              config: SearchTabConfigs.popular(ref),
            ),
            SearchTabGrid(
              config: SearchTabConfigs.allManga(ref),
            ),
          ],
          borderRadius: 12,
          activeColor: AppColors.getCardColor(context),
          backgroundColor: Colors.grey.shade200,
          activeTextColor: Colors.white,
          inactiveTextColor: Colors.black87,
        );
      },
    );
  }
}
