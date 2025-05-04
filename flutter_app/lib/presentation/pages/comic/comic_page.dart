import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/mahas_utils.dart';
import '../../../data/models/complete_comic_model.dart';
import '../../riverpod/comic/comic_provider.dart';
import '../../riverpod/comic/comic_state.dart';
import '../../widgets/skeletons/comic_detail_skeleton.dart';
import '../../../core/mahas/widget/mahas_tab.dart';

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
          return _buildErrorState(context, "Comic not found", ref);
        }
        return _buildSuccessState(context, state, ref);

      case ComicStateStatus.error:
        return _buildErrorState(context, state.errorMessage, ref);
    }
  }

  Widget _buildSuccessState(
      BuildContext context, ComicState state, WidgetRef ref) {
    // Menggunakan state.selectedComic sebagai CompleteComic
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
                Icons.arrow_back,
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
            if (comic != null) _buildComicHeader(context, comic),

            // Action buttons (Read, Bookmark, Add to Reading List)
            if (comic != null) _buildActionButtons(context, comic),

            // Comic metadata (genres, authors, artists, format)
            if (comic != null) _buildMetadataSection(context, comic),

            // Comic description
            if (comic != null) _buildInfoSection(context, comic),

            // Tab bar for chapters, info, and comments
            // Tab bar and content
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: MahasPillTabBar(
                tabLabels: const ['Chapters', 'Info', 'Comments'],
                activeColor: Colors.purple,
                backgroundColor: Colors.grey.shade200,
                activeTextColor: Colors.white,
                inactiveTextColor: Colors.black87,
                tabViews: [
                  // Chapters tab
                  _buildChaptersTab(context),

                  // Info tab (more detailed information)
                  comic != null
                      ? _buildInfoTab(context, comic)
                      : const Center(child: Text('Comic info not available')),

                  // Comments tab
                  _buildCommentsTab(context),
                ],
                onTabChanged: (index) {
                  // Load data for the selected tab if needed
                  if (index == 0) {
                    // Chapters tab
                    // Chapter tab implementation akan ditambahkan nanti
                  }
                  // Implementasi untuk tab komentar akan ditambahkan nanti
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComicHeader(BuildContext context, CompleteComic completeComic) {
    final comic = completeComic.comic;
    final alternativeTitle = comic.alternativeTitle;

    return Container(
      color: Colors.black,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Cover image
          Container(
            width: 180,
            height: 240,
            margin: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                comic.coverImageUrl ?? '',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[800],
                    child: const Icon(Icons.broken_image,
                        color: Colors.white, size: 40),
                  );
                },
              ),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              comic.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Alternative title if available
          if (alternativeTitle != null && alternativeTitle.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Text(
                alternativeTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            )
          else
            const SizedBox(height: 16),

          // Stats row
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStatItem(
                    Icons.star, Colors.amber, '${comic.voteCount / 100}'),
                const SizedBox(width: 24),
                _buildStatItem(Icons.remove_red_eye, Colors.blue,
                    '${comic.viewCount / 1000}k'),
                const SizedBox(width: 24),
                _buildStatItem(Icons.emoji_events, Colors.purple,
                    '${comic.bookmarkCount}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, Color color, String value) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildActionButtons(
      BuildContext context, CompleteComic completeComic) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Consumer(builder: (context, ref, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Read button
            ElevatedButton.icon(
              onPressed: () {
                // Get comic ID from arguments
                final String? comicId = Mahas.argument<String>('comicId');
                // Use Provider to get chapters
                final state = ref.read(comicProvider);
                final chapterList = state.chapterList;

                // Navigate to first chapter if available
                if (comicId != null &&
                    chapterList != null &&
                    chapterList.data.isNotEmpty) {
                  // Logic untuk navigasi ke chapter pertama
                  // Contoh: Mahas.routeTo('/chapter', arguments: {'chapterId': chapterList.data.first.id});
                }
              },
              icon: const Icon(Icons.menu_book_rounded),
              label: const Text('Read'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Bookmark and Add to Reading List buttons
            Row(
              children: [
                // Bookmark button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Toggle bookmark status
                    },
                    icon: const Icon(Icons.bookmark_border),
                    label: const Text('Bookmark'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.grey),
                      minimumSize: const Size(0, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Add to Reading List button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Add to reading list
                    },
                    icon: const Icon(Icons.list),
                    label: const Text('Tambah ke Readlist'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.grey),
                      minimumSize: const Size(0, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }

  Widget _buildMetadataSection(
      BuildContext context, CompleteComic completeComic) {
    final comic = completeComic.comic;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description
          if (comic.synopsis != null && comic.synopsis!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                comic.synopsis!,
                style: TextStyle(
                  color: AppColors.getTextPrimaryColor(context),
                  fontSize: 14,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),

          // Genres
          if (comic.genres != null && comic.genres!.isNotEmpty)
            _buildMetadataRow(
                'Genre', comic.genres!.map((g) => g.name).join(', ')),

          // Authors
          if (comic.authors != null && comic.authors!.isNotEmpty)
            _buildMetadataRow(
                'Author', comic.authors!.map((a) => a.name).join(', ')),

          // Artists
          if (comic.artists != null && comic.artists!.isNotEmpty)
            _buildMetadataRow(
                'Artist', comic.artists!.map((a) => a.name).join(', ')),

          // Format
          if (comic.formats != null && comic.formats!.isNotEmpty)
            _buildMetadataRow(
                'Format', comic.formats!.map((f) => f.name).join(', ')),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildMetadataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, CompleteComic completeComic) {
    final comic = completeComic.comic;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Read more button for description
          if (comic.synopsis != null && comic.synopsis!.isNotEmpty)
            TextButton(
              onPressed: () {
                // Show full description dialog
              },
              child: const Text('... Read More'),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildChaptersTab(BuildContext context) {
    // Get comic ID from argument

    return Consumer(builder: (context, ref, _) {
      final state = ref.watch(comicProvider);
      final chapterList = state.chapterList;

      // Show chapters if available
      if (chapterList != null && chapterList.data.isNotEmpty) {
        // Navigate to chapter
        // Contoh: Mahas.routeTo('/chapter', arguments: {'chapterId': chapterList.data.first.id});
      }

      // Placeholder untuk tab chapter
      // Implementasi lengkap akan ditambahkan nanti setelah ChapterListProvider dibuat
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.list, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Daftar chapter akan segera hadir',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Implementasi akan ditambahkan nanti
              },
              child: const Text('Muat Chapter'),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildInfoTab(BuildContext context, CompleteComic completeComic) {
    final comic = completeComic.comic;
    return Consumer(builder: (context, ref, _) {
      final state = ref.watch(comicProvider);
      final chapterCount = state.chapterList?.data.length ?? 0;

      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoItem('Status', comic.status ?? 'Unknown'),
              _buildInfoItem(
                  'Released',
                  comic.createdDate != null
                      ? '${comic.createdDate!.year}'
                      : 'Unknown'),
              _buildInfoItem('Total Chapters', '$chapterCount'),
              _buildInfoItem('Views', '${comic.viewCount}'),
              _buildInfoItem('Bookmarks', '${comic.bookmarkCount}'),
              _buildInfoItem('Votes', '${comic.voteCount}'),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsTab(BuildContext context) {
    // Get comic ID from arguments
    final String? comicId = Mahas.argument<String>('comicId');

    // Placeholder untuk tab komentar
    // Implementasi lengkap akan ditambahkan nanti
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.comment, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Komentar akan segera hadir',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Lihat komentar untuk komik ${comicId ?? "ini"}',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
      BuildContext context, String? errorMessage, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 60,
          ),
          const SizedBox(height: 16),
          Text(
            errorMessage ?? 'An error occurred',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Retry loading comic details
              ref.read(comicProvider.notifier).fetchComicDetails();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
