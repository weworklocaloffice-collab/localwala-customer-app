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
import 'package:user/app/core/models/coupon_list_response_model.dart';
import 'package:user/app/presentation/pages/modals/coupon_list_modal/bloc/coupon_list_modal_bloc.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/error_dialog.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class CouponListModalScreen extends StatelessWidget {
  final String restaurant;
  final double itemTotal;
  final double latitude;
  final double longitude;
  final String trackingId;
  const CouponListModalScreen({super.key, required this.restaurant, required this.itemTotal, required this.latitude, required this.longitude, required this.trackingId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CouponListModalBloc()..add(CouponListModalInitialEvent(restaurant: restaurant, itemTotal: itemTotal, latitude: latitude, longitude: longitude, trackingId: trackingId)),
      child: const CouponListModalView(),
    );
  }
}

class CouponListModalView extends StatelessWidget {
  const CouponListModalView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return BlocConsumer<CouponListModalBloc, CouponListModalState>(
      listener: (context, state) {
        if (state.status.isFailure || state.status.isValidationFailure || state.status.isCouponRedeemFailed) {
          showErrorDialog(context, state.alertMessage, state.extraMessage, state.statusCode);
        } else if (state.status.isCouponRedeemSuccess) {
          Navigator.of(context).pop(state.coupons.coupons![state.redeemCouponIndex].toJson());
        }
      },
      builder: (context, state) {
        return SafeArea(
          child: AbsorbPointer(
            absorbing: state.status.isCouponRedeemStart ? true : false,
            child: Scaffold(
              appBar: AppBar(
                scrolledUnderElevation: 0,
                automaticallyImplyLeading: false,
                title: Text(translate.coupon_for_you),
                actions: [IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close))],
              ),
              body: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (state.status.isLoading) ...[
                      const CouponListModalLoadingView(),
                    ] else if (state.status.isFailure) ...[
                      const CouponListModalErrorView(),
                    ] else if (state.status.isEmpty) ...[
                      const CouponListModalEmptyView(),
                    ] else ...[
                      Padding(
                        padding: const EdgeInsets.all(ThemeProvider.scaffoldPadding),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List.generate(
                            state.coupons.coupons!.length,
                            (index) => Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).scaffoldBackgroundColor,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: ThemeProvider.lightDisabledColor, width: 1.5),
                              ),
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              child: CouponListModalTile(model: state.coupons.coupons![index], status: state.status, redeemCouponIndex: state.redeemCouponIndex, index: index),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class CouponListModalTile extends StatelessWidget {
  final CouponConfigModel model;
  final CouponListModalStatus status;
  final int redeemCouponIndex;
  final int index;
  const CouponListModalTile({super.key, required this.model, required this.status, required this.redeemCouponIndex, required this.index});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              kAppCouponIcon(model.couponType!, 15, 15),
              kAppSpacerHorizontal(width: 10),
              Flexible(
                child: Text(model.name!, maxLines: 2, overflow: TextOverflow.ellipsis, style: kAppLblMediumFontBold(context)),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
          child: Text(model.promoLbl!, style: kAppCouponLblTinyFontRegular(context)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: ThemeProvider.lightDisabledColor, width: 1.5),
                ),
                padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 3),
                child: Text(model.code!, style: kAppLblTinyFontRegular(context)),
              ),
              InkWell(
                onTap: () => context.read<CouponListModalBloc>().add(CouponListModalOpenDiscriptionEvent(index: index)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(translate.view_details, style: kAppLblTinyFontRegular(context)),
                    kAppSpacerHorizontal(width: 5),
                    Icon(Icons.keyboard_arrow_down_outlined, size: 12, color: Theme.of(context).canvasColor),
                  ],
                ),
              ),
            ],
          ),
        ),
        kAppSpacerVertical(height: 10),
        model.isOpened!
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.circle, size: 10, color: Theme.of(context).shadowColor),
                        kAppSpacerHorizontal(width: 5),
                        Text(translate.personalised_offer, style: kAppLblTinyFontRegular(context)),
                      ],
                    ),
                    kAppSpacerVertical(height: 5),
                    model.minCartTotal! > 0
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(Icons.circle, size: 10, color: Theme.of(context).shadowColor),
                              kAppSpacerHorizontal(width: 5),
                              Text("${translate.min_cart_value} ${kAppPriceFormat(model.minCartTotal!)}", style: kAppLblTinyFontRegular(context)),
                            ],
                          )
                        : const SizedBox(),
                    model.minCartTotal! > 0 ? kAppSpacerVertical(height: 5) : const SizedBox(),
                    if (model.couponType! == 'default' || model.couponType! == 'restaurant' || model.couponType! == 'firstorder') ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.circle, size: 10, color: Theme.of(context).shadowColor),
                          kAppSpacerHorizontal(width: 5),
                          model.discountType == 'amount'
                              ? Text("${translate.max_instant_discount_off} ${kAppPriceFormat(model.minDiscount!)}", style: kAppLblTinyFontRegular(context))
                              : Text("${translate.max_instant_discount_off} ${model.maxDiscount! > 0 ? kAppPriceFormat(model.maxSave!) : kAppPriceFormat(model.minSave!)}", style: kAppLblTinyFontRegular(context)),
                        ],
                      ),
                      kAppSpacerVertical(height: 5),
                    ] else if (model.couponType == 'loyality') ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.circle, size: 10, color: Theme.of(context).shadowColor),
                          kAppSpacerHorizontal(width: 5),
                          Text(translate.loyalty_points_available, style: kAppLblTinyFontRegular(context)),
                        ],
                      ),
                      kAppSpacerVertical(height: 5),
                    ] else if (model.couponType == 'bogo') ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.circle, size: 10, color: Theme.of(context).shadowColor),
                          kAppSpacerHorizontal(width: 5),
                          Text(translate.bogo_offer, style: kAppLblTinyFontRegular(context)),
                        ],
                      ),
                      kAppSpacerVertical(height: 5),
                    ] else if (model.couponType == 'freedelivery') ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.circle, size: 10, color: Theme.of(context).shadowColor),
                          kAppSpacerHorizontal(width: 5),
                          Text(translate.free_delivery_offer, style: kAppLblTinyFontRegular(context)),
                        ],
                      ),
                      kAppSpacerVertical(height: 5),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.circle, size: 10, color: Theme.of(context).shadowColor),
                        kAppSpacerHorizontal(width: 5),
                        Text(model.allRestaurants! ? translate.applicable_on_every_restaurant : translate.applicable_on_selected_restaurants, style: kAppLblTinyFontRegular(context)),
                      ],
                    ),
                    kAppSpacerVertical(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.circle, size: 10, color: Theme.of(context).shadowColor),
                        kAppSpacerHorizontal(width: 5),
                        Text("${translate.applicable_max} ${model.limitSameUser!} ${translate.times_per_user}", style: kAppLblTinyFontRegular(context)),
                      ],
                    ),
                    kAppSpacerVertical(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.circle, size: 10, color: Theme.of(context).shadowColor),
                        kAppSpacerHorizontal(width: 5),
                        Text(model.allUsers! ? translate.applicable_on_every_users : translate.applicable_on_selected_users, style: kAppLblTinyFontRegular(context)),
                      ],
                    ),
                    kAppSpacerVertical(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.circle, size: 10, color: Theme.of(context).shadowColor),
                        kAppSpacerHorizontal(width: 5),
                        Text(translate.coupon_terms_and_condition, style: kAppLblTinyFontRegular(context)),
                      ],
                    ),
                    kAppSpacerVertical(height: 5),
                  ],
                ),
              )
            : const SizedBox(),
        InkWell(
          onTap: () => context.read<CouponListModalBloc>().add(CouponListModalSelectCouponEvent(index: index)),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
            ),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Center(
              child: status.isCouponRedeemStart && redeemCouponIndex == index
                  ? kAppCircularProgress(context, color: 'light', strokeWidth: 3.0, width: 24.0, height: 24.0, padding: 2.0)
                  : Text(translate.tap_to_apply, style: kAppLblSmallFontMedium(context)),
            ),
          ),
        ),
      ],
    );
  }
}

class CouponListModalLoadingView extends StatelessWidget {
  const CouponListModalLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(ThemeProvider.scaffoldPadding),
      child: Column(
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
      ),
    );
  }
}

class CouponListModalEmptyView extends StatelessWidget {
  const CouponListModalEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(ThemeProvider.scaffoldPadding),
      child: Center(
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
      ),
    );
  }
}

class CouponListModalErrorView extends StatelessWidget {
  const CouponListModalErrorView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(ThemeProvider.scaffoldPadding),
      child: Center(
        child: Column(
          children: [
            kAppSpacerVertical(height: 20),
            Image.asset(AssetsUrl.imageURL.homeEmpty, height: 256, width: 256, fit: BoxFit.fitWidth),
            kAppSpacerVertical(height: 20),
            Text(translate.empty_data, textAlign: TextAlign.center, style: kAppLblMediumFontRegular(context)),
          ],
        ),
      ),
    );
  }
}
// Done //
