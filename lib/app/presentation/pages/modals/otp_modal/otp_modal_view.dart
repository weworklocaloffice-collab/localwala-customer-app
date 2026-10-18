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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/otp_field_style.dart';
import 'package:otp_text_field/style.dart';
import 'package:user/app/presentation/pages/modals/otp_modal/bloc/otp_modal_bloc.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/error_dialog.dart';
import 'package:user/app/presentation/styles/success_dialog.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class OtpModalScreen extends StatelessWidget {
  final String providerName;
  final String sentTo;
  final String providerId;
  final int otpLength;
  final bool canResendOTP;
  final String mode;
  const OtpModalScreen({super.key, required this.providerName, required this.sentTo, required this.providerId, required this.otpLength, required this.canResendOTP, required this.mode});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OtpModalBloc()..add(OtpModalInitialEvent(provider: providerName, providerId: providerId, canResendOTP: canResendOTP, otpLength: otpLength)),
      child: OtpModalView(providerName: providerName, sentTo: sentTo, providerId: providerId, otpLength: otpLength, canResendOTP: canResendOTP, mode: mode),
    );
  }
}

class OtpModalView extends StatefulWidget {
  final String providerName;
  final String sentTo;
  final String providerId;
  final int otpLength;
  final bool canResendOTP;
  final String mode;
  const OtpModalView({super.key, required this.providerName, required this.sentTo, required this.providerId, required this.otpLength, required this.canResendOTP, required this.mode});

  @override
  State<OtpModalView> createState() => _OtpModalViewState();
}

class _OtpModalViewState extends State<OtpModalView> with TickerProviderStateMixin {
  OtpFieldController otpController = OtpFieldController();
  Timer? _resendTimer;
  int _resendCountdown = 30;

  AnimationController? _fadeController;
  AnimationController? _shakeController;
  AnimationController? _successController;
  Animation<double>? _fadeAnimation;
  Animation<Offset>? _slideAnimation;

