import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Модель для темы обсуждения
class DiscussionTopic {
  final String id;
  final String title;
  final String description;
  final String author;
  final DateTime createdAt;
  final List<Message> messages;

  DiscussionTopic({
    required this.id,
    required this.title,
    required this.description,
    required this.author,
    required this.createdAt,
    this.messages = const [],
  });
}

// Модель для сообщения
class Message {
  final String id;
  final String text;
  final String author;
  final DateTime timestamp;

  Message({
    required this.id,
    required this.text,
    required this.author,
    required this.timestamp,
  });
}

class RoomsPage extends StatefulWidget {
  final String userName;
  final String userEmail;
  final VoidCallback onLogout;

  const RoomsPage({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.onLogout,
  });

  @override
  State<RoomsPage> createState() => _RoomsPageState();
}

class _RoomsPageState extends State<RoomsPage> {
  final List<DiscussionTopic> _topics = [];
  final _topicTitleController = TextEditingController();
  final _topicDescriptionController = TextEditingController();
  final _messageController = TextEditingController();

  DiscussionTopic? _selectedTopic;
  bool _showTopicCreation = false;

  @override
  void dispose() {
    _topicTitleController.dispose();
    _topicDescriptionController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _createNewTopic() {
    if (_topicTitleController.text.isNotEmpty) {
      final newTopic = DiscussionTopic(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _topicTitleController.text,
        description: _topicDescriptionController.text,
        author: widget.userName,
        createdAt: DateTime.now(),
      );

      setState(() {
        _topics.add(newTopic);
        _selectedTopic = newTopic;
        _showTopicCreation = false;
      });

      _topicTitleController.clear();
      _topicDescriptionController.clear();
    }
  }

  void _sendMessage() {
    if (_messageController.text.isNotEmpty && _selectedTopic != null) {
      final newMessage = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: _messageController.text,
        author: widget.userName,
        timestamp: DateTime.now(),
      );

      setState(() {
        final topicIndex = _topics.indexWhere((t) => t.id == _selectedTopic!.id);
        if (topicIndex != -1) {
          _topics[topicIndex] = DiscussionTopic(
            id: _selectedTopic!.id,
            title: _selectedTopic!.title,
            description: _selectedTopic!.description,
            author: _selectedTopic!.author,
            createdAt: _selectedTopic!.createdAt,
            messages: [..._selectedTopic!.messages, newMessage],
          );
          _selectedTopic = _topics[topicIndex];
        }
      });

      _messageController.clear();
    }
  }

  void _cancelTopicCreation() {
    setState(() {
      _showTopicCreation = false;
      _topicTitleController.clear();
      _topicDescriptionController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Комнаты для обсуждений'),
        actions: [
          if (!_showTopicCreation && _selectedTopic == null)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => setState(() => _showTopicCreation = true),
              tooltip: 'Создать тему',
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: widget.onLogout,
            tooltip: 'Выйти',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Создание новой темы
            if (_showTopicCreation) ...[
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Создать новую тему',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _topicTitleController,
                        decoration: const InputDecoration(
                          labelText: 'Название темы*',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _topicDescriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Описание',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: _cancelTopicCreation,
                            child: const Text('Отмена'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: _createNewTopic,
                            child: const Text('Создать'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Список тем
            if (_topics.isNotEmpty && _selectedTopic == null) ...[
              const Text(
                'Темы для обсуждения:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ..._topics.map((topic) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(topic.title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        topic.description.isNotEmpty
                            ? topic.description
                            : 'Без описания',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Автор: ${topic.author} • '
                            'Сообщений: ${topic.messages.length} • '
                            'Создана: ${DateFormat('dd.MM.yyyy').format(topic.createdAt)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => setState(() => _selectedTopic = topic),
                ),
              )).toList(),
            ],

            // Область обсуждения выбранной темы
            if (_selectedTopic != null) ...[
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () => setState(() => _selectedTopic = null),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedTopic!.title,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Автор: ${_selectedTopic!.author} • '
                                      'Создана: ${DateFormat('dd.MM.yyyy HH:mm').format(_selectedTopic!.createdAt)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (_selectedTopic!.description.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          _selectedTopic!.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Сообщения
              if (_selectedTopic!.messages.isNotEmpty) ...[
                ..._selectedTopic!.messages.map((message) => Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              message.author,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            Text(
                              DateFormat('HH:mm').format(message.timestamp),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(message.text),
                      ],
                    ),
                  ),
                )).toList(),
              ] else ...[
                const Center(
                  child: Text(
                    'Пока нет сообщений. Будьте первым!',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // Поле ввода сообщения
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: const InputDecoration(
                            hintText: 'Введите сообщение...',
                            border: OutlineInputBorder(),
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: _sendMessage,
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // Пустое состояние
            if (_topics.isEmpty && !_showTopicCreation && _selectedTopic == null)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.forum_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Пока нет тем для обсуждения',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => setState(() => _showTopicCreation = true),
                      child: const Text('Создать первую тему'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),

      // Кнопка создания темы внизу экрана
      floatingActionButton: _selectedTopic == null && !_showTopicCreation
          ? FloatingActionButton(
        onPressed: () => setState(() => _showTopicCreation = true),
        child: const Icon(Icons.add),
      )
          : null,
    );
  }
}