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
import 'package:user/app/presentation/pages/chats/@core/bloc/chat_card_bloc.dart';
import 'package:user/app/presentation/pages/chats/chat_list/chat_list_view.dart';
import 'package:user/app/presentation/pages/chats/support_chat_list/support_chat_list_view.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class ChatCardScreen extends StatelessWidget {
  const ChatCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => ChatCardBloc()..add(ChatCardInitialEvent()), child: const ChatCardView());
  }
}

class ChatCardView extends StatefulWidget {
  const ChatCardView({super.key});

  @override
  State<ChatCardView> createState() => _ChatCardViewState();
}

class _ChatCardViewState extends State<ChatCardView> with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(initialIndex: 0, length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Text(translate.chats),
        bottom: TabBar(
          controller: tabController,
          physics: const NeverScrollableScrollPhysics(),
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Theme.of(context).hintColor,
          indicatorColor: Theme.of(context).primaryColor,
          labelStyle: kAppStyleTabTitleStyle(context),
          unselectedLabelStyle: kAppStyleTabTitleStyle(context),
          labelPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          tabs: [Text(translate.direct_chat), Text(translate.support_chat)],
        ),
      ),
      body: TabBarView(controller: tabController, physics: const NeverScrollableScrollPhysics(), children: const [ChatListScreen(), SupportChatListScreen()]),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
// Done //