  @override
  void initState() {
    super.initState();
    _startResendCountdown();
    _setupAnimations();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(duration: const Duration(milliseconds: 400), vsync: this);
    _shakeController = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    _successController = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _fadeController!, curve: Curves.easeOut));
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero).animate(CurvedAnimation(parent: _fadeController!, curve: Curves.easeOutCubic));

    _fadeController?.forward();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _fadeController?.dispose();
    _shakeController?.dispose();
    _successController?.dispose();
    super.dispose();
  }

  void _startResendCountdown() {
    _resendCountdown = 30;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _resendCountdown--;
      });
      if (_resendCountdown <= 0) {
        timer.cancel();
      }
    });
  }

  String _formatCountdown() {
    final seconds = _resendCountdown.toString().padLeft(2, '0');
    return "00:$seconds";
  }

  bool get _canResend => _resendCountdown <= 0 && widget.canResendOTP;

  void _triggerShake() {
    _shakeController?.reset();
    _shakeController?.forward().then((_) {
      _shakeController?.reset();
    });
  }

  void _triggerSuccess() {
    _successController?.reset();
    _successController?.forward();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translate = AppLocalizations.of(context)!;
    final primaryColor = Theme.of(context).primaryColor;
    final state = context.select((OtpModalBloc bloc) => bloc.state);
    final isFailure = state.status.isFailure;
    final borderColor = isFailure ? ThemeProvider.errorColor : primaryColor;

    return BlocConsumer<OtpModalBloc, OtpModalState>(
      listener: (context, state) {
        if (state.status.isFailure) {
          _triggerShake();
          HapticFeedback.heavyImpact();
          showErrorDialog(context, state.alertMessage.toString(), state.extraMessage, state.statusCode);
        } else if (state.status.isSuccess) {
          _triggerSuccess();
          HapticFeedback.heavyImpact();
          if (mounted) Navigator.of(context, rootNavigator: true).pop({'action': true, 'status': true, 'otp': state.otp.toString()});
        } else if (state.status.isSuccessResent) {
          showSuccessDialog(context, translate.otp_sent);
          _startResendCountdown();
        }
      },
      builder: (context, state) {
        return AbsorbPointer(
          absorbing: state.status.isInProgress ? true : false,
          child: Scaffold(
            appBar: AppBar(
              title: Text(translate.verification_code),
              scrolledUnderElevation: 0,
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop({'action': false, 'status': false}),
                  icon: Icon(Icons.close_outlined, color: Theme.of(context).iconTheme.color),
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(ThemeProvider.scaffoldPadding),
              child: FadeTransition(
                opacity: _fadeAnimation!,
                child: SlideTransition(
                  position: _slideAnimation!,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      kAppSpacerVertical(height: 24),
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          widget.mode == 'email_otp' ? Icons.mail_outline_rounded : Icons.phone_android_rounded,
                          size: 30,
                          color: primaryColor,
                        ),
                      ),
                      kAppSpacerVertical(height: 32),
                      Text(
                        translate.verification_code,
                        textAlign: TextAlign.center,
                        style: kAppLblLargeFontBold(context),
                      ),
                      kAppSpacerVertical(height: 12),
                      Text(
                        'Enter the 6-digit code sent to',
                        textAlign: TextAlign.center,
                        style: kAppLblSmallFontRegular(context),
                      ),
                      kAppSpacerVertical(height: 8),
                      Text(
                        widget.sentTo,
                        textAlign: TextAlign.center,
                        style: kAppLblMediumFontMedium(context),
                      ),
                      kAppSpacerVertical(height: 40),
                      AnimatedBuilder(
                        animation: _shakeController!,
                        builder: (context, child) {
                          double shakeValue = 0;
                          if (_shakeController!.isAnimating) {
                            shakeValue = (1 - _shakeController!.value) * 12;
                            if (_shakeController!.value > 0.5) {
                              shakeValue = -shakeValue;
                            }
                          }
                          return Transform.translate(
                            offset: Offset(shakeValue, 0),
                            child: child,
                          );
                        },
                        child: OTPTextField(
                          controller: otpController,
                          length: widget.otpLength,
                          width: MediaQuery.of(context).size.width,
                          textFieldAlignment: MainAxisAlignment.spaceAround,
                          fieldWidth: 50,
                          fieldStyle: FieldStyle.box,
                          outlineBorderRadius: 12,
                          style: kAppLblMediumFontBold(context),
                          keyboardType: TextInputType.number,
                          otpFieldStyle: OtpFieldStyle(
                            borderColor: borderColor.withValues(alpha: 0.4),
                            disabledBorderColor: borderColor.withValues(alpha: 0.4),
                            focusBorderColor: primaryColor,
                            enabledBorderColor: borderColor.withValues(alpha: 0.4),
                            errorBorderColor: ThemeProvider.errorColor,
                          ),
                          onChanged: (pin) {
                            if (pin.length == 1) {
                              HapticFeedback.lightImpact();
                            }
                            context.read<OtpModalBloc>().add(OtpModalOnOTPChanged(otp: pin.toString()));
                          },
                          onCompleted: (pin) {
                            context.read<OtpModalBloc>().add(OtpModalOnOTPChanged(otp: pin.toString()));
                            context.read<OtpModalBloc>().add(OtpModalOnSubmitEvent());
                          },
                        ),
                      ),
                      kAppSpacerVertical(height: isFailure ? 8 : 0),
                      if (isFailure)
                        Text(
                          state.alertMessage.isNotEmpty ? state.alertMessage : translate.server_wrong_otp_error,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: kFontFromTheme(context, Theme.of(context).textTheme.labelSmall?.fontSize), fontFamily: 'medium', color: ThemeProvider.errorColor),
                        ),
                      kAppSpacerVertical(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => state.otp.isNotEmpty && state.otp.length == widget.otpLength ? context.read<OtpModalBloc>().add(OtpModalOnSubmitEvent()) : null,
                          style: kAppElevatedButtonStyle(context, disabledColor: Theme.of(context).disabledColor, bgColor: Theme.of(context).primaryColor, foreColor: Theme.of(context).scaffoldBackgroundColor, height: 50),
                          child: state.status.isInProgress ? kAppCircularProgress(context, color: 'light', strokeWidth: 3.0, width: 24.0, height: 24.0, padding: 2.0) : Text(translate.verify),
                        ),
                      ),
                      kAppSpacerVertical(height: 20),
                      if (widget.canResendOTP)
                        AbsorbPointer(
                          absorbing: !_canResend,
                          child: TextButton(
                            onPressed: _canResend
                                ? () {
                                    otpController.clear();
                                    context.read<OtpModalBloc>().add(OtpModalOnResendEvent());
                                  }
                                : null,
                            child: Text(
                              _canResend ? translate.resend_otp : "Didn't receive code? Resend in ${_formatCountdown()}",
                              style: kAppLblSmallFontMedium(context).copyWith(
                                color: _canResend ? Theme.of(context).primaryColor : ThemeProvider.greyColorText,
                              ),
                            ),
                          ),
                        ),
                      kAppSpacerVertical(height: 16),
                      Text(
                        translate.otp_verification_privacy,
                        textAlign: TextAlign.center,
                        style: kAppLblSmallFontRegular(context).copyWith(
                          color: ThemeProvider.greyColorText,
                        ),
                      ),
                      kAppSpacerVertical(height: 16),
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
