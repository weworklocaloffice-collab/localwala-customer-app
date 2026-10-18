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

enum AccountSettingUpdateMobileCountryCodeFieldValidationError { empty }

enum AccountSettingUpdateMobileNumberFieldValidationError { empty }

class AccountSettingUpdateMobileCountryCodeField extends FormzInput<String, AccountSettingUpdateMobileCountryCodeFieldValidationError> {
  const AccountSettingUpdateMobileCountryCodeField.pure([super.value = '']) : super.pure();
  const AccountSettingUpdateMobileCountryCodeField.dirty([super.value = '']) : super.dirty();

  @override
  AccountSettingUpdateMobileCountryCodeFieldValidationError? validator(String value) {
    if (value.isEmpty) return AccountSettingUpdateMobileCountryCodeFieldValidationError.empty;
    return null;
  }
}

class AccountSettingUpdateMobileNumberField extends FormzInput<String, AccountSettingUpdateMobileNumberFieldValidationError> {
  const AccountSettingUpdateMobileNumberField.pure([super.value = '']) : super.pure();
  const AccountSettingUpdateMobileNumberField.dirty([super.value = '']) : super.dirty();

  @override
  AccountSettingUpdateMobileNumberFieldValidationError? validator(String value) {
    if (value.isEmpty) return AccountSettingUpdateMobileNumberFieldValidationError.empty;
    return null;
  }
}

