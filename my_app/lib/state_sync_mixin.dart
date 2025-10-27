// lib/utils/state_sync_mixin.dart
import 'package:flutter/material.dart';
import '../services/interaction_manager.dart' as im;

mixin StateSyncMixin<T extends StatefulWidget> on State<T> {
  im.InteractionManager get interactionManager;
  String get postId;

  im.PostInteractionState? _postState;
  VoidCallback? _stateListener;

  @override
  void initState() {
    super.initState();
    _initializeStateSync();
  }




  void _initializeStateSync() {
    // Инициализируем состояние поста
    _postState = interactionManager.getPostState(postId);

    // Если состояние не существует, инициализируем его
    if (_postState == null) {
      _initializePostState();
    } else {
      print('✅ StateSyncMixin: Using existing state for $postId');
    }

    // Слушаем изменения
    _stateListener = () {
      if (mounted) {
        final newState = interactionManager.getPostState(postId);
        if (newState != null && newState != _postState) {
          setState(() {
            _postState = newState;
          });
          print('🔄 StateSync: Updated state for $postId');
        }
      }
    };

    interactionManager.addListener(_stateListener!);
  }

  /// Инициализация состояния поста если его нет - должен быть переопределен
  void _initializePostState() {
    print('⚠️ StateSyncMixin: Need to override _initializePostState for $postId');
  }




  im.PostInteractionState? get postState => _postState;

  @override
  void dispose() {
    _stateListener?.call();
    interactionManager.removeListener(_stateListener!);
    super.dispose();
  }
}