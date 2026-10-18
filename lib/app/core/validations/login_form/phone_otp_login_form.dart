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

enum LoginWithTypeFourCountryCodeFieldValidationError { empty }

enum LoginWithTypeFourMobileNumberFieldValidationError { empty }

enum LoginWithTypeFourRememberMeFieldValidationError { valid }

class LoginWithTypeFourCountryCodeField extends FormzInput<String, LoginWithTypeFourCountryCodeFieldValidationError> {
  const LoginWithTypeFourCountryCodeField.pure([super.value = '']) : super.pure();
  const LoginWithTypeFourCountryCodeField.dirty([super.value = '']) : super.dirty();

  @override
  LoginWithTypeFourCountryCodeFieldValidationError? validator(String value) {
    if (value.isEmpty) return LoginWithTypeFourCountryCodeFieldValidationError.empty;
    return null;
  }
}

class LoginWithTypeFourMobileNumberField extends FormzInput<String, LoginWithTypeFourMobileNumberFieldValidationError> {
  const LoginWithTypeFourMobileNumberField.pure([super.value = '']) : super.pure();
  const LoginWithTypeFourMobileNumberField.dirty([super.value = '']) : super.dirty();

  @override
  LoginWithTypeFourMobileNumberFieldValidationError? validator(String value) {
    if (value.isEmpty) return LoginWithTypeFourMobileNumberFieldValidationError.empty;
    return null;
  }
}

class LoginWithTypeFourRememberMeField extends FormzInput<bool, LoginWithTypeFourRememberMeFieldValidationError> {
  const LoginWithTypeFourRememberMeField.pure([super.value = false]) : super.pure();
  const LoginWithTypeFourRememberMeField.dirty([super.value = false]) : super.dirty();

  @override
  LoginWithTypeFourRememberMeFieldValidationError? validator(bool value) {
    if (value) return LoginWithTypeFourRememberMeFieldValidationError.valid;
    return null;
  }
}

