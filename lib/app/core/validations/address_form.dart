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

enum AddressReceiverNameFieldValidationError { empty }

enum AddressReceiveCountryCodeFieldValidationError { empty }

enum AddressReceiverNumberFieldValidationError { empty }

enum AddressHouseFieldValidationError { empty }

enum AddressLocalityFieldValidationError { empty }

class AddressReceiverNameField extends FormzInput<String, AddressReceiverNameFieldValidationError> {
  const AddressReceiverNameField.pure([super.value = '']) : super.pure();
  const AddressReceiverNameField.dirty([super.value = '']) : super.dirty();

  @override
  AddressReceiverNameFieldValidationError? validator(String value) {
    if (value.isEmpty) return AddressReceiverNameFieldValidationError.empty;
    return null;
  }
}

class AddressReceiveCountryCodeField extends FormzInput<String, AddressReceiveCountryCodeFieldValidationError> {
  const AddressReceiveCountryCodeField.pure([super.value = '']) : super.pure();
  const AddressReceiveCountryCodeField.dirty([super.value = '']) : super.dirty();

  @override
  AddressReceiveCountryCodeFieldValidationError? validator(String value) {
    if (value.isEmpty) return AddressReceiveCountryCodeFieldValidationError.empty;
    return null;
  }
}

class AddressReceiverNumberField extends FormzInput<String, AddressReceiverNumberFieldValidationError> {
  const AddressReceiverNumberField.pure([super.value = '']) : super.pure();
  const AddressReceiverNumberField.dirty([super.value = '']) : super.dirty();

  @override
  AddressReceiverNumberFieldValidationError? validator(String value) {
    if (value.isEmpty) return AddressReceiverNumberFieldValidationError.empty;
    return null;
  }
}

class AddressHouseField extends FormzInput<String, AddressHouseFieldValidationError> {
  const AddressHouseField.pure([super.value = '']) : super.pure();
  const AddressHouseField.dirty([super.value = '']) : super.dirty();

  @override
  AddressHouseFieldValidationError? validator(String value) {
    if (value.isEmpty) return AddressHouseFieldValidationError.empty;
    return null;
  }
}

class AddressLocalityField extends FormzInput<String, AddressLocalityFieldValidationError> {
  const AddressLocalityField.pure([super.value = '']) : super.pure();
  const AddressLocalityField.dirty([super.value = '']) : super.dirty();

  @override
  AddressLocalityFieldValidationError? validator(String value) {
    if (value.isEmpty) return AddressLocalityFieldValidationError.empty;
    return null;
  }
}

