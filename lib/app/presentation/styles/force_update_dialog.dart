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
import 'package:url_launcher/url_launcher.dart';
import 'package:user/app/core/config/assets_url.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class ForceUpdateDialogService {
  static void showUpdateDialog(BuildContext context, String version, String url) async {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: false,
      useSafeArea: true,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          content: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(AssetsUrl.imageURL.forceUpdateIcon, height: 45, width: 45),
              kAppSpacerVertical(height: 10),
              Text(translate.update_required, style: kAppLblLargeFontBold(context)),
              kAppSpacerVertical(height: 10),
              Text("${translate.new_version_one} ($version) ${translate.new_version_two}", style: kAppLblMediumFontRegular(context, color: 'regular')),
            ],
          ),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
          actions: <Widget>[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final Uri updateUrl = Uri.parse(url);
                  if (!await launchUrl(updateUrl)) {}
                },
                style: kAppElevatedButtonStyle(context, disabledColor: Theme.of(context).disabledColor, bgColor: Theme.of(context).primaryColor, foreColor: Theme.of(context).scaffoldBackgroundColor, height: 50.0),
                child: Text(translate.update_now_btn),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// Done //
