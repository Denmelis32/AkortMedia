// lib/providers/state_sync_provider.dart
import 'package:flutter/foundation.dart';

class StateSyncProvider with ChangeNotifier {
  static final StateSyncProvider _instance = StateSyncProvider._internal();
  factory StateSyncProvider() => _instance;
  StateSyncProvider._internal();

  final Map<String, DateTime> _lastUpdates = {};

  void notifyPostUpdated(String postId) {
    _lastUpdates[postId] = DateTime.now();
    notifyListeners();
    print('🔄 StateSyncProvider: Post $postId updated');
  }

  DateTime? getLastUpdate(String postId) {
    return _lastUpdates[postId];
  }
}