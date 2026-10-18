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

enum SocialAccountVerificationFirstNameFieldValidationError { empty }

enum SocialAccountVerificationLastNameFieldValidationError { empty }

enum SocialAccountVerificationCountryCodeFieldValidationError { empty }

enum SocialAccountVerificationMobileNumberFieldValidationError { empty }

class SocialAccountVerificationFirstNameField extends FormzInput<String, SocialAccountVerificationFirstNameFieldValidationError> {
  const SocialAccountVerificationFirstNameField.pure([super.value = '']) : super.pure();
  const SocialAccountVerificationFirstNameField.dirty([super.value = '']) : super.dirty();

  @override
  SocialAccountVerificationFirstNameFieldValidationError? validator(String value) {
    if (value.isEmpty) return SocialAccountVerificationFirstNameFieldValidationError.empty;
    return null;
  }
}

class SocialAccountVerificationLastNameField extends FormzInput<String, SocialAccountVerificationLastNameFieldValidationError> {
  const SocialAccountVerificationLastNameField.pure([super.value = '']) : super.pure();
  const SocialAccountVerificationLastNameField.dirty([super.value = '']) : super.dirty();

  @override
  SocialAccountVerificationLastNameFieldValidationError? validator(String value) {
    if (value.isEmpty) return SocialAccountVerificationLastNameFieldValidationError.empty;
    return null;
  }
}

class SocialAccountVerificationCountryCodeField extends FormzInput<String, SocialAccountVerificationCountryCodeFieldValidationError> {
  const SocialAccountVerificationCountryCodeField.pure([super.value = '']) : super.pure();
  const SocialAccountVerificationCountryCodeField.dirty([super.value = '']) : super.dirty();

  @override
  SocialAccountVerificationCountryCodeFieldValidationError? validator(String value) {
    if (value.isEmpty) return SocialAccountVerificationCountryCodeFieldValidationError.empty;
    return null;
  }
}

class SocialAccountVerificationMobileNumberField extends FormzInput<String, SocialAccountVerificationMobileNumberFieldValidationError> {
  const SocialAccountVerificationMobileNumberField.pure([super.value = '']) : super.pure();
  const SocialAccountVerificationMobileNumberField.dirty([super.value = '']) : super.dirty();

  @override
  SocialAccountVerificationMobileNumberFieldValidationError? validator(String value) {
    if (value.isEmpty) return SocialAccountVerificationMobileNumberFieldValidationError.empty;
    return null;
  }
}

