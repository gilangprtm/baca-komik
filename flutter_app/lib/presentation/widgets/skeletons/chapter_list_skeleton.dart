import 'package:flutter/material.dart';
import '../common/shimmer_loading.dart';

/// A skeleton loader for chapter list that mimics the layout of the actual chapter list
class ChapterListSkeleton extends StatelessWidget {
  final int itemCount;
  final EdgeInsetsGeometry padding;

  const ChapterListSkeleton({
    Key? key,
    this.itemCount = 10,
    this.padding = const EdgeInsets.all(8.0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: ListView.builder(
        padding: padding,
        itemCount: itemCount,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) => const ChapterItemSkeleton(),
      ),
    );
  }
}

/// A skeleton loader for a single chapter item
class ChapterItemSkeleton extends StatelessWidget {
  const ChapterItemSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Chapter thumbnail
            ShimmerContainer(
              width: 60,
              height: 60,
              borderRadius: 8,
            ),
            const SizedBox(width: 12),
            
            // Chapter info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Chapter number
                  ShimmerContainer(
                    width: 120,
                    height: 16,
                    margin: const EdgeInsets.only(bottom: 8),
                  ),
                  
                  // Release date
                  ShimmerContainer(
                    width: 80,
                    height: 12,
                    margin: const EdgeInsets.only(bottom: 8),
                  ),
                  
                  // Stats (views, votes)
                  Row(
                    children: [
                      ShimmerContainer(
                        width: 60,
                        height: 12,
                      ),
                      const SizedBox(width: 16),
                      ShimmerContainer(
                        width: 60,
                        height: 12,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
