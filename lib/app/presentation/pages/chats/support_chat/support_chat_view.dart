/*
 * WeWorkLocal
 * Hyperlocal Commerce, Delivery & Service Platform
 *
 * Copyright © 2026 WeWorkLocal.
 * All Rights Reserved.
 *
 * Website: https://localwala.tech
 * Email: weworklocal1@gmail.com
 *
 * Proprietary and Confidential.
 *
 * WeWorkLocal is a technology platform that connects
 * customers, vendors, service providers, and delivery
 * partners through a unified digital ecosystem.
 *
 * Core features include local commerce, food delivery,
 * service bookings, referral programs, wallet management,
 * real-time tracking, digital payments, and business
 * management solutions.
 *
 * This source code, including all associated assets,
 * APIs, databases, business logic, designs, and
 * documentation, is proprietary to WeWorkLocal.
 *
 * Unauthorized copying, modification, distribution,
 * publication, resale, reverse engineering, or use of
 * this software without prior written authorization is
 * strictly prohibited.
 */

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_skeleton_ui/flutter_skeleton_ui.dart';
import 'package:image_picker/image_picker.dart';
import 'package:user/app/core/config/api_request_service.dart';
import 'package:user/app/core/config/assets_url.dart';
import 'package:user/app/core/models/chat_socket_incoming_message_model.dart';
import 'package:user/app/core/repositories/chat_repository.dart';
import 'package:user/app/presentation/pages/chats/support_chat/bloc/support_chat_bloc.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/cache_network_widget/cache_network_widget_view.dart';
import 'package:user/app/presentation/styles/error_dialog.dart';
import 'package:user/app/router/app_route_config.dart';
import 'package:user/app/services/chat_service_socket_io.dart';
import 'package:user/app/services/local_notification_service.dart';
import 'package:user/app/services/uuid_generator.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class SupportChatScreen extends StatelessWidget {
  final String type;
  final String typeId;
  const SupportChatScreen({super.key, required this.type, required this.typeId});

  @override
  Widget build(BuildContext context) {
    // Bot-first: instant triage (payment pre-questions) in the same ticket
    // thread; human on handover. Classic InitialEvent had no bot replies.
    return BlocProvider(
      create: (context) => SupportChatBloc()..add(SupportChatBotStartEvent(type: type, typeId: typeId)),
      child: const SupportChatView(),
    );
  }
}

class SupportChatView extends StatefulWidget {
  const SupportChatView({super.key});

  @override
  State<SupportChatView> createState() => _SupportChatViewState();
}

class _SupportChatViewState extends State<SupportChatView> {
  final ChatService chatService = ChatService();
  final ChatRepository chatRepository = ChatRepository();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollMessages = ScrollController();
  bool _socketInitialized = false;  bool _loadMoreInFlight = false;
  bool _loadMoreExhausted = false;
  // True while the agent's keystrokes are in flight. Reset by the socket event,
  // never by a timer — a timer would lie during a network stall.
  bool _agentTyping = false;
  bool _uploading = false;
  final ImagePicker _imagePicker = ImagePicker();

