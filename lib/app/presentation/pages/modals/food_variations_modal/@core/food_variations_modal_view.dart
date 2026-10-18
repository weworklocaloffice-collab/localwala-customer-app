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
import 'package:user/app/presentation/pages/modals/food_variations_modal/@core/bloc/food_variations_bloc.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/error_dialog.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/app/presentation/styles/cache_network_widget/cache_network_widget_view.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class FoodVariationsModalScreen extends StatelessWidget {
  final String id;
  final String name;
  final String image;
  final String options;
  final double price;
  final double offerPrice;
  final String discountType;
  final double discount;
  final int purchaseLimit;
  final int stockNumber;
  final String stockType;
  const FoodVariationsModalScreen({
    super.key,
    required this.id,
    required this.name,
    required this.image,
    required this.options,
    required this.price,
    required this.offerPrice,
    required this.discountType,
    required this.discount,
    required this.purchaseLimit,
    required this.stockNumber,
    required this.stockType,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FoodVariationsBloc()
        ..add(
          FoodVariationsInitialEvent(
            id: id,
            name: name,
            image: image,
            options: options,
            price: price,
            offerPrice: offerPrice,
            discountType: discountType,
            discount: discount,
            purchaseLimit: purchaseLimit,
            stockNumber: stockNumber,
            stockType: stockType,
          ),
        ),
      child: FoodVariationsModalView(id: id, name: name, image: image),
    );
  }
}

