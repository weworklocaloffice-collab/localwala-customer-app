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
import 'package:user/app/presentation/pages/modals/report_issue_restaurant_modal/bloc/report_issue_restaurant_modal_bloc.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/error_dialog.dart';
import 'package:user/app/presentation/styles/success_dialog.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class ReportIssueRestaurantModalScreen extends StatelessWidget {
  final String id;
  const ReportIssueRestaurantModalScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ReportIssueRestaurantModalBloc()..add(ReportIssueRestaurantModalInitialEvent(id: id)),
      child: const ReportIssueRestaurantModalView(),
    );
  }
}

class ReportIssueRestaurantModalView extends StatefulWidget {
  const ReportIssueRestaurantModalView({super.key});

  @override
  State<ReportIssueRestaurantModalView> createState() => _ReportIssueRestaurantModalViewState();
}

class _ReportIssueRestaurantModalViewState extends State<ReportIssueRestaurantModalView> {
  final _messageFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _messageFocusNode.addListener(() {
      if (!_messageFocusNode.hasFocus) {
        context.read<ReportIssueRestaurantModalBloc>().add(ReportIssueRestaurantMessageUnfocusedEvent());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isValid = context.select((ReportIssueRestaurantModalBloc bloc) => bloc.state.isValid);
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return BlocConsumer<ReportIssueRestaurantModalBloc, ReportIssueRestaurantModalState>(
      listener: (context, state) {
        if (state.status.isFailure || state.status.isCustomError) {
          showErrorDialog(context, state.alertMessage, state.extraMessage, state.statusCode);
        } else if (state.status.isReportSent) {
          showSuccessDialog(context, translate.report_sent).then((value) {
            if (!context.mounted) return;
            Navigator.of(context, rootNavigator: true).pop(true);
          });
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            scrolledUnderElevation: 0,
            leadingWidth: state.issueSelected ? 40 : 0,
            leading: state.issueSelected ? IconButton(onPressed: () => context.read<ReportIssueRestaurantModalBloc>().add(ReportIssueRestaurantReSelectEvent()), icon: const Icon(Icons.arrow_back)) : const SizedBox(),
            title: state.issueSelected ? Text(state.reasonName) : Text(translate.report_issue_on_menu),
            actions: [IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close))],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: ThemeProvider.scaffoldPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (state.status.isLoading) ...[
                  const ReportIssueRestaurantModalLoadingView(),
                ] else if (state.status.isFailure) ...[
                  const ReportIssueRestaurantModalErrorView(),
                ] else if (state.status.isEmpty) ...[
                  const ReportIssueRestaurantModalEmptyView(),
                ] else if (state.status.isSuccess || state.status.isInProgress || state.status.isCustomError) ...[
                  state.issueSelected == false
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List.generate(
                            state.list.reasons!.length,
                            (index) => Container(
                              width: MediaQuery.of(context).size.width,
                              margin: const EdgeInsets.symmetric(vertical: 5),
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                              decoration: BoxDecoration(border: Border.all(color: ThemeProvider.lightDisabledColor, width: 1.5)),
                              child: InkWell(
                                onTap: () => context.read<ReportIssueRestaurantModalBloc>().add(ReportIssueRestaurantModalSelectReasonEvent(id: state.list.reasons![index].id!, name: state.list.reasons![index].name!)),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width * 0.75,
                                      child: Text(state.list.reasons![index].name!, style: kAppLblTinyFontBold(context), maxLines: 2, overflow: TextOverflow.ellipsis, softWrap: true),
                                    ),
                                    Icon(Icons.chevron_right_outlined, size: 12, color: Theme.of(context).canvasColor),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(translate.report_issue_on_menu_one, style: kAppLblMediumFontBold(context)),
                            kAppSpacerVertical(height: 5),
                            Text(translate.report_issue_on_menu_two, style: kAppLblTinyFontRegular(context)),
                            kAppSpacerVertical(height: 20),
                            TextFormField(
                              initialValue: state.message.value,
                              focusNode: _messageFocusNode,
                              decoration: kAppInputDecoration(context, lblText: translate.start_typing, errText: state.message.displayError != null ? translate.form_required : null),
                              maxLines: 4,
                              style: kAppLblSmallFontMedium(context),
                              keyboardType: TextInputType.text,
                              onChanged: (value) => context.read<ReportIssueRestaurantModalBloc>().add(ReportIssueRestaurantMessageChangedEvent(message: value)),
                              textInputAction: TextInputAction.done,
                            ),
                          ],
                        ),
                ],
              ],
            ),
          ),
          bottomNavigationBar: state.issueSelected
              ? SafeArea(
                  child: SizedBox(
                    height: 50,
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: isValid ? () => context.read<ReportIssueRestaurantModalBloc>().add(ReportIssueRestaurantSubmitEvent()) : null,
                                style: kAppElevatedButtonStyle(context, disabledColor: Theme.of(context).disabledColor, bgColor: Theme.of(context).primaryColor, foreColor: Theme.of(context).scaffoldBackgroundColor, height: 50.0),
                                child: state.status.isInProgress ? kAppCircularProgress(context, color: 'light', strokeWidth: 3.0, width: 24.0, height: 24.0, padding: 2.0) : Text(translate.submit),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : SafeArea(child: const SizedBox()),
        );
      },
    );
  }
}

class ReportIssueRestaurantModalLoadingView extends StatelessWidget {
  const ReportIssueRestaurantModalLoadingView({super.key});

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

class ReportIssueRestaurantModalEmptyView extends StatelessWidget {
  const ReportIssueRestaurantModalEmptyView({super.key});

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

class ReportIssueRestaurantModalErrorView extends StatelessWidget {
  const ReportIssueRestaurantModalErrorView({super.key});

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
