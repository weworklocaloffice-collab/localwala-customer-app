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
import 'package:user/app/core/models/purchased_tiffin_subscription_info_view_response_model.dart';
import 'package:user/app/core/models/purchased_tiffin_subscription_response_package_model.dart';
import 'package:user/app/presentation/pages/account/food_subscription_list/@core/bloc/food_subscription_list_bloc.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/error_dialog.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/app/presentation/styles/unauthorized_widget.dart';
import 'package:user/app/presentation/styles/cache_network_widget/cache_network_widget_view.dart';
import 'package:user/app/router/app_route_config.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class FoodSubscriptionListScreen extends StatelessWidget {
  const FoodSubscriptionListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => FoodSubscriptionListBloc()..add(FoodSubscriptionListInitialEvent()), child: const FoodSubscriptionListView());
  }
}

class FoodSubscriptionListView extends StatefulWidget {
  const FoodSubscriptionListView({super.key});

  @override
  State<FoodSubscriptionListView> createState() => _FoodSubscriptionListViewState();
}

class _FoodSubscriptionListViewState extends State<FoodSubscriptionListView> {
  final ScrollController _scrollMoreSubscription = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollMoreSubscription.addListener(() {
      if (_scrollMoreSubscription.position.pixels == _scrollMoreSubscription.position.maxScrollExtent) {
        context.read<FoodSubscriptionListBloc>().add(FoodSubscriptionListLoadMoreEvent());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return BlocConsumer<FoodSubscriptionListBloc, FoodSubscriptionListState>(
      listener: (context, state) {
        if (state.status.isFailure) {
          showErrorDialog(context, state.alertMessage, state.extraMessage, state.statusCode);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: Text(translate.your_purchased_tiffin_packages), scrolledUnderElevation: 0),
          body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            controller: _scrollMoreSubscription,
            padding: const EdgeInsets.symmetric(horizontal: ThemeProvider.scaffoldPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (state.status.isLoading) ...[
                  const FoodSubscriptionListLoadingView(),
                ] else if (state.status.isEmpty) ...[
                  const FoodSubscriptionListEmptyView(),
                ] else if (state.status.isFailure) ...[
                  const FoodSubscriptionListFailureView(),
                ] else if (state.status.isUnAuthorized) ...[
                  const UnauthorizedWidget(),
                ] else if (state.status.isSuccess) ...[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(state.purchasedList.purchased!.length, (index) => FoodSubscriptionListInfoTile(model: state.purchasedList.purchased![index])),
                  ),
                  kAppSpacerVertical(height: 20),
                  state.loadMore ? kAppCenterCircularProgress(context) : const SizedBox(),
                  kAppSpacerVertical(height: 20),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class FoodSubscriptionListInfoTile extends StatelessWidget {
  final PurchasedTiffinSubscriptionPackageModel model;
  const FoodSubscriptionListInfoTile({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(AppRouter.purchasedFoodSubscriptionInfoRoute, arguments: [model.id!]).then((value) {
          if (!context.mounted) return;
          if (value != null && value != '' && value.toString().isNotEmpty) {
            var map = Map<String, dynamic>.from(value as Map<dynamic, dynamic>);
            PurchasedTiffinSubscriptionInfoViewResponseModel backResponse = PurchasedTiffinSubscriptionInfoViewResponseModel.fromJson(map);
            if (backResponse.type!.isNotEmpty && backResponse.type! == 'refresh' && backResponse.value!.isNotEmpty && backResponse.value! == 'hard') {
              context.read<FoodSubscriptionListBloc>().add(FoodSubscriptionListInitialEvent());
            }
          }
        });
      },
      child: Container(
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
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: CacheNetworkImageWidget(width: MediaQuery.of(context).size.width, height: 120.0, imageUrl: model.package!.image!),
                ),
                Positioned(
                  left: 0,
                  top: 5,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(color: ThemeProvider.darkBackgroundColor, borderRadius: BorderRadius.circular(10.0)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        if (model.status! == 'created') ...[
                          Text(translate.ongoing, style: kAppLblTinyBoldOffer(context)),
                        ] else if (model.status! == 'cancelled') ...[
                          Text(translate.cancelled, style: kAppLblTinyBoldOffer(context)),
                        ] else if (model.status! == 'completed') ...[
                          Text(translate.completed, style: kAppLblTinyBoldOffer(context)),
                        ] else if (model.status! == 'refunded') ...[
                          Text(translate.refunded, style: kAppLblTinyBoldOffer(context)),
                        ] else if (model.status! == 'partially_refunded') ...[
                          Text(translate.refunded, style: kAppLblTinyBoldOffer(context)),
                        ] else if (model.status! == 'pending_payments') ...[
                          Text(translate.payment_pending, style: kAppLblTinyBoldOffer(context)),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
            kAppSpacerVertical(height: 5),
            Text(kAppTrimWord(model.restaurant!.name!, 50), style: kAppLblTinyFontRegular(context)),
            Text(model.package!.name!, style: kAppLblMediumFontBold(context)),
            kAppSpacerVertical(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("${translate.paid} : ${kAppPriceFormat(model.grandTotal!)}", style: kAppLblTinyMediumFontSemi(context)),
                Text("${translate.sent} (${model.ordersDates!.length} ${translate.orders})", style: kAppLblTinyMediumFontSemi(context)),
              ],
            ),
            kAppSpacerVertical(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("${model.totalOrder} ${translate.days} & ${model.orderTo! == 'homedelivery' ? translate.home_delivery : translate.take_away} ${translate.only}", style: kAppLblTinyFontRegular(context)),
                Text("${translate.schedule} ${model.slot}", style: kAppLblTinyFontRegular(context)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class FoodSubscriptionListLoadingView extends StatelessWidget {
  const FoodSubscriptionListLoadingView({super.key});

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

class FoodSubscriptionListEmptyView extends StatelessWidget {
  const FoodSubscriptionListEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        children: [
          kAppSpacerVertical(height: 20),
          Image.asset(AssetsUrl.imageURL.cartEmpty, height: 256, width: 256, fit: BoxFit.fitWidth),
          kAppSpacerVertical(height: 20),
          Text(translate.no_subscription, textAlign: TextAlign.center, style: kAppLblMediumFontBold(context)),
          kAppSpacerVertical(height: 5),
          Text(translate.no_subscription_sub_title, textAlign: TextAlign.center, style: kAppLblMediumFontRegular(context)),
        ],
      ),
    );
  }
}

class FoodSubscriptionListFailureView extends StatelessWidget {
  const FoodSubscriptionListFailureView({super.key});

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
