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
import 'package:user/app/core/models/user_order_transaction_response_model.dart';
import 'package:user/app/presentation/pages/account/order_transaction_list/bloc/order_transaction_list_bloc.dart';
import 'package:user/app/presentation/pages/history/history_detail/history_detail_view.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/error_dialog.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/app/presentation/styles/unauthorized_widget.dart';
import 'package:user/app/presentation/styles/cache_network_widget/cache_network_widget_view.dart';
import 'package:user/app/router/app_route_config.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class OrderTransactionListScreen extends StatelessWidget {
  const OrderTransactionListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => OrderTransactionListBloc()..add(OrderTransactionListInitialEvent()), child: const OrderTransactionListView());
  }
}

class OrderTransactionListView extends StatefulWidget {
  const OrderTransactionListView({super.key});

  @override
  State<OrderTransactionListView> createState() => _OrderTransactionListViewState();
}

class _OrderTransactionListViewState extends State<OrderTransactionListView> {
  final GlobalKey<RefreshIndicatorState> _refreshOrderTransctionIndicatorKey = GlobalKey<RefreshIndicatorState>();
  final ScrollController _scrollMoreOrdersTransaction = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollMoreOrdersTransaction.addListener(() {
      if (_scrollMoreOrdersTransaction.position.pixels == _scrollMoreOrdersTransaction.position.maxScrollExtent) {
        context.read<OrderTransactionListBloc>().add(OrderTransactionListLoadMoreOrderTransactionEvent());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return BlocConsumer<OrderTransactionListBloc, OrderTransactionListState>(
      listener: (context, state) {
        if (state.status.isFailure) {
          showErrorDialog(context, state.alertMessage, state.extraMessage, state.statusCode);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: Text(translate.your_order_transactions), scrolledUnderElevation: 0),
          body: RefreshIndicator(
            key: _refreshOrderTransctionIndicatorKey,
            color: Theme.of(context).primaryColor,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            onRefresh: () async {
              context.read<OrderTransactionListBloc>().add(OrderTransactionListPullRefreshEvent());
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: ThemeProvider.scaffoldPadding),
              controller: _scrollMoreOrdersTransaction,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (state.status.isLoading) ...[
                    const OrderTransactionListLoadingView(),
                  ] else if (state.status.isFailure) ...[
                    const OrderTransactionListErrorView(),
                  ] else if (state.status.isEmpty) ...[
                    const OrderTransactionListEmptyView(),
                  ] else if (state.status.isUnAuthorized) ...[
                    const UnauthorizedWidget(),
                  ] else ...[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(state.model.transactions!.length, (index) => OrderTransactionListTransactionTileView(model: state.model.transactions![index])),
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

class OrderTransactionListTransactionTileView extends StatelessWidget {
  final OrderTransactionConfigModel model;
  const OrderTransactionListTransactionTileView({super.key, required this.model});

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
              onTap: () => Navigator.of(context).pushNamed(AppRouter.restaurantRoute, arguments: [model.orderInfo!.id!, model.orderInfo!.slug!, model.orderInfo!.name!]),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                    child: CacheNetworkImageWidget(width: 40.0, height: 40.0, imageUrl: model.orderInfo!.cover!),
                  ),
                  kAppSpacerHorizontal(width: 5),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 1.4,
                        child: Text(model.orderInfo!.name!, maxLines: 1, overflow: TextOverflow.ellipsis, style: kAppLblMediumFontBold(context)),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 1.4,
                        child: Text(model.orderInfo!.address!, maxLines: 1, overflow: TextOverflow.ellipsis, style: kAppLblTinyFontRegular(context)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          kAppSpacerVertical(height: 5),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  fullscreenDialog: true,
                  builder: (BuildContext context) {
                    return HistoryDetailScreen(id: model.orderInfo!.id!);
                  },
                ),
              );
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("${translate.order_id} :", style: kAppLblTinyFontRegular(context)),
                    kAppSpacerHorizontal(width: 5),
                    Text("${model.orderInfo!.orderNo!}", style: kAppLblTinyFontRegular(context)),
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

class OrderTransactionListLoadingView extends StatelessWidget {
  const OrderTransactionListLoadingView({super.key});

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

class OrderTransactionListErrorView extends StatelessWidget {
  const OrderTransactionListErrorView({super.key});

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

class OrderTransactionListEmptyView extends StatelessWidget {
  const OrderTransactionListEmptyView({super.key});

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
