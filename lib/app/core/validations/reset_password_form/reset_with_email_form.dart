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

enum ResetWithOptionOneEmailFieldValidationError { invalid }

enum ResetWithOptionOnePasswordFieldValidationError { empty }

enum ResetWithOptionOneConfirmPasswordFieldValidationError { empty, mismatch }

class ResetWithOptionOneEmailField extends FormzInput<String, ResetWithOptionOneEmailFieldValidationError> {
  const ResetWithOptionOneEmailField.pure([super.value = '']) : super.pure();

  const ResetWithOptionOneEmailField.dirty([super.value = '']) : super.dirty();

  static final _emailRegExp = RegExp(r'^[a-zA-Z\d.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z\d-]+(?:\.[a-zA-Z\d-]+)*$');

  @override
  ResetWithOptionOneEmailFieldValidationError? validator(String value) {
    return _emailRegExp.hasMatch(value) ? null : ResetWithOptionOneEmailFieldValidationError.invalid;
  }
}

class ResetWithOptionOnePasswordField extends FormzInput<String, ResetWithOptionOnePasswordFieldValidationError> {
  const ResetWithOptionOnePasswordField.pure([super.value = '']) : super.pure();
  const ResetWithOptionOnePasswordField.dirty([super.value = '']) : super.dirty();

  @override
  ResetWithOptionOnePasswordFieldValidationError? validator(String value) {
    if (value.isEmpty) return ResetWithOptionOnePasswordFieldValidationError.empty;
    return null;
  }
}

class ResetWithOptionOneConfirmedPasswordField extends FormzInput<String, ResetWithOptionOneConfirmPasswordFieldValidationError> {
  final String password;

  const ResetWithOptionOneConfirmedPasswordField.pure({this.password = ''}) : super.pure('');

  const ResetWithOptionOneConfirmedPasswordField.dirty({required this.password, String value = ''}) : super.dirty(value);

  @override
  ResetWithOptionOneConfirmPasswordFieldValidationError? validator(String value) {
    if (value.isEmpty) {
      return ResetWithOptionOneConfirmPasswordFieldValidationError.empty;
    }
    return password == value ? null : ResetWithOptionOneConfirmPasswordFieldValidationError.mismatch;
  }
}