  /// Evidence photo: gallery/camera -> client compress (1280px/q70) ->
  /// 1MB guard (server multer cap) -> upload -> img message.
  /// REST-only on purpose: the socket path forces messageType text and would
  /// duplicate the bubble. The agent side polls/refreshes for new messages.
  Future<void> _pickAndSendImage(BuildContext context) async {
    final bloc = context.read<SupportChatBloc>();
    if (bloc.state.chatRoomId.isEmpty || _uploading) return;
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Gallery'),
              onTap: () => Navigator.of(ctx).pop(ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Camera'),
              onTap: () => Navigator.of(ctx).pop(ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (source == null || !context.mounted) return;
    try {
      final XFile? file = await _imagePicker.pickImage(source: source, maxWidth: 1280, maxHeight: 1280, imageQuality: 70);
      if (file == null) return;
      final int bytes = await file.length();
      if (bytes > 1024 * 1024) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Image too large (max 1 MB). Try again.')));
        }
        return;
      }
      if (mounted) setState(() => _uploading = true);
      final String uid = bloc.state.userId;
      final res = await chatRepository.uploadSupportImage(uid, file);
      if (!context.mounted) return;
      dynamic body;
      try {
        body = jsonDecode(res.body);
      } catch (_) {
        body = null;
      }
      final String? path = body is Map ? (body['path'] ?? body['imageUrl'] ?? body['url'])?.toString() : null;
      if (res.errorType == NetErrorType.none && path != null && path.isNotEmpty) {
        bloc.add(SupportChatSendNewMessageEvent(msg: path, msgType: 'img'));
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Upload failed. Try again.')));
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not pick image.')));
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    LocalNotificationService.supportChatOpen = true;
    _scrollMessages.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (!_scrollMessages.hasClients) return;
    // `pixels == minScrollExtent` is exact-equality on a float; it fires on the
    // same pixel row repeatedly while a bounce settles, which fired a burst of
    // overlapping page requests. A small threshold plus an in-flight guard
    // stops that.
    if (!_loadMoreInFlight && !_loadMoreExhausted && _scrollMessages.position.pixels <= _scrollMessages.position.minScrollExtent + 24) {
      _loadMoreInFlight = true;
      context.read<SupportChatBloc>().add(SupportChatReceiveLoadMoreEvent());
    }
  }

  Future<void> initSocket(String roomId) async {
    if (_socketInitialized || roomId.isEmpty) return;
    // The socket must present the access token or the server rejects the
    // handshake outright and the user receives nothing.
    final String token = await chatRepository.authToken();
    if (!mounted) return;
    chatService.connectToServer(roomId, token, (data) {
      if (!mounted) return;
      final chatMessage = ChatSocketIncomingMessageModel.fromJson(data);
      final bloc = context.read<SupportChatBloc>();
      // An arriving message from the other side ends their typing stream.
      // This clears a stale indicator even if the sender's `typing:false`
      // event was lost.
      if (chatMessage.senderId != bloc.state.userId && _agentTyping) {
        setState(() => _agentTyping = false);
      }
      bloc.add(SupportChatReceiveNewMessageEvent(msg: chatMessage));
      // Mark the incoming message read so the agent's ticks turn. The id may
      // be a socket randomId the server has not persisted under; the server
      // marks everything up to it read regardless.
      final String? incomingId = chatMessage.messageId ?? chatMessage.randomId;
      if (incomingId != null && incomingId.isNotEmpty) {
        chatService.sendMessageRead(roomId, incomingId);
      }
    });
    // Agent typing indicator. Guarded by room so a late event for a previous
    // ticket cannot paint state on this one.
    chatService.onTyping((data) {
      if (!mounted) return;
      final Map<String, dynamic> event = data is Map<String, dynamic> ? data : <String, dynamic>{};
      if (event['chatRoomId'] != null && event['chatRoomId'].toString() != roomId) return;
      setState(() {
        _agentTyping = event['isTyping'] == true;
      });
    });
    // Read receipts: agent saw our messages -> flip own ticks to read.
    chatService.onMessageRead((data) {
      if (!mounted) return;
      final Map<String, dynamic> event = data is Map<String, dynamic> ? data : <String, dynamic>{};
      if (event['chatRoomId'] != null && event['chatRoomId'].toString() != roomId) return;
      context.read<SupportChatBloc>().add(SupportChatReadReceiptEvent());
    });
    // Failed socket persist: remove that bubble instead of leaving it as if
    // it had been delivered.
    chatService.onMessageFailed((data) {
      if (!mounted) return;
      final Map<String, dynamic> event = data is Map<String, dynamic> ? data : <String, dynamic>{};
      if (event['chatRoomId'] != null && event['chatRoomId'].toString() != roomId) return;
      final String failedId = event['randomId']?.toString() ?? '';
      if (failedId.isEmpty) return;
      context.read<SupportChatBloc>().add(SupportChatSendFailedEvent(randomId: failedId));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Message not delivered. Try again.')));
    });
    _socketInitialized = true;
  }

  /// Tell the agent everything on screen is seen (covers messages that
  /// arrived while away). Delayed: the socket connects asynchronously.
  void _markSeenDelayed(String roomId, String? lastId) {
    if (roomId.isEmpty || lastId == null || lastId.isEmpty) return;
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      chatService.sendMessageRead(roomId, lastId);
    });
  }

