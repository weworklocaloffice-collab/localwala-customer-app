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
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:user/app/core/models/address_list_response_model.dart';
import 'package:user/app/presentation/pages/account/address_book/@core/bloc/address_book_bloc.dart';
import 'package:user/app/presentation/pages/account/address_book/new_address_map/new_address_map_view.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/confirm_dialog.dart';
import 'package:user/app/presentation/styles/error_dialog.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/app/presentation/styles/unauthorized_widget.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class AddressBookScreen extends StatelessWidget {
  const AddressBookScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => AddressBookBloc()..add(AddressBookInitialEvent()), child: const AddressBookView());
  }
}

class AddressBookView extends StatelessWidget {
  const AddressBookView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return BlocConsumer<AddressBookBloc, AddressBookState>(
      listener: (context, state) {
        if (state.status.isFailure) {
          showErrorDialog(context, state.alertMessage, state.extraMessage, state.statusCode);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: Text(translate.my_address_title), scrolledUnderElevation: 0),
          body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(ThemeProvider.scaffoldPadding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (state.status.isLoading) ...[
                    const AddressBookLoadingView(),
                  ] else if (state.status.isEmpty) ...[
                    const AddressBookEmptyView(),
                  ] else if (state.status.isUnAuthorizd) ...[
                    const UnauthorizedWidget(),
                  ] else ...[
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
                            return const FractionallySizedBox(
                              child: NewAddressMapScreen(
                                isNew: true,
                                fromDelivery: false,
                                id: '',
                                latitude: 0.0,
                                longitude: 0.0,
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
                            context.read<AddressBookBloc>().add(AddressBookRefreshEvent());
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
                    AddressBookListView(list: state.addresses.list!),
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

class AddressBookListView extends StatelessWidget {
  final List<AddressDataModel> list;
  const AddressBookListView({super.key, required this.list});

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(kAppAddressTitle(context, list[index].title!), style: kAppLblTinyFontBold(context)),
                        PopupMenuButton(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          onSelected: (value) {},
                          icon: FaIcon(FontAwesomeIcons.ellipsisVertical, size: Theme.of(context).textTheme.titleSmall?.fontSize, color: Theme.of(context).canvasColor),
                          itemBuilder: (context) => <PopupMenuEntry>[
                            PopupMenuItem<String>(
                              value: 'edit',
                              child: Text(translate.edit, style: kAppLblMediumFontBold(context)),
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
                                        isNew: false,
                                        fromDelivery: false,
                                        id: list[index].id!,
                                        latitude: list[index].location!.coordinates![1],
                                        longitude: list[index].location!.coordinates![0],
                                        locality: list[index].locality!,
                                        title: list[index].title!,
                                        receiverName: list[index].receiverName!,
                                        countryCode: list[index].countryCode!,
                                        receiverContact: list[index].receiverContact!,
                                        flatHouse: list[index].flatHouse!,
                                        landmark: list[index].landmark!,
                                      ),
                                    );
                                  },
                                ).then((value) {
                                  if (!context.mounted) return;
                                  if (value == 'true' || value == true) {
                                    context.read<AddressBookBloc>().add(AddressBookRefreshEvent());
                                  }
                                });
                              },
                            ),
                            PopupMenuItem<String>(
                              value: 'delete',
                              child: Text(translate.delete_title, style: kAppLblMediumFontBold(context)),
                              onTap: () {
                                showConfirmDialog(context, translate.are_you_sure, translate.confirm_delete_address, translate.cancel_title, translate.confirm_delete_item).then((value) {
                                  if (value) {
                                    if (!context.mounted) return;
                                    context.read<AddressBookBloc>().add(AddressBookDeleteEvent(id: list[index].id!));
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
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
              )
            : const SizedBox(),
      ),
    );
  }
}

class AddressBookLoadingView extends StatelessWidget {
  const AddressBookLoadingView({super.key});

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

class AddressBookEmptyView extends StatelessWidget {
  const AddressBookEmptyView({super.key});

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
