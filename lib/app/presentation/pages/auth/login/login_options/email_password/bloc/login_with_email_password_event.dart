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

part of 'login_with_email_password_bloc.dart';

sealed class LoginWithEmailPasswordEvent {}

final class LoginWithEmailInitialEvent extends LoginWithEmailPasswordEvent {}

final class LoginEmailChangedEvent extends LoginWithEmailPasswordEvent {
  final String email;
  LoginEmailChangedEvent({required this.email});
}

final class LoginEmailUnfocusedEvent extends LoginWithEmailPasswordEvent {}

final class LoginPasswordChangedEvent extends LoginWithEmailPasswordEvent {
  final String password;
  LoginPasswordChangedEvent({required this.password});
}

final class LoginRememberChangedEvent extends LoginWithEmailPasswordEvent {
  final bool checked;
  LoginRememberChangedEvent({required this.checked});
}

final class LoginPasswordUnfocusedEvent extends LoginWithEmailPasswordEvent {}

final class LoginFormSubmitEvent extends LoginWithEmailPasswordEvent {}

final class LoginWithGoogleAccountEvent extends LoginWithEmailPasswordEvent {}

final class LoginRegisterGoogleAccountEvent extends LoginWithEmailPasswordEvent {
  final SocialAccountVerificationModalResponseModel model;
  LoginRegisterGoogleAccountEvent({required this.model});
}

final class LoginWithFacebookAccountEvent extends LoginWithEmailPasswordEvent {}

final class LoginRegisterFacebookAccountEvent extends LoginWithEmailPasswordEvent {
  final SocialAccountVerificationModalResponseModel model;
  LoginRegisterFacebookAccountEvent({required this.model});
}

final class LoginWithGoogleLoginFailedEvent extends LoginWithEmailPasswordEvent {
  final String error;
  LoginWithGoogleLoginFailedEvent({required this.error});
}

final class LoginWithGoogleLoginAfterSuccessEvent extends LoginWithEmailPasswordEvent {
  final String token;
  LoginWithGoogleLoginAfterSuccessEvent({required this.token});
}