  /// Scroll to newest message.
  ///
  /// The old `jumpTo(maxScrollExtent + 120)` threw whenever the list had not
  /// been laid out yet (very common on the first state after load), because
  /// there is no content past `maxScrollExtent` to jump to.
  void jumpToBottom() {
    if (!_scrollMessages.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollMessages.hasClients) return;
      try {
        _scrollMessages.animateTo(
          _scrollMessages.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      } catch (_) {
        // List not laid out yet — the next frame will land it.
      }
    });
  }

  @override
  void dispose() {
    LocalNotificationService.supportChatOpen = false;
    _messageController.dispose();
    _scrollMessages.dispose();
    chatService.disconnect();
    super.dispose();
  }

  /// Server action -> chip. Unknown actions return null (dropped).
  /// The message is the user phrasing that triggers the intent server-side.
  static Map<String, Object>? _chipForAction(String action) {
    switch (action) {
      case 'track_order':
        return const {
          'icon': Icons.track_changes_outlined,
          'label': 'Where is my order?',
          'message': 'Where is my order?',
        };
      case 'payment_failed':
        return const {
          'icon': Icons.payment_outlined,
          'label': 'Payment failed, money deducted',
          'message': 'My payment failed but money was deducted. Please check.',
        };
      case 'check_payment_status':
        return const {
          'icon': Icons.manage_search_outlined,
          'label': 'Check payment status',
          'message': 'What is my payment status?',
        };
      case 'check_refund_status':
        return const {
          'icon': Icons.receipt_long_outlined,
          'label': 'Check refund status',
          'message': 'What is my refund status?',
        };
      case 'request_refund':
        return const {
          'icon': Icons.refresh_outlined,
          'label': 'Request refund',
          'message': 'I want a refund for my order.',
        };
      case 'cancel_order':
        return const {
          'icon': Icons.cancel_outlined,
          'label': 'Cancel my order',
          'message': 'I want to cancel my order.',
        };
      case 'call_rider':
        return const {
          'icon': Icons.delivery_dining_outlined,
          'label': 'Contact rider',
          'message': 'I want to contact the delivery rider.',
        };
      case 'talk_to_human':
        return null; // Dedicated button below already covers this.
      default:
        return null;
    }
  }

  /// Visible chips: server actions win; snapshot chooser fills the gap
  /// before the first bot turn (actions empty until then).
  static List<Map<String, Object>> _visibleChips(List<String> actions, Map<String, dynamic>? snap) {
    final fromServer = <Map<String, Object>>[];
    for (final a in actions) {
      final chip = _chipForAction(a);
      if (chip != null) fromServer.add(chip);
    }
    if (fromServer.isNotEmpty) return fromServer;
    return _quickReplies(snap);
  }

  /// Contextual quick questions from the live snapshot (state-driven).
  /// Placed/active -> track + cancel; pending -> payment triage; ongoing ->
  /// track + agent (rider intent is a backend gap, tracked separately);
  /// delivered/cancelled -> refund; dining/tiffin -> booking variants.
  /// No snapshot yet -> generic track/cancel pair (bot degrades gracefully).
  static List<Map<String, Object>> _quickReplies(Map<String, dynamic>? snap) {
    const payTriage = [
      {
        'icon': Icons.payment_outlined,
        'label': 'Payment failed, money deducted',
        'message': 'My payment failed but money was deducted. Please check.',
      },
      {
        'icon': Icons.receipt_long_outlined,
        'label': 'Check refund status',
        'message': 'What is my refund status?',
      },
    ];
    if (snap == null) {
      return const [
        {
          'icon': Icons.track_changes_outlined,
          'label': 'Where is my order?',
          'message': 'Where is my order?',
        },
        {
          'icon': Icons.cancel_outlined,
          'label': 'Cancel my order',
          'message': 'I want to cancel my order.',
        },
      ];
    }
    final kind = (snap['kind'] ?? 'orders').toString();
    if (kind == 'dining' || kind == 'tiffin_subscription') {
      return const [
        {
          'icon': Icons.track_changes_outlined,
          'label': 'Where is my booking?',
          'message': 'Where is my booking?',
        },
        {
          'icon': Icons.cancel_outlined,
          'label': 'Cancel booking',
          'message': 'I want to cancel my booking.',
        },
      ];
    }
    final status = (snap['status'] ?? '').toString();
    final pay = snap['payment'] is Map ? Map<String, dynamic>.from(snap['payment'] as Map) : null;
    final payPending = status == 'pending_payments' || (pay != null && pay['status'] == 'initiated');
    if (payPending) return payTriage;
    if (status == 'delivered') {
      return const [
        {
          'icon': Icons.refresh_outlined,
          'label': 'Request refund',
          'message': 'I want a refund for my order.',
        },
        {
          'icon': Icons.receipt_long_outlined,
          'label': 'Check refund status',
          'message': 'What is my refund status?',
        },
      ];
    }
    if (status == 'cancelled' || status == 'rejected' || status == 'refunded') {
      return const [
        {
          'icon': Icons.receipt_long_outlined,
          'label': 'Check refund status',
          'message': 'What is my refund status?',
        },
      ];
    }
    return const [
      {
        'icon': Icons.track_changes_outlined,
        'label': 'Where is my order?',
        'message': 'Where is my order?',
      },
      {
        'icon': Icons.cancel_outlined,
        'label': 'Cancel my order',
        'message': 'I want to cancel my order.',
      },
    ];
  }

  /// Human-owned text has one writer: the socket persists and broadcasts it.
  /// REST is only the offline fallback. Sending through both wrote the same
  /// text twice, which is exactly the duplicate pair in the report.
  void _sendHumanText(BuildContext context, dynamic state, String text) {
    final String message = text.trim();
    if (state.chatRoomId.isEmpty || message.isEmpty) return;
    final String randomId = Uuid().generateV4().toString();
    // Show the bubble immediately. Without this the message exists on the
    // server after a REST fallback but the customer sees nothing until a
    // refresh replaces the list.
    context.read<SupportChatBloc>().add(
          SupportChatOptimisticSendEvent(message: message, randomId: randomId),
        );
    final bool sent = chatService.sendMessage(
      chatRoomId: state.chatRoomId,
      senderId: state.userId,
      message: message,
      role: state.authRole,
      randomId: randomId,
      firstName: state.senderFirstName,
      lastName: state.senderLastName,
      cover: state.senderCover,
    );
    if (!sent) {
      context.read<SupportChatBloc>().add(
            SupportChatSendNewMessageEvent(msg: message, randomId: randomId),
          );
      return;
    }
    chatService.sendTyping(state.chatRoomId, false);
  }

  /// Per-bubble clock time (`hh:mm AM`). Unparseable stamps render blank
  /// rather than crashing the list.
  static String _bubbleTime(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    try {
      final dt = DateTime.parse(iso).toLocal();
      final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final mm = dt.minute.toString().padLeft(2, '0');
      return '$h:$mm ${dt.hour < 12 ? 'AM' : 'PM'}';
    } catch (_) {
      return '';
    }
  }

  /// Human-state shortcuts, status-aware. Kept to three so the composer
  /// never drowns in chips.
  static List<Map<String, Object>> _humanChips(Map<String, dynamic>? snap) {
    final status = (snap?['status'] ?? '').toString();
    final pay = snap?['payment'] is Map ? Map<String, dynamic>.from(snap!['payment'] as Map) : null;
    final payPending = status == 'pending_payments' || (pay != null && pay['status'] == 'initiated');
    if (payPending) {
      return const [
        {
          'icon': Icons.payment_outlined,
          'label': 'I have paid',
          'message': 'I have completed the payment. Please confirm.',
        },
        {
          'icon': Icons.error_outline,
          'label': 'Payment failed',
          'message': 'My payment failed. Please help.',
        },
      ];
    }
    if (status == 'delivered') {
      return const [
        {
          'icon': Icons.refresh_outlined,
          'label': 'Request refund',
          'message': 'I want a refund for my order.',
        },
        {
          'icon': Icons.receipt_long_outlined,
          'label': 'Refund status',
          'message': 'What is my refund status?',
        },
      ];
    }
    return const [
      {
        'icon': Icons.hourglass_empty_outlined,
        'label': 'Still waiting',
        'message': 'I am still waiting. Any update?',
      },
      {
        'icon': Icons.cancel_outlined,
        'label': 'Cancel request',
        'message': 'I want to cancel. Please help.',
      },
      {
        'icon': Icons.call_outlined,
        'label': 'Call me',
        'message': 'Please call me to resolve this faster.',
      },
    ];
  }

  /// Quick-reply sender: bot-owned ticket -> BotMessage (instant triage
  /// reply); human-owned -> socket-only. Never both transports at once.
  void _sendQuick(BuildContext context, String text) {
    final bloc = context.read<SupportChatBloc>();
    final s = bloc.state;
    if (s.chatRoomId.isEmpty) return;
    if (s.handoverState == 'bot') {
      bloc.add(SupportChatBotMessageEvent(message: text));
      return;
    }
    _sendHumanText(context, s, text);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return BlocConsumer<SupportChatBloc, SupportChatState>(
      listener: (context, state) {
        if (state.status.isFailure || state.status.isCustomError) {
          showErrorDialog(context, state.alertMessage, state.extraMessage, state.statusCode);
        } else if (state.status.isChatInitialize || state.status.isBotReplied) {
          initSocket(state.chatRoomId);
          jumpToBottom();
          // Mark-all-seen for anything that arrived while away.
          final chats = state.model.chats;
          if (chats != null && chats.isNotEmpty) {
            final last = chats.last;
            _markSeenDelayed(state.chatRoomId, last.id ?? last.randomId);
          }
        } else if (state.status.isBotThinking) {
          // Own bubble + typing must scroll into view like every reply.
          jumpToBottom();
        } else if (state.status.isScrollDown) {
          jumpToBottom();
        } else if (state.status.isLoadMoreStart || state.status.isLoadMoreEnd) {
          _loadMoreInFlight = false;
          // Stop asking once every message is on screen — otherwise the scroll
          // listener keeps re-firing an exhausted pager on every pixel.
          final int total = state.model.totalResults ?? 0;
          _loadMoreExhausted = total > 0 && state.model.chats!.length >= total;
          jumpToBottom();
        }
      },
      builder: (context, state) {
        return Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: AppBar(title: Text(translate.support_chat), scrolledUnderElevation: 0),
          body: SingleChildScrollView(
            controller: _scrollMessages,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (state.status.isLoading) ...[
                    const MessageLoadingView(),
                  ] else if (state.status.isFailure) ...[
                    const MessageErrorView(),
                  ] else ...[
                    // Live order card the bot resolved straight from the DB.
                    if (state.orderSnapshot != null && state.orderSnapshot!.isNotEmpty)
                      _OrderSnapshotCard(snapshot: state.orderSnapshot!),
                    // Persistent agent header: who owns this ticket, on every
                    // open — not just the moment they join.
                    if (state.agentName.isNotEmpty && state.handoverState != 'resolved')
                      _AgentHeader(agentName: state.agentName, agentAvatar: state.agentAvatar),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(
                        state.model.chats!.length,
                        (index) {
                          final m = state.model.chats![index];
                          // Ownership: senderId alone lies for bot turns (bot
                          // reuses the customer's id). Role breaks the tie:
                          // only plain user turns sit on the customer's side.
                          final role = (m.senderRole ?? '').toLowerCase();
                          final isOwn = m.senderId! == state.userId && (role.isEmpty || role == 'user');
                          if (isOwn) {
                            return MessageLeftSideView(
                                message: m.message!, messageType: m.messageType!, read: m.readStatus == 'read', time: _bubbleTime(m.createdAt));
                          }
                          final label = role == 'bot'
                              ? 'Bot'
                              : role == 'system'
                                  ? 'System'
                                  : (state.agentName.isNotEmpty ? state.agentName : 'Support');
                          return MessageRightSideView(
                              message: m.message!,
                              messageType: m.messageType!,
                              senderLabel: label,
                              isBot: role == 'bot',
                              time: _bubbleTime(m.createdAt),
                              senderAvatar: (role != 'bot' && role != 'system') ? state.agentAvatar : '');
                        },
                      ),
                    ),
                    if (state.status.isBotThinking) const _BotTypingIndicator(),
                    if (_agentTyping) const _AgentTypingIndicator(),
                    // Queue transparency: while the ticket waits for a human,
                    // say exactly where it stands instead of going quiet. The
                    // position comes from the server, so a stale number here
                    // means a stale fetch, not a guess.
                    if ((state.handoverState == 'queued' || state.handoverState == 'assigned') && state.queuePosition > 0)
                      _QueuePositionBanner(position: state.queuePosition),
                    // Handover in flight or freshly assigned: always say so.
                    // Previously an instant assign (position 0) showed nothing.
                    if (state.handoverState == 'queued' && state.queuePosition <= 0)
                      const _ConnectingBanner(),
                    if (state.handoverState == 'assigned' && state.queuePosition <= 0)
                      _AgentJoinedBanner(agentName: state.agentName, agentAvatar: state.agentAvatar),
                    // CSAT is only offered on a finished ticket, once, and never
                    // after the customer has already rated it.
                    if (state.handoverState == 'resolved' && state.csatScore == 0)
                      _CsatSheet(
                        onRate: (int score, String comment) {
                          context.read<SupportChatBloc>().add(SupportChatCsatEvent(score: score, comment: comment));
                        },
                      ),
                    // Explicit resolved marker, Swiggy-style: the ticket is
                    // closed, rated or not.
                    if (state.handoverState == 'resolved')
                      Container(
                        margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.grey, size: 18),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                state.csatScore > 0
                                    ? 'Marked as resolved. Thanks for rating us ${state.csatScore}/5.'
                                    : 'Marked as resolved.',
                                style: kAppLblSmallFontMedium(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    // The ticket is closed but still inside the 48h window the
                    // server enforces. Reopening continues this thread; without
                    // this the only path is a duplicate ticket.
                    if (state.handoverState == 'resolved')
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                        child: SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => context.read<SupportChatBloc>().add(SupportChatReopenEvent()),
                            icon: const Icon(Icons.replay),
                            label: const Text('Reopen this chat'),
                          ),
                        ),
                      ),
                    state.loadMore ? Column(children: [kAppSpacerVertical(height: 20), kAppCenterCircularProgress(context), kAppSpacerVertical(height: 20)]) : const SizedBox(),
                  ],
                ],
              ),
            ),
          ),
          // Bot -> human escalation. Shown only while the bot still owns the
          // ticket, so the customer is never asked to ask for something they
          // already have.
          bottomNavigationBar: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // In-chat order actions: deep-link history detail (single
                // repay/cancel implementation lives there). Repay only while
                // payment is pending; Open order for every orders ticket.
                if (state.subjectId.isNotEmpty &&
                    state.orderSnapshot != null &&
                    (state.orderSnapshot!['kind'] ?? 'orders') == 'orders')
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Row(
                      children: [
                        if ((state.orderSnapshot!['status'] ?? '') == 'pending_payments')
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => Navigator.of(context).pushNamed(
                                  AppRouter.historyDetailRoute,
                                  arguments: [state.subjectId]),
                              icon: const Icon(Icons.payment_outlined, size: 16),
                              label: const Text('Repay now', style: TextStyle(fontSize: 13)),
                            ),
                          ),
                        if ((state.orderSnapshot!['status'] ?? '') == 'pending_payments')
                          const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => Navigator.of(context).pushNamed(
                                AppRouter.historyDetailRoute,
                                arguments: [state.subjectId]),
                            icon: const Icon(Icons.receipt_long_outlined, size: 16),
                            label: const Text('Open order', style: TextStyle(fontSize: 13)),
                          ),
                        ),
                      ],
                    ),
                  ),
                // Quick questions: server actions first (single source of truth
                // from the last bot turn), snapshot chooser as fallback before
                // the first turn. Unknown server actions are dropped.
                if ((state.handoverState == 'bot' || state.handoverState.isEmpty) &&
                    _visibleChips(state.botActions, state.orderSnapshot).isNotEmpty)                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Wrap(
                        alignment: WrapAlignment.start,
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          for (final q in _visibleChips(state.botActions, state.orderSnapshot))
                            ActionChip(
                              backgroundColor: Theme.of(context).colorScheme.surface,
                              side: BorderSide(color: Theme.of(context).primaryColor),
                              avatar: Icon(q['icon'] as IconData, size: 16, color: Theme.of(context).primaryColor),
                              label: Text(q['label'] as String,
                                  style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface)),
                              onPressed: () => _sendQuick(context, q['message'] as String),
                            ),
                        ],
                      ),
                    ),
                  ),
                // Human-state shortcuts: server-driven chips first (managed
                // from Canned replies), built-in status-aware set as fallback.
                // Sends go through the same socket-only path as typed text.
                if (state.handoverState == 'queued' ||
                    state.handoverState == 'assigned' ||
                    state.handoverState == 'human')
                  _HumanChipsRow(
                    serverChips: state.humanChips,
                    fallbackChips: _humanChips(state.orderSnapshot),
                    onTap: (message) => _sendQuick(context, message),
                  ),
                if (state.handoverState == 'bot')
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => context.read<SupportChatBloc>().add(SupportChatHandoverEvent()),
                        icon: const Icon(Icons.support_agent),
                        label: Text(translate.talk_to_agent),
                      ),
                    ),
                  ),
                Padding(
                    padding: MediaQuery.of(context).viewInsets,
                    child: Row(
                      children: [
                        IconButton(
                          icon: _uploading
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.attach_file_outlined),
                          onPressed: _uploading ? null : () => _pickAndSendImage(context),
                        ),
                        Expanded(
                    child: Container(
                      decoration: BoxDecoration(color: Theme.of(context).disabledColor, borderRadius: BorderRadius.circular(20)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: TextField(
                          controller: _messageController,
                          minLines: 1,
                          maxLines: 5,
                          textInputAction: TextInputAction.done,
                          // Tells the agent the customer is typing. Keyed off
                          // non-blank content so clearing the field reads as
                          // stopped, not as an empty keystroke.
                          onChanged: (String value) {
                            final String roomId = context.read<SupportChatBloc>().state.chatRoomId;
                            if (roomId.isNotEmpty) {
                              chatService.sendTyping(roomId, value.trim().isNotEmpty);
                            }
                          },
                          decoration: InputDecoration(
                            hintText: translate.type_message,
                            labelStyle: TextStyle(fontSize: Theme.of(context).textTheme.labelMedium?.fontSize, fontFamily: 'medium', color: Theme.of(context).canvasColor),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Theme.of(context).canvasColor),
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Theme.of(context).canvasColor),
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                          ),
                          style: kAppLblSmallFontMedium(context),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      final bloc = context.read<SupportChatBloc>();
                      final st = bloc.state;
                      if (st.chatRoomId.isEmpty || _messageController.text.trim().isEmpty) return;
                      // Bot owns the ticket -> bot turn (instant reply).
                      // Human owns it -> socket-only text to the agent.
                      if (st.handoverState == 'bot') {
                        bloc.add(SupportChatBotMessageEvent(message: _messageController.text));
                        _messageController.clear();
                        return;
                      }
                      final String text = _messageController.text;
                      _messageController.clear();
                      _sendHumanText(context, st, text);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  },
);
}
}

