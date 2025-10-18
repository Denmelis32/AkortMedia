// providers/user_tags_provider.dart
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:my_app/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'news_provider.dart';

class UserTagsProvider with ChangeNotifier {
  Map<String, Map<String, Map<String, Map<String, dynamic>>>> _userTags = {};
  bool _isInitialized = false;
  String _currentUserId = '';

  final List<Color> _availableColors = [
    Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.red,
    Colors.teal, Colors.pink, Colors.indigo, Colors.amber, Colors.cyan,
  ];

  List<Color> get availableColors => _availableColors;
  bool get isInitialized => _isInitialized;
  String get currentUserId => _currentUserId;

  // Основной метод инициализации, который должен вызываться при старте приложения
  Future<void> initialize(UserProvider userProvider) async {
    if (_isInitialized) {
      print('⚠️ UserTagsProvider: уже инициализирован');
      return;
    }

    // Получаем userId из UserProvider
    if (userProvider.isLoggedIn && userProvider.userId.isNotEmpty) {
      _currentUserId = userProvider.userId;
      print('✅ UserTagsProvider: установлен пользователь из UserProvider: $_currentUserId');
    } else {
      // Создаем временного пользователя если UserProvider не готов
      _currentUserId = 'temp_user_${DateTime.now().millisecondsSinceEpoch}';
      print('⚠️ UserTagsProvider: UserProvider не готов, создан временный пользователь: $_currentUserId');
    }

    await _initializeCore();
  }

  void clearCurrentUserTags() {
    if (_currentUserId.isNotEmpty && _userTags.containsKey(_currentUserId)) {
      _userTags.remove(_currentUserId);
      print('✅ UserTagsProvider: теги очищены для пользователя $_currentUserId');
      notifyListeners();

      // Также сохраняем изменения в хранилище
      _saveUserTagsToStorage();
    }
  }

  // Альтернативная инициализация с прямым userId
  Future<void> initializeWithUserId(String userId) async {
    if (_isInitialized) return;

    if (userId.isNotEmpty) {
      _currentUserId = userId;
      print('✅ UserTagsProvider: установлен пользователь: $userId');
    } else {
      _currentUserId = 'temp_user_${DateTime.now().millisecondsSinceEpoch}';
      print('⚠️ UserTagsProvider: передан пустой userId, создан временный пользователь: $_currentUserId');
    }

    await _initializeCore();
  }

  // Основная логика инициализации
  Future<void> _initializeCore() async {
    print('🔄 UserTagsProvider: начата инициализация для пользователя $_currentUserId');

    await _loadUserTagsFromStorage();
    _isInitialized = true;

    // Если для текущего пользователя нет тегов, создаем дефолтные
    if (!_userTags.containsKey(_currentUserId) || _userTags[_currentUserId]!.isEmpty) {
      await _createDefaultTagsForUser(_currentUserId);
    }

    debugPrintTags();
    notifyListeners();
    print('✅ UserTagsProvider: инициализация завершена для пользователя $_currentUserId');
  }

  // Обновление пользователя при смене аккаунта
  Future<void> updateCurrentUser(String newUserId) async {
    if (newUserId == _currentUserId) return;

    print('🔄 UserTagsProvider: смена пользователя с $_currentUserId на $newUserId');

    await _saveUserTagsToStorage();
    _currentUserId = newUserId;

    // Переинициализируем для нового пользователя
    await _loadUserTagsForCurrentUser();
  }

  // Загрузка тегов для текущего пользователя
  Future<void> _loadUserTagsForCurrentUser() async {
    if (_currentUserId.isEmpty) return;

    await _loadUserTagsFromStorage();

    if (!_userTags.containsKey(_currentUserId) || _userTags[_currentUserId]!.isEmpty) {
      await _createDefaultTagsForUser(_currentUserId);
    }

    notifyListeners();
  }

  // Загрузка тегов из хранилища
  Future<void> _loadUserTagsFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tagsJson = prefs.getString('personal_user_tags_by_user');

