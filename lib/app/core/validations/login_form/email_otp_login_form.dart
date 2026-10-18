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

import 'package:formz/formz.dart';

enum LoginWithTypeThreeEmailFieldValidationError { invalid }

enum LoginWithTypeThreeRememberMeFieldValidationError { valid }

class LoginWithTypeThreeEmailField extends FormzInput<String, LoginWithTypeThreeEmailFieldValidationError> {
  const LoginWithTypeThreeEmailField.pure([super.value = '']) : super.pure();

  const LoginWithTypeThreeEmailField.dirty([super.value = '']) : super.dirty();

  static final _emailRegExp = RegExp(r'^[a-zA-Z\d.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z\d-]+(?:\.[a-zA-Z\d-]+)*$');

  @override
  LoginWithTypeThreeEmailFieldValidationError? validator(String value) {
    return _emailRegExp.hasMatch(value) ? null : LoginWithTypeThreeEmailFieldValidationError.invalid;
  }
}

class LoginWithTypeThreeRememberMeField extends FormzInput<bool, LoginWithTypeThreeRememberMeFieldValidationError> {
  const LoginWithTypeThreeRememberMeField.pure([super.value = false]) : super.pure();
  const LoginWithTypeThreeRememberMeField.dirty([super.value = false]) : super.dirty();

  @override
  LoginWithTypeThreeRememberMeFieldValidationError? validator(bool value) {
    if (value) return LoginWithTypeThreeRememberMeFieldValidationError.valid;
    return null;
  }
}

