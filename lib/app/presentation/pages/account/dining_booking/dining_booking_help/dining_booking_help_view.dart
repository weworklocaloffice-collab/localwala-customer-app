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
import 'package:user/app/presentation/pages/account/dining_booking/dining_booking_help/bloc/dining_booking_help_bloc.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class DiningBookingHelpScreen extends StatelessWidget {
  const DiningBookingHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => DiningBookingHelpBloc()..add(DiningBookingHelpInitialEvent()), child: const DiningBookingHelpView());
  }
}

class DiningBookingHelpView extends StatelessWidget {
  const DiningBookingHelpView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return BlocConsumer<DiningBookingHelpBloc, DiningBookingHelpState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Scaffold(appBar: AppBar(title: Text(translate.dining_support), scrolledUnderElevation: 0));
      },
    );
  }
}
// Done //
