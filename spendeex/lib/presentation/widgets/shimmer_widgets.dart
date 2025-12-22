import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:spendeex/config/theme.dart';

class ShimmerWidgets {
  // Basic circular shimmer for buttons
  static Widget circularShimmer({
    double size = 20.0,
    Color? baseColor,
    Color? highlightColor,
  }) {
    return Shimmer.fromColors(
      baseColor: baseColor ?? Colors.grey[300]!,
      highlightColor: highlightColor ?? Colors.grey[100]!,
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  // List item shimmer effect
  static Widget listItemShimmer({
    Color? baseColor,
    Color? highlightColor,
    double height = 80.0,
  }) {
    return Shimmer.fromColors(
      baseColor: baseColor ?? Colors.grey[800]!,
      highlightColor: highlightColor ?? Colors.grey[700]!,
      child: Container(
        height: height,
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 16,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 12,
                    width: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 60,
              height: 20,
              margin: const EdgeInsets.only(left: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Card shimmer effect
  static Widget cardShimmer({
    Color? baseColor,
    Color? highlightColor,
    double height = 120.0,
  }) {
    return Shimmer.fromColors(
      baseColor: baseColor ?? Colors.grey[800]!,
      highlightColor: highlightColor ?? Colors.grey[700]!,
      child: Container(
        height: height,
        margin: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // Text line shimmer
  static Widget textShimmer({
    double width = double.infinity,
    double height = 16.0,
    Color? baseColor,
    Color? highlightColor,
  }) {
    return Shimmer.fromColors(
      baseColor: baseColor ?? Colors.grey[800]!,
      highlightColor: highlightColor ?? Colors.grey[700]!,
      child: Container(
        width: width,
        height: height,
        color: Colors.white,
      ),
    );
  }

  // Profile shimmer
  static Widget profileShimmer({
    Color? baseColor,
    Color? highlightColor,
  }) {
    return Shimmer.fromColors(
      baseColor: baseColor ?? Colors.grey[800]!,
      highlightColor: highlightColor ?? Colors.grey[700]!,
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: 120,
            height: 20,
            color: Colors.white,
          ),
          const SizedBox(height: 8),
          Container(
            width: 80,
            height: 14,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  // Stats/Chart shimmer
  static Widget statsShimmer({
    Color? baseColor,
    Color? highlightColor,
  }) {
    return Shimmer.fromColors(
      baseColor: baseColor ?? Colors.grey[800]!,
      highlightColor: highlightColor ?? Colors.grey[700]!,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(3, (index) => 
              Container(
                width: 80,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ],
      ),
    );
  }

  // Group details shimmer
  static Widget groupDetailsShimmer({
    Color? baseColor,
    Color? highlightColor,
  }) {
    return Shimmer.fromColors(
      baseColor: baseColor ?? Colors.grey[800]!,
      highlightColor: highlightColor ?? Colors.grey[700]!,
      child: Column(
        children: [
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(3, (index) => Container(
            height: 60,
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          )),
        ],
      ),
    );
  }
}