/// Evidence photo bubble. Uses the cached widget (mediaUrl prefix + blocs)
/// so relative upload paths resolve; full URLs pass through.
class _ChatImage extends StatelessWidget {
  final String path;
  final bool alignRight;
  const _ChatImage({required this.path, this.alignRight = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: alignRight ? 10 : 0),
      constraints: const BoxConstraints(maxWidth: 220, maxHeight: 220),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: CacheNetworkImageWidget(width: 220, height: 180, imageUrl: path, fit: BoxFit.cover),
      ),
    );
  }
}

class MessageRightSideView extends StatelessWidget {  final String message;
  final String messageType;
  final String senderLabel;
  final bool isBot;
  final String time;
  final String senderAvatar;
  const MessageRightSideView(
      {super.key, required this.message, required this.messageType, this.senderLabel = 'Support', this.isBot = false, this.time = '', this.senderAvatar = ''});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      width: MediaQuery.of(context).size.width - 120,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Flexible(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (senderAvatar.startsWith('http'))
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: CircleAvatar(radius: 9, backgroundImage: NetworkImage(senderAvatar)),
                      ),
                    Flexible(
                      child: Text(senderLabel,
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: isBot ? const Color(0xFFB45309) : Colors.grey)),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                if (messageType == 'img')
                  _ChatImage(path: message, alignRight: false)
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    decoration: BoxDecoration(
                      color: isBot ? const Color(0xFFFEF3C7) : Theme.of(context).disabledColor,
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomRight: Radius.circular(10)),
                    ),
                    child: Text(message, style: kAppLblMediumFontBold(context)),
                  ),
                if (time.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(time, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MessageLeftSideView extends StatelessWidget {
  final String message;
  final String messageType;
  final bool read;
  final String time;
  const MessageLeftSideView({super.key, required this.message, required this.messageType, this.read = false, this.time = ''});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              width: MediaQuery.of(context).size.width - 120,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Flexible(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (messageType == 'img')
                          _ChatImage(path: message, alignRight: true)
                        else
                          Container(
                            margin: const EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10)),
                            ),
                            child: Text(message,
                                style: kAppLblMediumFontBold(context).copyWith(color: Colors.white)),
                          ),
                        const SizedBox(height: 2),
                        // Read receipt: single tick sent, double-blue read.
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (time.isNotEmpty)
                              Text(time, style: const TextStyle(fontSize: 10, color: Colors.white70)),
                            const SizedBox(width: 4),
                            Icon(read ? Icons.done_all : Icons.done,
                                size: 14, color: read ? Colors.lightBlueAccent : Colors.white70),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class MessageLoadingView extends StatelessWidget {
  const MessageLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(10, (index) {
        bool isLeftBubble = index % 2 == 0;
        return isLeftBubble
            ? Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.only(bottom: 5),
                        width: MediaQuery.of(context).size.width - 120,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Flexible(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(right: 5),
                                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                                    decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10)),
                                    ),
                                    child: SkeletonLine(
                                      style: SkeletonLineStyle(height: 30, width: MediaQuery.of(context).size.width / 1.4, borderRadius: BorderRadius.circular(8)),
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(right: 5),
                                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                                    decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10)),
                                    ),
                                    child: SkeletonLine(
                                      style: SkeletonLineStyle(height: 30, width: MediaQuery.of(context).size.width / 1.3, borderRadius: BorderRadius.circular(8)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              )
            : Container(
                margin: const EdgeInsets.only(bottom: 5),
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Flexible(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomRight: Radius.circular(10)),
                            ),
                            child: SkeletonLine(
                              style: SkeletonLineStyle(height: 30, width: MediaQuery.of(context).size.width / 1.8, borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomRight: Radius.circular(10)),
                            ),
                            child: SkeletonLine(
                              style: SkeletonLineStyle(height: 30, width: MediaQuery.of(context).size.width / 1.3, borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
      }),
    );
  }
}

