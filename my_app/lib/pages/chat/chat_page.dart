import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../providers/room_provider.dart';
import '../rooms_pages/models/room.dart';
import 'widgets/app_bar/chat_app_bar.dart';
import 'widgets/message/message_list.dart';
import 'widgets/input/message_input_field.dart';
import 'widgets/panels/members_panel.dart';
import 'widgets/panels/pinned_messages_panel.dart';
import 'widgets/panels/selection_panel.dart';
import 'widgets/panels/reply_panel.dart';
import 'widgets/panels/edit_panel.dart';
import 'widgets/panels/typing_indicator.dart';
import 'widgets/app_bar/chat_search_panel.dart';
import 'models/chat_message.dart';
import 'models/chat_member.dart';
import 'utils/chat_animations.dart';
import 'utils/chat_navigation.dart';

class ChatPage extends StatefulWidget {
  final Room room;
  final String userName;
  final String userAvatar;

  const ChatPage({
    super.key,
    required this.room,
    required this.userName,
    this.userAvatar = '',
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _messageFocusNode = FocusNode();
  final List<ChatMessage> _messages = [];

  // State variables
  bool _isLoading = true;
  bool _showScrollToBottom = false;
  bool _isTyping = false;
  bool _isRecording = false;
  bool _showReactions = false;
  bool _showStickers = false;
  bool _isPinnedMessagesOpen = false;
  bool _isMembersPanelOpen = false;
  bool _isSearchMode = false;
  bool _isDarkMode = false;
  String _typingUser = '';
  ChatMessage? _replyingTo;
  ChatMessage? _editingMessage;
  double _recordingTime = 0.0;
  String _searchQuery = '';

  final Map<String, Color> _userColors = {};
  final List<String> _pinnedMessages = [];
  late List<ChatMessage> _searchResults = [];

  // Animations
  late ChatAnimations _animations;
  late ChatNavigation _navigation;

  // Message states
  final Map<String, bool> _expandedMessages = {};
  final Map<String, bool> _selectedMessages = {};
  bool _isSelectionMode = false;

  // Room members
  List<ChatMember> _onlineMembers = [];
  List<ChatMember> _allMembers = [];
  List<ChatMessage> _filteredMessages = [];

  // Additional features
  bool _isVoiceMessagePlaying = false;
  String _playingVoiceMessageId = '';
  double _voiceMessageProgress = 0.0;
  bool _showMessageTranslation = false;
  Map<String, String> _messageTranslations = {};
  bool _isIncognitoMode = false;

  @override
  void initState() {
    super.initState();
    _initializeDependencies();
    _setupEventListeners();
    _loadInitialData();
  }

  void _initializeDependencies() {
    _animations = ChatAnimations(vsync: this);
    _navigation = ChatNavigation(
      context: context,
      room: widget.room,
      userName: widget.userName,
      userAvatar: widget.userAvatar,
      messages: _messages,
      updateState: setState,
      scrollToBottom: _scrollToBottom,
    );
  }

  void _setupEventListeners() {
    _scrollController.addListener(_onScroll);
    _messageController.addListener(_onMessageChanged);
  }

  void _loadInitialData() {
    _loadInitialMessages();
    _loadRoomMembers();
    _animations.initializeAnimations();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    setState(() {
      _showScrollToBottom = (maxScroll - currentScroll) > 200;
    });
  }

  void _onMessageChanged() {
    if (_messageController.text.isNotEmpty && !_isTyping) {
      setState(() => _isTyping = true);
      _simulateTyping();
    } else if (_messageController.text.isEmpty && _isTyping) {
      setState(() {
        _isTyping = false;
        _typingUser = '';
      });
    }
  }

  void _simulateTyping() {
    if (_isTyping) {
      final typingUsers = ['Алексей Петров', 'Мария Иванова', 'Иван Сидоров'];
      final randomUser = typingUsers[DateTime.now().millisecond % typingUsers.length];

      setState(() => _typingUser = randomUser);

      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _isTyping) {
          setState(() => _typingUser = '');
        }
      });
    }
  }

  void _loadInitialMessages() {
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;

      _navigation.loadSampleMessages(_userColors);
      setState(() {
        _isLoading = false;
        _filteredMessages = List.from(_messages);
      });
      _scrollToBottom();
    });
  }

  void _loadRoomMembers() {
    _navigation.loadRoomMembers().then((members) {
      if (mounted) {
        setState(() {
          _onlineMembers = members.onlineMembers;
          _allMembers = members.allMembers;
        });
      }
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _navigation.sendMessage(
      messageController: _messageController,
      replyingTo: _replyingTo,
      editingMessage: _editingMessage,
      onMessageSent: () {
        setState(() {
          _isTyping = false;
          _typingUser = '';
          _replyingTo = null;
          _editingMessage = null;
          _filteredMessages = List.from(_messages);
        });
      },
    );
  }

  Color _getUserColor(String userName) {
    if (!_userColors.containsKey(userName)) {
      _userColors[userName] = Colors.primaries[DateTime.now().millisecond % Colors.primaries.length].shade600;
    }
    return _userColors[userName]!;
  }

  void _toggleSearchMode() {
    setState(() {
      _isSearchMode = !_isSearchMode;
      if (!_isSearchMode) {
        _searchQuery = '';
        _searchResults.clear();
        _filteredMessages = List.from(_messages);
      }
    });
  }

  void _handleSearch(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _searchResults.clear();
        _filteredMessages = List.from(_messages);
      } else {
        _searchResults = _messages.where((message) {
          return message.text.toLowerCase().contains(query.toLowerCase()) ||
              message.sender.toLowerCase().contains(query.toLowerCase());
        }).toList();
        _filteredMessages = _searchResults;
      }
    });
  }

  void _togglePinnedMessagesPanel() {
    if (_isPinnedMessagesOpen) {
      _animations.pinnedMessagesController.reverse();
    } else {
      _animations.pinnedMessagesController.forward();
    }
    setState(() {
      _isPinnedMessagesOpen = !_isPinnedMessagesOpen;
    });
  }

  void _toggleMembersPanel() {
    setState(() {
      _isMembersPanelOpen = !_isMembersPanelOpen;
    });
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  void _toggleIncognitoMode() {
    setState(() {
      _isIncognitoMode = !_isIncognitoMode;
    });
  }

  void _replyToMessage(ChatMessage message) {
    setState(() {
      _replyingTo = message;
      _editingMessage = null;
    });
    _messageFocusNode.requestFocus();
  }

  void _cancelReply() {
    setState(() {
      _replyingTo = null;
    });
  }

  void _editMessage(ChatMessage message) {
    _messageController.text = message.text;
    _messageFocusNode.requestFocus();

    setState(() {
      _editingMessage = message;
      _replyingTo = null;
    });
  }

  void _clearEdit() {
    setState(() {
      _editingMessage = null;
      _messageController.clear();
    });
  }

  void _toggleReactions() {
    setState(() {
      _showReactions = !_showReactions;
      _showStickers = false;
    });
  }

  void _toggleStickers() {
    setState(() {
      _showStickers = !_showStickers;
      _showReactions = false;
    });
  }

  void _startVoiceRecording() {
    setState(() {
      _isRecording = true;
      _recordingTime = 0.0;
    });
    _navigation.startVoiceRecording(_updateRecordingTime);
  }

  void _stopVoiceRecording() {
    setState(() {
      _isRecording = false;
    });
  }

  void _updateRecordingTime(double time) {
    setState(() {
      _recordingTime = time;
    });
  }

  void _sendVoiceMessage() {
    _navigation.sendVoiceMessage(_recordingTime).then((_) {
      _stopVoiceRecording();
      _scrollToBottom();
    });
  }

  void _forwardSelectedMessages() {
    final selectedMessages = _messages.where((message) => _selectedMessages[message.id] == true).toList();
    if (selectedMessages.isEmpty) return;

    _navigation.showSnackBar('Переслано ${selectedMessages.length} сообщений');

    setState(() {
      _selectedMessages.clear();
      _isSelectionMode = false;
    });
  }

  void _deleteSelectedMessages() {
    final selectedMessages = _messages.where((message) => _selectedMessages[message.id] == true).toList();
    if (selectedMessages.isEmpty) return;

    _navigation.showSnackBar('Удалено ${selectedMessages.length} сообщений');

    setState(() {
      for (var message in selectedMessages) {
        _messages.remove(message);
        _filteredMessages.remove(message);
        if (message.isPinned) {
          _pinnedMessages.remove(message.id);
        }
      }
      _selectedMessages.clear();
      _isSelectionMode = false;
    });
  }

  void _addEmojiToMessage(String emoji) {
    final currentText = _messageController.text;
    final selection = _messageController.selection;
    final newText = currentText.replaceRange(
      selection.start,
      selection.end,
      emoji,
    );
    _messageController.value = _messageController.value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: selection.start + emoji.length),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _messageFocusNode.dispose();
    _animations.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = _isDarkMode ? ThemeData.dark() : ThemeData.light();

    return Theme(
      data: theme,
      child: Scaffold(
        backgroundColor: theme.colorScheme.background,
        body: SafeArea(
          child: Column(
            children: [
              ChatAppBar(
                room: widget.room,
                theme: theme,
                onlineMembers: _onlineMembers,
                pinnedMessages: _pinnedMessages,
                isSearchMode: _isSearchMode,
                isDarkMode: _isDarkMode,
                isIncognitoMode: _isIncognitoMode,
                onBack: () => Navigator.pop(context),
                onToggleSearch: _toggleSearchMode,
                onTogglePinnedMessages: _togglePinnedMessagesPanel,
                onToggleMembers: _toggleMembersPanel,
                onToggleTheme: _toggleTheme,
                onToggleIncognito: _toggleIncognitoMode,
                onShowRoomInfo: _navigation.showEnhancedRoomInfo,
                onShowRoomSettings: _navigation.showRoomSettings,
                onInviteUsers: _navigation.inviteUsers,
              ),

              if (_isSearchMode)
                ChatSearchPanel(
                  theme: theme,
                  onSearch: _handleSearch,
                  onClose: _toggleSearchMode,
                ),

              if (_pinnedMessages.isNotEmpty && _isPinnedMessagesOpen)
                PinnedMessagesPanel(
                  theme: theme,
                  animation: _animations.pinnedMessagesAnimation,
                  messages: _messages,
                  pinnedMessages: _pinnedMessages,
                  onClose: _togglePinnedMessagesPanel,
                  onMessageTap: (message) {
                    final messageIndex = _messages.indexWhere((msg) => msg.id == message.id);
                    if (messageIndex != -1) {
                      _scrollController.animateTo(
                        messageIndex * 120.0,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    }
                    _togglePinnedMessagesPanel();
                  },
                ),

              if (_isMembersPanelOpen)
                MembersPanel(
                  theme: theme,
                  onlineMembers: _onlineMembers,
                  onClose: _toggleMembersPanel,
                ),

              if (_isSelectionMode)
                SelectionPanel(
                  theme: theme,
                  selectedCount: _selectedMessages.values.where((isSelected) => isSelected).length,
                  onForward: _forwardSelectedMessages,
                  onDelete: _deleteSelectedMessages,
                  onClearSelection: () {
                    setState(() {
                      _selectedMessages.clear();
                      _isSelectionMode = false;
                    });
                  },
                ),

              Expanded(
                child: Stack(
                  children: [
                    _buildBackground(theme),

                    if (_isLoading)
                      _navigation.buildLoadingShimmer()
                    else
                      MessageList(
                        messages: _filteredMessages,
                        scrollController: _scrollController,
                        typingUser: _typingUser,
                        isSelectionMode: _isSelectionMode,
                        selectedMessages: _selectedMessages,
                        expandedMessages: _expandedMessages,
                        isIncognitoMode: _isIncognitoMode,
                        showMessageTranslation: _showMessageTranslation,
                        messageTranslations: _messageTranslations,
                        userColors: _userColors,
                        onMessageTap: (message) {
                          if (_isSelectionMode) {
                            _toggleMessageSelection(message);
                          }
                        },
                        onMessageLongPress: (message) {
                          if (_isSelectionMode) {
                            _toggleMessageSelection(message);
                          } else {
                            _navigation.showEnhancedMessageOptions(
                              message: message,
                              theme: theme,
                              onReply: () => _replyToMessage(message),
                              onEdit: () => _editMessage(message),
                              onDelete: () => _deleteMessage(message),
                              onToggleSelection: () => _toggleMessageSelection(message),
                              onToggleExpansion: (messageId) => _toggleMessageExpansion(messageId),
                              onTranslate: () => _translateMessage(message),
                              onPin: () => _pinMessage(message),
                              onUnpin: () => _unpinMessage(message),
                              onAddReaction: (emoji) => _addReaction(message, emoji),
                            );
                          }
                        },
                        onToggleExpansion: _toggleMessageExpansion,
                        onPlayVoiceMessage: _playVoiceMessage,
                        onStopVoiceMessage: _stopVoiceMessage,
                        isVoiceMessagePlaying: _isVoiceMessagePlaying,
                        playingVoiceMessageId: _playingVoiceMessageId,
                        voiceMessageProgress: _voiceMessageProgress,
                      ),

                    if (_showScrollToBottom)
                      _buildScrollToBottomButton(theme),
                  ],
                ),
              ),

              if (_typingUser.isNotEmpty)
                TypingIndicator(
                  theme: theme,
                  typingUser: _typingUser,
                  animationController: _animations.typingAnimationController,
                ),

              if (_replyingTo != null)
                ReplyPanel(
                  theme: theme,
                  replyingTo: _replyingTo!,
                  onCancel: _cancelReply,
                ),

              if (_editingMessage != null)
                EditPanel(
                  theme: theme,
                  editingMessage: _editingMessage!,
                  onCancel: _clearEdit,
                ),

              if (_showStickers)
                _navigation.buildStickersPanel(
                  onStickerSelected: (sticker) {
                    _navigation.sendSticker(sticker);
                    setState(() => _showStickers = false);
                    _scrollToBottom();
                  },
                ),

              MessageInputField(
                theme: theme,
                messageController: _messageController,
                messageFocusNode: _messageFocusNode,
                room: widget.room,
                isRecording: _isRecording,
                showReactions: _showReactions,
                editingMessage: _editingMessage,
                availableReactions: _navigation.availableReactions,
                onSendMessage: _sendMessage,
                onStartVoiceRecording: _startVoiceRecording,
                onStopVoiceRecording: _stopVoiceRecording,
                onSendVoiceMessage: _sendVoiceMessage,
                onToggleReactions: _toggleReactions,
                onToggleStickers: _toggleStickers,
                onShowAttachmentMenu: _navigation.showEnhancedAttachmentMenu,
                onAddEmoji: _addEmojiToMessage,
                recordingTime: _recordingTime,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackground(ThemeData theme) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: _isDarkMode
              ? [
            theme.colorScheme.surface.withOpacity(0.3),
            theme.colorScheme.background.withOpacity(0.7),
            theme.colorScheme.background,
          ]
              : [
            theme.colorScheme.primary.withOpacity(0.03),
            theme.colorScheme.background.withOpacity(0.8),
            theme.colorScheme.background,
          ],
        ),
      ),
    );
  }

  Widget _buildScrollToBottomButton(ThemeData theme) {
    return Positioned(
      bottom: 100,
      right: 20,
      child: FloatingActionButton(
        mini: true,
        backgroundColor: theme.primaryColor,
        onPressed: _scrollToBottom,
        child: Icon(Icons.arrow_downward, size: 20, color: theme.colorScheme.onPrimary),
      ),
    );
  }

  void _toggleMessageSelection(ChatMessage message) {
    setState(() {
      _selectedMessages[message.id] = !(_selectedMessages[message.id] ?? false);
      _isSelectionMode = _selectedMessages.values.any((isSelected) => isSelected);
    });
  }

  void _toggleMessageExpansion(String messageId) {
    setState(() {
      _expandedMessages[messageId] = !(_expandedMessages[messageId] ?? false);
    });
  }

  void _addReaction(ChatMessage message, String emoji) {
    setState(() {
      final currentReactions = message.reactions ?? {};
      final newCount = (currentReactions[emoji] ?? 0) + 1;
      final updatedReactions = Map<String, int>.from(currentReactions);
      updatedReactions[emoji] = newCount;

      final index = _messages.indexWhere((msg) => msg.id == message.id);
      if (index != -1) {
        _messages[index] = _messages[index].copyWith(reactions: updatedReactions);
      }
    });
  }

  void _pinMessage(ChatMessage message) {
    setState(() {
      final index = _messages.indexWhere((msg) => msg.id == message.id);
      if (index != -1) {
        _messages[index] = _messages[index].copyWith(isPinned: true);
        if (!_pinnedMessages.contains(message.id)) {
          _pinnedMessages.add(message.id);
        }
      }
    });

    _navigation.showSnackBar('Сообщение закреплено');
  }

  void _unpinMessage(ChatMessage message) {
    setState(() {
      final index = _messages.indexWhere((msg) => msg.id == message.id);
      if (index != -1) {
        _messages[index] = _messages[index].copyWith(isPinned: false);
        _pinnedMessages.remove(message.id);
      }
    });
  }

  void _playVoiceMessage(ChatMessage message) {
    setState(() {
      _isVoiceMessagePlaying = true;
      _playingVoiceMessageId = message.id;
      _voiceMessageProgress = 0.0;
    });

    _navigation.simulateVoicePlayback(
      message.voiceDuration ?? 0,
          (progress) {
        if (mounted) {
          setState(() {
            _voiceMessageProgress = progress;
            if (progress >= 1.0) {
              _isVoiceMessagePlaying = false;
              _playingVoiceMessageId = '';
              _voiceMessageProgress = 0.0;
            }
          });
        }
      },
    );
  }

  void _stopVoiceMessage() {
    setState(() {
      _isVoiceMessagePlaying = false;
      _playingVoiceMessageId = '';
      _voiceMessageProgress = 0.0;
    });
  }

  void _translateMessage(ChatMessage message) {
    _navigation.translateMessage(message).then((translation) {
      if (mounted && translation != null) {
        setState(() {
          _messageTranslations[message.id] = translation;
        });
      }
    });
  }

  void _deleteMessage(ChatMessage message) {
    _navigation.deleteMessage(
      message: message,
      onDelete: () {
        setState(() {
          _messages.remove(message);
          _filteredMessages.remove(message);
          if (message.isPinned) {
            _pinnedMessages.remove(message.id);
          }
        });
      },
    );
  }
}