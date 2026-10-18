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

enum ReportEmergencyFormEmailFieldValidationError { invalid }

enum ReportEmergencyFormNameFieldValidationError { empty }

enum ReportEmergencyFormCountryCodeFieldValidationError { empty }

enum ReportEmergencyFormNumberFieldValidationError { empty }

enum ReportEmergencyFormShortDescriptionFieldValidationError { empty }

class ReportEmergencyFormEmailField extends FormzInput<String, ReportEmergencyFormEmailFieldValidationError> {
  const ReportEmergencyFormEmailField.pure([super.value = '']) : super.pure();

  const ReportEmergencyFormEmailField.dirty([super.value = '']) : super.dirty();

  static final _emailRegExp = RegExp(r'^[a-zA-Z\d.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z\d-]+(?:\.[a-zA-Z\d-]+)*$');

  @override
  ReportEmergencyFormEmailFieldValidationError? validator(String value) {
    return _emailRegExp.hasMatch(value) ? null : ReportEmergencyFormEmailFieldValidationError.invalid;
  }
}

class ReportEmergencyFormNameField extends FormzInput<String, ReportEmergencyFormNameFieldValidationError> {
  const ReportEmergencyFormNameField.pure([super.value = '']) : super.pure();
  const ReportEmergencyFormNameField.dirty([super.value = '']) : super.dirty();

  @override
  ReportEmergencyFormNameFieldValidationError? validator(String value) {
    if (value.isEmpty) return ReportEmergencyFormNameFieldValidationError.empty;
    return null;
  }
}

class ReportEmergencyFormCountryCodeField extends FormzInput<String, ReportEmergencyFormCountryCodeFieldValidationError> {
  const ReportEmergencyFormCountryCodeField.pure([super.value = '']) : super.pure();
  const ReportEmergencyFormCountryCodeField.dirty([super.value = '']) : super.dirty();

  @override
  ReportEmergencyFormCountryCodeFieldValidationError? validator(String value) {
    if (value.isEmpty) return ReportEmergencyFormCountryCodeFieldValidationError.empty;
    return null;
  }
}

class ReportEmergencyFormNumberField extends FormzInput<String, ReportEmergencyFormNumberFieldValidationError> {
  const ReportEmergencyFormNumberField.pure([super.value = '']) : super.pure();
  const ReportEmergencyFormNumberField.dirty([super.value = '']) : super.dirty();

  @override
  ReportEmergencyFormNumberFieldValidationError? validator(String value) {
    if (value.isEmpty) return ReportEmergencyFormNumberFieldValidationError.empty;
    return null;
  }
}

class ReportEmergencyFormShortDescriptionField extends FormzInput<String, ReportEmergencyFormShortDescriptionFieldValidationError> {
  const ReportEmergencyFormShortDescriptionField.pure([super.value = '']) : super.pure();
  const ReportEmergencyFormShortDescriptionField.dirty([super.value = '']) : super.dirty();

  @override
  ReportEmergencyFormShortDescriptionFieldValidationError? validator(String value) {
    if (value.isEmpty) return ReportEmergencyFormShortDescriptionFieldValidationError.empty;
    return null;
  }
}

