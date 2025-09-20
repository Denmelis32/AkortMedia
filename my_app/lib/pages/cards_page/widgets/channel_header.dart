// lib/pages/cards_page/widgets/channel_header.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/channel.dart';

class ChannelHeader extends StatelessWidget {
  final Channel channel;

  const ChannelHeader({super.key, required this.channel});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Фоновое изображение
        Container(
          color: channel.cardColor,
          height: double.infinity,
          width: double.infinity,
          child: Opacity(
            opacity: 0.1,
            child: Image.network(
              channel.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(),
            ),
          ),
        ),

        // Градиент поверх фона
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                channel.cardColor.withOpacity(0.8),
                channel.cardColor.withOpacity(0.4),
                Colors.transparent,
              ],
            ),
          ),
        ),

        // Контент заголовка
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Аватар канала
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: channel.imageUrl,
                    placeholder: (context, url) => Container(
                      color: Colors.white.withOpacity(0.2),
                      child: const Icon(Icons.person, color: Colors.white, size: 40),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.white.withOpacity(0.2),
                      child: const Icon(Icons.person, color: Colors.white, size: 40),
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Название канала
              Text(
                channel.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Теги канала
              if (channel.tags.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: channel.tags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '#$tag',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ],
    );
  }
}