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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_skeleton_ui/flutter_skeleton_ui.dart';
import 'package:user/app/core/config/assets_url.dart';
import 'package:user/app/core/models/chat_socket_incoming_message_model.dart';
import 'package:user/app/core/repositories/chat_repository.dart';
import 'package:user/app/presentation/pages/chats/messages/bloc/messages_bloc.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/error_dialog.dart';
import 'package:user/app/services/chat_service_socket_io.dart';
import 'package:user/app/services/uuid_generator.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class MessageScreen extends StatelessWidget {
  final String receiverId;
  final String name;
  const MessageScreen({super.key, required this.receiverId, required this.name});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MessagesBloc()..add(MessagesInitialEvent(receiverId: receiverId, name: name)),
      child: const MessageView(),
    );
  }
}

class MessageView extends StatefulWidget {
  const MessageView({super.key});

  @override
  State<MessageView> createState() => _MessageViewState();
}

class _MessageViewState extends State<MessageView> {
  final ChatService chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollMessages = ScrollController();
  final ChatRepository chatRepository = ChatRepository();
  bool _socketInitialized = false;
  bool _loadMoreInFlight = false;
  // Set from the bloc listener once every message is on screen.
  bool _loadMoreExhausted = false;

  @override
  void initState() {
    super.initState();
    _scrollMessages.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (!_scrollMessages.hasClients) return;
    if (_loadMoreInFlight || _loadMoreExhausted) return;
    if (_scrollMessages.position.pixels <= _scrollMessages.position.minScrollExtent + 24) {
      _loadMoreInFlight = true;
      context.read<MessagesBloc>().add(MessageReceiveLoadMoreEvent());
    }
  }

  Future<void> initSocket(String roomId) async {
    if (_socketInitialized || roomId.isEmpty) return;
    // Socket handshake must carry the access token or the server rejects it.
    final String token = await chatRepository.authToken();
    if (!mounted) return;
    chatService.connectToServer(roomId, token, (data) {
      if (!mounted) return;
      final chatMessage = ChatSocketIncomingMessageModel.fromJson(data);
      context.read<MessagesBloc>().add(MessageReceiveNewMessageEvent(msg: chatMessage));
    });
    _socketInitialized = true;
  }

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
        // Not laid out yet.
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollMessages.dispose();
    chatService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return BlocConsumer<MessagesBloc, MessagesState>(
      listener: (context, state) {
        if (state.status.isFailure || state.status.isCustomError) {
          showErrorDialog(context, state.alertMessage, state.extraMessage, state.statusCode);
        } else if (state.status.isChatInitialize) {
          initSocket(state.chatRoomId);
          jumpToBottom();
        } else if (state.status.isLoadMoreStart || state.status.isLoadMoreEnd) {
          _loadMoreInFlight = false;
          // Stop requesting once every message is on screen, otherwise the
          // scroll listener keeps re-firing an exhausted pager on every pixel.
          final int total = state.model.totalResults ?? 0;
          _loadMoreExhausted = total > 0 && state.model.chats!.length >= total;
          jumpToBottom();
        }
      },
      builder: (context, state) {
        return Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: AppBar(title: Text(state.name), scrolledUnderElevation: 0),
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
                    state.loadMore ? Column(children: [kAppSpacerVertical(height: 20), kAppCenterCircularProgress(context), kAppSpacerVertical(height: 20)]) : const SizedBox(),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(
                        state.model.chats!.length,
                        (index) => state.model.chats![index].senderId! == state.userId
                            ? MessageLeftSideView(message: state.model.chats![index].message!, messageType: state.model.chats![index].messageType!)
                            : MessageRightSideView(message: state.model.chats![index].message!, messageType: state.model.chats![index].messageType!),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          bottomNavigationBar: state.status.isLoading
              ? SafeArea(child: const SizedBox())
              : SafeArea(
                  child: Padding(
                    padding: MediaQuery.of(context).viewInsets,
                    child: Row(
                      children: [
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
                            context.read<MessagesBloc>().add(MessagesSendNewMessageEvent(msg: _messageController.text));
                            chatService.sendMessage(
                              chatRoomId: state.chatRoomId,
                              senderId: state.userId,
                              message: _messageController.text,
                              role: state.authRole,
                              randomId: Uuid().generateV4().toString(),
                              firstName: state.senderFirstName,
                              lastName: state.senderLastName,
                              cover: state.senderCover,
                            );
                            _messageController.clear();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
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

class MessageRightSideView extends StatelessWidget {
  final String message;
  final String messageType;
  const MessageRightSideView({super.key, required this.message, required this.messageType});

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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).disabledColor,
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomRight: Radius.circular(10)),
                  ),
                  child: Text(message, style: kAppLblMediumFontBold(context)),
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
  const MessageLeftSideView({super.key, required this.message, required this.messageType});

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
                        Container(
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                          decoration: BoxDecoration(
                            color: Theme.of(context).disabledColor,
                            borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10)),
                          ),
                          child: Text(message, style: kAppLblMediumFontBold(context)),
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
