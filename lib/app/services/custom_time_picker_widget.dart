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
import 'package:intl/intl.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/theme.dart';

class CustomDatePickerTimeline extends StatefulWidget {
  final DateTime startDate;
  final int daysCount;
  final DateTime? initialSelectedDate;
  final Function(DateTime) onDateChange;
  final Locale? locale;
  const CustomDatePickerTimeline({super.key, required this.startDate, required this.daysCount, this.initialSelectedDate, required this.onDateChange, this.locale});

  @override
  State<CustomDatePickerTimeline> createState() => _CustomDatePickerTimelineState();
}

class _CustomDatePickerTimelineState extends State<CustomDatePickerTimeline> {
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialSelectedDate ?? widget.startDate;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.daysCount,
        itemBuilder: (context, index) {
          DateTime date = widget.startDate.add(Duration(days: index));
          bool isSelected = selectedDate.day == date.day && selectedDate.month == date.month && selectedDate.year == date.year;

          final dayFormat = DateFormat.E(widget.locale?.toLanguageTag());
          final dateFormat = DateFormat.d(widget.locale?.toLanguageTag());

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedDate = date;
              });
              widget.onDateChange(date);
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: ThemeProvider.lightDisabledColor, width: 1.5),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(dayFormat.format(date), style: isSelected ? kAppLblMediumFontSemiBoldWhite(context) : kAppLblMediumFontSemiBold(context)),
                  kAppSpacerVertical(height: 5),
                  Text(dateFormat.format(date), style: isSelected ? kAppLblMediumFontSemiBoldWhite(context) : kAppLblMediumFontSemiBold(context)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
// Done //
