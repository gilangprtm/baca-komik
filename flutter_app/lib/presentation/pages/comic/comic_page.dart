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
    return Consumer(builder: (context, ref, _) {
      // Watch the comic provider state
      final comicState = ref.watch(comicProvider);

      return Scaffold(
        body: _buildBody(context, comicState, ref),
      );
    });
  }

  Widget _buildBody(BuildContext context, ComicState state, WidgetRef ref) {
    switch (state.detailStatus) {
      case ComicStateStatus.initial:
      case ComicStateStatus.loading:
        return const ComicDetailSkeleton();

      case ComicStateStatus.success:
        if (state.selectedComic == null) {
          return ComicErrorWidget(errorMessage: "Comic not found");
        }
        return _buildSuccessState(context, state, ref);

      case ComicStateStatus.error:
        return ComicErrorWidget(errorMessage: state.errorMessage);
    }
  }

  Widget _buildSuccessState(
      BuildContext context, ComicState state, WidgetRef ref) {
    final CompleteComic? comic = state.selectedComic;

    return NestedScrollView(
      controller: ScrollController(),
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverAppBar(
            expandedHeight: 0,
            pinned: true,
            backgroundColor: AppColors.getBackgroundColor(context),
            title: Text(
              comic?.comic.title ?? 'Comic Detail',
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
          ),
        ];
      },
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Comic header with cover image and title
            if (comic != null) ComicHeader(completeComic: comic),

            // Action buttons (Read, Bookmark, Add to Reading List)
            if (comic != null) ComicActionButtons(completeComic: comic),

            // Comic metadata (genres, authors, artists, format)
            if (comic != null) ComicMetadata(completeComic: comic),

            // Tab bar for chapters, info, and comments
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: MahasPillTabBar(
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
                  comic != null
                      ? InfoTab(completeComic: comic)
                      : const Center(child: Text('Comic info not available')),

                  // Comments tab
                  const CommentsTab(),
                ],
                onTabChanged: (index) {
                  // Load data for the selected tab if needed
                  if (index == 0) {
                    // Chapters tab - already loaded in fetchComicDetails
                    final String? comicId = Mahas.argument<String>('comicId');
                    if (comicId != null) {
                      // Refresh chapters if needed
                      // ref.read(comicProvider.notifier).fetchComicChapters(comicId);
                    }
                  } else if (index == 2) {
                    // Comments tab
                    ref.read(comicProvider.notifier).fetchComments(1);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
