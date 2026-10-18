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
import 'package:user/app/core/models/dining_booking_table_date_list_model.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/theme.dart';

class DiningDateListModalScreen extends StatelessWidget {
  final String dateFormat;
  final List<DiningBookTableDateListModel> dates;
  const DiningDateListModalScreen({super.key, required this.dateFormat, required this.dates});

  @override
  Widget build(BuildContext context) {
    return DiningDateListModalView(dateFormat: dateFormat, dates: dates);
  }
}

class DiningDateListModalView extends StatelessWidget {
  final String dateFormat;
  final List<DiningBookTableDateListModel> dates;
  const DiningDateListModalView({super.key, required this.dateFormat, required this.dates});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(ThemeProvider.scaffoldPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(
            dates.length,
            (dateIndex) => InkWell(
              onTap: () => Navigator.of(context).pop(dates[dateIndex].dateFormat),
              child: Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(dates[dateIndex].dateName!, style: kAppLblMediumFontBold(context, color: 'regular')),
                    kAppSpacerHorizontal(width: 10),
                    Icon(dateFormat == dates[dateIndex].dateFormat ? Icons.radio_button_on_outlined : Icons.radio_button_off_outlined, color: Theme.of(context).primaryColor, size: 15),
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
