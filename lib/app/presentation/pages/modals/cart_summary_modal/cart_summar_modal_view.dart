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
import 'package:user/app/presentation/pages/modals/cart_summary_modal/bloc/cart_summary_modal_bloc.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/confirm_dialog.dart';
import 'package:user/app/presentation/styles/error_dialog.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/app/presentation/styles/cache_network_widget/cache_network_widget_view.dart';
import 'package:user/app/router/app_route_config.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class CartSummarModalScreen extends StatelessWidget {
  const CartSummarModalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CartSummarModalView();
  }
}

class CartSummarModalView extends StatefulWidget {
  const CartSummarModalView({super.key});

  @override
  State<CartSummarModalView> createState() => _CartSummarModalViewState();
}

class _CartSummarModalViewState extends State<CartSummarModalView> {
  @override
  void initState() {
    super.initState();
    context.read<CartSummaryModalBloc>().add(CartSummaryModalInitialEvent());
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return BlocConsumer<CartSummaryModalBloc, CartSummaryModalState>(
      listener: (context, state) {
        if (state.status.isFailure) {
          showErrorDialog(context, state.alertMessage, state.extraMessage, state.statusCode);
        } else if (state.status.isEmpty) {
          Navigator.of(context).pop();
        } else if (state.status.isAuthorized) {
          context.read<CartSummaryModalBloc>().add(CartSummaryModalChangeInitialEvent());
          Navigator.of(context).pushNamed(AppRouter.checkoutRoute, arguments: [state.checkoutName, state.checkoutRestaurant]);
        } else if (state.status.isUnauthorized) {
          showConfirmDialog(
            context,
            translate.unauthorized,
            translate.unauthorized_checkout_access,
            state.guestCheckout ? translate.sign_in : translate.cancle,
            state.guestCheckout ? translate.guest_checkout : translate.sign_in,
          ).then((value) {
            if (!context.mounted) return;
            if (state.guestCheckout) {
              if (value == false) {
                context.read<CartSummaryModalBloc>().add(CartSummaryModalChangeInitialEvent());
                Navigator.of(context).pushNamedAndRemoveUntil(AppRouter.loginRoute, (Route<dynamic> route) => false);
              } else {
                context.read<CartSummaryModalBloc>().add(CartSummaryModalGuestCheckoutEvent());
              }
            } else {
              if (value == true) {
                context.read<CartSummaryModalBloc>().add(CartSummaryModalChangeInitialEvent());
                Navigator.of(context).pushNamedAndRemoveUntil(AppRouter.loginRoute, (Route<dynamic> route) => false);
              }
            }
          });
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            scrolledUnderElevation: 0,
            automaticallyImplyLeading: false,
            title: Text(translate.your_cart),
            actions: [
              TextButton.icon(
                onPressed: () {
                  showConfirmDialog(context, translate.are_you_sure, translate.confirm_remove_cart_item, translate.no, translate.yes).then((value) {
                    if (!context.mounted) return;
                    if (value == true) {
                      context.read<CartSummaryModalBloc>().add(CartSummaryModalClearCartEvent());
                    }
                  });
                },
                label: Text(
                  translate.clear_all,
                  style: TextStyle(color: Theme.of(context).primaryColor, fontFamily: 'semibold'),
                ),
                icon: Icon(Icons.delete_forever_outlined, color: Theme.of(context).primaryColor, size: Theme.of(context).textTheme.labelSmall?.fontSize),
                iconAlignment: IconAlignment.start,
              ),
              IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close)),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: ThemeProvider.scaffoldPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(
                state.summary.length,
                (summaryIndex) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    border: Border.all(color: ThemeProvider.lightDisabledColor, width: 1.5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop({"type": "restaurant", "value": state.summary[summaryIndex].restId!}),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                              child: CacheNetworkImageWidget(width: 40.0, height: 30.0, imageUrl: state.summary[summaryIndex].restaurantInfo!.logo!),
                            ),
                            kAppSpacerHorizontal(width: 10),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(kAppTrimWord(state.summary[summaryIndex].restaurantInfo!.name!, 30), style: kAppLblTinyFontBold(context)),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(translate.view_menu, style: kAppLblTinyFontRegularChip(context, color: 'primary')),
                                    Icon(Icons.chevron_right, color: Theme.of(context).primaryColor, size: 12),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop({"type": "checkout", "value": state.summary[summaryIndex].restId!}),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                              decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.circular(5)),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(translate.view_cart, style: kAppLblTinyFontBoldCart(context)),
                                  Text("${state.summary[summaryIndex].totalItemInCart} ${translate.items}", style: kAppLblTinyFontBoldCart(context)),
                                ],
                              ),
                            ),
                          ),
                          kAppSpacerHorizontal(width: 10),
                          GestureDetector(
                            onTap: () {
                              showConfirmDialog(
                                context,
                                translate.are_you_sure,
                                '${translate.confirm_remove_restaurant_cart_item_one} ${state.summary[summaryIndex].restaurantInfo!.name!} ${translate.confirm_remove_restaurant_cart_item_two}',
                                translate.no,
                                translate.yes,
                              ).then((value) {
                                if (!context.mounted) return;
                                if (value == true) {
                                  context.read<CartSummaryModalBloc>().add(CartSummaryModalRemoveCartItemByRestaurantEvent(restaurantId: state.summary[summaryIndex].restaurantInfo!.id!));
                                }
                              });
                            },
                            child: Icon(Icons.close, color: Theme.of(context).canvasColor, size: 12),
                          ),
                        ],
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
// Done //
