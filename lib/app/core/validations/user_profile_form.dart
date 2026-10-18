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

enum UserProfileEmailFieldValidationError { invalid }

enum UserProfileFirstNameFieldValidationError { empty }

enum UserProfileLastNameFieldValidationError { empty }

enum UserProfileCountryCodeFieldValidationError { empty }

enum UserProfileMobileNumberFieldValidationError { empty }

class UserProfileEmailField extends FormzInput<String, UserProfileEmailFieldValidationError> {
  const UserProfileEmailField.pure([super.value = '']) : super.pure();

  const UserProfileEmailField.dirty([super.value = '']) : super.dirty();

  static final _emailRegExp = RegExp(r'^[a-zA-Z\d.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z\d-]+(?:\.[a-zA-Z\d-]+)*$');

  @override
  UserProfileEmailFieldValidationError? validator(String value) {
    return _emailRegExp.hasMatch(value) ? null : UserProfileEmailFieldValidationError.invalid;
  }
}

class UserProfileFirstNameField extends FormzInput<String, UserProfileFirstNameFieldValidationError> {
  const UserProfileFirstNameField.pure([super.value = '']) : super.pure();
  const UserProfileFirstNameField.dirty([super.value = '']) : super.dirty();

  @override
  UserProfileFirstNameFieldValidationError? validator(String value) {
    if (value.isEmpty) return UserProfileFirstNameFieldValidationError.empty;
    return null;
  }
}

class UserProfileLastNameField extends FormzInput<String, UserProfileLastNameFieldValidationError> {
  const UserProfileLastNameField.pure([super.value = '']) : super.pure();
  const UserProfileLastNameField.dirty([super.value = '']) : super.dirty();

  @override
  UserProfileLastNameFieldValidationError? validator(String value) {
    if (value.isEmpty) return UserProfileLastNameFieldValidationError.empty;
    return null;
  }
}

class UserProfileCountryCodeField extends FormzInput<String, UserProfileCountryCodeFieldValidationError> {
  const UserProfileCountryCodeField.pure([super.value = '']) : super.pure();
  const UserProfileCountryCodeField.dirty([super.value = '']) : super.dirty();

  @override
  UserProfileCountryCodeFieldValidationError? validator(String value) {
    if (value.isEmpty) return UserProfileCountryCodeFieldValidationError.empty;
    return null;
  }
}

class UserProfileMobileNumberField extends FormzInput<String, UserProfileMobileNumberFieldValidationError> {
  const UserProfileMobileNumberField.pure([super.value = '']) : super.pure();
  const UserProfileMobileNumberField.dirty([super.value = '']) : super.dirty();

  @override
  UserProfileMobileNumberFieldValidationError? validator(String value) {
    if (value.isEmpty) return UserProfileMobileNumberFieldValidationError.empty;
    return null;
  }
}

