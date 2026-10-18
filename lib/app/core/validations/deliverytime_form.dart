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

enum DeliveryTimeFromFieldValidationError { empty }

enum DeliveryTimeToFieldValidationError { empty }

class DeliveryTimeFromField extends FormzInput<String, DeliveryTimeFromFieldValidationError> {
  const DeliveryTimeFromField.pure([super.value = '']) : super.pure();
  const DeliveryTimeFromField.dirty([super.value = '']) : super.dirty();

  @override
  DeliveryTimeFromFieldValidationError? validator(String value) {
    if (value.isEmpty) return DeliveryTimeFromFieldValidationError.empty;
    return null;
  }
}

class DeliveryTimeToField extends FormzInput<String, DeliveryTimeToFieldValidationError> {
  const DeliveryTimeToField.pure([super.value = '']) : super.pure();
  const DeliveryTimeToField.dirty([super.value = '']) : super.dirty();

  @override
  DeliveryTimeToFieldValidationError? validator(String value) {
    if (value.isEmpty) return DeliveryTimeToFieldValidationError.empty;
    return null;
  }
}

