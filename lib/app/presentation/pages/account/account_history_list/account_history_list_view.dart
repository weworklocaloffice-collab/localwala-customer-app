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
import 'package:user/app/core/models/history_detail_view_response_model.dart';
import 'package:user/app/core/models/my_order_list_response_model.dart';
import 'package:user/app/presentation/pages/account/account_history_list/bloc/account_history_list_bloc.dart';
import 'package:user/app/presentation/pages/history/history_detail/history_detail_view.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/error_dialog.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/app/presentation/styles/unauthorized_widget.dart';
import 'package:user/app/presentation/styles/cache_network_widget/cache_network_widget_view.dart';
import 'package:user/app/router/app_route_config.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class AccountHistoryListScreen extends StatelessWidget {
  const AccountHistoryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => AccountHistoryListBloc()..add(AccountHistoryListInitialEvent()), child: const AccountHistoryListView());
  }
}

class AccountHistoryListView extends StatefulWidget {
  const AccountHistoryListView({super.key});

  @override
  State<AccountHistoryListView> createState() => _AccountHistoryListViewState();
}

class _AccountHistoryListViewState extends State<AccountHistoryListView> {
  final GlobalKey<RefreshIndicatorState> _refreshAccountHistoryIndicatorKey = GlobalKey<RefreshIndicatorState>();
  final ScrollController _scrollAccountHistoryMoreOrders = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollAccountHistoryMoreOrders.addListener(() {
      if (_scrollAccountHistoryMoreOrders.position.pixels == _scrollAccountHistoryMoreOrders.position.maxScrollExtent) {
        context.read<AccountHistoryListBloc>().add(AccountHistoryListLoadMoreOrderEvent());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return BlocConsumer<AccountHistoryListBloc, AccountHistoryListState>(
      listener: (context, state) {
        if (state.status.isFailure) {
          showErrorDialog(context, state.alertMessage, state.extraMessage, state.statusCode);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: Text(translate.your_orders), scrolledUnderElevation: 0),
          body: RefreshIndicator(
            key: _refreshAccountHistoryIndicatorKey,
            color: Theme.of(context).primaryColor,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            onRefresh: () async {
              context.read<AccountHistoryListBloc>().add(AccountHistoryListPullRefreshEvent());
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: ThemeProvider.scaffoldPadding),
              scrollDirection: Axis.vertical,
              controller: _scrollAccountHistoryMoreOrders,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (state.status.isLoading) ...[
                    const AccountHistoryListLoadingView(),
                  ] else if (state.status.isEmpty) ...[
                    const AccountHistoryListEmptyView(),
                  ] else if (state.status.isUnAuthorized) ...[
                    const UnauthorizedWidget(),
                  ] else if (state.status.isFailure) ...[
                    const AccountHistoryListErrorView(),
                  ] else if (state.status.isSuccess) ...[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(state.orderList.orders!.length, (index) => AccountHistoryListOrderView(model: state.orderList.orders![index])),
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

class AccountHistoryListOrderView extends StatelessWidget {
  final OrdersListModel model;
  const AccountHistoryListOrderView({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: ThemeProvider.lightDisabledColor, width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 5),
            padding: const EdgeInsets.only(bottom: 5),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: ThemeProvider.lightDisabledColor, width: 1.5)),
            ),
            child: InkWell(
              onTap: () => Navigator.of(context).pushNamed(AppRouter.restaurantRoute, arguments: [model.restaurant!.id, model.restaurant!.slug, model.restaurant!.name]),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                        child: CacheNetworkImageWidget(width: 40.0, height: 40.0, imageUrl: model.restaurant!.cover!),
                      ),
                      kAppSpacerHorizontal(width: 5),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(kAppTrimWord(model.restaurant!.name!, 20), style: kAppLblMediumFontBold(context)),
                          Text(kAppTrimWord(model.restaurant!.address!, 20), style: kAppLblTinyFontRegular(context)),
                        ],
                      ),
                    ],
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(color: Theme.of(context).colorScheme.shadow, borderRadius: BorderRadius.circular(5)),
                          child: Text(kAppRegularOrderStatus(context, model.status!), textAlign: TextAlign.center, style: kAppLblTinyFontBold(context)),
                        ),
                        Text(translate.view_menu, style: kAppLblTinyFontRegularChip(context, color: 'primary')),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          kAppSpacerVertical(height: 5),
          InkWell(
            onTap: () {
              Navigator.of(context)
                  .push(
                    MaterialPageRoute(
                      fullscreenDialog: true,
                      builder: (BuildContext context) {
                        return HistoryDetailScreen(id: model.id!);
                      },
                    ),
                  )
                  .then((value) {
                    if (!context.mounted) return;
                    if (value != null && value != '' && value.toString().isNotEmpty) {
                      HistoryDetailViewResponseModel backResponse = HistoryDetailViewResponseModel.fromJson(value);
                      if (backResponse.type!.isNotEmpty && backResponse.type! == 'refresh' && backResponse.value!.isNotEmpty && backResponse.value! == 'hard') {
                        context.read<AccountHistoryListBloc>().add(AccountHistoryListInitialEvent());
                      }
                    }
                  });
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(
                model.cartItem!.length,
                (cartIndex) => Container(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      kAppFoodType(model.cartItem![cartIndex].foodType!, height: 10, width: 10),
                      kAppSpacerHorizontal(width: 5),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text("${model.cartItem![cartIndex].quantity!}", style: kAppLblTinyFontBold(context)),
                              Text(" X ", style: kAppLblTinyFontBold(context)),
                              Text(kAppTrimWord(model.cartItem![cartIndex].name!, 40), style: kAppLblTinyFontBold(context)),
                            ],
                          ),
                          Container(
                            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width / 1.3, minWidth: MediaQuery.of(context).size.width / 2.5),
                            child: Text(model.cartItem![cartIndex].optionName!, maxLines: 4, style: kAppLblTinyFontRegular(context)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          kAppSpacerVertical(height: 5),
          InkWell(
            onTap: () {
              Navigator.of(context)
                  .push(
                    MaterialPageRoute(
                      fullscreenDialog: true,
                      builder: (BuildContext context) {
                        return HistoryDetailScreen(id: model.id!);
                      },
                    ),
                  )
                  .then((value) {
                    if (!context.mounted) return;
                    if (value != null && value != '' && value.toString().isNotEmpty) {
                      HistoryDetailViewResponseModel backResponse = HistoryDetailViewResponseModel.fromJson(value);
                      if (backResponse.type!.isNotEmpty && backResponse.type! == 'refresh' && backResponse.value!.isNotEmpty && backResponse.value! == 'hard') {
                        context.read<AccountHistoryListBloc>().add(AccountHistoryListInitialEvent());
                      }
                    }
                  });
            },
            child: Container(
              margin: const EdgeInsets.only(top: 5),
              padding: const EdgeInsets.only(top: 5),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: ThemeProvider.lightDisabledColor, width: 1.5)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      model.instantOrder!
                          ? Text("${model.createdAt} ${translate.at} ${model.orderAt}", style: kAppLblTinyFontRegular(context))
                          : Text("${model.scheduleDate} ${translate.at} ${model.scheduleTime}", style: kAppLblTinyFontRegular(context)),
                      kAppSpacerHorizontal(width: model.subscriptionOrder! ? 5 : 0),
                      model.subscriptionOrder! ? Text("(${translate.subscription_order})", style: kAppLblTinyFontRegular(context)) : const SizedBox(),
                    ],
                  ),
                  Text(kAppPriceFormat(model.grandTotal!), style: kAppLblTinyFontBold(context)),
                ],
              ),
            ),
          ),
          model.status! == 'partially_refunded' || model.status == 'pending_payments'
              ? Container(
                  margin: const EdgeInsets.only(top: 10),
                  padding: const EdgeInsets.only(top: 10),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: ThemeProvider.lightDisabledColor, width: 1.5)),
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context)
                          .push(
                            MaterialPageRoute(
                              fullscreenDialog: true,
                              builder: (BuildContext context) {
                                return HistoryDetailScreen(id: model.id!);
                              },
                            ),
                          )
                          .then((value) {
                            if (!context.mounted) return;
                            if (value != null && value != '' && value.toString().isNotEmpty) {
                              HistoryDetailViewResponseModel backResponse = HistoryDetailViewResponseModel.fromJson(value);
                              if (backResponse.type!.isNotEmpty && backResponse.type! == 'refresh' && backResponse.value!.isNotEmpty && backResponse.value! == 'hard') {
                                context.read<AccountHistoryListBloc>().add(AccountHistoryListInitialEvent());
                              }
                            }
                          });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.info, color: Theme.of(context).primaryColor, size: 10),
                        kAppSpacerHorizontal(width: 5),
                        Text(kAppRegularOrderStatus(context, model.status!), style: kAppLblTinyFontRegularChip(context, color: 'primary')),
                      ],
                    ),
                  ),
                )
              : const SizedBox(),
        ],
      ),
    );
  }
}

