import 'package:flutter/material.dart';
import '../../../core/mahas/widget/mahas_tab.dart';
import '../../../core/theme/app_colors.dart';
import 'widget/all_comics_tab.dart';
import 'widget/discover_tab.dart';

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
      body: MahasPillTabBar(
        tabLabels: const ['Comics', 'Discover'],
        tabViews: const [
          AllComicsTab(),
          DiscoverTab(),
        ],
        activeColor: AppColors.getCardColor(context),
        backgroundColor: Colors.grey.shade200,
        activeTextColor: Colors.white,
        inactiveTextColor: Colors.black87,
        borderRadius: 12,
      ),
    );
  }
}
