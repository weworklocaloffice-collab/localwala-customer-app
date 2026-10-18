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

Future<bool> showConfirmDialog(BuildContext context, String title, String subTitle, String cancelBtnTitle, String okBtnTitle) async {
  return (await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Text(title),
          content: Text(subTitle),
          titleTextStyle: TextStyle(fontFamily: 'bold', fontSize: Theme.of(context).textTheme.titleMedium?.fontSize, color: Theme.of(context).canvasColor),
          contentTextStyle: kAppLblMediumFontMedium(context),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(cancelBtnTitle, style: kAppLblMediumFontMedium(context)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                okBtnTitle,
                style: TextStyle(fontSize: Theme.of(context).textTheme.labelMedium?.fontSize, fontFamily: 'medium', color: Theme.of(context).primaryColor),
              ),
            ),
          ],
        ),
      )) ??
      false;
}
// Done //
