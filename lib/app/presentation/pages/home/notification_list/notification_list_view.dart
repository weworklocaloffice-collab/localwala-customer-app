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
import 'package:user/app/presentation/pages/home/notification_list/bloc/notification_list_bloc.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/error_dialog.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class NotificationListScreen extends StatelessWidget {
  const NotificationListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => NotificationListBloc()..add(NotificationListInitialEvent()), child: const NotificationListView());
  }
}

class NotificationListView extends StatefulWidget {
  const NotificationListView({super.key});

  @override
  State<NotificationListView> createState() => _NotificationListViewState();
}

class _NotificationListViewState extends State<NotificationListView> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  final ScrollController _scrollMoreNotification = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollMoreNotification.addListener(() {
      if (_scrollMoreNotification.position.pixels == _scrollMoreNotification.position.maxScrollExtent) {
        context.read<NotificationListBloc>().add(NotificationListLoadMoreEvent());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return BlocConsumer<NotificationListBloc, NotificationListState>(
      listener: (context, state) {
        if (state.status.isFailure || state.status.isCustomError) {
          showErrorDialog(context, state.alertMessage, state.extraMessage, state.statusCode);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            scrolledUnderElevation: 0,
            title: Text(translate.notifications),
            actions: [
              TextButton(
                onPressed: () => context.read<NotificationListBloc>().add(NotificationListReadAllEvent()),
                child: Text(translate.mark_all_read, style: kAppLblSmallFontMedium(context, color: 'primary')),
              ),
            ],
          ),
          body: RefreshIndicator(
            key: _refreshIndicatorKey,
            color: Theme.of(context).primaryColor,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            onRefresh: () async {
              context.read<NotificationListBloc>().add(NotificationListPullRefreshEvent());
            },
            child: SingleChildScrollView(
              controller: _scrollMoreNotification,
              padding: const EdgeInsets.symmetric(horizontal: ThemeProvider.scaffoldPadding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (state.status.isLoading) ...[
                    const NotificationListLoadingView(),
                  ] else if (state.status.isEmpty) ...[
                    const NotificationListEmptyView(),
                  ] else if (state.status.isFailure) ...[
                    const NotificationListErrorView(),
                  ] else ...[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: state.response.results!
                          .map(
                            (item) => Container(
                              width: MediaQuery.of(context).size.width,
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                                border: Border.all(color: item.status! ? Theme.of(context).primaryColor : ThemeProvider.lightDisabledColor, width: 1.5),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.title!, style: kAppLblTinyFontBold(context)),
                                  kAppSpacerVertical(height: 5),
                                  Text(item.content!, style: kAppLblTinyFontRegular(context)),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [Text(item.createdAt!, style: kAppLblTinyFontRegular(context))],
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    kAppSpacerVertical(height: 20),
                    state.loadMore ? kAppCenterCircularProgress(context) : const SizedBox(),
                    kAppSpacerVertical(height: 20),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class NotificationListLoadingView extends StatelessWidget {
  const NotificationListLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(10, (index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: ThemeProvider.lightDisabledColor, width: 1.5)),
          ),
          child: Column(
            children: [
              SkeletonLine(
                style: SkeletonLineStyle(height: 10, width: MediaQuery.of(context).size.width, borderRadius: BorderRadius.circular(8)),
              ),
              const SizedBox(height: 5),
              SkeletonLine(
                style: SkeletonLineStyle(height: 10, width: MediaQuery.of(context).size.width / 1.5, borderRadius: BorderRadius.circular(8)),
              ),
              const SizedBox(height: 5),
              SkeletonLine(
                style: SkeletonLineStyle(height: 10, width: MediaQuery.of(context).size.width / 1.2, borderRadius: BorderRadius.circular(8)),
              ),
              const SizedBox(height: 5),
            ],
          ),
        );
      }),
    );
  }
}

class NotificationListEmptyView extends StatelessWidget {
  const NotificationListEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        children: [
          kAppSpacerVertical(height: 20),
          Image.asset(AssetsUrl.imageURL.homeEmpty, height: 256, width: 256, fit: BoxFit.fitWidth),
          kAppSpacerVertical(height: 20),
          Text(translate.empty_data, textAlign: TextAlign.center, style: kAppLblMediumFontRegular(context)),
        ],
      ),
    );
  }
}

class NotificationListErrorView extends StatelessWidget {
  const NotificationListErrorView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        children: [
          kAppSpacerVertical(height: 20),
          Image.asset(AssetsUrl.imageURL.homeEmpty, height: 256, width: 256, fit: BoxFit.fitWidth),
          kAppSpacerVertical(height: 20),
          Text(translate.system_error_one, textAlign: TextAlign.center, style: kAppLblMediumFontRegular(context)),
          kAppSpacerVertical(height: 30),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: kAppTextButtonColoredStyle(context, bgColor: Theme.of(context).primaryColor, foreColor: Theme.of(context).scaffoldBackgroundColor),
            child: Text(translate.undestand_and_go_back),
          ),
        ],
      ),
    );
  }
}
// Done //
