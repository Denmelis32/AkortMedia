import 'package:flutter/material.dart';
import '../shimmer_loading.dart';

class NewsLoadingState extends StatelessWidget {
  const NewsLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return const NewsShimmerLoader(); // 🎯 ИСПРАВЛЕНО: используем исправленный NewsShimmerLoader
  }
}