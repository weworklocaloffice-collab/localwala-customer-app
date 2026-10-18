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

enum LoginWithTypeTwoCountryCodeFieldValidationError { empty }

enum LoginWithTypeTwoMobileNumberFieldValidationError { empty }

enum LoginWithTypeTwoPasswordFieldValidationError { empty }

enum LoginWithTypeTwoRememberMeFieldValidationError { valid }

class LoginWithTypeTwoCountryCodeField extends FormzInput<String, LoginWithTypeTwoCountryCodeFieldValidationError> {
  const LoginWithTypeTwoCountryCodeField.pure([super.value = '']) : super.pure();
  const LoginWithTypeTwoCountryCodeField.dirty([super.value = '']) : super.dirty();

  @override
  LoginWithTypeTwoCountryCodeFieldValidationError? validator(String value) {
    if (value.isEmpty) return LoginWithTypeTwoCountryCodeFieldValidationError.empty;
    return null;
  }
}

class LoginWithTypeTwoMobileNumberField extends FormzInput<String, LoginWithTypeTwoMobileNumberFieldValidationError> {
  const LoginWithTypeTwoMobileNumberField.pure([super.value = '']) : super.pure();
  const LoginWithTypeTwoMobileNumberField.dirty([super.value = '']) : super.dirty();

  @override
  LoginWithTypeTwoMobileNumberFieldValidationError? validator(String value) {
    if (value.isEmpty) return LoginWithTypeTwoMobileNumberFieldValidationError.empty;
    return null;
  }
}

class LoginWithTypeTwoPasswordField extends FormzInput<String, LoginWithTypeTwoPasswordFieldValidationError> {
  const LoginWithTypeTwoPasswordField.pure([super.value = '']) : super.pure();
  const LoginWithTypeTwoPasswordField.dirty([super.value = '']) : super.dirty();

  @override
  LoginWithTypeTwoPasswordFieldValidationError? validator(String value) {
    if (value.isEmpty) return LoginWithTypeTwoPasswordFieldValidationError.empty;
    return null;
  }
}

class LoginWithTypeTwoRememberMeField extends FormzInput<bool, LoginWithTypeTwoRememberMeFieldValidationError> {
  const LoginWithTypeTwoRememberMeField.pure([super.value = false]) : super.pure();
  const LoginWithTypeTwoRememberMeField.dirty([super.value = false]) : super.dirty();

  @override
  LoginWithTypeTwoRememberMeFieldValidationError? validator(bool value) {
    if (value) return LoginWithTypeTwoRememberMeFieldValidationError.valid;
    return null;
  }
}

