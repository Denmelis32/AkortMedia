import 'package:flutter/material.dart';

class ShimmerLoading extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius borderRadius;

  const ShimmerLoading({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = BorderRadius.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: borderRadius,
      ),
    );
  }
}

class NewsCardShimmer extends StatelessWidget {
  const NewsCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const ShimmerLoading(width: 44, height: 44, borderRadius: BorderRadius.all(Radius.circular(22))),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerLoading(width: 120, height: 16, borderRadius: BorderRadius.circular(4)),
                  const SizedBox(height: 6),
                  ShimmerLoading(width: 80, height: 12, borderRadius: BorderRadius.circular(4)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ShimmerLoading(width: double.infinity, height: 20, borderRadius: BorderRadius.circular(4)),
          const SizedBox(height: 8),
          ShimmerLoading(width: double.infinity, height: 16, borderRadius: BorderRadius.circular(4)),
          const SizedBox(height: 8),
          ShimmerLoading(width: 200, height: 16, borderRadius: BorderRadius.circular(4)),
          const SizedBox(height: 16),
          Row(
            children: [
              ShimmerLoading(width: 60, height: 28, borderRadius: BorderRadius.circular(14)),
              const SizedBox(width: 12),
              ShimmerLoading(width: 60, height: 28, borderRadius: BorderRadius.circular(14)),
            ],
          ),
        ],
      ),
    );
  }
}