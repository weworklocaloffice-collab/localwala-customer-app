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
import 'package:user/app/core/models/wallet_info_model.dart';
import 'package:user/app/presentation/pages/account/wallet/@core/bloc/wallet_bloc.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/error_dialog.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/app/presentation/styles/unauthorized_widget.dart';
import 'package:user/app/router/app_route_config.dart';
import 'package:flutter_skeleton_ui/flutter_skeleton_ui.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => WalletBloc()..add(WalletInitalEvent()), child: const WalletView());
  }
}

class WalletView extends StatefulWidget {
  const WalletView({super.key});

  @override
  State<WalletView> createState() => _WalletViewState();
}

class _WalletViewState extends State<WalletView> {
  final ScrollController _transactionScroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _transactionScroll.addListener(() {
      if (_transactionScroll.position.pixels == _transactionScroll.position.maxScrollExtent) {
        context.read<WalletBloc>().add(WalletScrollMoreTransactionEvent());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return BlocConsumer<WalletBloc, WalletState>(
      listener: (context, state) {
        if (state.status.isFailure || state.status.isLoadMoreError) {
          showErrorDialog(context, state.alertMessage, state.extraMessage, state.statusCode);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            scrolledUnderElevation: 0,
            title: Text(translate.wallet),
            actions: state.status.isLoading
                ? []
                : [
                    state.isAuthorized && state.wallet.userSettings!.canAddFundToWallet!
                        ? TextButton(
                            onPressed: () {
                              Navigator.of(context).pushNamed(AppRouter.addWalletMoneyRoute).then((value) {
                                if (!context.mounted) return;
                                if (value != null && value != '' && value.toString() == 'true') {
                                  context.read<WalletBloc>().add(WalletInitalEvent());
                                }
                              });
                            },
                            child: Text(translate.add_money, style: kAppLblMediumFontBold(context)),
                          )
                        : const SizedBox(),
                    state.isAuthorized && state.wallet.userSettings!.canEarnLoyaltyPointOnOrder!
                        ? TextButton(
                            onPressed: () {
                              Navigator.of(context).pushNamed(AppRouter.loyaltyRoute).then((value) {
                                if (!context.mounted) return;
                                if (value != null && value != '' && value.toString() == 'true') {
                                  context.read<WalletBloc>().add(WalletInitalEvent());
                                }
                              });
                            },
                            child: Text(translate.loyalty, style: kAppLblMediumFontBold(context)),
                          )
                        : const SizedBox(),
                  ],
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: ThemeProvider.scaffoldPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (state.status.isLoading) ...[
                  const WalletLoadingView(),
                ] else if (state.status.isFailure) ...[
                  const WalletErrorView(),
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
                        Text(state.wallet.info!.description!, style: kAppLblMediumFontBold(context)),
                        kAppSpacerVertical(height: 10),
                        Text("${translate.balance} ${kAppPriceFormat(state.wallet.info!.balance!)}", style: kAppLblLargeFontBold(context)),
                        kAppSpacerVertical(height: 10),
                        Text("${translate.id} : ${state.wallet.info!.id!}", style: kAppLblMediumFontRegular(context)),
                      ],
                    ),
                  ),
                  kAppSpacerVertical(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: Image.asset(AssetsUrl.imageURL.moneyDeposite, width: 15, height: 15),
                          label: Text(translate.deposite, style: kAppLblMediumFontSemiBold(context, color: state.toggleTransaction == 'deposite' ? 'primary' : 'regular')),
                          onPressed: () => context.read<WalletBloc>().add(WalletToggleTransactionEvent(transaction: 'deposite')),
                          style: kAppElevatedButtonOutlineStyle(
                            context,
                            disabledColor: Theme.of(context).disabledColor,
                            bgColor: ThemeProvider.transparentColor,
                            foreColor: Theme.of(context).canvasColor,
                            borderColor: state.toggleTransaction == 'deposite' ? Theme.of(context).primaryColor : Theme.of(context).canvasColor,
                            height: 40,
                          ),
                        ),
                      ),
                      kAppSpacerHorizontal(width: 15),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: Image.asset(AssetsUrl.imageURL.moneyWithdrawal, width: 15, height: 15),
                          label: Text(translate.withdrawal, style: kAppLblMediumFontSemiBold(context, color: state.toggleTransaction == 'withdrawal' ? 'primary' : 'regular')),
                          onPressed: () => context.read<WalletBloc>().add(WalletToggleTransactionEvent(transaction: 'withdrawal')),
                          style: kAppElevatedButtonOutlineStyle(
                            context,
                            disabledColor: Theme.of(context).disabledColor,
                            bgColor: ThemeProvider.transparentColor,
                            foreColor: Theme.of(context).canvasColor,
                            borderColor: state.toggleTransaction == 'withdrawal' ? Theme.of(context).primaryColor : Theme.of(context).canvasColor,
                            height: 40,
                          ),
                        ),
                      ),
                    ],
                  ),
                  kAppSpacerVertical(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(translate.transaction_history, style: kAppLblSmallFontRegular(context)),
                      Text("${state.wallet.transaction!.length}/${state.wallet.totalResults!} ${translate.results}", style: kAppLblSmallFontRegular(context)),
                    ],
                  ),
                  kAppSpacerVertical(height: 20),
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
                  Expanded(
                    child: SingleChildScrollView(
                      controller: _transactionScroll,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(
                          state.wallet.transaction!.length,
                          (walletIndex) => Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (state.toggleTransaction == 'withdrawal') ...[
                                state.wallet.transaction![walletIndex].type! == 'withdrawal' ? WalletTransactionWidget(model: state.wallet, walletIndex: walletIndex) : const SizedBox(),
                              ] else if (state.toggleTransaction == 'deposite')
                                state.wallet.transaction![walletIndex].type! == 'deposite' ? WalletTransactionWidget(model: state.wallet, walletIndex: walletIndex) : const SizedBox()
                              else ...[
                                WalletTransactionWidget(model: state.wallet, walletIndex: walletIndex),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
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

class WalletTransactionWidget extends StatelessWidget {
  final WalletInfoModel model;
  final int walletIndex;
  const WalletTransactionWidget({super.key, required this.model, required this.walletIndex});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return Container(
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
              children: [Image.asset(model.transaction![walletIndex].type == 'deposite' ? AssetsUrl.imageURL.moneyDeposite : AssetsUrl.imageURL.moneyWithdrawal, height: 20, width: 20)],
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
                    Text(model.transaction![walletIndex].type == 'deposite' ? translate.deposite : translate.withdrawal, style: kAppLblMediumFontBold(context)),
                    Text(model.transaction![walletIndex].createdAt!, style: kAppLblSmallFontRegular(context)),
                  ],
                ),
                Text(kAppPriceFormat(model.transaction![walletIndex].amount!), style: kAppLblMediumFontBold(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class WalletLoadingView extends StatelessWidget {
  const WalletLoadingView({super.key});

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

class WalletErrorView extends StatelessWidget {
  const WalletErrorView({super.key});

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
