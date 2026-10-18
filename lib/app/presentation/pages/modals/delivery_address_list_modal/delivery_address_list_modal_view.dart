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
import 'package:user/app/core/models/delivery_address_list_from_checkout_model.dart';
import 'package:user/app/presentation/pages/account/address_book/new_address_map/new_address_map_view.dart';
import 'package:user/app/presentation/pages/modals/delivery_address_list_modal/bloc/delivery_addresss_list_bloc.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/error_dialog.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class DeliveryAddressListModalScreen extends StatelessWidget {
  final double deliveryArea;
  final String restaurant;
  final String deliveryAddressId;
  const DeliveryAddressListModalScreen({super.key, required this.deliveryArea, required this.restaurant, required this.deliveryAddressId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DeliveryAddresssListBloc()..add(DeliveryAddressListInitialEvent(deliveryArea: deliveryArea, restaurant: restaurant, deliveryAddressId: deliveryAddressId)),
      child: const DeliveryAddressListModalView(),
    );
  }
}

class DeliveryAddressListModalView extends StatelessWidget {
  const DeliveryAddressListModalView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return BlocConsumer<DeliveryAddresssListBloc, DeliveryAddresssListState>(
      listener: (context, state) {
        if (state.status.isFailure) {
          showErrorDialog(context, state.alertMessage, state.extraMessage, state.statusCode);
        } else if (state.status.isSelected) {
          Navigator.of(context).pop({'status': true, 'selected': state.addresses.list![state.selectedIndex].toJson()});
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            scrolledUnderElevation: 0,
            automaticallyImplyLeading: false,
            title: Text(translate.select_address),
            actions: [IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close))],
          ),
          body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(ThemeProvider.scaffoldPadding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        isDismissible: false,
                        enableDrag: false,
                        showDragHandle: false,
                        useSafeArea: true,
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(10.0))),
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        builder: (BuildContext context) {
                          return FractionallySizedBox(
                            child: NewAddressMapScreen(
                              isNew: true,
                              fromDelivery: true,
                              id: '',
                              latitude: state.latitude,
                              longitude: state.longitude,
                              locality: '',
                              title: 0,
                              receiverName: '',
                              countryCode: '',
                              receiverContact: '',
                              flatHouse: '',
                              landmark: '',
                            ),
                          );
                        },
                      ).then((value) {
                        if (!context.mounted) return;
                        if (value == 'true' || value == true) {
                          context.read<DeliveryAddresssListBloc>().add(DeliveryAddresssRefreshEvent());
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        border: Border.all(color: ThemeProvider.lightDisabledColor, width: 1.5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(Icons.add, size: Theme.of(context).textTheme.labelMedium?.fontSize, color: Theme.of(context).primaryColor),
                              kAppSpacerHorizontal(width: 10),
                              Text(translate.add_address, style: kAppLblMediumFontMedium(context, color: 'primary')),
                            ],
                          ),
                          Icon(Icons.chevron_right_outlined, size: Theme.of(context).textTheme.labelMedium?.fontSize),
                        ],
                      ),
                    ),
                  ),
                  kAppSpacerVertical(height: 10),
                  kAppTitleDivider(context, translate.saved_address_title, 0),
                  kAppSpacerVertical(height: 10),
                  state.status.isLoading ? const DeliveryAddressListLoadingView() : const SizedBox(),
                  state.status.isEmpty ? const DeliveryAddressListEmptyView() : const SizedBox(),
                  DeliveryAddressListView(courage: state.addresses.courage!, deliveryAddressId: state.deliveryAddressId, list: state.addresses.list!, mode: state.addresses.mode!),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class DeliveryAddressListView extends StatelessWidget {
  final double courage;
  final String deliveryAddressId;
  final List<AddressListConfigModel> list;
  final String mode;
  const DeliveryAddressListView({super.key, required this.courage, required this.deliveryAddressId, required this.list, required this.mode});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(
        list.length,
        (index) => list[index].willShow!
            ? Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                margin: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  border: Border.all(color: ThemeProvider.lightDisabledColor, width: 1.5),
                ),
                child: InkWell(
                  onTap: () => context.read<DeliveryAddresssListBloc>().add(DeliveryAddressSelectEvent(id: list[index].id!)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        double.parse(list[index].distance!.toString()) <= courage ? translate.delivers_to : translate.does_not_deliver_to,
                        style: kAppLblSemiBoldToggle(context, canDeliver: double.parse(list[index].distance!.toString()) <= courage),
                      ),
                      kAppSpacerVertical(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(kAppAddressTitle(context, list[index].title!), style: kAppLblTinyFontBold(context)),
                              Text(" - ", style: kAppLblTinyFontBold(context)),
                              Text("${list[index].distance}$mode", style: kAppLblTinyFontBold(context)),
                            ],
                          ),
                          Icon(
                            list[index].id! == deliveryAddressId ? Icons.check_circle : Icons.circle_outlined,
                            size: Theme.of(context).textTheme.labelLarge?.fontSize,
                            color: list[index].id! == deliveryAddressId ? Theme.of(context).primaryColor : Theme.of(context).canvasColor,
                          ),
                        ],
                      ),
                      kAppSpacerVertical(height: 5),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 1.2,
                        child: Text("${list[index].flatHouse!}, ${list[index].locality!}, ${list[index].landmark!}", maxLines: 2, overflow: TextOverflow.ellipsis, style: kAppLblTinyFontRegular(context)),
                      ),
                      kAppSpacerVertical(height: 3),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text("${translate.receiver_name} : ", style: kAppLblTinyFontRegular(context)),
                          kAppSpacerHorizontal(width: 5),
                          Text("${list[index].receiverName}", style: kAppLblTinyFontBold(context)),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text("${translate.receiver_contact} : ", style: kAppLblTinyFontRegular(context)),
                          kAppSpacerHorizontal(width: 5),
                          Text("+${list[index].countryCode} - ${list[index].receiverContact}", style: kAppLblTinyFontBold(context)),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            : const SizedBox(),
      ),
    );
  }
}

class DeliveryAddressListLoadingView extends StatelessWidget {
  const DeliveryAddressListLoadingView({super.key});

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

class DeliveryAddressListEmptyView extends StatelessWidget {
  const DeliveryAddressListEmptyView({super.key});

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

