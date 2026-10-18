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

enum ComplaintsTitleFieldValidationError { empty }

enum ComplaintsBriefFieldValidationError { empty }

class ComplaintsTitleField extends FormzInput<String, ComplaintsTitleFieldValidationError> {
  const ComplaintsTitleField.pure([super.value = '']) : super.pure();
  const ComplaintsTitleField.dirty([super.value = '']) : super.dirty();

  @override
  ComplaintsTitleFieldValidationError? validator(String value) {
    if (value.isEmpty) return ComplaintsTitleFieldValidationError.empty;
    return null;
  }
}

class ComplaintsBriefField extends FormzInput<String, ComplaintsBriefFieldValidationError> {
  const ComplaintsBriefField.pure([super.value = '']) : super.pure();
  const ComplaintsBriefField.dirty([super.value = '']) : super.dirty();

  @override
  ComplaintsBriefFieldValidationError? validator(String value) {
    if (value.isEmpty) return ComplaintsBriefFieldValidationError.empty;
    return null;
  }
}