class MessageErrorView extends StatelessWidget {
  const MessageErrorView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        children: [
          kAppSpacerVertical(height: 20),
          Image.asset(AssetsUrl.imageURL.homeEmpty, height: 256, width: 256, fit: BoxFit.fitWidth),
          kAppSpacerVertical(height: 20),
          Text(translate.empty_data_two, textAlign: TextAlign.center, style: kAppLblMediumFontRegular(context)),
        ],
      ),
    );
  }
}
// Done //

/// Live order/booking card the bot resolved from the database, so the customer
/// sees the answer rather than having to ask a human for it.
class _OrderSnapshotCard extends StatelessWidget {
  const _OrderSnapshotCard({required this.snapshot});

  final Map<String, dynamic> snapshot;

  @override
  Widget build(BuildContext context) {
    final String? orderNo = snapshot['orderNo']?.toString();
    final String status = snapshot['status']?.toString() ?? '-';
    final String? restaurant = snapshot['restaurantName']?.toString();
    final String? total = snapshot['total']?.toString();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.receipt_long, size: 18),
              const SizedBox(width: 8),
              Text(
                orderNo != null ? 'Order #${_shortId(orderNo)}' : 'Your request',
                style: kAppLblLargeFontMedium(context),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor(context, status).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: kAppLblSmallFontMedium(context).copyWith(color: _statusColor(context, status)),
                ),
              ),
            ],
          ),
          if (restaurant != null && restaurant.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(restaurant, style: kAppLblSmallFontRegular(context)),
          ],
          if (total != null && total.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text('Total: ${double.tryParse(total)?.toStringAsFixed(2) ?? total}',
                style: kAppLblSmallFontRegular(context)),
          ],
          if (snapshot['payment'] is Map) ...[
            const SizedBox(height: 8),
            _PaymentSnapshotRow(payment: Map<String, dynamic>.from(snapshot['payment'] as Map)),
          ],
        ],
      ),
    );
  }

  static String _shortId(String id) {
    return id.length > 6 ? id.substring(id.length - 6) : id;
  }

  static Color _statusColor(BuildContext context, String status) {
    if (status == 'delivered' || status == 'completed') {
      return Colors.green;
    }
    if (status == 'cancelled' || status == 'rejected' || status == 'refunded') {
      return Colors.red;
    }
    return Colors.orange;
  }
}

