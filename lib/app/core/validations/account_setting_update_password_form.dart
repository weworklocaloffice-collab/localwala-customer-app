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

enum AccountSettingChangePasswordPasswordFieldValidationError { empty }

enum AccountSettingChangePasswordConfirmPasswordFieldValidationError { empty, mismatch }

class AccountSettingChangePasswordPasswordField extends FormzInput<String, AccountSettingChangePasswordPasswordFieldValidationError> {
  const AccountSettingChangePasswordPasswordField.pure([super.value = '']) : super.pure();
  const AccountSettingChangePasswordPasswordField.dirty([super.value = '']) : super.dirty();

  @override
  AccountSettingChangePasswordPasswordFieldValidationError? validator(String value) {
    if (value.isEmpty) return AccountSettingChangePasswordPasswordFieldValidationError.empty;
    return null;
  }
}

class AccountSettingChangePasswordConfirmedPasswordField extends FormzInput<String, AccountSettingChangePasswordConfirmPasswordFieldValidationError> {
  final String password;

  const AccountSettingChangePasswordConfirmedPasswordField.pure({this.password = ''}) : super.pure('');

  const AccountSettingChangePasswordConfirmedPasswordField.dirty({required this.password, String value = ''}) : super.dirty(value);

  @override
  AccountSettingChangePasswordConfirmPasswordFieldValidationError? validator(String value) {
    if (value.isEmpty) {
      return AccountSettingChangePasswordConfirmPasswordFieldValidationError.empty;
    }
    return password == value ? null : AccountSettingChangePasswordConfirmPasswordFieldValidationError.mismatch;
  }
}

