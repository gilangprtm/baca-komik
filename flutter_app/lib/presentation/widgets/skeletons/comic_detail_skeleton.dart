import 'package:flutter/material.dart';
import '../common/shimmer_loading.dart';

/// A skeleton loader for comic details page that mimics the layout of the actual comic details
class ComicDetailSkeleton extends StatelessWidget {
  const ComicDetailSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover and basic info section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cover image
                  ShimmerContainer(
                    width: 120,
                    height: 180,
                    borderRadius: 8,
                  ),
                  const SizedBox(width: 16),
                  
                  // Comic info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        ShimmerContainer(
                          width: double.infinity,
                          height: 20,
                          margin: const EdgeInsets.only(bottom: 8),
                        ),
                        
                        // Alternative title
                        ShimmerContainer(
                          width: double.infinity * 0.8,
                          height: 16,
                          margin: const EdgeInsets.only(bottom: 16),
                        ),
                        
                        // Stats row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(3, (index) => 
                            ShimmerContainer(
                              width: 60,
                              height: 40,
                              borderRadius: 4,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Action buttons
                        Row(
                          children: List.generate(2, (index) => 
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                child: ShimmerContainer(
                                  width: double.infinity,
                                  height: 40,
                                  borderRadius: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Genre tags
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(6, (index) => 
                  ShimmerContainer(
                    width: 80,
                    height: 32,
                    borderRadius: 16,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section title
                  ShimmerContainer(
                    width: 120,
                    height: 18,
                    margin: const EdgeInsets.only(bottom: 8),
                  ),
                  
                  // Description lines
                  ...List.generate(5, (index) => 
                    ShimmerContainer(
                      width: double.infinity,
                      height: 14,
                      margin: const EdgeInsets.only(bottom: 6),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Chapters section title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ShimmerContainer(
                width: 120,
                height: 18,
                margin: const EdgeInsets.only(bottom: 8),
              ),
            ),
            
            // First few chapter items (just placeholders)
            ...List.generate(3, (index) => 
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: ShimmerContainer(
                  width: double.infinity,
                  height: 60,
                  borderRadius: 8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