/// Payment pre-question context: live initiation state on the order card,
/// so "money deducted but order failed" is answered without asking a human.
class _PaymentSnapshotRow extends StatelessWidget {
  const _PaymentSnapshotRow({required this.payment});

  final Map<String, dynamic> payment;

  @override
  Widget build(BuildContext context) {
    final status = (payment['status'] ?? '').toString();
    final method = (payment['method'] ?? '').toString();
    final pid = (payment['razorpayPaymentId'] ?? '').toString();
    final amount = payment['amount'];
    final amountStr = amount == null ? '' : '₹${double.tryParse('$amount')?.toStringAsFixed(2) ?? '$amount'}';
    final Color color = status == 'paid' ? Colors.green : Colors.orange;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(status == 'paid' ? Icons.check_circle : Icons.hourglass_bottom, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              status == 'paid'
                  ? 'Payment confirmed${amountStr.isNotEmpty ? ' $amountStr' : ''}${method.isNotEmpty ? ' via $method' : ''}${pid.isNotEmpty ? ' • $pid' : ''}'
                  : 'Payment ${amountStr.isNotEmpty ? '$amountStr ' : ''}not confirmed yet${method.isNotEmpty ? ' ($method)' : ''} — auto-heals on capture, or Repay to retry',
              style: kAppLblSmallFontRegular(context),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shown while the bot is deciding. Keeps the transcript visible instead of
/// blanking the screen the way a full-page spinner did.
class _BotTypingIndicator extends StatelessWidget {
  const _BotTypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
          const SizedBox(width: 12),
          Text('Support assistant is typing...', style: kAppLblSmallFontRegular(context)),
        ],
      ),
    );
  }
}

