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
import 'package:user/app/core/config/assets_url.dart';
import 'package:user/app/env.dart';
import 'package:user/app/presentation/pages/account/wallet/loyalty_points/bloc/loyalty_bloc.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/error_dialog.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:flutter_skeleton_ui/flutter_skeleton_ui.dart';
import 'package:user/app/presentation/styles/unauthorized_widget.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class LoyaltyScreen extends StatelessWidget {
  const LoyaltyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => LoyaltyBloc()..add(LoyaltyInitialEvent()), child: const LoyaltyView());
  }
}

class LoyaltyView extends StatelessWidget {
  const LoyaltyView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return BlocConsumer<LoyaltyBloc, LoyaltyState>(
      listener: (context, state) {
        if (state.status.isFailure || state.status.isCustomError) {
          showErrorDialog(context, state.alertMessage, state.extraMessage, state.statusCode);
        } else if (state.status.isRedeemSuccess) {
          Navigator.of(context, rootNavigator: true).pop(true);
        }
      },
      builder: (context, state) {
        return AbsorbPointer(
          absorbing: state.status.isRedeeming ? true : false,
          child: Scaffold(
            appBar: AppBar(title: Text(translate.loyalty_points), scrolledUnderElevation: 0),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: ThemeProvider.scaffoldPadding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (state.status.isLoading) ...[
                    const LoyaltyLoadingView(),
                  ] else if (state.status.isFailure) ...[
                    const LoyaltyErrorView(),
                  ] else if (state.status.isUnAuthorized) ...[
                    const UnauthorizedWidget(),
                  ] else ...[
                    Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.2,
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        border: Border.all(color: ThemeProvider.lightDisabledColor, width: 1.5),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text("${Environments.appName} ${translate.rewards}", style: kAppLblMediumFontBold(context)),
                          kAppSpacerVertical(height: 10),
                          Text("${translate.loyalty_points} ${state.points.totalPoints}", style: kAppLblLargeFontBold(context)),
                          kAppSpacerVertical(height: 10),
                          Text("${translate.can_earn_cash_in_wallet} ${kAppPriceFormat(state.points.canEarnInWallet!)}", style: kAppLblMediumFontRegular(context)),
                          kAppSpacerVertical(height: 10),
                          Text("${translate.wallet_required} ${state.points.userSettings!.minLoyaltyPointToRedeem!} ${translate.points_to_redeem}", style: kAppLblTinyFontRegular(context)),
                          kAppSpacerVertical(height: 10),
                          Text("${state.points.userSettings!.priceOfOneLoyaltyPoint!} ${translate.points_to} ${kAppPriceFormat(1)} ${translate.in_wallet_cash_amount}", style: kAppLblTinyFontRegular(context)),
                        ],
                      ),
                    ),
                    kAppSpacerVertical(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(translate.active_points_history, style: kAppLblSmallFontRegular(context)),
                        Text("${state.points.activePoints!.length} ${translate.results}", style: kAppLblSmallFontRegular(context)),
                      ],
                    ),
                    state.status.isEmpty
                        ? SizedBox(
                            width: double.infinity,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                kAppSpacerVertical(height: 20),
                                Image.asset(AssetsUrl.imageURL.noMoney, height: 80, width: 80, color: Theme.of(context).canvasColor),
                                kAppSpacerVertical(height: 20),
                                Text(translate.no_record_found, style: kAppLblMediumFontSemiBold(context)),
                              ],
                            ),
                          )
                        : const SizedBox(),
                    kAppSpacerVertical(height: 20),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List.generate(
                            state.points.activePoints!.length,
                            (pointIndex) => Container(
                              width: MediaQuery.of(context).size.width,
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                              margin: const EdgeInsets.symmetric(vertical: 5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                                color: Theme.of(context).scaffoldBackgroundColor,
                                border: Border.all(color: ThemeProvider.lightDisabledColor, width: 1.5),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width / 8.6,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [Image.asset(state.points.activePoints![pointIndex].redeemFrom == 'order' ? AssetsUrl.imageURL.loyaltyPointsOrders : AssetsUrl.imageURL.loyaltyPointsCoupon, height: 30, width: 30)],
                                    ),
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width / 1.4,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(state.points.activePoints![pointIndex].redeemFrom == 'order' ? translate.received_from_order : translate.received_from_coupon, style: kAppLblMediumFontBold(context)),
                                            Text(state.points.activePoints![pointIndex].createdAt!, style: kAppLblSmallFontRegular(context)),
                                          ],
                                        ),
                                        Text("${state.points.activePoints![pointIndex].loyaltyPointValue!}", style: kAppLblMediumFontBold(context)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            bottomNavigationBar: SafeArea(
              child: Container(
                height: 60,
                margin: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (state.status.isLoading) ...[
                      Expanded(
                        flex: 6,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [SkeletonLine(style: SkeletonLineStyle(borderRadius: BorderRadius.circular(10), height: 10, width: 80))],
                        ),
                      ),
                    ] else if (state.status.isSuccess || state.status.isRedeeming || state.status.isCustomError) ...[
                      Expanded(
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: state.points.totalPoints! > state.points.userSettings!.minLoyaltyPointToRedeem! && state.points.activePoints!.isNotEmpty
                                ? () => context.read<LoyaltyBloc>().add(LoyaltyRedeemPointEvent())
                                : null,
                            style: kAppElevatedButtonStyle(context, disabledColor: Theme.of(context).disabledColor, bgColor: Theme.of(context).primaryColor, foreColor: Theme.of(context).scaffoldBackgroundColor, height: 40),
                            child: state.status.isRedeeming ? kAppCircularProgress(context, color: 'light', strokeWidth: 3.0, width: 24.0, height: 24.0, padding: 2.0) : Text(translate.redeem_points_btn),
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

class LoyaltyLoadingView extends StatelessWidget {
  const LoyaltyLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SkeletonAvatar(
          style: SkeletonAvatarStyle(borderRadius: BorderRadius.circular(10), height: MediaQuery.of(context).size.height * 0.2, width: MediaQuery.of(context).size.width),
        ),
        kAppSpacerVertical(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [SkeletonLine(style: SkeletonLineStyle(borderRadius: BorderRadius.circular(10), height: 10, width: 80))],
        ),
        kAppSpacerVertical(height: 10),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(color: ThemeProvider.lightDisabledColor, width: 1.5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(width: 1.5, color: ThemeProvider.lightDisabledColor)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [SkeletonLine(style: SkeletonLineStyle(borderRadius: BorderRadius.circular(10), height: 10, width: 80))],
                ),
              ),
              kAppSpacerVertical(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 3,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(right: BorderSide(width: 1.5, color: ThemeProvider.lightDisabledColor)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [SkeletonLine(style: SkeletonLineStyle(borderRadius: BorderRadius.circular(10), height: 10, width: 80))],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [SkeletonLine(style: SkeletonLineStyle(borderRadius: BorderRadius.circular(10), height: 10, width: 80))],
                    ),
                  ),
                ],
              ),
              kAppSpacerVertical(height: 10),
            ],
          ),
        ),
        kAppSpacerVertical(height: 10),
        Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(color: ThemeProvider.lightDisabledColor, width: 1.5),
          ),
          child: Column(
            children: [
              SkeletonLine(
                style: SkeletonLineStyle(height: 10, width: MediaQuery.of(context).size.width / 1.5, borderRadius: BorderRadius.circular(8)),
              ),
              kAppSpacerVertical(height: 5),
              SkeletonLine(
                style: SkeletonLineStyle(height: 10, width: MediaQuery.of(context).size.width / 1.2, borderRadius: BorderRadius.circular(8)),
              ),
              kAppSpacerVertical(height: 5),
              SkeletonLine(
                style: SkeletonLineStyle(height: 10, width: MediaQuery.of(context).size.width / 2.8, borderRadius: BorderRadius.circular(8)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class LoyaltyErrorView extends StatelessWidget {
  const LoyaltyErrorView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        children: [
          kAppSpacerVertical(height: 10),
          Image.asset(AssetsUrl.imageURL.homeEmpty, height: 256, width: 256, fit: BoxFit.fitWidth),
          kAppSpacerVertical(height: 10),
          Text(translate.empty_data_two, textAlign: TextAlign.center, style: kAppLblMediumFontRegular(context)),
        ],
      ),
    );
  }
}
// Done //