class AccountHistoryListLoadingView extends StatelessWidget {
  const AccountHistoryListLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
        10,
        (index) => Container(
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.symmetric(vertical: 5),
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(color: ThemeProvider.lightDisabledColor, width: 1.5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonListTile(
                hasSubtitle: true,
                padding: const EdgeInsets.all(0),
                leadingStyle: const SkeletonAvatarStyle(width: 25, height: 25),
                titleStyle: SkeletonLineStyle(height: 10, randomLength: false, borderRadius: BorderRadius.circular(16)),
                subtitleStyle: SkeletonLineStyle(height: 10, randomLength: true, borderRadius: BorderRadius.circular(16)),
              ),
              kAppSpacerVertical(height: 20),
              SkeletonParagraph(
                style: SkeletonParagraphStyle(
                  spacing: 6,
                  padding: const EdgeInsets.all(0),
                  lineStyle: SkeletonLineStyle(height: 10, randomLength: false, borderRadius: BorderRadius.circular(16)),
                ),
              ),
              kAppSpacerVertical(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SkeletonLine(
                    style: SkeletonLineStyle(height: 10, width: MediaQuery.of(context).size.width / 3.5, borderRadius: BorderRadius.circular(8)),
                  ),
                  SkeletonLine(
                    style: SkeletonLineStyle(height: 10, width: MediaQuery.of(context).size.width / 3.5, borderRadius: BorderRadius.circular(8)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AccountHistoryListEmptyView extends StatelessWidget {
  const AccountHistoryListEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        children: [
          kAppSpacerVertical(height: 20),
          Image.asset(AssetsUrl.imageURL.cartEmpty, height: 256, width: 256, fit: BoxFit.fitWidth),
          kAppSpacerVertical(height: 20),
          Text(translate.no_orders, textAlign: TextAlign.center, style: kAppLblMediumFontBold(context)),
          kAppSpacerVertical(height: 5),
          Text(translate.no_order_data_one, textAlign: TextAlign.center, style: kAppLblMediumFontRegular(context)),
        ],
      ),
    );
  }
}

class AccountHistoryListErrorView extends StatelessWidget {
  const AccountHistoryListErrorView({super.key});

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
