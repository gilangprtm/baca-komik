import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/mahas_utils.dart';
import '../../../data/models/shinigami/shinigami_models.dart';
import '../../riverpod/comic/comic_provider.dart';
import '../../riverpod/comic/comic_state.dart';
import '../../widgets/skeletons/comic_detail_skeleton.dart';
import '../../../core/mahas/widget/mahas_tab.dart';
import 'widget/comic_header.dart';
import 'widget/comic_action_buttons.dart';
import 'widget/chapters_tab.dart';
import 'widget/info_tab.dart';
import 'widget/comments_tab.dart';
import 'widget/error_widget.dart';

class ComicPage extends StatelessWidget {
  const ComicPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer(
        builder: (context, ref, _) {
          // Only watch detailStatus to minimize rebuilds
          final detailStatus = ref.watch(
            comicProvider.select((state) => state.detailStatus),
          );

          switch (detailStatus) {
            case ComicStateStatus.initial:
            case ComicStateStatus.loading:
              return const ComicDetailSkeleton();

            case ComicStateStatus.success:
              return const _ComicSuccessView();

            case ComicStateStatus.error:
              return Consumer(
                builder: (context, ref, _) {
                  final errorMessage = ref.watch(
                    comicProvider.select((state) => state.errorMessage),
                  );
                  return ComicErrorWidget(errorMessage: errorMessage);
                },
              );
          }
        },
      ),
    );
  }
}

/// Separate widget for success state to optimize rebuilds
class _ComicSuccessView extends StatelessWidget {
  const _ComicSuccessView();

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        // Only watch selectedComic for this view
        final comic = ref.watch(comicDetailProvider);

        if (comic == null) {
          return const ComicErrorWidget(errorMessage: "Comic not found");
        }

        return NestedScrollView(
          controller: ScrollController(),
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              _ComicAppBar(comic: comic),
            ];
          },
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Comic header with cover image and title
                ComicHeader(manga: comic),

                // Action buttons (Read, Bookmark, Add to Reading List)
                ComicActionButtons(manga: comic),

                // Tab bar for chapters, info, and comments
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.65,
                  child: _ComicTabBar(comic: comic),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Optimized AppBar widget
class _ComicAppBar extends StatelessWidget {
  final ShinigamiManga comic;

  const _ComicAppBar({required this.comic});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 0,
      pinned: true,
      backgroundColor: AppColors.getBackgroundColor(context),
      title: Text(
        comic.title,
        style: TextStyle(
          color: AppColors.getTextPrimaryColor(context),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          color: AppColors.getTextPrimaryColor(context),
        ),
        onPressed: () => Mahas.back(),
      ),
    );
  }
}

/// Optimized TabBar widget
class _ComicTabBar extends StatelessWidget {
  final ShinigamiManga comic;

  const _ComicTabBar({required this.comic});

  @override
  Widget build(BuildContext context) {
    return MahasPillTabBar(
      borderRadius: 12,
      tabLabels: const ['Chapters', 'Info', 'Comments'],
      activeColor: AppColors.getCardColor(context),
      backgroundColor: Colors.grey.shade200,
      activeTextColor: Colors.white,
      inactiveTextColor: Colors.black87,
      tabViews: [
        // Chapters tab
        const ChaptersTab(),

        // Info tab (more detailed information)
        InfoTab(manga: comic),

        // Comments tab (coming soon)
        const CommentsTab(),
      ],
      onTabChanged: (index) {
        // Load data for the selected tab if needed
        // Note: Chapters are already loaded in fetchComicDetails
        // No need to reload unless specifically needed
      },
    );
  }
}