      if (tagsJson != null && tagsJson.isNotEmpty) {
        _userTags = _parseTagsJson(tagsJson);
        print('✅ UserTagsProvider: загружены персональные теги для ${_userTags.length} пользователей');
      } else {
        print('ℹ️ UserTagsProvider: в хранилище нет данных о тегах');
        _userTags = {};
      }
    } catch (e) {
      print('❌ UserTagsProvider: ошибка загрузки персональных тегов: $e');
      _userTags = {};
    }
  }

  Map<String, Map<String, Map<String, Map<String, dynamic>>>> _parseTagsJson(String jsonString) {
    final Map<String, Map<String, Map<String, Map<String, dynamic>>>> result = {};
    try {
      final Map<String, dynamic> parsed = json.decode(jsonString);
      print('🔍 UserTagsProvider: парсинг JSON, найдено ${parsed.length} пользователей');

      parsed.forEach((userId, userData) {
        if (userData is Map) {
          final userTags = <String, Map<String, Map<String, dynamic>>>{};

          userData.forEach((postId, postData) {
            if (postData is Map) {
              final postTags = <String, Map<String, dynamic>>{};

              postData.forEach((tagId, tagData) {
                if (tagData is Map) {
                  postTags[tagId] = {
                    'name': tagData['name']?.toString() ?? 'Тег',
                    'color': Color(tagData['color'] as int? ?? Colors.blue.value),
                  };
                }
              });

              userTags[postId] = postTags;
            }
          });

          result[userId] = userTags;
        }
      });
    } catch (e) {
      print('❌ UserTagsProvider: ошибка парсинга тегов: $e');
    }
    return result;
  }

  // Создание дефолтных тегов для пользователя
  // Создание дефолтных тегов для пользователя
  Future<void> _createDefaultTagsForUser(String userId) async {
    if (userId.isEmpty) return;

    _userTags[userId] = {
      'default': {
        'tag1': {
          'name': 'Интересное',
          'color': Colors.blue,
        },
        'tag2': {
          'name': 'Контент',
          'color': Colors.green,
        },
        'tag3': {
          'name': 'Обсуждение',
          'color': Colors.orange,
        },
      }
    };

    await _saveUserTagsToStorage();
    print('✅ UserTagsProvider: созданы дефолтные персональные теги для пользователя $userId');
  }

  // Сохранение тегов в хранилище
  Future<void> _saveUserTagsToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final Map<String, dynamic> jsonData = {};

      _userTags.forEach((userId, userData) {
        final userJson = <String, dynamic>{};

        userData.forEach((postId, postData) {
          final postJson = <String, dynamic>{};

          postData.forEach((tagId, tagData) {
            postJson[tagId] = {
              'name': tagData['name'],
              'color': (tagData['color'] as Color).value,
            };
          });

          userJson[postId] = postJson;
        });

        jsonData[userId] = userJson;
      });

      await prefs.setString('personal_user_tags_by_user', json.encode(jsonData));
      print('💾 UserTagsProvider: персональные теги сохранены для ${_userTags.length} пользователей');
    } catch (e) {
      print('❌ UserTagsProvider: ошибка сохранения персональных тегов: $e');
    }
  }

  Color getTagColorForPost(String postId, String tagId) {
    if (_currentUserId.isEmpty || !_userTags.containsKey(_currentUserId)) {
      print('⚠️ UserTagsProvider: нет данных для получения цвета тега $tagId, используем мок цвет');
      return _getMockTagColor(postId, tagId);
    }

    final userTags = _userTags[_currentUserId]!;

    // Сначала ищем в тегах конкретного поста
    if (userTags.containsKey(postId) && userTags[postId]!.containsKey(tagId)) {
      final tagData = userTags[postId]![tagId];
      if (tagData != null && tagData['color'] is Color) {
        final color = tagData['color'] as Color;
        print('✅ UserTagsProvider: найден цвет для тега $tagId в посте $postId: $color');
        return color;
      }
    }

    // Потом ищем в дефолтных тегах
    if (userTags.containsKey('default') && userTags['default']!.containsKey(tagId)) {
      final tagData = userTags['default']![tagId];
      if (tagData != null && tagData['color'] is Color) {
        final color = tagData['color'] as Color;
        print('✅ UserTagsProvider: найден цвет для тега $tagId в дефолтных тегах: $color');
        return color;
      }
    }

    // Если тег не найден, используем цвет из мок данных
    final mockColor = _getMockTagColor(postId, tagId);
    print('ℹ️ UserTagsProvider: цвет для тега $tagId взят из мок данных: $mockColor');
    return mockColor;
  }

  // ДОБАВЛЕН ОТСУТСТВУЮЩИЙ МЕТОД
  Map<String, Color> getLastUsedTagColors() {
    if (_currentUserId.isEmpty || !_userTags.containsKey(_currentUserId)) {
      return {'tag1': _getDefaultColor('tag1')};
    }

    final userTags = _userTags[_currentUserId]!;

    // Сначала ищем в дефолтных настройках пользователя
    if (userTags.containsKey('default') && userTags['default']!.isNotEmpty) {
      final defaultTags = userTags['default']!;
      final result = <String, Color>{};

      defaultTags.forEach((tagId, tagData) {
        if (tagData['color'] is Color &&
            tagData['name']?.toString() != 'Новый тег' &&
            tagData['name']?.toString().isNotEmpty == true) {
          result[tagId] = tagData['color'] as Color;
        }
      });

      if (result.isNotEmpty) {
        return result;
      }
    }

    // Если нет дефолтных, ищем последний пост с тегами
    final postsWithTags = userTags.entries
        .where((entry) => entry.key != 'default' && entry.value.isNotEmpty)
        .toList();

    if (postsWithTags.isNotEmpty) {
      final lastPostTags = postsWithTags.last.value;
      final result = <String, Color>{};

      lastPostTags.forEach((tagId, tagData) {
        if (tagData['color'] is Color &&
            tagData['name']?.toString() != 'Новый тег' &&
            tagData['name']?.toString().isNotEmpty == true) {
          result[tagId] = tagData['color'] as Color;
        }
      });

      if (result.isNotEmpty) {
        return result;
      }
    }

    return {'tag1': _getDefaultColor('tag1')};
  }

  Future<void> initializeTagsForNewPost(String postId) async {
    if (_currentUserId.isEmpty) {
      print('❌ UserTagsProvider: currentUserId не установлен для инициализации тегов нового поста');
      return;
    }

    if (!_isInitialized) {
      print('🔄 UserTagsProvider: автоматическая инициализация перед созданием тегов для нового поста');
      await initializeWithUserId(_currentUserId);
    }

    // Создаем структуру если её нет
    if (!_userTags.containsKey(_currentUserId)) {
      _userTags[_currentUserId] = {};
      print('✅ UserTagsProvider: создана структура для пользователя $_currentUserId');
    }

    // ИСПОЛЬЗУЕМ ПОСЛЕДНИЕ ТЕГИ ПОЛЬЗОВАТЕЛЯ вместо пустых
    final lastTags = getLastUsedTags();
    final lastColors = getLastUsedTagColors();

    if (!_userTags[_currentUserId]!.containsKey(postId)) {
      _userTags[_currentUserId]![postId] = {};

      // Сохраняем последние теги пользователя для нового поста
      lastTags.forEach((tagId, tagName) {
        final color = lastColors[tagId] ?? _getDefaultColor(tagId);
        _userTags[_currentUserId]![postId]![tagId] = {
          'name': tagName,
          'color': color,
        };
      });

      await _saveUserTagsToStorage();
      print('✅ UserTagsProvider: инициализированы теги для нового поста $postId: $lastTags');

      // Отладочная информация
      debugPrintTags();
    } else {
      print('ℹ️ UserTagsProvider: теги для поста $postId уже существуют');
    }
  }

  Future<void> updateTagForPost({
    required String postId,
    required String tagId,
    required String newName,
    required Color color,
    bool updateGlobally = true,
    BuildContext? context,
  }) async {
    if (_currentUserId.isEmpty) {
      print('❌ UserTagsProvider: не установлен текущий пользователь для обновления тега');
      return;
    }

    if (!_isInitialized) {
      print('🔄 UserTagsProvider: автоматическая инициализация перед обновлением тега');
      await initializeWithUserId(_currentUserId);
    }

    // Создаем структуру если её нет
    if (!_userTags.containsKey(_currentUserId)) {
      _userTags[_currentUserId] = {};
      print('✅ UserTagsProvider: создана структура для пользователя $_currentUserId');
    }

    // Убедимся, что для этого поста есть запись
    if (!_userTags[_currentUserId]!.containsKey(postId)) {
      _userTags[_currentUserId]![postId] = {};
      print('✅ UserTagsProvider: создана структура для поста $postId');
    }

    // Сохраняем тег для конкретного поста
    _userTags[_currentUserId]![postId]![tagId] = {
      'name': newName,
      'color': color,
    };

    // ВАЖНОЕ ИЗМЕНЕНИЕ: ГЛОБАЛЬНОЕ ОБНОВЛЕНИЕ
    if (updateGlobally) {
      await updateTagGlobally(tagId, newName, color, context: context);
    } else {
      await _saveUserTagsToStorage();
      notifyListeners();

      // Все равно уведомляем NewsProvider для обновления UI
      if (context != null) {
        _notifyNewsProvider(context);
      }
    }

    print('✅ UserTagsProvider: тег сохранен для пользователя $_currentUserId и поста $postId: $tagId -> $newName ($color)');

    // Отладочная информация после обновления
    debugPrintTags();
  }

  Future<void> _updateUserDefaultTags(String tagId, String newName, Color color) async {
    if (!_userTags.containsKey(_currentUserId)) {
      _userTags[_currentUserId] = {};
    }

    if (!_userTags[_currentUserId]!.containsKey('default')) {
      _userTags[_currentUserId]!['default'] = {};
    }

    // Сохраняем тег в дефолтные настройки пользователя
    _userTags[_currentUserId]!['default']![tagId] = {
      'name': newName,
      'color': color,
    };

    await _saveUserTagsToStorage();
    print('✅ UserTagsProvider: тег сохранен в дефолтные настройки пользователя: $tagId -> $newName');
  }

  Future<void> saveTagsForNewPost({
    required String postId,
    required Map<String, String> tags,
    required Map<String, Color> tagColors,
  }) async {
    if (_currentUserId.isEmpty) {
      print('❌ UserTagsProvider: не установлен текущий пользователь');
      return;
    }

    if (!_isInitialized) {
      await initializeWithUserId(_currentUserId);
    }

    // Создаем структуру если её нет
    if (!_userTags.containsKey(_currentUserId)) {
      _userTags[_currentUserId] = {};
    }

    // Сохраняем все теги для поста
    _userTags[_currentUserId]![postId] = {};

    tags.forEach((tagId, tagName) {
      final color = tagColors[tagId] ?? _getDefaultColor(tagId);
      _userTags[_currentUserId]![postId]![tagId] = {
        'name': tagName,
        'color': color,
      };
    });

    await _saveUserTagsToStorage();
    notifyListeners();

    print('✅ UserTagsProvider: сохранены теги для нового поста $postId: $tags');
  }

  Map<String, String> _getDefaultTags() {
    return {
      'tag1': 'Фанат Манчестера',
      'tag2': 'Спорт',
      'tag3': 'Новости',
    };
  }

  Map<String, String> getTagsForPost(String postId) {
    if (_currentUserId.isEmpty) {
      print('⚠️ UserTagsProvider: currentUserId не установлен при запросе тегов для поста $postId');
      return _getMockTagsForPost(postId); // Используем мок теги
    }

    if (!_isInitialized) {
      print('⚠️ UserTagsProvider: не инициализирован при запросе тегов для поста $postId');
      return _getMockTagsForPost(postId); // Используем мок теги
    }

    if (!_userTags.containsKey(_currentUserId)) {
      print('⚠️ UserTagsProvider: нет тегов для пользователя $_currentUserId');
      return _getMockTagsForPost(postId); // Используем мок теги
    }

    final userTags = _userTags[_currentUserId]!;

    // Сначала ищем теги для конкретного поста
    if (userTags.containsKey(postId) && userTags[postId]!.isNotEmpty) {
      final tags = userTags[postId]!;
      final result = tags.map((key, value) => MapEntry(key, value['name']?.toString() ?? 'Тег'));

      // ФИЛЬТРУЕМ ПУСТЫЕ ТЕГИ - если тег называется "Новый тег", считаем его пустым
      final filteredResult = Map<String, String>.fromEntries(
          result.entries.where((entry) => entry.value != 'Новый тег' && entry.value.isNotEmpty)
      );

      if (filteredResult.isNotEmpty) {
        print('✅ UserTagsProvider: найдены сохраненные теги для поста $postId: $filteredResult');
        return filteredResult;
      } else {
        print('ℹ️ UserTagsProvider: для поста $postId только пустые теги, используем мок теги');
        return _getMockTagsForPost(postId); // Используем мок теги
      }
    }

    // Если для поста нет сохраненных тегов, используем теги из мок данных
    print('ℹ️ UserTagsProvider: для поста $postId нет сохраненных тегов, используем мок теги');
    return _getMockTagsForPost(postId);
  }

