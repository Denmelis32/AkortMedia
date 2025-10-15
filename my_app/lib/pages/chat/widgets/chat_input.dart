import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../chat_controller.dart';
import '../models/chat_message.dart';

class ChatInputField extends StatefulWidget {
  final String roomId;
  final ChatMessage? replyTo;
  final VoidCallback? onCancelReply;

  const ChatInputField({
    super.key,
    required this.roomId,
    this.replyTo,
    this.onCancelReply,
  });

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isComposing = false;
  bool _showSendButton = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final text = _textController.text.trim();
    setState(() {
      _showSendButton = text.isNotEmpty;
    });

    // Отправка индикатора набора текста
    if (text.isNotEmpty && !_isComposing) {
      _isComposing = true;
      context.read<ChatController>().startTyping();
    } else if (text.isEmpty && _isComposing) {
      _isComposing = false;
      context.read<ChatController>().stopTyping();
    }
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus && _isComposing) {
      _isComposing = false;
      context.read<ChatController>().stopTyping();
    }
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final controller = context.read<ChatController>();
    controller.sendMessage(text, replyTo: widget.replyTo);

    // Сбрасываем состояние
    _textController.clear();
    _isComposing = false;
    controller.stopTyping();

    // Отменяем ответ если был
    if (widget.replyTo != null) {
      widget.onCancelReply?.call();
    }
  }

  void _showAttachmentMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildAttachmentMenu(),
    );
  }

  void _showEmojiPicker() {
    // TODO: Интеграция с эмодзи пикером
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Превью ответа
          if (widget.replyTo != null)
            _buildReplyPreview(),

          // Основная строка ввода
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Кнопка прикрепления
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.attach_file,
                    size: 20,
                    color: Colors.grey,
                  ),
                ),
                onPressed: _showAttachmentMenu,
              ),

              // Поле ввода текста
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(
                    maxHeight: 120,
                  ),
                  child: TextField(
                    controller: _textController,
                    focusNode: _focusNode,
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: InputDecoration(
                      hintText: 'Написать сообщение...',
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Кнопка эмодзи или отправки
              if (_showSendButton)
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                  onPressed: _sendMessage,
                )
              else
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.emoji_emotions_outlined,
                      size: 20,
                      color: Colors.grey,
                    ),
                  ),
                  onPressed: _showEmojiPicker,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReplyPreview() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Row(
        children: [
          // Вертикальная линия
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),

          // Контент ответа
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ответ ${widget.replyTo!.author.name}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.replyTo!.text,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          // Кнопка отмены
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: widget.onCancelReply,
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentMenu() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Заголовок
            const Text(
              'Прикрепить файл',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),

            // Опции
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildAttachmentOption(
                  icon: Icons.photo,
                  label: 'Фото',
                  onTap: () => _attachPhoto(),
                ),
                _buildAttachmentOption(
                  icon: Icons.videocam,
                  label: 'Видео',
                  onTap: () => _attachVideo(),
                ),
                _buildAttachmentOption(
                  icon: Icons.audio_file,
                  label: 'Аудио',
                  onTap: () => _attachAudio(),
                ),
                _buildAttachmentOption(
                  icon: Icons.insert_drive_file,
                  label: 'Файл',
                  onTap: () => _attachFile(),
                ),
                _buildAttachmentOption(
                  icon: Icons.location_on,
                  label: 'Местоположение',
                  onTap: () => _attachLocation(),
                ),
                _buildAttachmentOption(
                  icon: Icons.contact_page,
                  label: 'Контакт',
                  onTap: () => _attachContact(),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Кнопка отмены
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Отмена'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 28, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  void _attachPhoto() {
    // TODO: Интеграция с выбором фото
  }

  void _attachVideo() {
    // TODO: Интеграция с выбором видео
  }

  void _attachAudio() {
    // TODO: Интеграция с записью/выбором аудио
  }

  void _attachFile() {
    // TODO: Интеграция с выбором файла
  }

  void _attachLocation() {
    // TODO: Интеграция с картами
  }

  void _attachContact() {
    // TODO: Интеграция с контактами
  }
}