// Done //

/// Post-resolution rating. Shown once per ticket; `csatScore` in the state
/// hides it permanently after a rating is recorded.
class _CsatSheet extends StatefulWidget {
  const _CsatSheet({required this.onRate});

  final void Function(int score, String comment) onRate;

  @override
  State<_CsatSheet> createState() => _CsatSheetState();
}

class _CsatSheetState extends State<_CsatSheet> {
  int _score = 0;
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('How would you rate our support?', style: kAppLblLargeFontMedium(context)),
          const SizedBox(height: 12),
          Row(
            children: List.generate(5, (int i) {
              final int value = i + 1;
              return IconButton(
                onPressed: () => setState(() => _score = value),
                iconSize: 30,
                icon: Icon(
                  value <= _score ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: Colors.amber,
                ),
              );
            }),
          ),
          if (_score > 0) ...[
            const SizedBox(height: 8),
            TextField(
              controller: _commentController,
              maxLines: 2,
              decoration: const InputDecoration(hintText: 'Add a comment (optional)'),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: () => widget.onRate(_score, _commentController.text.trim()),
                child: const Text('Submit'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Done //

/// Shown while the agent is typing. Separate from `_BotTypingIndicator` so the
/// customer can tell a human from the bot at a glance.
class _AgentTypingIndicator extends StatelessWidget {
  const _AgentTypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
          const SizedBox(width: 12),
          Text('Agent is typing...', style: kAppLblSmallFontRegular(context)),
        ],
      ),
    );
  }
}

