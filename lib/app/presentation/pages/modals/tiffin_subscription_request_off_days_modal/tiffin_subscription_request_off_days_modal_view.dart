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
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:user/app/presentation/pages/modals/tiffin_subscription_request_off_days_modal/bloc/tiffin_subscription_request_off_days_modal_bloc.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/error_dialog.dart';
import 'package:user/app/presentation/styles/success_dialog.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/app/services/custom_time_picker_widget.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class TiffinSubscriptionRequestOffDaysModalScreen extends StatelessWidget {
  final String purchaseId;
  final List<String> requestedOffDates;
  final List<String> offDays;
  final int totalOrders;
  const TiffinSubscriptionRequestOffDaysModalScreen({super.key, required this.purchaseId, required this.requestedOffDates, required this.offDays, required this.totalOrders});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          TiffinSubscriptionRequestOffDaysModalBloc()..add(TiffinSubscriptionRequestOffDaysModalInitialEvent(requestedOffDates: requestedOffDates, offDays: offDays, totalOrders: totalOrders, purchaseId: purchaseId)),
      child: const TiffinSubscriptionRequestOffDaysModalView(),
    );
  }
}

class TiffinSubscriptionRequestOffDaysModalView extends StatelessWidget {
  const TiffinSubscriptionRequestOffDaysModalView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return BlocConsumer<TiffinSubscriptionRequestOffDaysModalBloc, TiffinSubscriptionRequestOffDaysModalState>(
      listener: (context, state) {
        if (state.status.isFailure || state.status.isSubmitFailed) {
          showErrorDialog(context, state.alertMessage, state.extraMessage, state.statusCode);
        } else if (state.status.isSubmitSuccess) {
          showSuccessDialog(context, translate.off_day_request_saved).then((value) {
            if (!context.mounted) return;
            Navigator.of(context, rootNavigator: true).pop(true);
          });
        }
      },
      builder: (context, state) {
        return AbsorbPointer(
          absorbing: state.status.isSubmitStart ? true : false,
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              scrolledUnderElevation: 0,
              title: Text(translate.tiffin_package_request_off_days),
              actions: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  icon: FaIcon(FontAwesomeIcons.xmark, size: Theme.of(context).textTheme.titleSmall?.fontSize, color: Theme.of(context).canvasColor),
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: ThemeProvider.scaffoldPadding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (state.status.isEmpty || state.status.isFailure) ...[
                    Text(translate.oops_title, style: kAppLblLargeFontBold(context)),
                    kAppSpacerVertical(height: 5),
                    Text(translate.empty_data_three, style: kAppLblSmallFontMedium(context)),
                  ] else ...[
                    Text(translate.tiffin_package_request_off_days_instruction, style: kAppLblTinyFontBold(context)),
                    kAppSpacerVertical(height: 5),
                    Text("${translate.tiffin_off_day_one} ${state.offDays} ${translate.tiffin_off_day_two}", style: kAppLblTinyFontBold(context)),
                    kAppSpacerVertical(height: 10),
                    Text("${translate.tiffin_off_day_date} :", style: kAppLblMediumFontBold(context)),
                    kAppSpacerVertical(height: 10),
                    CustomDatePickerTimeline(
                      startDate: DateTime.now(),
                      daysCount: state.totalDays,
                      locale: Locale(state.locale),
                      onDateChange: (newDate) {
                        context.read<TiffinSubscriptionRequestOffDaysModalBloc>().add(TiffinSubscriptionRequestOffDaysModalSelectedDateEvent(date: newDate));
                      },
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
                            onPressed: () => Navigator.of(context).pop(false),
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
                            onPressed: state.selectedDate.isNotEmpty ? () => context.read<TiffinSubscriptionRequestOffDaysModalBloc>().add(TiffinSubscriptionRequestOffDaySubmitEvent()) : null,
                            style: kAppElevatedButtonStyle(context, disabledColor: Theme.of(context).disabledColor, bgColor: Theme.of(context).primaryColor, foreColor: Theme.of(context).scaffoldBackgroundColor, height: 40),
                            child: state.status.isSubmitStart ? kAppCircularProgress(context, color: 'light', strokeWidth: 3.0, width: 24.0, height: 24.0, padding: 2.0) : Text(translate.save_btn),
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
// Done //
