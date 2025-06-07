import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/mahas_utils.dart';
import '../../../riverpod/chapter/chapter_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Widget for displaying loading state
class ChapterLoadingWidget extends StatelessWidget {
  const ChapterLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

/// Widget for displaying error state
class ChapterErrorWidget extends StatelessWidget {
  const ChapterErrorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final notifier = ref.read(chapterProvider.notifier);

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
      },
    );
  }
}

/// Widget for displaying empty state
class ChapterEmptyWidget extends StatelessWidget {
  const ChapterEmptyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
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
              color: AppColors.white,
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
    );
  }
}
