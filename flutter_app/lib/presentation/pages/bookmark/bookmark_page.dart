import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/mahas/widget/mahas_tab.dart';
import 'widget/bookmark_tab.dart';
import 'widget/history_tab.dart';

class BookmarkPage extends StatelessWidget {
  const BookmarkPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Library'),
        backgroundColor: AppColors.getBackgroundColor(context),
        elevation: 0,
      ),
      body: const BookmarkPageContent(),
    );
  }
}

class BookmarkPageContent extends StatelessWidget {
  const BookmarkPageContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        return MahasPillTabBar(
          tabLabels: const ['Bookmarks', 'History'],
          tabViews: [
            BookmarkTab(),
            HistoryTab(),
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
