import 'package:flutter/material.dart';

class ImageCache {
  final Map<String, ImageProvider> _cache = {};

  ImageProvider getImage(String url) {
    if (!_cache.containsKey(url)) {
      _cache[url] = NetworkImage(url);
    }
    return _cache[url]!;
  }

  void clear() {
    _cache.clear();
  }

  void remove(String url) {
    _cache.remove(url);
  }
}