import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/mahas_utils.dart';
import '../../riverpod/chapter/chapter_provider.dart';
import '../../riverpod/chapter/chapter_state.dart';

class ChapterPage extends StatelessWidget {
  const ChapterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Consumer(
        builder: (context, ref, _) {
          // Select only the necessary parts of the state
          final status = ref.watch(
            chapterProvider.select((state) => state.status),
          );
          final pages = ref.watch(
            chapterProvider.select((state) => state.pages),
          );
          final currentPageIndex = ref.watch(
            chapterProvider.select((state) => state.currentPageIndex),
          );
          final chapter = ref.watch(
            chapterProvider.select((state) => state.chapter),
          );
          final isFirstPage = ref.watch(
            chapterProvider.select((state) => state.isFirstPage),
          );
          final isLastPage = ref.watch(
            chapterProvider.select((state) => state.isLastPage),
          );

          final notifier = ref.read(chapterProvider.notifier);
          final showControls = ref.watch(
            chapterProvider.select((state) => state.isReaderControlsVisible),
          );

          // Handle loading state
          if (status == ChapterStateStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Handle error state
          if (status == ChapterStateStatus.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Error loading chapter',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      final chapterId = Mahas.argument<String>('chapterId');
                      if (chapterId != null) {
                        notifier.fetchChapterDetails(chapterId);
                      }
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Handle empty state
          if (pages.isEmpty) {
            return const Center(
              child: Text(
                'No pages found',
                style: TextStyle(color: AppColors.white),
              ),
            );
          }

          return Stack(
            children: [
              // Main Content
              GestureDetector(
                onTap: () => notifier.toggleReaderControls(),
                child: pages.isEmpty
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : ListView.builder(
                        itemCount: pages.length,
                        itemBuilder: (context, index) {
                          return CachedNetworkImage(
                            imageUrl: pages[index].imageUrl,
                            fit: BoxFit.contain,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            errorWidget: (context, url, error) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.error_outline,
                                      color: Colors.red,
                                      size: 48,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Failed to load page ${index + 1}',
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                    const SizedBox(height: 8),
                                    ElevatedButton(
                                      onPressed: () {
                                        // Retry loading the image
                                        notifier.jumpToPage(index);
                                      },
                                      child: const Text('Retry'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),

              // Page Indicator
              if (showControls && pages.isNotEmpty)
                Positioned(
                  bottom: 16,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${currentPageIndex + 1} / ${pages.length}',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),

              // Navigation Controls
              if (showControls)
                Positioned.fill(
                  child: Row(
                    children: [
                      // Left side tap area for previous page
                      Expanded(
                        child: GestureDetector(
                          onTap: isFirstPage
                              ? () => notifier.previousPage()
                              : () => notifier.jumpToPage(currentPageIndex - 1),
                          child: Container(
                            color: Colors.transparent,
                          ),
                        ),
                      ),
                      // Right side tap area for next page
                      Expanded(
                        child: GestureDetector(
                          onTap: isLastPage
                              ? () => notifier.nextPage()
                              : () => notifier.jumpToPage(currentPageIndex + 1),
                          child: Container(
                            color: Colors.transparent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // App Bar
              if (showControls)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: AppBar(
                    backgroundColor: Colors.black87,
                    title: Text(
                      chapter?.title ?? 'Chapter',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.fullscreen_exit),
                        onPressed: () => notifier.toggleReaderControls(),
                      ),
                    ],
                    elevation: 0,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
