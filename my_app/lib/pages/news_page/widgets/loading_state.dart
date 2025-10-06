import 'package:flutter/material.dart';
import '../shimmer_loading.dart';

class NewsLoadingState extends StatelessWidget {
  const NewsLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (context, index) => const NewsCardShimmer(),
    );
  }
}