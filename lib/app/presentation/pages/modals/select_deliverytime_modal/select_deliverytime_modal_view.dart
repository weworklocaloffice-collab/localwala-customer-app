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
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_skeleton_ui/flutter_skeleton_ui.dart';
import 'package:user/app/core/config/assets_url.dart';
import 'package:user/app/presentation/pages/modals/select_deliverytime_modal/bloc/select_delivery_time_modal_bloc.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/error_dialog.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class SelectDeliverytimeModalScreen extends StatelessWidget {
  final String deliveryTime;
  const SelectDeliverytimeModalScreen({super.key, required this.deliveryTime});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SelectDeliveryTimeModalBloc()..add(SelectDeliveryTimeModalInitialEvent(deliveryTime: deliveryTime)),
      child: const SelectDeliverytimeModalView(),
    );
  }
}

class SelectDeliverytimeModalView extends StatefulWidget {
  const SelectDeliverytimeModalView({super.key});

  @override
  State<SelectDeliverytimeModalView> createState() => _SelectDeliverytimeModalViewState();
}

class _SelectDeliverytimeModalViewState extends State<SelectDeliverytimeModalView> {
  final TextEditingController fromController = TextEditingController();
  final TextEditingController toController = TextEditingController();

  final _fromFocusNode = FocusNode();
  final _toFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _fromFocusNode.addListener(() {
      if (!_fromFocusNode.hasFocus) {
        context.read<SelectDeliveryTimeModalBloc>().add(SelectDeliveryTimeModalFromUnfocusedEvent());
      }
    });

    _toFocusNode.addListener(() {
      if (!_toFocusNode.hasFocus) {
        context.read<SelectDeliveryTimeModalBloc>().add(SelectDeliveryTimeModalToUnfocusedEvent());
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    fromController.dispose();
    toController.dispose();
    _fromFocusNode.dispose();
    _toFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return BlocConsumer<SelectDeliveryTimeModalBloc, SelectDeliveryTimeModalState>(
      listener: (context, state) {
        if (state.status.isFailure) {
          showErrorDialog(context, state.alertMessage, state.extraMessage, state.statusCode);
        } else if (state.status.isFetched) {
          fromController.text = state.from.value;
          toController.text = state.to.value;
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            scrolledUnderElevation: 0,
            title: Text(translate.change_deliverytime),
            actions: [IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close))],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: ThemeProvider.scaffoldPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (state.status.isLoading) ...[
                  const SelectDeliveryTimeModalLoadingView(),
                ] else if (state.status.isFailure) ...[
                  const SelectDeliveryTimeModalErrorView(),
                ] else ...[
                  kAppSpacerVertical(height: 20),
                  TextFormField(
                    controller: fromController,
                    focusNode: _fromFocusNode,
                    decoration: kAppInputDecoration(context, lblText: translate.min_time, errText: state.from.displayError != null ? translate.form_required : null),
                    style: kAppLblLargeFontMedium(context),
                    keyboardType: TextInputType.text,
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+]'))],
                    onChanged: (value) => context.read<SelectDeliveryTimeModalBloc>().add(SelectDeliveryTimeModalFromChangeEvent(from: value)),
                    textInputAction: TextInputAction.next,
                  ),
                  kAppSpacerVertical(height: 20),
                  TextFormField(
                    controller: toController,
                    focusNode: _toFocusNode,
                    decoration: kAppInputDecoration(context, lblText: translate.max_time, errText: state.to.displayError != null ? translate.form_required : null),
                    style: kAppLblLargeFontMedium(context),
                    keyboardType: TextInputType.text,
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+]'))],
                    onChanged: (value) => context.read<SelectDeliveryTimeModalBloc>().add(SelectDeliveryTimeModalToChangeEvent(to: value)),
                    textInputAction: TextInputAction.next,
                  ),
                  kAppSpacerVertical(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      border: Border.all(color: Theme.of(context).canvasColor, width: 1),
                    ),
                    child: DropdownButton<DeliveryTimeTimeModel>(
                      underline: const SizedBox(),
                      isExpanded: true,
                      value: state.time,
                      dropdownColor: Theme.of(context).scaffoldBackgroundColor,
                      style: kAppLblMediumFontRegular(context),
                      items: state.timeList.map((DeliveryTimeTimeModel item) {
                        return DropdownMenuItem<DeliveryTimeTimeModel>(value: item, child: Text(kAppDDTranslate(context, item.label.toString())));
                      }).toList(),
                      onChanged: (newValue) {
                        context.read<SelectDeliveryTimeModalBloc>().add(SelectDeliveryTimeChangeEvent(time: newValue!));
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
          bottomNavigationBar: state.status.isLoading || state.status.isFailure
              ? SafeArea(child: const SizedBox())
              : SafeArea(
                  child: SizedBox(
                    height: 40,
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => Navigator.of(context).pop(),
                                style: kAppElevatedButtonStyle(context, disabledColor: Theme.of(context).disabledColor, bgColor: Theme.of(context).scaffoldBackgroundColor, foreColor: Theme.of(context).canvasColor, height: 40.0),
                                child: Text(translate.cancel_title),
                              ),
                            ),
                          ),
                          kAppSpacerHorizontal(width: 10),
                          Expanded(
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop('${state.from.value} ${translate.to} ${state.to.value} ${state.time.value}');
                                },
                                style: kAppElevatedButtonStyle(context, disabledColor: Theme.of(context).disabledColor, bgColor: Theme.of(context).primaryColor, foreColor: Theme.of(context).scaffoldBackgroundColor, height: 40),
                                child: Text(translate.save_btn),
                              ),
                            ),
                          ),
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

class SelectDeliveryTimeModalLoadingView extends StatelessWidget {
  const SelectDeliveryTimeModalLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SkeletonLine(
          style: SkeletonLineStyle(height: 20, width: MediaQuery.of(context).size.width, borderRadius: BorderRadius.circular(5)),
        ),
        kAppSpacerVertical(height: 20),
        SkeletonLine(
          style: SkeletonLineStyle(height: 20, width: MediaQuery.of(context).size.width, borderRadius: BorderRadius.circular(5)),
        ),
        kAppSpacerVertical(height: 20),
        SkeletonLine(
          style: SkeletonLineStyle(height: 20, width: MediaQuery.of(context).size.width, borderRadius: BorderRadius.circular(5)),
        ),
      ],
    );
  }
}

class SelectDeliveryTimeModalErrorView extends StatelessWidget {
  const SelectDeliveryTimeModalErrorView({super.key});

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

