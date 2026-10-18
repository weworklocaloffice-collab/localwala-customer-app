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
import 'package:user/gen/l10n/app_localizations.dart';

class DiningGuestListModalScreen extends StatelessWidget {
  final int savedGuest;
  final List<int> guestAvailability;
  const DiningGuestListModalScreen({super.key, required this.savedGuest, required this.guestAvailability});

  @override
  Widget build(BuildContext context) {
    return DiningGuestListModalView(savedGuest: savedGuest, guestAvailability: guestAvailability);
  }
}

class DiningGuestListModalView extends StatelessWidget {
  final int savedGuest;
  final List<int> guestAvailability;
  const DiningGuestListModalView({super.key, required this.savedGuest, required this.guestAvailability});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(ThemeProvider.scaffoldPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(
            guestAvailability.length,
            (guestIndex) => InkWell(
              onTap: () => Navigator.of(context).pop(guestAvailability[guestIndex]),
              child: Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("${guestAvailability[guestIndex]} ${guestAvailability[guestIndex] == 1 ? translate.guest : translate.guests}", style: kAppLblMediumFontBold(context, color: 'regular')),
                    kAppSpacerHorizontal(width: 10),
                    Icon(savedGuest == guestAvailability[guestIndex] ? Icons.radio_button_on_outlined : Icons.radio_button_off_outlined, color: Theme.of(context).primaryColor, size: 15),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
// Done //
