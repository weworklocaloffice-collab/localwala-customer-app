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
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/otp_field_style.dart';
import 'package:otp_text_field/style.dart';
import 'package:user/app/presentation/pages/modals/firebase_verification_modal/bloc/firebase_verification_modal_bloc.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/error_dialog.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class FirebaseVerificationModalScreen extends StatelessWidget {
  final String countryCode;
  final String mobileNumber;
  const FirebaseVerificationModalScreen({super.key, required this.countryCode, required this.mobileNumber});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FirebaseVerificationModalBloc()..add(FirebaseVerificationModalInitialEvent(countryCode: countryCode, mobileNumber: mobileNumber)),
      child: const FirebaseVerificationModalView(),
    );
  }
}

class FirebaseVerificationModalView extends StatefulWidget {
  const FirebaseVerificationModalView({super.key});

  @override
  State<FirebaseVerificationModalView> createState() => _FirebaseVerificationModalViewState();
}

class _FirebaseVerificationModalViewState extends State<FirebaseVerificationModalView> {
  OtpFieldController otpController = OtpFieldController();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    return BlocConsumer<FirebaseVerificationModalBloc, FirebaseVerificationModalState>(
      listener: (context, state) {
        if (state.status.isSentFailed) {
          showErrorDialog(context, state.alertMessage.toString(), state.extraMessage, state.statusCode).then((value) {
            if (!context.mounted) return;
            Navigator.of(context, rootNavigator: true).pop({'action': false, 'status': false});
          });
        } else if (state.status.isVerifyFailed) {
          showErrorDialog(context, state.alertMessage.toString(), state.extraMessage, state.statusCode);
        } else if (state.status.isVerified) {
          Navigator.of(context, rootNavigator: true).pop({'action': true, 'status': true, 'token': state.accessToken});
        }
      },
      builder: (context, state) {
        return AbsorbPointer(
          absorbing: state.status.isVerifying ? true : false,
          child: Scaffold(
            appBar: AppBar(
              title: Text(translate.verification_code),
              automaticallyImplyLeading: false,
              scrolledUnderElevation: 0,
              actions: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop({'action': false, 'status': false}),
                  icon: Icon(Icons.close_outlined, color: Theme.of(context).iconTheme.color),
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(ThemeProvider.scaffoldPadding),
              child: state.status.isSending
                  ? SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [CircularProgressIndicator(color: Theme.of(context).primaryColor, strokeWidth: 2.0)],
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${translate.verification_sent_to} ${state.toNumber}", textAlign: TextAlign.start, style: kAppLblMediumFontBold(context)),
                        kAppSpacerVertical(height: 20),
                        Text(translate.check_phone_inbox_verification, textAlign: TextAlign.start, style: kAppLblMediumFontMedium(context)),
                        kAppSpacerVertical(height: 30),
                        OTPTextField(
                          controller: otpController,
                          length: 6,
                          width: MediaQuery.of(context).size.width,
                          textFieldAlignment: MainAxisAlignment.spaceAround,
                          fieldWidth: 45,
                          fieldStyle: FieldStyle.box,
                          outlineBorderRadius: 5,
                          style: kAppLblMediumFontBold(context),
                          keyboardType: TextInputType.text,
                          otpFieldStyle: OtpFieldStyle(
                            borderColor: Theme.of(context).canvasColor,
                            disabledBorderColor: Theme.of(context).canvasColor,
                            focusBorderColor: Theme.of(context).canvasColor,
                            enabledBorderColor: Theme.of(context).canvasColor,
                            errorBorderColor: Theme.of(context).canvasColor,
                          ),
                          onChanged: (pin) {
                            context.read<FirebaseVerificationModalBloc>().add(FirebaseVerificationSMSChangeEvent(otp: pin.toString()));
                          },
                        ),
                      ],
                    ),
            ),
            bottomNavigationBar: state.status.isSending
                ? SafeArea(child: const SizedBox())
                : SafeArea(
                    child: SizedBox(
                      height: 50,
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () => state.smsCode.isNotEmpty && state.smsCode.length == 6 ? context.read<FirebaseVerificationModalBloc>().add(FirebaseVerificationVerifyEvent()) : null,
                                  style: kAppElevatedButtonStyle(context, disabledColor: Theme.of(context).disabledColor, bgColor: Theme.of(context).primaryColor, foreColor: Theme.of(context).scaffoldBackgroundColor, height: 50),
                                  child: state.status.isVerifying ? kAppCircularProgress(context, color: 'light', strokeWidth: 3.0, width: 24.0, height: 24.0, padding: 2.0) : Text(translate.verify),
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

