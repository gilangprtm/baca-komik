import 'package:flutter/material.dart';
import '../../../core/mahas/widget/mahas_grid.dart';
import '../common/shimmer_loading.dart';

/// A skeleton loader for comic grid that mimics the layout of the actual comic grid
class ComicGridSkeleton extends StatelessWidget {
  final int itemCount;
  final int crossAxisCount;
  final double childAspectRatio;
  final EdgeInsetsGeometry padding;

  const ComicGridSkeleton({
    super.key,
    this.itemCount = 6,
    this.crossAxisCount = 2,
    this.childAspectRatio = 0.65, // Adjusted for better comic card proportion
    this.padding = const EdgeInsets.all(8.0),
  });

  @override
  Widget build(BuildContext context) {
    return MahasGrid(
      items: List<Widget>.generate(
        itemCount,
        (_) => const ComicCardSkeleton(),
      ),
      crossAxisCount: crossAxisCount,
      childAspectRatio: childAspectRatio,
      padding: EdgeInsets.all(8.0),
    );
  }
}

/// A skeleton loader for a single comic card
class ComicCardSkeleton extends StatelessWidget {
  const ComicCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(12), // Slightly larger radius for modern look
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Comic thumbnail placeholder
          ShimmerLoading(
            child: ShimmerContainer(
              width: double.infinity,
              height: 240,
            ),
          ),
          const SizedBox(height: 8),
          // Comic title placeholder
          ShimmerLoading(
            child: ShimmerContainer(
              width: double.infinity,
              height: 20,
            ),
          ),
          const SizedBox(height: 8),
          // Chapter number placeholder
          ShimmerLoading(
            child: ShimmerContainer(
              width: double.infinity,
              height: 20,
            ),
          ),
        ],
      ),
    );
  }
}
