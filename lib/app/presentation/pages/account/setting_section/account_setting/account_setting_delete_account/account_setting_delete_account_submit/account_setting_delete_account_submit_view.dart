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
import 'package:user/app/presentation/pages/account/setting_section/account_setting/account_setting_delete_account/account_setting_delete_account_submit/bloc/account_setting_delete_account_submit_bloc.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/confirm_dialog.dart';
import 'package:user/app/presentation/styles/error_dialog.dart';
import 'package:user/app/presentation/styles/success_dialog.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/app/router/app_route_config.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class AccountSettingDeleteAccountSubmitScreen extends StatelessWidget {
  final String reason;
  const AccountSettingDeleteAccountSubmitScreen({super.key, required this.reason});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AccountSettingDeleteAccountSubmitBloc()..add(AccountSettingDeleteAccountSubmitInitialEvent(reason: reason)),
      child: const AccountSettingDeleteAccountSubmitView(),
    );
  }
}

class AccountSettingDeleteAccountSubmitView extends StatefulWidget {
  const AccountSettingDeleteAccountSubmitView({super.key});

  @override
  State<AccountSettingDeleteAccountSubmitView> createState() => _AccountSettingDeleteAccountSubmitViewState();
}

class _AccountSettingDeleteAccountSubmitViewState extends State<AccountSettingDeleteAccountSubmitView> {
  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    List<String> noticeList = <String>[
      translate.delete_reason_one,
      translate.delete_reason_two,
      translate.delete_reason_three,
      translate.delete_reason_four,
      translate.delete_reason_five,
      translate.delete_reason_six,
      translate.delete_reason_seven,
      translate.delete_reason_eight,
      translate.delete_reason_nine,
    ];
    return BlocConsumer<AccountSettingDeleteAccountSubmitBloc, AccountSettingDeleteAccountSubmitState>(
      listener: (context, state) {
        if (state.status.isSuccess) {
          showSuccessDialog(context, translate.account_deleted).then((value) {
            if (!context.mounted) return;
            Navigator.of(context).pushNamedAndRemoveUntil(AppRouter.loginRoute, (Route<dynamic> route) => false);
          });
        } else if (state.status.isFailure) {
          showErrorDialog(context, state.alertMessage, state.extraMessage, state.statusCode);
        }
      },
      builder: (context, state) {
        return AbsorbPointer(
          absorbing: state.status.isLoading ? true : false,
          child: Scaffold(
            appBar: AppBar(title: Text(translate.delete_account), scrolledUnderElevation: 0),
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: ThemeProvider.scaffoldPadding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(translate.sorry_for_deleting_account, style: kAppLblMediumFontBold(context)),
                  kAppSpacerVertical(height: 20),
                  Container(
                    padding: const EdgeInsets.only(bottom: 10),
                    margin: const EdgeInsets.only(bottom: 10),
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: noticeList.map((item) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(Icons.brightness_1, size: 5, color: Theme.of(context).canvasColor),
                              kAppSpacerHorizontal(width: 8),
                              Expanded(child: Text(item, style: kAppLblSmallFontRegular(context))),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: SafeArea(
              child: SizedBox(
                height: 50,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: ThemeProvider.scaffoldPadding),
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              showConfirmDialog(context, translate.confirm_delete_account_title, translate.confirm_delete_account, translate.cancel_title, translate.confirm_delete_item).then((value) {
                                if (value) {
                                  if (!context.mounted) return;
                                  context.read<AccountSettingDeleteAccountSubmitBloc>().add(AccountSettingDeleteAccountSubmitYesEvent());
                                }
                              });
                            },
                            style: kAppElevatedButtonStyle(context, disabledColor: Theme.of(context).disabledColor, bgColor: Theme.of(context).primaryColor, foreColor: Theme.of(context).scaffoldBackgroundColor, height: 50.0),
                            child: state.status.isLoading ? kAppCircularProgress(context, color: 'light', strokeWidth: 3.0, width: 24.0, height: 24.0, padding: 2.0) : Text(translate.delete_account),
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
