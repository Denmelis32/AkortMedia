enum MessageType {
  text('text'),
  image('image'),
  video('video'),
  file('file'),
  sticker('sticker'),
  system('system'),
  voice('voice');

  final String value;
  const MessageType(this.value);

  bool get isText => this == MessageType.text;
  bool get isImage => this == MessageType.image;
  bool get isVideo => this == MessageType.video;
  bool get isFile => this == MessageType.file;
  bool get isSticker => this == MessageType.sticker;
  bool get isSystem => this == MessageType.system;
  bool get isVoice => this == MessageType.voice;
  bool get isMedia => isImage || isVideo || isFile || isVoice;
}