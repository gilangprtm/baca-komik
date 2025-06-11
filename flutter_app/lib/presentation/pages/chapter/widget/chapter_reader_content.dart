import 'package:flutter/material.dart';
import 'package:flutter_project/core/base/global_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../riverpod/chapter/chapter_provider.dart';

/// Widget for displaying chapter pages content
class ChapterReaderContent extends StatelessWidget {
  const ChapterReaderContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final pages = ref.watch(
          chapterProvider.select((state) => state.pages),
        );

        final notifier = ref.read(chapterProvider.notifier);

        // Filter out pages with invalid URLs
        final validPages = pages
            .where((page) =>
                page.imageUrl.isNotEmpty && Uri.tryParse(page.imageUrl) != null)
            .toList();

        if (validPages.isEmpty) {
          return GestureDetector(
            onTap: () {
              notifier.toggleReaderControls();
            },
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.image_not_supported,
                    color: Colors.grey,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No pages available',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This chapter doesn\'t have any pages yet',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return GestureDetector(
          onTap: () {
            notifier.toggleReaderControls();
          },
          child: ListView.builder(
            itemCount: validPages.length,
            itemBuilder: (context, index) {
              final page = validPages[index];

              return CachedNetworkImage(
                httpHeaders: {
                  'User-Agent':
                      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36',
                  'Origin': GlobalState.refererUrl,
                  'Referer': GlobalState.refererUrl + '/',
                  'Sec-Fetch-Dest': 'empty',
                },
                imageUrl: page.imageUrl,
                fit: BoxFit.contain,
                placeholder: (context, url) => Container(
                  height: 200,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) {
                  return Container(
                    height: 200,
                    color: Colors.grey[800],
                    child: Center(
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
                            'Failed to load page ${page.pageNumber}',
                            style: const TextStyle(color: Colors.white),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () {
                              // Retry by rebuilding the widget
                              // notifier.toggleReaderControls();
                              // notifier.toggleReaderControls();
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
