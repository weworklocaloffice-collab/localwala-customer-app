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
import 'package:user/app/presentation/pages/modals/delivery_instructions_modal/bloc/delivery_instructions_modal_bloc.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/error_dialog.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/app/presentation/styles/cache_network_widget/cache_network_widget_view.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class DeliveryInstructionModalScreen extends StatelessWidget {
  final String deliveryInstructionId;
  final String deliveryInstructionList;
  final String addressTitle;
  final String addressSubtitle;
  const DeliveryInstructionModalScreen({super.key, required this.deliveryInstructionId, required this.deliveryInstructionList, required this.addressTitle, required this.addressSubtitle});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          DeliveryInstructionsModalBloc()
            ..add(DeliveryInstructionsModalInitialEvent(deliveryInstructionId: deliveryInstructionId, deliveryInstructionList: deliveryInstructionList, addressTitle: addressTitle, addressSubtitle: addressSubtitle)),
      child: const DeliveryInstructionModalView(),
    );
  }
}

class DeliveryInstructionModalView extends StatelessWidget {
  const DeliveryInstructionModalView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return BlocConsumer<DeliveryInstructionsModalBloc, DeliveryInstructionsModalState>(
      listener: (context, state) {
        if (state.status.isFailure) {
          showErrorDialog(context, state.alertMessage, state.extraMessage, state.statusCode);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            scrolledUnderElevation: 0,
            toolbarHeight: 80,
            title: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(translate.instruction_for_deliveryman),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(state.addressTitle, style: kAppLblTinyFontBold(context)),
                    const Text(" - "),
                    Flexible(
                      child: Text(state.addressSubtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: kAppLblTinyFontRegular(context)),
                    ),
                  ],
                ),
              ],
            ),
            actions: [IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close))],
          ),
          body: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (state.status.isLoading) ...[
                  const DeliveryInstructionLoadingView(),
                ] else if (state.status.isFailure) ...[
                  const DeliveryInstructionErrorView(),
                ] else ...[
                  Padding(
                    padding: const EdgeInsets.all(ThemeProvider.scaffoldPadding),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(
                        state.instructions.length,
                        (index) => Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: ThemeProvider.lightDisabledColor, width: 1.5),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          child: InkWell(
                            onTap: () =>
                                context.read<DeliveryInstructionsModalBloc>().add(DeliveryInstructionSaveEvent(id: state.instructions[index].id!, name: state.instructions[index].name!, image: state.instructions[index].image!)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(5),
                                      child: CacheNetworkImageWidget(width: 15, height: 15.0, imageUrl: state.instructions[index].image!),
                                    ),
                                    kAppSpacerHorizontal(width: 10),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width * 0.75,
                                      child: Text(state.instructions[index].name!, style: kAppLblMediumFontBold(context), maxLines: 2, overflow: TextOverflow.ellipsis, softWrap: true),
                                    ),
                                  ],
                                ),
                                Icon(
                                  state.deliveryInstructionId == state.instructions[index].id! ? Icons.radio_button_checked_sharp : Icons.circle_outlined,
                                  size: Theme.of(context).textTheme.bodyMedium?.fontSize,
                                  color: Theme.of(context).primaryColor,
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
            child: SizedBox(
              height: 50,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: ThemeProvider.scaffoldPadding, vertical: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
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
                        child: InkWell(
                          onTap: () => Navigator.of(context).pop(false),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [Text(translate.clear, style: kAppLblSmallFontBold(context, color: 'canvas'))],
                          ),
                        ),
                      ),
                    ),
                    const Expanded(flex: 1, child: SizedBox(width: double.infinity)),
                    Expanded(
                      flex: 3,
                      child: InkWell(
                        onTap: () => state.deliveryInstructionId.isNotEmpty ? Navigator.of(context).pop({"id": state.deliveryInstructionId, "name": state.deliveryInstructionName, "image": state.deliveryInstructionImage}) : null,
                        child: Container(
                          width: double.infinity,
                          height: 40.0,
                          decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.circular(5)),
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [Text(translate.save_btn, style: kAppLblSmallFontBoldCart(context))],
                          ),
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

class DeliveryInstructionLoadingView extends StatelessWidget {
  const DeliveryInstructionLoadingView({super.key});

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

class DeliveryInstructionErrorView extends StatelessWidget {
  const DeliveryInstructionErrorView({super.key});

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
            Text(translate.api_list_response_error, textAlign: TextAlign.center, style: kAppLblMediumFontRegular(context)),
          ],
        ),
      ),
    );
  }
}
// Done //
