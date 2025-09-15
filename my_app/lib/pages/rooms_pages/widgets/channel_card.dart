import 'package:flutter/material.dart';
import 'package:my_app/services/channel_service.dart'; // ← Используем только ChannelService
import '../models_room/channel.dart';

class ChannelCard extends StatefulWidget {
  final Channel channel;
  final String userId;
  final VoidCallback onTap;
  final VoidCallback? onSubscriptionChanged;
  final bool showAsGrid;

  const ChannelCard({
    super.key,
    required this.channel,
    required this.userId,
    required this.onTap,
    this.onSubscriptionChanged,
    this.showAsGrid = false,
  });

  @override
  State<ChannelCard> createState() => _ChannelCardState();
}

class _ChannelCardState extends State<ChannelCard> {
  bool _isSubscribed = false;

  @override
  void initState() {
    super.initState();
    _isSubscribed = ChannelService.isUserSubscribed(widget.channel, widget.userId); // ← Изменено
  }

  void _toggleSubscription() {
    setState(() {
      ChannelService.toggleSubscription(widget.channel, widget.userId); // ← Изменено
      _isSubscribed = ChannelService.isUserSubscribed(widget.channel, widget.userId); // ← Изменено
    });
    widget.onSubscriptionChanged?.call();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isSubscribed ? 'Подписались на канал' : 'Отписались от канала'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.showAsGrid ? _buildGridCard() : _buildListCard();
  }

  Widget _buildListCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок с аватаркой
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(widget.channel.ownerAvatarUrl),
                    radius: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              widget.channel.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (widget.channel.isVerified) ...[
                              const SizedBox(width: 4),
                              const Icon(Icons.verified, color: Colors.blue, size: 16),
                            ],
                          ],
                        ),
                        Text(
                          widget.channel.ownerName,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  _buildSubscribeButton(),
                ],
              ),
              const SizedBox(height: 12),
              // Описание
              Text(
                widget.channel.description,
                style: TextStyle(color: Colors.grey[700]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              // Метки
              if (widget.channel.tags.isNotEmpty) ...[
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: widget.channel.tags.take(3).map((tag) => Chip(
                    label: Text(
                      tag,
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: Colors.blue[50],
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  )).toList(),
                ),
                const SizedBox(height: 12),
              ],
              // Статистика
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${widget.channel.subscribersCount} подписчиков',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Text(
                    '${widget.channel.recentTopicIds.length} активных тем',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Баннер (если есть) или заглушка
              Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[200],
                  image: widget.channel.bannerImageUrl != null
                      ? DecorationImage(
                    image: NetworkImage(widget.channel.bannerImageUrl!),
                    fit: BoxFit.cover,
                  )
                      : null,
                ),
                child: widget.channel.bannerImageUrl == null
                    ? const Icon(Icons.people, size: 40, color: Colors.grey)
                    : null,
              ),
              const SizedBox(height: 8),
              // Название и верификация
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.channel.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  if (widget.channel.isVerified)
                    const Icon(Icons.verified, color: Colors.blue, size: 16),
                ],
              ),
              const SizedBox(height: 4),
              // Владелец
              Text(
                widget.channel.ownerName,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              // Кнопка подписки
              SizedBox(
                width: double.infinity,
                child: _buildSubscribeButton(),
              ),
              const SizedBox(height: 8),
              // Статистика
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${widget.channel.subscribersCount}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${widget.channel.recentTopicIds.length} тем',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubscribeButton() {
    return OutlinedButton(
      onPressed: _toggleSubscription,
      style: OutlinedButton.styleFrom(
        backgroundColor: _isSubscribed ? Colors.grey[100] : Colors.blue,
        foregroundColor: _isSubscribed ? Colors.grey[700] : Colors.white,
        side: BorderSide(
          color: _isSubscribed ? Colors.grey[300]! : Colors.blue,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Text(
        _isSubscribed ? 'Вы подписаны' : 'Подписаться',
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }
}