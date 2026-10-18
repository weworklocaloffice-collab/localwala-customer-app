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
import 'package:user/app/core/models/user_food_subscription_transaction_response_model.dart';
import 'package:user/app/presentation/pages/account/food_subscription_list/food_subscription_transaction_list/bloc/food_subscription_transaction_list_bloc.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/error_dialog.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/app/presentation/styles/unauthorized_widget.dart';
import 'package:user/app/presentation/styles/cache_network_widget/cache_network_widget_view.dart';
import 'package:user/app/router/app_route_config.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class FoodSubscriptionTransactionListScreen extends StatelessWidget {
  const FoodSubscriptionTransactionListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => FoodSubscriptionTransactionListBloc()..add(FoodSubscriptionTransactionListInitialEvent()), child: const FoodSubscriptionTransactionListView());
  }
}

class FoodSubscriptionTransactionListView extends StatefulWidget {
  const FoodSubscriptionTransactionListView({super.key});

  @override
  State<FoodSubscriptionTransactionListView> createState() => _FoodSubscriptionTransactionListViewState();
}

class _FoodSubscriptionTransactionListViewState extends State<FoodSubscriptionTransactionListView> {
  final GlobalKey<RefreshIndicatorState> _refreshSubscriptionTransctionIndicatorKey = GlobalKey<RefreshIndicatorState>();
  final ScrollController _scrollMoreSubscriptionTransaction = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollMoreSubscriptionTransaction.addListener(() {
      if (_scrollMoreSubscriptionTransaction.position.pixels == _scrollMoreSubscriptionTransaction.position.maxScrollExtent) {
        context.read<FoodSubscriptionTransactionListBloc>().add(FoodSubscriptionLoadMoreSubscriptionTransactionEvent());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return BlocConsumer<FoodSubscriptionTransactionListBloc, FoodSubscriptionTransactionListState>(
      listener: (context, state) {
        if (state.status.isFailure) {
          showErrorDialog(context, state.alertMessage, state.extraMessage, state.statusCode);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: Text(translate.your_tiffin_package_transactions), scrolledUnderElevation: 0),
          body: RefreshIndicator(
            key: _refreshSubscriptionTransctionIndicatorKey,
            color: Theme.of(context).primaryColor,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            onRefresh: () async {
              context.read<FoodSubscriptionTransactionListBloc>().add(FoodSubscriptionPullRefreshEvent());
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: ThemeProvider.scaffoldPadding),
              controller: _scrollMoreSubscriptionTransaction,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (state.status.isLoading) ...[
                    const FoodSubscriptionTransactionListLoadingView(),
                  ] else if (state.status.isFailure) ...[
                    const FoodSubscriptionTransactionListErrorView(),
                  ] else if (state.status.isEmpty) ...[
                    const FoodSubscriptionTransactionListEmptyView(),
                  ] else if (state.status.isUnAuthorized) ...[
                    const UnauthorizedWidget(),
                  ] else ...[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(state.model.transactions!.length, (index) => FoodSubscriptionTransactionListInfoTileView(model: state.model.transactions![index])),
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

class FoodSubscriptionTransactionListInfoTileView extends StatelessWidget {
  final UserFoodSubscriptionTransactionConfigModel model;
  const FoodSubscriptionTransactionListInfoTileView({super.key, required this.model});

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
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.only(bottom: 10),
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: ThemeProvider.lightDisabledColor, width: 1.5)),
            ),
            child: GestureDetector(
              onTap: () => Navigator.of(context).pushNamed(AppRouter.foodSubscriptionInfoRoute, arguments: [model.subscription!.id!, model.subscription!.name!]),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                    child: CacheNetworkImageWidget(width: 40.0, height: 40.0, imageUrl: model.subscription!.image!),
                  ),
                  kAppSpacerHorizontal(width: 5),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 1.4,
                        child: Text(model.subscription!.name!, maxLines: 1, overflow: TextOverflow.ellipsis, style: kAppLblMediumFontBold(context)),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 1.4,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("${translate.available} : ${kAppTiffinKind(context, model.subscription!.available!)}", style: kAppLblTinyFontRegular(context)),
                            kAppSpacerHorizontal(width: 5),
                            Text("${translate.total_orders} : ${model.subscription!.totalOrder!}", style: kAppLblTinyFontRegular(context)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(AppRouter.purchasedFoodSubscriptionInfoRoute, arguments: [model.tiffinSubscription!]);
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("${translate.subscription_id} :", style: kAppLblTinyFontRegular(context)),
                    kAppSpacerHorizontal(width: 5),
                    Text(model.subscription!.displayId!.toUpperCase(), style: kAppLblTinyFontRegular(context)),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("${translate.transaction_date} :", style: kAppLblTinyFontRegular(context)),
                    kAppSpacerHorizontal(width: 5),
                    Text(model.createdAt!.toUpperCase(), style: kAppLblTinyFontRegular(context)),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("${translate.total_amount} :", style: kAppLblTinyFontRegular(context)),
                    kAppSpacerHorizontal(width: 5),
                    Text(kAppPriceFormat(model.amount!), style: kAppLblTinyFontRegular(context)),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("${translate.transaction_status} :", style: kAppLblTinyFontRegular(context)),
                    kAppSpacerHorizontal(width: 5),
                    Text("${kAppPaymentStatus(context, model.status!)}  (${model.paymentInfo!.name!})", style: kAppLblTinyFontRegular(context)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FoodSubscriptionTransactionListLoadingView extends StatelessWidget {
  const FoodSubscriptionTransactionListLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
        10,
        (index) => Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: ThemeProvider.lightDisabledColor, width: 1.5)),
          ),
          child: Column(
            children: [
              SkeletonLine(
                style: SkeletonLineStyle(height: 10, width: MediaQuery.of(context).size.width, borderRadius: BorderRadius.circular(5)),
              ),
              kAppSpacerVertical(height: 5),
              SkeletonLine(
                style: SkeletonLineStyle(height: 10, width: MediaQuery.of(context).size.width, borderRadius: BorderRadius.circular(5)),
              ),
              kAppSpacerVertical(height: 5),
              SkeletonLine(
                style: SkeletonLineStyle(height: 10, width: MediaQuery.of(context).size.width / 2, borderRadius: BorderRadius.circular(5)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FoodSubscriptionTransactionListErrorView extends StatelessWidget {
  const FoodSubscriptionTransactionListErrorView({super.key});

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

class FoodSubscriptionTransactionListEmptyView extends StatelessWidget {
  const FoodSubscriptionTransactionListEmptyView({super.key});

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