// НОВЫЙ МЕТОД: Получение тегов из мок данных
  // НОВЫЙ МЕТОД: Получение тегов из мок данных
  Map<String, String> _getMockTagsForPost(String postId) {
    // Обновленный маппинг ID постов на теги из новых мок данных
    final mockTags = {
      // Технологии
      'tech-1': {'tag1': 'Технологии', 'tag2': 'ИИ', 'tag3': 'Будущее'},
      'tech-2': {'tag1': 'Наука', 'tag2': 'Квант', 'tag3': 'Рекорд'},

      // Спорт
      'sport-1': {'tag1': 'Фанат Манчестера', 'tag2': 'Спорт', 'tag3': 'Футбол'},
      'sport-2': {'tag1': 'Гонки', 'tag2': 'Автоспорт', 'tag3': 'Formula 1'},

      // Путешествия
      'travel-1': {'tag1': 'Путешествия', 'tag2': 'Япония', 'tag3': 'Советы'},
      'travel-2': {'tag1': 'Бали', 'tag2': 'Пляжи', 'tag3': 'Приключения'},

      // Кулинария
      'food-1': {'tag1': 'Кулинария', 'tag2': 'Италия', 'tag3': 'Рецепты'},
      'food-2': {'tag1': 'Выпечка', 'tag2': 'Хлеб', 'tag3': 'Дом'},

      // Искусство
      'art-1': {'tag1': 'Искусство', 'tag2': 'Выставка', 'tag3': 'Культура'},

      // Образование
      'edu-1': {'tag1': 'Образование', 'tag2': 'Курсы', 'tag3': 'Развитие'},

      // Канальные посты
      'channel-1': {'tag1': 'Официально', 'tag2': 'Обновление', 'tag3': 'Важно'},
      'channel-2': {'tag1': 'Конкурс', 'tag2': 'События', 'tag3': 'Призы'},

      // Личные истории
      'story-1': {'tag1': 'История', 'tag2': 'Обучение', 'tag3': 'Успех'},

      // Наука
      'science-1': {'tag1': 'Наука', 'tag2': 'Космос', 'tag3': 'Открытие'},

      // Старые ID для обратной совместимости
      '1': {'tag1': 'Приветствие', 'tag2': 'Официально', 'tag3': 'Новости'},
      '2': {'tag1': 'Фанат Манчестера', 'tag2': 'Спорт', 'tag3': 'Футбол'},
      '3': {'tag1': 'Гонки', 'tag2': 'Автоспорт', 'tag3': 'Formula 1'},
      '4': {'tag1': 'Технологии', 'tag2': 'ИИ', 'tag3': 'Инновации'},
      '5': {'tag1': 'Путешествия', 'tag2': 'Япония', 'tag3': 'Культура'},
      '6': {'tag1': 'Кулинария', 'tag2': 'Италия', 'tag3': 'Рецепты'},
    };

    // Возвращаем теги для конкретного поста или пустой map если не найдено
    final tags = mockTags[postId] ?? <String, String>{};

    if (tags.isNotEmpty) {
      print('✅ UserTagsProvider: использованы мок теги для поста $postId: $tags');
    } else {
      print('⚠️ UserTagsProvider: не найдены мок теги для поста $postId');
    }

    return tags;
  }

  Color _getDefaultColor(String tagId) {
    final colors = _availableColors;
    final hash = tagId.hashCode;
    return colors[hash.abs() % colors.length];
  }

  Map<String, String> getLastUsedTags() {
    if (_currentUserId.isEmpty || !_userTags.containsKey(_currentUserId)) {
      // Возвращаем более универсальные теги для нового поста
      return {'tag1': 'Интересное', 'tag2': 'Контент', 'tag3': 'Обсуждение'};
    }

    final userTags = _userTags[_currentUserId]!;

    // Сначала ищем в дефолтных настройках пользователя
    if (userTags.containsKey('default') && userTags['default']!.isNotEmpty) {
      final defaultTags = userTags['default']!;
      final result = defaultTags.map((key, value) =>
          MapEntry(key, value['name']?.toString() ?? 'Тег'));

      // Фильтруем пустые теги
      final filtered = Map<String, String>.fromEntries(
          result.entries.where((entry) => entry.value != 'Новый тег' && entry.value.isNotEmpty)
      );

      if (filtered.isNotEmpty) {
        print('✅ UserTagsProvider: найдены дефолтные теги пользователя: $filtered');
        return filtered;
      }
    }

    // Если нет дефолтных, ищем последний пост с тегами
    final postsWithTags = userTags.entries
        .where((entry) => entry.key != 'default' && entry.value.isNotEmpty)
        .toList();

    if (postsWithTags.isNotEmpty) {
      // Берем теги из последнего поста
      final lastPostTags = postsWithTags.last.value;
      final result = lastPostTags.map((key, value) =>
          MapEntry(key, value['name']?.toString() ?? 'Тег'));

      // Фильтруем пустые теги
      final filtered = Map<String, String>.fromEntries(
          result.entries.where((entry) => entry.value != 'Новый тег' && entry.value.isNotEmpty)
      );

      if (filtered.isNotEmpty) {
        print('✅ UserTagsProvider: найдены теги из последнего поста: $filtered');
        return filtered;
      }
    }

    // Если ничего не найдено, используем универсальные теги
    return {'tag1': 'Интересное', 'tag2': 'Контент', 'tag3': 'Обсуждение'};
  }

  Color _getMockTagColor(String postId, String tagId) {
    // Обновленные цвета для новых ID постов
    final mockColors = {
      'tech-1': Colors.purple,
      'tech-2': Colors.indigo,
      'sport-1': Colors.green,
      'sport-2': Colors.red,
      'travel-1': Colors.teal,
      'travel-2': Colors.blue,
      'food-1': Colors.orange,
      'food-2': Colors.amber,
      'art-1': Colors.deepPurple,
      'edu-1': Colors.cyan,
      'channel-1': Colors.blue,
      'channel-2': Colors.pink,
      'story-1': Colors.green,
      'science-1': Colors.deepOrange,

      // Старые ID для обратной совместимости
      '1': Colors.blue,
      '2': Colors.green,
      '3': Colors.red,
      '4': Colors.purple,
      '5': Colors.teal,
      '6': Colors.pink,
      'channel-1': Colors.orange,
    };

    return mockColors[postId] ?? _getDefaultColor(tagId);
  }


  Future<void> updateTagGlobally(String tagId, String newName, Color color, {BuildContext? context}) async {
    if (_currentUserId.isEmpty) {
      print('❌ UserTagsProvider: не установлен текущий пользователь для глобального обновления тега');
      return;
    }

    if (!_isInitialized) {
      print('🔄 UserTagsProvider: автоматическая инициализация перед глобальным обновлением тега');
      await initializeWithUserId(_currentUserId);
    }

    // Создаем структуру если её нет
    if (!_userTags.containsKey(_currentUserId)) {
      _userTags[_currentUserId] = {};
      print('✅ UserTagsProvider: создана структура для пользователя $_currentUserId');
    }

    bool hasChanges = false;

    // ОБНОВЛЯЕМ ТЕГ ВО ВСЕХ ПОСТАХ
    _userTags[_currentUserId]!.forEach((postId, postTags) {
      if (postTags.containsKey(tagId)) {
        final currentName = postTags[tagId]!['name']?.toString() ?? '';

        // Обновляем только если имя изменилось или это не пустой тег
        if (currentName != newName && currentName != 'Новый тег') {
          postTags[tagId] = {
            'name': newName,
            'color': color,
          };
          hasChanges = true;
          print('✅ UserTagsProvider: обновлен тег $tagId в посте $postId: $currentName -> $newName');
        }
      }
    });

    // ОБНОВЛЯЕМ ДЕФОЛТНЫЕ НАСТРОЙКИ
    if (!_userTags[_currentUserId]!.containsKey('default')) {
      _userTags[_currentUserId]!['default'] = {};
    }

    _userTags[_currentUserId]!['default']![tagId] = {
      'name': newName,
      'color': color,
    };
    hasChanges = true;

    if (hasChanges) {
      await _saveUserTagsToStorage();
      notifyListeners();
      print('✅ UserTagsProvider: тег $tagId глобально обновлен на "$newName" ($color)');

      // УВЕДОМЛЯЕМ NewsProvider ОБ ОБНОВЛЕНИИ (если передан context)
      if (context != null) {
        _notifyNewsProvider(context);
      }
    } else {
      print('ℹ️ UserTagsProvider: тег $tagId не требует обновления в других постах');
    }

    debugPrintTags();
  }

  void _notifyNewsProvider(BuildContext context) {
    try {
      final newsProvider = Provider.of<NewsProvider>(context, listen: false);
      newsProvider.refreshAllPostsUserTags();
      print('✅ UserTagsProvider: NewsProvider уведомлен об обновлении тегов');
    } catch (e) {
      print('⚠️ UserTagsProvider: не удалось уведомить NewsProvider: $e');
    }
  }

  // Отладочный метод для печати всех тегов
  void debugPrintTags() {
    print('=== DEBUG USER TAGS PROVIDER ===');
    print('Текущий пользователь: $_currentUserId');
    print('Инициализирован: $_isInitialized');
    print('Всего пользователей в системе: ${_userTags.length}');

    if (_userTags.containsKey(_currentUserId)) {
      final userData = _userTags[_currentUserId]!;
      print('Постов с тегами у текущего пользователя: ${userData.length}');

      userData.forEach((postId, tags) {
        print('📝 Пост "$postId": ${tags.length} тегов');
        tags.forEach((tagId, tagData) {
          print('   - $tagId: "${tagData['name']}" (${tagData['color']})');
        });
      });
    } else {
      print('❌ Нет тегов для текущего пользователя $_currentUserId');
    }
    print('================================');
  }

  @override
  void dispose() {
    print('🔚 UserTagsProvider: dispose');
    super.dispose();
  }
}