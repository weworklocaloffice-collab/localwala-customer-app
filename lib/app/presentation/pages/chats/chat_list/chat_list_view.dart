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
import 'package:user/app/core/models/my_chat_list_response_model.dart';
import 'package:user/app/presentation/pages/chats/chat_list/bloc/chat_list_bloc.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/error_dialog.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/app/presentation/styles/unauthorized_widget.dart';
import 'package:user/app/presentation/styles/cache_network_widget/cache_network_widget_view.dart';
import 'package:user/app/router/app_route_config.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => ChatListBloc()..add(ChatListInitialEvent()), child: const ChatListView());
  }
}

class ChatListView extends StatefulWidget {
  const ChatListView({super.key});

  @override
  State<ChatListView> createState() => _ChatListViewState();
}

class _ChatListViewState extends State<ChatListView> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocConsumer<ChatListBloc, ChatListState>(
      listener: (context, state) {
        if (state.status.isFailure) {
          showErrorDialog(context, state.alertMessage, state.extraMessage, state.statusCode);
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: ThemeProvider.scaffoldPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (state.status.isLoading) ...[
                  const ChatListLoadingView(),
                ] else if (state.status.isFailure) ...[
                  const ChatListErrorView(),
                ] else if (state.status.isEmpty) ...[
                  const ChatListEmptyView(),
                ] else if (state.status.isUnAuthorized) ...[
                  const UnauthorizedWidget(),
                ] else ...[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(state.model.chats!.length, (chatIndex) => ChatListInfoTileView(model: state.model.chats![chatIndex], userId: state.userId)),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class ChatListInfoTileView extends StatelessWidget {
  final ChatConfigModel model;
  final String userId;
  const ChatListInfoTileView({super.key, required this.model, required this.userId});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final String id = userId == model.senderId! ? model.receiverId! : model.senderId!;
        final String name = userId == model.senderId! ? '${model.receiverInfo!.firstName!} ${model.receiverInfo!.lastName!}' : '${model.senderInfo!.firstName!} ${model.senderInfo!.lastName!}';
        Navigator.of(context).pushNamed(AppRouter.messagesRoute, arguments: [id, name]);
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: ThemeProvider.lightDisabledColor, width: 1.5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                userId == model.senderId
                    ? ClipRRect(
                        borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                        child: CacheNetworkImageWidget(width: 30.0, height: 30.0, imageUrl: model.receiverInfo!.image!),
                      )
                    : ClipRRect(
                        borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                        child: CacheNetworkImageWidget(width: 30.0, height: 30.0, imageUrl: model.senderInfo!.image!),
                      ),
                kAppSpacerHorizontal(width: 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    userId == model.senderId
                        ? Text("${model.receiverInfo!.firstName!} ${model.receiverInfo!.lastName!}", style: kAppLblMediumFontBold(context))
                        : Text("${model.senderInfo!.firstName!} ${model.senderInfo!.lastName!}", style: kAppLblMediumFontBold(context)),
                    Text(kAppTrimWord(model.lastMessage!, 30), maxLines: 1, style: kAppLblTinyFontRegular(context)),
                  ],
                ),
              ],
            ),
            Text(model.updatedAt!, style: kAppLblTinyFontRegular(context)),
          ],
        ),
      ),
    );
  }
}

class ChatListLoadingView extends StatelessWidget {
  const ChatListLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
        20,
        (index) => Container(
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.symmetric(vertical: 5),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
          decoration: BoxDecoration(border: Border.all(color: ThemeProvider.lightDisabledColor, width: 1.5)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SkeletonLine(style: SkeletonLineStyle(height: 50, width: 50, borderRadius: BorderRadius.circular(8))),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonLine(
                      style: SkeletonLineStyle(height: 10, width: MediaQuery.of(context).size.width / 1.3, borderRadius: BorderRadius.circular(8)),
                    ),
                    kAppSpacerVertical(height: 10),
                    SkeletonLine(
                      style: SkeletonLineStyle(height: 10, width: MediaQuery.of(context).size.width / 1.5, borderRadius: BorderRadius.circular(8)),
                    ),
                    kAppSpacerVertical(height: 10),
                    SkeletonLine(
                      style: SkeletonLineStyle(height: 10, width: MediaQuery.of(context).size.width / 2.3, borderRadius: BorderRadius.circular(8)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChatListErrorView extends StatelessWidget {
  const ChatListErrorView({super.key});

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

class ChatListEmptyView extends StatelessWidget {
  const ChatListEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        children: [
          kAppSpacerVertical(height: 20),
          Image.asset(AssetsUrl.imageURL.cartEmpty, height: 256, width: 256, fit: BoxFit.fitWidth),
          kAppSpacerVertical(height: 20),
          Text(translate.matching_record_not_found, textAlign: TextAlign.center, style: kAppLblMediumFontBold(context)),
          kAppSpacerVertical(height: 5),
          Text(translate.no_data_reason_one, textAlign: TextAlign.center, style: kAppLblMediumFontRegular(context)),
        ],
      ),
    );
  }
}
// Done //
