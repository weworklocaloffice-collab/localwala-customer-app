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
import 'package:user/app/core/models/tiffin_subscription_cancellation_reason_list_model.dart';
import 'package:user/app/presentation/pages/modals/tiffin_subscription_cancellation_reason_list_modal/bloc/tiffin_subscription_cancellation_reason_list_modal_bloc.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/error_dialog.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class TiffinSubscriptionCancellationReasonListModalScreen extends StatelessWidget {
  const TiffinSubscriptionCancellationReasonListModalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => TiffinSubscriptionCancellationReasonListModalBloc()..add(TiffinSubscriptionCancellationReasonListModalInitalEvent()), child: const TiffinSubscriptionCancellationReasonListModalView());
  }
}

class TiffinSubscriptionCancellationReasonListModalView extends StatelessWidget {
  const TiffinSubscriptionCancellationReasonListModalView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return BlocConsumer<TiffinSubscriptionCancellationReasonListModalBloc, TiffinSubscriptionCancellationReasonListModalState>(
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
            title: Text(translate.select_reason),
            actions: [IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close))],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: ThemeProvider.scaffoldPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (state.status.isLoading) ...[
                  const TiffinSubscriptionCancellationReasonListLoadingView(),
                ] else if (state.status.isFailure) ...[
                  const TiffinSubscriptionCancellationReasonListErrorView(),
                ] else if (state.status.isEmpty) ...[
                  const TiffinSubscriptionCancellationReasonListEmptyView(),
                ] else ...[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(state.list.reasons!.length, (index) => TiffinSubscriptionCancellationReasonListTile(reasonId: state.reasonId, model: state.list.reasons![index])),
                  ),
                ],
              ],
            ),
          ),
          bottomNavigationBar: SafeArea(
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
                          onPressed: state.reasonId.isNotEmpty ? () => Navigator.of(context).pop(state.reasonId) : null,
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

class TiffinSubscriptionCancellationReasonListTile extends StatelessWidget {
  final String reasonId;
  final TiffinSubscriptionCancellationReasonModel model;
  const TiffinSubscriptionCancellationReasonListTile({super.key, required this.reasonId, required this.model});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      decoration: BoxDecoration(border: Border.all(color: ThemeProvider.lightDisabledColor, width: 1.5)),
      child: InkWell(
        onTap: () => context.read<TiffinSubscriptionCancellationReasonListModalBloc>().add(TiffinSubscriptionCancellationReasonListModalSelectEvent(id: model.id!)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.75,
              child: Text(model.name!, style: kAppLblTinyFontBold(context), maxLines: 2, overflow: TextOverflow.ellipsis, softWrap: true),
            ),
            Icon(reasonId == model.id ? Icons.radio_button_checked_sharp : Icons.circle_outlined, size: 12, color: Theme.of(context).primaryColor),
          ],
        ),
      ),
    );
  }
}

class TiffinSubscriptionCancellationReasonListLoadingView extends StatelessWidget {
  const TiffinSubscriptionCancellationReasonListLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
        10,
        (index) => Container(
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.symmetric(vertical: 5),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
          decoration: BoxDecoration(border: Border.all(color: ThemeProvider.lightDisabledColor, width: 1.5)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SkeletonLine(
                style: SkeletonLineStyle(height: 10, width: MediaQuery.of(context).size.width / 1.3, borderRadius: BorderRadius.circular(8)),
              ),
              SkeletonLine(style: SkeletonLineStyle(height: 10, width: 20, borderRadius: BorderRadius.circular(8))),
            ],
          ),
        ),
      ),
    );
  }
}

class TiffinSubscriptionCancellationReasonListEmptyView extends StatelessWidget {
  const TiffinSubscriptionCancellationReasonListEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        children: [
          kAppSpacerVertical(height: 20),
          Image.asset(AssetsUrl.imageURL.cartEmpty, height: 256, width: 256, fit: BoxFit.fitWidth),
          kAppSpacerVertical(height: 20),
          Text(translate.matching_record_not_found, textAlign: TextAlign.center, style: kAppLblMediumFontBold(context)),
          kAppSpacerVertical(height: 5),
          Text(translate.no_data_reason_one, textAlign: TextAlign.center, style: kAppLblMediumFontRegular(context)),
        ],
      ),
    );
  }
}

class TiffinSubscriptionCancellationReasonListErrorView extends StatelessWidget {
  const TiffinSubscriptionCancellationReasonListErrorView({super.key});

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
// Done //
