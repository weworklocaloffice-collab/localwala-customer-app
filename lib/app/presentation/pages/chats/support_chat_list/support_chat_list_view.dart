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
import 'package:user/app/core/models/my_support_chat_list_model.dart';
import 'package:user/app/presentation/pages/chats/support_chat_list/bloc/support_chat_list_bloc.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/error_dialog.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/app/presentation/styles/unauthorized_widget.dart';
import 'package:user/app/presentation/styles/cache_network_widget/cache_network_widget_view.dart';
import 'package:user/app/router/app_route_config.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class SupportChatListScreen extends StatelessWidget {
  const SupportChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => SupportChatListBloc()..add(SupportChatListInitialEvent()), child: const SupportChatListView());
  }
}

class SupportChatListView extends StatefulWidget {
  const SupportChatListView({super.key});

  @override
  State<SupportChatListView> createState() => _SupportChatListViewState();
}

class _SupportChatListViewState extends State<SupportChatListView> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocConsumer<SupportChatListBloc, SupportChatListState>(
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
                  const SupportChatListLoadingView(),
                ] else if (state.status.isFailure) ...[
                  const SupportChatListErrorView(),
                ] else if (state.status.isEmpty) ...[
                  const SupportChatListEmptyView(),
                ] else if (state.status.isUnAuthorized) ...[
                  const UnauthorizedWidget(),
                ] else ...[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(state.model.chats!.length, (chatIndex) => SupportChatInfoTileWidget(model: state.model.chats![chatIndex])),
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

class SupportChatInfoTileWidget extends StatelessWidget {
  final SupportChatListModel model;
  const SupportChatInfoTileWidget({super.key, required this.model});

  /// Entity reference for the title row, without the five-way if/else inline.
  /// Unknown types render blank instead of throwing on a null bang.
  static String _entityRef(SupportChatListModel m) {
    try {
      switch (m.supportType) {
        case 'orders':
          return '#${m.orders!.toUpperCase()}';
        case 'dining':
          return '#${m.booking!.toUpperCase()}';
        case 'tiffin_subscription':
          return '#${m.purchaseSubscription!.toUpperCase()}';
        case 'complaints':
          return '#${m.complaints!.toUpperCase()}';
        case 'reports':
          return '#${m.reportIssue!.toUpperCase()}';
        default:
          return '';
      }
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: () {
        String type = model.supportType!;
        String typeId = '';
        if (model.supportType! == 'orders') {
          typeId = model.orders!;
        } else if (model.supportType! == 'dining') {
          typeId = model.booking!;
        } else if (model.supportType! == 'tiffin_subscription') {
          typeId = model.purchaseSubscription!;
        } else if (model.supportType! == 'complaints') {
          typeId = model.complaints!;
        } else if (model.supportType! == 'reports') {
          typeId = model.reportIssue!;
        }
        Navigator.of(context).pushNamed(AppRouter.supportChatRoute, arguments: [type, typeId]);
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
            Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(kAppSupportChatType(context, model.supportType!),
                          style: kAppLblMediumFontBold(context),
                          overflow: TextOverflow.ellipsis),
                    ),
                    kAppSpacerHorizontal(width: 10),
                    Flexible(
                      child: Text(
                        _entityRef(model),
                        style: kAppLblTinyFontRegular(context),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                kAppSpacerVertical(height: 2),
                // Wrap, not Row: long locale status strings + date must fold
                // to a second line on narrow screens, never overflow.
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 10,
                  runSpacing: 2,
                  children: [
                    _StatusPill(status: model.status!, translate: translate),
                    Text(model.updatedAt!, style: kAppLblTinyFontRegular(context)),
                  ],
                ),
                kAppSpacerVertical(height: 2),
                Text(kAppTrimWord(model.lastMessage!, 40),
                    maxLines: 1, overflow: TextOverflow.ellipsis, style: kAppLblTinyFontRegular(context)),
              ],
            ),
            ),
            OverlappingAvatars(imageUrls: model.team!),
          ],
        ),
      ),
    );
  }
}

/// Status pill shared by the tile: one widget instead of a tripled if/else,
/// so the next status is added in one place.
class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status, required this.translate});

  final String status;
  final dynamic translate;

  @override
  Widget build(BuildContext context) {
    final String label;
    final Color color;
    switch (status) {
      case 'open':
        label = translate.open_ticket;
        color = ThemeProvider.primaryColor;
      case 'in_progress':
        label = translate.in_progress_ticket;
        color = ThemeProvider.blueColor;
      case 'resolved':
        label = translate.resolved_ticket;
        color = ThemeProvider.ratingBgColorLight;
      default:
        label = status;
        color = ThemeProvider.lightDisabledColor;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(5.0)),
      child: Text(label, style: TextStyle(color: ThemeProvider.ratingTextColorLight)),
    );
  }
}

class SupportChatListLoadingView extends StatelessWidget {
  const SupportChatListLoadingView({super.key});

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

class SupportChatListErrorView extends StatelessWidget {
  const SupportChatListErrorView({super.key});

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

class SupportChatListEmptyView extends StatelessWidget {
  const SupportChatListEmptyView({super.key});

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

class OverlappingAvatars extends StatelessWidget {
  final List<SupportTeamConfigModel> imageUrls;

  const OverlappingAvatars({super.key, required this.imageUrls});

  @override
  Widget build(BuildContext context) {
    // Shrink-to-fit and stack from the RIGHT: a fixed 120px box with
    // left-anchored avatars parked 1–2 faces in the middle of the tile.
    final int count = imageUrls.length.clamp(0, 3);
    if (count == 0) return const SizedBox.shrink();
    const double radius = 16;
    const double step = 22;
    final double width = radius * 2 + step * (count - 1);
    return SizedBox(
      height: radius * 2,
      width: width,
      child: Stack(
        children: imageUrls.take(count).toList().asMap().entries.map((entry) {
          final int index = entry.key;
          final SupportTeamConfigModel team = entry.value;
          return Positioned(
            // Right-anchored: last avatar flush with the tile end.
            right: index * step,
            child: CircleAvatar(
              radius: radius,
              backgroundColor: Colors.white,
              child: ClipOval(
                child: CacheNetworkImageWidget(width: 28.0, height: 28.0, imageUrl: team.image!),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
// Done //
