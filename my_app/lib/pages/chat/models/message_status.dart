enum MessageStatus {
  sending('sending'),
  sent('sent'),
  delivered('delivered'),
  read('read'),
  failed('failed');

  final String value;
  const MessageStatus(this.value);

  bool get isSending => this == MessageStatus.sending;
  bool get isSent => this == MessageStatus.sent;
  bool get isDelivered => this == MessageStatus.delivered;
  bool get isRead => this == MessageStatus.read;
  bool get isFailed => this == MessageStatus.failed;

  String get displayText {
    switch (this) {
      case MessageStatus.sending:
        return 'Отправляется...';
      case MessageStatus.sent:
        return 'Отправлено';
      case MessageStatus.delivered:
        return 'Доставлено';
      case MessageStatus.read:
        return 'Прочитано';
      case MessageStatus.failed:
        return 'Ошибка отправки';
    }
  }
}