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
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/app/router/app_route_config.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class AccountSettingScreen extends StatelessWidget {
  const AccountSettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(translate.app_settings), scrolledUnderElevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: ThemeProvider.scaffoldPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).pushNamed(AppRouter.accountSettingChangeEmailRoute),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Theme.of(context).disabledColor, width: 1.5)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(translate.change_email, style: kAppLblMediumFontBold(context)),
                    Icon(Icons.chevron_right, size: 13, color: Theme.of(context).canvasColor),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.of(context).pushNamed(AppRouter.accountSettingChangeMobileRoute),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Theme.of(context).disabledColor, width: 1.5)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(translate.change_mobile_number, style: kAppLblMediumFontBold(context)),
                    Icon(Icons.chevron_right, size: 13, color: Theme.of(context).canvasColor),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.of(context).pushNamed(AppRouter.accountSettingUpdatePasswordRoute),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Theme.of(context).disabledColor, width: 1.5)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(translate.change_password, style: kAppLblMediumFontBold(context)),
                    Icon(Icons.chevron_right, size: 13, color: Theme.of(context).canvasColor),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.of(context).pushNamed(AppRouter.accountSettingDeleteAccountRoute),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Theme.of(context).disabledColor, width: 1.5)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(translate.delete_account, style: kAppLblMediumFontBold(context)),
                    Icon(Icons.chevron_right, size: 13, color: Theme.of(context).canvasColor),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// Done //