// Done //

/// Queue transparency banner. Shown only while the ticket waits for a human
/// and only when the server reported a real position — never a guess.
class _QueuePositionBanner extends StatelessWidget {
  const _QueuePositionBanner({required this.position});

  final int position;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.hourglass_bottom, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              position == 1
                  ? 'You are next in line for an agent.'
                  : 'You are #$position in line for an agent.',
              style: kAppLblSmallFontMedium(context),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shown between handover tap and queue/assign state settling.
class _ConnectingBanner extends StatelessWidget {
  const _ConnectingBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
          const SizedBox(width: 10),
          Expanded(child: Text('Connecting you to a support agent…', style: kAppLblSmallFontMedium(context))),
        ],
      ),
    );
  }
}

/// Human-state chip row: server chips win, built-in status-aware set fills in.
class _HumanChipsRow extends StatelessWidget {
  const _HumanChipsRow({required this.serverChips, required this.fallbackChips, required this.onTap});

  final List<Map<String, String>> serverChips;
  final List<Map<String, Object>> fallbackChips;
  final void Function(String message) onTap;

  @override
  Widget build(BuildContext context) {
    final bool useServer = serverChips.isNotEmpty;
    final int count = useServer ? serverChips.length : fallbackChips.length;
    if (count == 0) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Wrap(
          alignment: WrapAlignment.start,
          spacing: 8,
          runSpacing: 4,
          children: [
            for (var i = 0; i < count; i++)
              ActionChip(
                backgroundColor: Theme.of(context).colorScheme.surface,
                side: BorderSide(color: Theme.of(context).primaryColor),
                avatar: Icon(
                  useServer ? Icons.flash_on_outlined : (fallbackChips[i]['icon'] as IconData),
                  size: 16,
                  color: Theme.of(context).primaryColor,
                ),
                label: Text(
                  useServer ? serverChips[i]['label']! : (fallbackChips[i]['label'] as String),
                  style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface),
                ),
                onPressed: () => onTap(useServer ? serverChips[i]['message']! : (fallbackChips[i]['message'] as String)),
              ),
          ],
        ),
      ),
    );
  }
}

/// Persistent ticket owner header: avatar + name on every open while a human
/// owns the ticket.
class _AgentHeader extends StatelessWidget {
  const _AgentHeader({required this.agentName, this.agentAvatar = ''});

  final String agentName;
  final String agentAvatar;

  String get _initials {
    final parts = agentName.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (parts.isEmpty) return 'S';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: Colors.blue,
            backgroundImage: agentAvatar.startsWith('http') ? NetworkImage(agentAvatar) : null,
            child: agentAvatar.startsWith('http')
                ? null
                : Text(_initials, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(agentName, style: kAppLblSmallFontMedium(context)),
                const Text('Support agent', style: TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          const Icon(Icons.verified, color: Colors.blue, size: 16),
        ],
      ),
    );
  }
}

/// Shown the moment an agent joins (even at queue position 0).
class _AgentJoinedBanner extends StatelessWidget {
  const _AgentJoinedBanner({required this.agentName, this.agentAvatar = ''});

  final String agentName;
  final String agentAvatar;

  String get _initials {
    final parts = agentName.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (parts.isEmpty) return 'S';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.green,
            backgroundImage: agentAvatar.startsWith('http') ? NetworkImage(agentAvatar) : null,
            child: agentAvatar.startsWith('http')
                ? null
                : Text(_initials, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              agentName.isNotEmpty ? '$agentName (support) joined the chat.' : 'A support agent joined the chat.',
              style: kAppLblSmallFontMedium(context),
            ),
          ),
        ],
      ),
    );
  }
}

// Done //
