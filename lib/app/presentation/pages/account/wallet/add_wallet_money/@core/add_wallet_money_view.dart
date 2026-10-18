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
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_skeleton_ui/flutter_skeleton_ui.dart';
import 'package:user/app/core/config/assets_url.dart';
import 'package:user/app/presentation/pages/account/wallet/add_wallet_money/@core/bloc/add_wallet_money_bloc.dart';
import 'package:user/app/presentation/pages/account/wallet/add_wallet_money/make_wallet_payments/make_wallet_payments_view.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/error_dialog.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/app/presentation/styles/cache_network_widget/cache_network_widget_view.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class AddWalletMoneyScreen extends StatelessWidget {
  const AddWalletMoneyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => AddWalletMoneyBloc()..add(AddWalletMoneyInitialEvent()), child: const AddWalletMoneyView());
  }
}

class AddWalletMoneyView extends StatefulWidget {
  const AddWalletMoneyView({super.key});

  @override
  State<AddWalletMoneyView> createState() => _AddWalletMoneyViewState();
}

class _AddWalletMoneyViewState extends State<AddWalletMoneyView> {
  final TextEditingController _amountController = TextEditingController();
  final _amountFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _amountFocusNode.addListener(() {
      if (!_amountFocusNode.hasFocus) {
        context.read<AddWalletMoneyBloc>().add(AddWalletMoneyAmountUnfocused());
      }
    });
  }

  @override
  void dispose() {
    _amountFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return BlocConsumer<AddWalletMoneyBloc, AddWalletMoneyState>(
      listener: (context, state) {
        if (state.status.isFailure || state.status.isPaymentLinkFailed) {
          showErrorDialog(context, state.alertMessage, state.extraMessage, state.statusCode);
        } else if (state.status.isNewCount) {
          _amountController.text = state.amount.value;
        } else if (state.status.isPaymentLinkFetched) {
          Navigator.of(context)
              .push(
                MaterialPageRoute(
                  builder: (BuildContext context) {
                    return MakeWalletPaymentScreen(paymentId: state.paymentLinkId);
                  },
                  fullscreenDialog: true,
                ),
              )
              .then((value) {
                if (!context.mounted) return;
                if (value != null && value != '' && value.toString() == 'true') {
                  Navigator.of(context).pop(true);
                }
              });
        }
      },
      builder: (context, state) {
        return AbsorbPointer(
          absorbing: state.status.isFetchingPaymentLink ? true : false,
          child: Scaffold(
            appBar: AppBar(title: Text(translate.add_money_to_wallet), scrolledUnderElevation: 0),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(ThemeProvider.scaffoldPadding),
                child: Column(
                  children: [
                    if (state.status.isLoading) ...[
                      const AddWalletMoneyLoading(),
                    ] else if (state.status.isFailure) ...[
                      const AddWalletMoneyErrorView(),
                    ] else if (state.status.isEmpty) ...[
                      const AddWalletMoneyEmptyView(),
                    ] else ...[
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              border: Border.all(color: ThemeProvider.lightDisabledColor, width: 1.5),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextFormField(
                                  focusNode: _amountFocusNode,
                                  controller: _amountController,
                                  decoration: kAppInputDecoration(
                                    context,
                                    prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
                                    lblText: translate.enter_amount,
                                    errText: state.amount.displayError != null ? translate.form_required : null,
                                  ),
                                  style: kAppLblSmallFontMedium(context),
                                  keyboardType: TextInputType.emailAddress,
                                  onChanged: (value) => context.read<AddWalletMoneyBloc>().add(AddWalletMoneyAmountChanged(amount: value)),
                                  textInputAction: TextInputAction.next,
                                ),
                                kAppSpacerVertical(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: List.generate(
                                    state.suggested.length,
                                    (index) => InkWell(
                                      onTap: () => context.read<AddWalletMoneyBloc>().add(AddWalletMoneyIncrementEvent(amount: state.suggested[index])),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                        margin: const EdgeInsets.only(right: 10),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(5.0),
                                          border: Border.all(color: Theme.of(context).canvasColor, width: 1),
                                        ),
                                        child: Text("+ ${kAppPriceFormat(double.parse(state.suggested[index]))}", style: kAppLblTinyFontRegularChip(context, color: 'regular')),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          kAppSpacerVertical(height: 20),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              border: Border.all(color: ThemeProvider.lightDisabledColor, width: 1.5),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.asset(AssetsUrl.iconsURL.billIcon, height: 15, width: 15, color: Theme.of(context).canvasColor),
                                kAppSpacerHorizontal(width: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(translate.to_pay, style: kAppLblMediumFontMedium(context)),
                                    Text(" : ", style: kAppLblMediumFontMedium(context)),
                                    Text(state.amount.value.isNotEmpty && state.amount.value != '' ? kAppPriceFormat(double.parse(state.amount.value)) : kAppPriceFormat(0.0), style: kAppLblMediumFontBold(context)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          kAppSpacerVertical(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(translate.single_click_payment, style: kAppLblTinyFontRegular(context)),
                              Text(translate.no_additional_cost, style: kAppLblTinyFontRegular(context)),
                            ],
                          ),
                          kAppSpacerVertical(height: 20),
                          CarouselSlider(
                            options: CarouselOptions(autoPlay: true, viewportFraction: 1, aspectRatio: 2.0, enlargeCenterPage: false, height: 160.0, scrollDirection: Axis.horizontal),
                            items: List.generate(
                              state.basicDetail.bonus!.length,
                              (bonusIndex) => Container(
                                width: MediaQuery.of(context).size.width,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15.0),
                                  border: Border.all(color: ThemeProvider.lightDisabledColor, width: 1.5),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Expanded(
                                      flex: 5,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(state.basicDetail.bonus![bonusIndex].name!, style: kAppLblMediumFontBold(context, color: 'primary')),
                                          kAppSpacerVertical(height: 5),
                                          Text("${translate.valid_till} ${state.basicDetail.bonus![bonusIndex].expires!}", style: kAppLblTinyFontBold(context)),
                                          kAppSpacerVertical(height: 5),
                                          Text(kAppTrimWord(state.basicDetail.bonus![bonusIndex].shortDescription!, 130), style: kAppLblTinyFontRegular(context)),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: SizedBox(
                                        width: 50.0,
                                        height: 50.0,
                                        child: CacheNetworkImageWidget(width: 50.0, height: 50.0, imageUrl: state.basicDetail.bonus![bonusIndex].image!, fit: BoxFit.contain),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            bottomNavigationBar: SafeArea(
              child: SizedBox(
                height: 80,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: ThemeProvider.scaffoldPadding, vertical: 10),
                  child: state.status.isLoading
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Expanded(
                              flex: 2,
                              child: SkeletonLine(
                                style: SkeletonLineStyle(height: 30, width: MediaQuery.of(context).size.width, borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                            const Expanded(flex: 1, child: SizedBox(width: double.infinity)),
                            Expanded(
                              flex: 3,
                              child: SkeletonLine(
                                style: SkeletonLineStyle(height: 30, width: MediaQuery.of(context).size.width, borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(3),
                                        decoration: BoxDecoration(color: Theme.of(context).primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(5)),
                                        child: Icon(Icons.account_balance_wallet_outlined, size: 16, color: Theme.of(context).primaryColor),
                                      ),
                                      kAppSpacerHorizontal(width: 5),
                                      Flexible(child: Text(translate.pay_using, style: kAppLblTinyFontRegular(context), overflow: TextOverflow.ellipsis)),
                                    ],
                                  ),
                                  kAppSpacerVertical(height: 5),
                                  Text(state.paymentName, maxLines: 1, overflow: TextOverflow.ellipsis, style: kAppLblMediumFontRegular(context)),
                                  Text(translate.pay_methods_hint, maxLines: 1, overflow: TextOverflow.ellipsis, style: kAppLblTinyFontRegular(context)),
                                ],
                              ),
                            ),
                            const Expanded(flex: 1, child: SizedBox(width: double.infinity)),
                            Expanded(
                              flex: 3,
                              child: InkWell(
                                onTap: () => state.amount.value.isNotEmpty && state.amount.value != '' ? context.read<AddWalletMoneyBloc>().add(AddWalletMoneySubmitEvent()) : null,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                                  width: double.infinity,
                                  height: 60.0,
                                  decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.circular(5)),
                                  child: state.status.isFetchingPaymentLink
                                      ? Center(child: kAppCircularProgress(context, color: 'light', strokeWidth: 3.0, width: 24.0, height: 24.0, padding: 2.0))
                                      : Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Text(
                                                  state.amount.value.isNotEmpty && state.amount.value != '' ? kAppPriceFormat(double.parse(state.amount.value)) : kAppPriceFormat(0.0),
                                                  style: kAppLblMediumFontSemiBoldWhite(context),
                                                ),
                                                kAppSpacerVertical(height: 3),
                                                Text(translate.total, style: kAppLblTinyFontBoldCart(context)),
                                              ],
                                            ),
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                Text(translate.pay_now, style: kAppLblMediumFontSemiBoldWhite(context)),
                                                Icon(Icons.arrow_right, color: Theme.of(context).scaffoldBackgroundColor, size: 14),
                                              ],
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class AddWalletMoneyLoading extends StatelessWidget {
  const AddWalletMoneyLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SkeletonLine(
                  style: SkeletonLineStyle(height: 30, width: MediaQuery.of(context).size.width / 1.5, borderRadius: BorderRadius.circular(8)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SkeletonLine(
                  style: SkeletonLineStyle(height: 10, width: MediaQuery.of(context).size.width / 1.5, borderRadius: BorderRadius.circular(8)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SkeletonLine(style: SkeletonLineStyle(height: 8, width: 64, borderRadius: BorderRadius.circular(8))),
                const SizedBox(width: 5),
                SkeletonLine(style: SkeletonLineStyle(height: 8, width: 64, borderRadius: BorderRadius.circular(8))),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SkeletonLine(
                  style: SkeletonLineStyle(height: 10, width: MediaQuery.of(context).size.width / 1.5, borderRadius: BorderRadius.circular(8)),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
        const SizedBox(height: 20),
        SkeletonLine(
          style: SkeletonLineStyle(height: 50, width: double.infinity, borderRadius: BorderRadius.circular(8)),
        ),
        const SizedBox(height: 20),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(10, (index) {
              return SkeletonAvatar(
                style: SkeletonAvatarStyle(width: 80, height: 30, padding: const EdgeInsets.symmetric(horizontal: 5), borderRadius: BorderRadius.circular(8)),
              );
            }),
          ),
        ),
        const SizedBox(height: 20),
        SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: List.generate(2, (index) {
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
                      style: SkeletonLineStyle(height: 10, width: MediaQuery.of(context).size.width, borderRadius: BorderRadius.circular(8)),
                    ),
                    const SizedBox(height: 5),
                    SkeletonLine(
                      style: SkeletonLineStyle(height: 10, width: MediaQuery.of(context).size.width, borderRadius: BorderRadius.circular(8)),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SkeletonLine(style: SkeletonLineStyle(height: 25, width: 25, borderRadius: BorderRadius.circular(8))),
                        const SizedBox(width: 10),
                        SkeletonLine(style: SkeletonLineStyle(height: 25, width: 25, borderRadius: BorderRadius.circular(8))),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class AddWalletMoneyErrorView extends StatelessWidget {
  const AddWalletMoneyErrorView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        children: [
          kAppSpacerVertical(height: 20),
          Image.asset(AssetsUrl.imageURL.homeEmpty, height: 256, width: 256, fit: BoxFit.fitWidth),
          kAppSpacerVertical(height: 20),
          Text(translate.comman_error_reason, textAlign: TextAlign.center, style: kAppLblMediumFontRegular(context)),
        ],
      ),
    );
  }
}

class AddWalletMoneyEmptyView extends StatelessWidget {
  const AddWalletMoneyEmptyView({super.key});

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
// Done //
