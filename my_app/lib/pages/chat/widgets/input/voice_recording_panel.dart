import 'package:flutter/material.dart';
import 'dart:math';

class VoiceRecordingPanel extends StatelessWidget {
  final ThemeData theme;
  final double recordingTime;
  final VoidCallback onStopRecording;
  final VoidCallback onSendVoiceMessage;

  // Делаем Random статическим
  static final Random _random = Random();

  // Теперь конструктор может быть const
  const VoiceRecordingPanel({
    super.key,
    required this.theme,
    required this.recordingTime,
    required this.onStopRecording,
    required this.onSendVoiceMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: Column(
        children: [
          // Визуализатор звука
          _buildSoundVisualizer(),

          const SizedBox(height: 16),

          // Индикатор записи
          _buildRecordingIndicator(),

          const SizedBox(height: 12),

          // Прогресс бар
          _buildProgressBar(),

          const SizedBox(height: 16),

          // Кнопки действий
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildSoundVisualizer() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(20, (index) {
        final height = (_random.nextDouble() * 30) + 5;
        final isActive = index < ((recordingTime * 2) % 20).toInt();
        return Container(
          width: 3,
          height: isActive ? height : 5,
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            color: isActive ? theme.colorScheme.onErrorContainer : theme.colorScheme.onErrorContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }

  Widget _buildRecordingIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.mic, color: theme.colorScheme.onErrorContainer, size: 24),
        const SizedBox(width: 8),
        Text(
          'Запись... ${recordingTime.toStringAsFixed(1)}с',
          style: TextStyle(
            color: theme.colorScheme.onErrorContainer,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    return LinearProgressIndicator(
      value: recordingTime % 30 / 30,
      backgroundColor: theme.colorScheme.errorContainer.withOpacity(0.3),
      valueColor: AlwaysStoppedAnimation(theme.colorScheme.onErrorContainer),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ElevatedButton(
          onPressed: onStopRecording,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
            foregroundColor: theme.colorScheme.onError,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Row(
            children: [
              Icon(Icons.cancel, size: 18),
              SizedBox(width: 6),
              Text('Отменить'),
            ],
          ),
        ),
        ElevatedButton(
          onPressed: onSendVoiceMessage,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Row(
            children: [
              Icon(Icons.send, size: 18),
              SizedBox(width: 6),
              Text('Отправить'),
            ],
          ),
        ),
      ],
    );
  }
}