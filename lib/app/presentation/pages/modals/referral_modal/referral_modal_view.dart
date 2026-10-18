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
import 'package:user/app/core/config/assets_url.dart';
import 'package:user/app/presentation/pages/modals/referral_modal/bloc/referral_modal_bloc.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class ReferralModalScreen extends StatelessWidget {
  final String message;
  final String extraContent;
  const ReferralModalScreen({super.key, required this.message, required this.extraContent});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ReferralModalBloc()..add(ReferralModalInitialEvent()),
      child: ReferralModalView(message: message, extraContent: extraContent),
    );
  }
}

class ReferralModalView extends StatelessWidget {
  final String message;
  final String extraContent;
  const ReferralModalView({super.key, required this.message, required this.extraContent});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(ThemeProvider.scaffoldPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(AssetsUrl.imageURL.referralModal, height: 120, width: 120),
              kAppSpacerVertical(height: 20),
              Text(translate.congratulations, textAlign: TextAlign.center, style: kAppLblLargeFontBold(context)),
              kAppSpacerVertical(height: 20),
              Text(kAppReferralMessage(context, message, extraContent), textAlign: TextAlign.center, style: kAppLblMediumFontRegular(context)),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: SizedBox(
          height: 50,
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(translate.cancel_title, style: kAppLblSmallFontMedium(context)),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(translate.ok_thanks, style: kAppLblSmallFontMedium(context, color: 'primary')),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
// Done //
