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

enum DiningBookingEmailFieldValidationError { invalid }

enum DiningBookingNameFieldValidationError { empty }

enum DiningBookingCountryCodeFieldValidationError { empty }

enum DiningBookingNumberFieldValidationError { empty }

class DiningBookingEmailField extends FormzInput<String, DiningBookingEmailFieldValidationError> {
  const DiningBookingEmailField.pure([super.value = '']) : super.pure();

  const DiningBookingEmailField.dirty([super.value = '']) : super.dirty();

  static final _emailRegExp = RegExp(r'^[a-zA-Z\d.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z\d-]+(?:\.[a-zA-Z\d-]+)*$');

  @override
  DiningBookingEmailFieldValidationError? validator(String value) {
    return _emailRegExp.hasMatch(value) ? null : DiningBookingEmailFieldValidationError.invalid;
  }
}

class DiningBookingNameField extends FormzInput<String, DiningBookingNameFieldValidationError> {
  const DiningBookingNameField.pure([super.value = '']) : super.pure();
  const DiningBookingNameField.dirty([super.value = '']) : super.dirty();

  @override
  DiningBookingNameFieldValidationError? validator(String value) {
    if (value.isEmpty) return DiningBookingNameFieldValidationError.empty;
    return null;
  }
}

class DiningBookingCountryCodeField extends FormzInput<String, DiningBookingCountryCodeFieldValidationError> {
  const DiningBookingCountryCodeField.pure([super.value = '']) : super.pure();
  const DiningBookingCountryCodeField.dirty([super.value = '']) : super.dirty();

  @override
  DiningBookingCountryCodeFieldValidationError? validator(String value) {
    if (value.isEmpty) return DiningBookingCountryCodeFieldValidationError.empty;
    return null;
  }
}

class DiningBookingNumberField extends FormzInput<String, DiningBookingNumberFieldValidationError> {
  const DiningBookingNumberField.pure([super.value = '']) : super.pure();
  const DiningBookingNumberField.dirty([super.value = '']) : super.dirty();

  @override
  DiningBookingNumberFieldValidationError? validator(String value) {
    if (value.isEmpty) return DiningBookingNumberFieldValidationError.empty;
    return null;
  }
}