class FoodVariationsModalView extends StatelessWidget {
  final String id;
  final String name;
  final String image;
  const FoodVariationsModalView({super.key, required this.id, required this.name, required this.image});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return BlocConsumer<FoodVariationsBloc, FoodVariationsState>(
      listener: (context, state) {
        if (state.status.isFailure) {
          showErrorDialog(context, state.alertMessage, state.extraMessage, state.statusCode);
        } else if (state.status.isEmptyClose) {
          Navigator.of(context, rootNavigator: true).pop({'action': false, 'cartItem': state.cartItem.toJson()});
        } else if (state.status.isSuccessClose) {
          Navigator.of(context, rootNavigator: true).pop({'action': true, 'cartItem': state.cartItem.toJson(), 'instruction': state.instruction});
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            scrolledUnderElevation: 0,
            toolbarHeight: 70,
            flexibleSpace: Padding(
              padding: const EdgeInsets.symmetric(horizontal: ThemeProvider.scaffoldPadding, vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: SizedBox.fromSize(
                          size: const Size.fromRadius(20.0),
                          child: CacheNetworkImageWidget(width: 20.0, height: 20.0, imageUrl: image),
                        ),
                      ),
                      kAppSpacerHorizontal(width: 5),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(kAppTrimWord(name, 20), style: Theme.of(context).appBarTheme.titleTextStyle),
                          state.discount <= 0
                              ? Text(kAppPriceFormat(state.price), style: kAppLblTinyFontBold(context))
                              : Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(kAppPriceFormat(state.price), style: kAppLblTinyStrokeRegular(context)),
                                    kAppSpacerHorizontal(width: 5),
                                    Text(kAppPriceFormat(state.offerPrice), style: kAppLblTinyFontBold(context)),
                                  ],
                                ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(Icons.close, color: Theme.of(context).primaryColor),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: ThemeProvider.scaffoldPadding),
              child: state.status.isLoading
                  ? kAppCenterCircularProgress(context)
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        state.discount > 0
                            ? Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                margin: const EdgeInsets.symmetric(vertical: 5),
                                decoration: BoxDecoration(color: ThemeProvider.darkBackgroundColor, borderRadius: BorderRadius.circular(10.0)),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Image.asset(AssetsUrl.imageURL.offerTag, height: 10, width: 10),
                                    kAppSpacerHorizontal(width: 5),
                                    Text(
                                      state.discountType == '%' ? '${translate.flat} ${state.discount}% ${translate.off}' : '${translate.flat} ${kAppPriceFormat(state.discount)} ${translate.off}',
                                      style: kAppLblTinyBoldOffer(context),
                                    ),
                                  ],
                                ),
                              )
                            : const SizedBox(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: List.generate(
                            state.options.variations!.length,
                            (vIndex) => Container(
                              width: MediaQuery.of(context).size.width,
                              margin: const EdgeInsets.symmetric(vertical: 5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                border: Border.all(color: ThemeProvider.lightDisabledColor, width: 1.5),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(5),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Text(kAppTrimWord(state.options.variations![vIndex].title!, 20), style: kAppLblMediumFontBold(context)),
                                            kAppSpacerVertical(height: 5),
                                            state.options.variations![vIndex].type == 'single'
                                                ? Text(translate.select_any_one_option, style: kAppLblTinyFontRegular(context))
                                                : Text("${translate.select_min} ${state.options.variations![vIndex].min} ${translate.and_upto} ${state.options.variations![vIndex].max}", style: kAppLblTinyFontRegular(context)),
                                          ],
                                        ),
                                        state.options.variations![vIndex].isRequired!
                                            ? Container(
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(5.0),
                                                  border: Border.all(color: ThemeProvider.lightDisabledColor, width: 1.5),
                                                ),
                                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                                child: Text(translate.required_food_variation, style: kAppLblTinyFontRegular(context)),
                                              )
                                            : const SizedBox(),
                                      ],
                                    ),
                                  ),
                                  Divider(thickness: 0.5, color: ThemeProvider.lightDisabledColor, height: 5),
                                  Padding(
                                    padding: const EdgeInsets.all(5),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: List.generate(
                                        state.options.variations![vIndex].options!.length,
                                        (oIndex) => InkWell(
                                          onTap: () => context.read<FoodVariationsBloc>().add(FoodVariationOptionEvent(vIndex: vIndex, oIndex: oIndex, type: state.options.variations![vIndex].type!)),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 8),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    Text(state.options.variations![vIndex].options![oIndex].name!, style: kAppLblTinyFontBold(context)),
                                                    state.options.variations![vIndex].options![oIndex].limitCrossed!
                                                        ? Row(
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            children: [
                                                              kAppSpacerHorizontal(width: 5),
                                                              Text(
                                                                "(${translate.only} ${state.options.variations![vIndex].options![oIndex].stock!} ${translate.item_available})",
                                                                style: kAppLblTinyFontRegularChip(context, color: 'primary'),
                                                              ),
                                                            ],
                                                          )
                                                        : const SizedBox(),
                                                    !state.options.variations![vIndex].options![oIndex].inStock!
                                                        ? Row(
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            children: [
                                                              kAppSpacerHorizontal(width: 5),
                                                              Text("(${translate.out_of_stock})", style: kAppLblTinyFontRegularChip(context, color: 'primary')),
                                                            ],
                                                          )
                                                        : const SizedBox(),
                                                  ],
                                                ),
                                                Row(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                  children: [
                                                    !state.options.variations![vIndex].options![oIndex].haveDiscount!
                                                        ? Text("+ ${kAppPriceFormat(state.options.variations![vIndex].options![oIndex].price!)}", style: kAppLblTinyFontBold(context))
                                                        : Row(
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            mainAxisAlignment: MainAxisAlignment.end,
                                                            children: [
                                                              Text(kAppPriceFormat(state.options.variations![vIndex].options![oIndex].price!), style: kAppLblTinyStrokeRegular(context)),
                                                              kAppSpacerHorizontal(width: 5),
                                                              Text("+ ${kAppPriceFormat(state.options.variations![vIndex].options![oIndex].discountPrice!)}", style: kAppLblTinyFontBold(context)),
                                                            ],
                                                          ),
                                                    kAppSpacerHorizontal(width: 5),
                                                    state.options.variations![vIndex].type == 'single'
                                                        ? Icon(
                                                            state.options.variations![vIndex].options![oIndex].checked! ? Icons.radio_button_checked_rounded : Icons.radio_button_off,
                                                            size: 16,
                                                            color: Theme.of(context).primaryColor,
                                                          )
                                                        : Icon(
                                                            state.options.variations![vIndex].options![oIndex].checked!
                                                                ? Icons.check_box_rounded
                                                                : state.options.variations![vIndex].options![oIndex].enable!
                                                                ? Icons.check_box_outline_blank_rounded
                                                                : Icons.indeterminate_check_box_outlined,
                                                            size: 16,
                                                            color: Theme.of(context).primaryColor,
                                                          ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        state.options.addons!.isNotEmpty
                            ? Container(
                                width: MediaQuery.of(context).size.width,
                                margin: const EdgeInsets.symmetric(vertical: 5),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  border: Border.all(color: ThemeProvider.lightDisabledColor, width: 1.5),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(5),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Text(translate.food_addon, style: kAppLblMediumFontBold(context)),
                                              kAppSpacerVertical(height: 5),
                                              Text(translate.select_addon_title, style: kAppLblTinyFontRegular(context)),
                                            ],
                                          ),
                                          const SizedBox(),
                                        ],
                                      ),
                                    ),
                                    Divider(thickness: 0.5, color: ThemeProvider.lightDisabledColor, height: 5),
                                    Padding(
                                      padding: const EdgeInsets.all(5),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: List.generate(
                                          state.options.addons!.length,
                                          (aIndex) => InkWell(
                                            onTap: () => context.read<FoodVariationsBloc>().add(FoodVariationsAddonsEvent(index: aIndex)),
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 8),
                                              child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      Text(state.options.addons![aIndex].name!, style: kAppLblTinyFontBold(context)),
                                                      state.options.addons![aIndex].limitCrossed!
                                                          ? Row(
                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                              children: [
                                                                kAppSpacerHorizontal(width: 5),
                                                                Text("(${translate.only} ${state.options.addons![aIndex].stockNumber!} ${translate.item_available})", style: kAppLblTinyFontRegularChip(context, color: 'primary')),
                                                              ],
                                                            )
                                                          : const SizedBox(),
                                                      !state.options.addons![aIndex].inStock!
                                                          ? Row(
                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                              children: [
                                                                kAppSpacerHorizontal(width: 5),
                                                                Text("(${translate.out_of_stock})", style: kAppLblTinyFontRegularChip(context, color: 'primary')),
                                                              ],
                                                            )
                                                          : const SizedBox(),
                                                    ],
                                                  ),
                                                  Row(
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                    children: [
                                                      !state.options.addons![aIndex].haveDiscount!
                                                          ? Text("+ ${kAppPriceFormat(state.options.addons![aIndex].price!)}", style: kAppLblTinyFontBold(context))
                                                          : Row(
                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                              mainAxisAlignment: MainAxisAlignment.end,
                                                              children: [
                                                                Text(kAppPriceFormat(state.options.addons![aIndex].price!), style: kAppLblTinyStrokeRegular(context)),
                                                                kAppSpacerHorizontal(width: 5),
                                                                Text("+ ${kAppPriceFormat(state.options.addons![aIndex].discountPrice!)}", style: kAppLblTinyFontBold(context)),
                                                              ],
                                                            ),
                                                      kAppSpacerHorizontal(width: 5),
                                                      Icon(state.options.addons![aIndex].checked! ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded, size: 16, color: Theme.of(context).primaryColor),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : const SizedBox(),
                        kAppSpacerVertical(height: 30),
                        TextField(
                          maxLines: 3,
                          maxLength: 100,
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.done,
                          decoration: kAppInputDecoration(context, lblText: translate.cooking_instruction, errText: null),
                          style: kAppLblSmallFontMedium(context),
                          onChanged: (value) => context.read<FoodVariationsBloc>().add(FoodVariationInstructionChangeEvent(instruction: value)),
                        ),
                      ],
                    ),
            ),
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: ThemeProvider.scaffoldPadding, vertical: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("${translate.total_amount} :", style: kAppLblMediumFontBold(context)),
                        state.discount > 0
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(kAppPriceFormat(state.originalPrice), style: kAppLblTinyStrokeRegular(context)),
                                  kAppSpacerHorizontal(width: 5),
                                  Text("+ ${kAppPriceFormat(state.discountPrice)}", style: kAppLblTinyFontBold(context)),
                                ],
                              )
                            : Text("+ ${kAppPriceFormat(state.originalPrice)}", style: kAppLblTinyFontBold(context)),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Container(
                          width: double.infinity,
                          height: 40.0,
                          decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: ThemeProvider.lightDisabledColor, width: 1.5),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              InkWell(
                                onTap: () => context.read<FoodVariationsBloc>().add(FoodVariationQuantityEvent(action: 'decrease')),
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 15, left: 5),
                                  child: Icon(Icons.remove, size: 18, color: Theme.of(context).primaryColor),
                                ),
                              ),
                              Text("${state.quantity}", style: kAppLblSmallFontBold(context, color: 'primary')),
                              InkWell(
                                onTap: () => context.read<FoodVariationsBloc>().add(FoodVariationQuantityEvent(action: 'increase')),
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 15, right: 5),
                                  child: Icon(Icons.add, size: 18, color: Theme.of(context).primaryColor),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Expanded(flex: 1, child: SizedBox(width: double.infinity)),
                      Expanded(
                        flex: 3,
                        child: InkWell(
                          onTap: () => context.read<FoodVariationsBloc>().add(FoodVariationSaveEvent()),
                          child: Container(
                            width: double.infinity,
                            height: 40.0,
                            decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.circular(5)),
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [Text(translate.add_to_cart_btn, style: kAppLblSmallFontBoldCart(context))],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
// Done //
