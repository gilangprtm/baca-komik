import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/mahas_utils.dart';
import '../../../data/models/complete_comic_model.dart';
import '../../riverpod/comic/comic_provider.dart';
import '../../riverpod/comic/comic_state.dart';
import '../../widgets/skeletons/comic_detail_skeleton.dart';
import '../../../core/mahas/widget/mahas_tab.dart';
import 'widget/comic_header.dart';
import 'widget/comic_action_buttons.dart';
import 'widget/comic_metadata.dart';
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
class _ComicSuccessView extends ConsumerWidget {
  const _ComicSuccessView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only watch selectedComic for this view
    final comic = ref.watch(
      comicProvider.select((state) => state.selectedComic),
    );

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
            ComicHeader(completeComic: comic),

            // Action buttons (Read, Bookmark, Add to Reading List)
            ComicActionButtons(completeComic: comic),

            // Comic metadata (genres, authors, artists, format)
            ComicMetadata(completeComic: comic),

            // Tab bar for chapters, info, and comments
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.65,
              child: _ComicTabBar(comic: comic),
            ),
          ],
        ),
      ),
    );
  }
}

/// Optimized AppBar widget
class _ComicAppBar extends StatelessWidget {
  final CompleteComic comic;

  const _ComicAppBar({required this.comic});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 0,
      pinned: true,
      backgroundColor: AppColors.getBackgroundColor(context),
      title: Text(
        comic.comic.title,
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
class _ComicTabBar extends ConsumerWidget {
  final CompleteComic comic;

  const _ComicTabBar({required this.comic});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        InfoTab(completeComic: comic),

        // Comments tab
        const CommentsTab(),
      ],
      onTabChanged: (index) {
        // Load data for the selected tab if needed
        if (index == 2) {
          // Comments tab - only load when user switches to it
          ref.read(comicProvider.notifier).fetchComments(1);
        }
        // Note: Chapters are already loaded in fetchComicDetails
        // No need to reload unless specifically needed
      },
    );
  }
}
