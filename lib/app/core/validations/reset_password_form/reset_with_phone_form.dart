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

enum ResetWithOptionTwoCountryCodeFieldValidationError { empty }

enum ResetWithOptionTwoMobileNumberFieldValidationError { empty }

enum ResetWithOptionTwoPasswordFieldValidationError { empty }

enum ResetWithOptionTwoConfirmPasswordFieldValidationError { empty, mismatch }

class ResetWithOptionTwoCountryCodeField extends FormzInput<String, ResetWithOptionTwoCountryCodeFieldValidationError> {
  const ResetWithOptionTwoCountryCodeField.pure([super.value = '']) : super.pure();
  const ResetWithOptionTwoCountryCodeField.dirty([super.value = '']) : super.dirty();

  @override
  ResetWithOptionTwoCountryCodeFieldValidationError? validator(String value) {
    if (value.isEmpty) return ResetWithOptionTwoCountryCodeFieldValidationError.empty;
    return null;
  }
}

class ResetWithOptionTwoMobileNumberField extends FormzInput<String, ResetWithOptionTwoMobileNumberFieldValidationError> {
  const ResetWithOptionTwoMobileNumberField.pure([super.value = '']) : super.pure();
  const ResetWithOptionTwoMobileNumberField.dirty([super.value = '']) : super.dirty();

  @override
  ResetWithOptionTwoMobileNumberFieldValidationError? validator(String value) {
    if (value.isEmpty) return ResetWithOptionTwoMobileNumberFieldValidationError.empty;
    return null;
  }
}

class ResetWithOptionTwoPasswordField extends FormzInput<String, ResetWithOptionTwoPasswordFieldValidationError> {
  const ResetWithOptionTwoPasswordField.pure([super.value = '']) : super.pure();
  const ResetWithOptionTwoPasswordField.dirty([super.value = '']) : super.dirty();

  @override
  ResetWithOptionTwoPasswordFieldValidationError? validator(String value) {
    if (value.isEmpty) return ResetWithOptionTwoPasswordFieldValidationError.empty;
    return null;
  }
}

class ResetWithOptionTwoConfirmedPasswordField extends FormzInput<String, ResetWithOptionTwoConfirmPasswordFieldValidationError> {
  final String password;

  const ResetWithOptionTwoConfirmedPasswordField.pure({this.password = ''}) : super.pure('');

  const ResetWithOptionTwoConfirmedPasswordField.dirty({required this.password, String value = ''}) : super.dirty(value);

  @override
  ResetWithOptionTwoConfirmPasswordFieldValidationError? validator(String value) {
    if (value.isEmpty) {
      return ResetWithOptionTwoConfirmPasswordFieldValidationError.empty;
    }
    return password == value ? null : ResetWithOptionTwoConfirmPasswordFieldValidationError.mismatch;
  }
}

