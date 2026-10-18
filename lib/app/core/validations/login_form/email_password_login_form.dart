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

enum LoginWithTypeOneEmailFieldValidationError { invalid }

enum LoginWithTypeOnePasswordFieldValidationError { empty }

enum LoginWithTypeOneRememberMeFieldValidationError { valid }

class LoginWithTypeOneEmailField extends FormzInput<String, LoginWithTypeOneEmailFieldValidationError> {
  const LoginWithTypeOneEmailField.pure([super.value = '']) : super.pure();

  const LoginWithTypeOneEmailField.dirty([super.value = '']) : super.dirty();

  static final _emailRegExp = RegExp(r'^[a-zA-Z\d.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z\d-]+(?:\.[a-zA-Z\d-]+)*$');

  @override
  LoginWithTypeOneEmailFieldValidationError? validator(String value) {
    return _emailRegExp.hasMatch(value) ? null : LoginWithTypeOneEmailFieldValidationError.invalid;
  }
}

class LoginWithTypeOnePasswordField extends FormzInput<String, LoginWithTypeOnePasswordFieldValidationError> {
  const LoginWithTypeOnePasswordField.pure([super.value = '']) : super.pure();
  const LoginWithTypeOnePasswordField.dirty([super.value = '']) : super.dirty();

  @override
  LoginWithTypeOnePasswordFieldValidationError? validator(String value) {
    if (value.isEmpty) return LoginWithTypeOnePasswordFieldValidationError.empty;
    return null;
  }
}

class LoginWithTypeOneRememberMeField extends FormzInput<bool, LoginWithTypeOneRememberMeFieldValidationError> {
  const LoginWithTypeOneRememberMeField.pure([super.value = false]) : super.pure();
  const LoginWithTypeOneRememberMeField.dirty([super.value = false]) : super.dirty();

  @override
  LoginWithTypeOneRememberMeFieldValidationError? validator(bool value) {
    if (value) return LoginWithTypeOneRememberMeFieldValidationError.valid;
    return null;
  }
}

