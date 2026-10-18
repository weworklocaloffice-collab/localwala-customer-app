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
import 'package:user/app/presentation/pages/auth/reset_password/@core/bloc/reset_password_bloc.dart';
import 'package:user/app/presentation/pages/auth/reset_password/reset_password_option/reset_with_email_otp/reset_with_email_otp_view.dart';
import 'package:user/app/presentation/pages/auth/reset_password/reset_password_option/reset_with_phone_otp/reset_with_phone_otp_view.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => ResetPasswordBloc()..add(ResetPasswordInitialEvent()), child: const ResetPasswordView());
  }
}

class ResetPasswordView extends StatelessWidget {
  const ResetPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return BlocConsumer<ResetPasswordBloc, ResetPasswordState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: Text(translate.forgot_password_title), scrolledUnderElevation: 0),
          body: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (state.userResetPasswordWith == 'email_otp') ...[const ResetWithEmailOtpScreen()] else if (state.userResetPasswordWith == 'phone_otp') ...[const ResetWithPhoneOtpScreen()],
              ],
            ),
          ),
        );
      },
    );
  }
}
// Done //
