import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// A base shimmer loading widget that can be used as a foundation for all skeleton loaders
class ShimmerLoading extends StatelessWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration period;

  const ShimmerLoading({
    Key? key,
    required this.child,
    this.baseColor,
    this.highlightColor,
    this.period = const Duration(milliseconds: 1500),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    // Default colors based on theme brightness
    final defaultBaseColor = isDarkMode 
        ? Colors.grey[800] 
        : Colors.grey[300];
    final defaultHighlightColor = isDarkMode 
        ? Colors.grey[700] 
        : Colors.grey[100];

    return Shimmer.fromColors(
      baseColor: baseColor ?? defaultBaseColor!,
      highlightColor: highlightColor ?? defaultHighlightColor!,
      period: period,
      child: child,
    );
  }
}

/// A skeleton container with rounded corners for shimmer effect
class ShimmerContainer extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;

  const ShimmerContainer({
    Key? key,
    required this.width,
    required this.height,
    this.borderRadius = 8.0,
    this.margin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: Colors.white, // This is the color that will be animated by Shimmer
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}
