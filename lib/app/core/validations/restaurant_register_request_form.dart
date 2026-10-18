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

enum RestaurantRegisterRequestNameFieldValidationError { empty }

enum RestaurantRegisterRequestShortDescriptionFieldValidationError { empty }

enum RestaurantRegisterRequestAddressFieldValidationError { empty }

enum RestaurantRegisterRequestCuisineFieldValidationError { empty }

enum RestaurantRegisterRequestTypeFieldValidationError { empty }

enum RestaurantRegisterRequestFacilitiesFieldValidationError { empty }

enum RestaurantRegisterRequestMinOrderAmountFieldValidationError { empty }

enum RestaurantRegisterRequestDishPriceForTwoFieldValidationError { empty }

enum RestaurantRegisterRequestFoodLicenseFieldValidationError { empty }

enum RestaurantRegisterRequestDeliveryTimeFieldValidationError { empty }

enum RestaurantRegisterRequestEmailFieldValidationError { invalid }

enum RestaurantRegisterRequestPasswordFieldValidationError { empty }

enum RestaurantRegisterRequestFirstNameFieldValidationError { empty }

enum RestaurantRegisterRequestLastNameFieldValidationError { empty }

enum RestaurantRegisterRequestCountryCodeFieldValidationError { empty }

enum RestaurantRegisterRequestMobileNumberFieldValidationError { empty }

enum RestaurantRegisterRequestLatitudeFieldValidationError { empty }

enum RestaurantRegisterRequestLongitudeFieldValidationError { empty }

enum RestaurantRegisterRequestCoverFieldValidationError { empty }

enum RestaurantRegisterRequestLogoFieldValidationError { empty }

class RestaurantRegisterRequestNameField extends FormzInput<String, RestaurantRegisterRequestNameFieldValidationError> {
  const RestaurantRegisterRequestNameField.pure([super.value = '']) : super.pure();
  const RestaurantRegisterRequestNameField.dirty([super.value = '']) : super.dirty();

  @override
  RestaurantRegisterRequestNameFieldValidationError? validator(String value) {
    if (value.isEmpty) return RestaurantRegisterRequestNameFieldValidationError.empty;
    return null;
  }
}

class RestaurantRegisterRequestShortDescriptionField extends FormzInput<String, RestaurantRegisterRequestShortDescriptionFieldValidationError> {
  const RestaurantRegisterRequestShortDescriptionField.pure([super.value = '']) : super.pure();
  const RestaurantRegisterRequestShortDescriptionField.dirty([super.value = '']) : super.dirty();

  @override
  RestaurantRegisterRequestShortDescriptionFieldValidationError? validator(String value) {
    if (value.isEmpty) return RestaurantRegisterRequestShortDescriptionFieldValidationError.empty;
    return null;
  }
}

class RestaurantRegisterRequestAddressField extends FormzInput<String, RestaurantRegisterRequestAddressFieldValidationError> {
  const RestaurantRegisterRequestAddressField.pure([super.value = '']) : super.pure();
  const RestaurantRegisterRequestAddressField.dirty([super.value = '']) : super.dirty();

  @override
  RestaurantRegisterRequestAddressFieldValidationError? validator(String value) {
    if (value.isEmpty) return RestaurantRegisterRequestAddressFieldValidationError.empty;
    return null;
  }
}

class RestaurantRegisterRequestCuisineField extends FormzInput<String, RestaurantRegisterRequestCuisineFieldValidationError> {
  const RestaurantRegisterRequestCuisineField.pure([super.value = '']) : super.pure();
  const RestaurantRegisterRequestCuisineField.dirty([super.value = '']) : super.dirty();

  @override
  RestaurantRegisterRequestCuisineFieldValidationError? validator(String value) {
    if (value.isEmpty) return RestaurantRegisterRequestCuisineFieldValidationError.empty;
    return null;
  }
}

class RestaurantRegisterRequestTypeField extends FormzInput<String, RestaurantRegisterRequestTypeFieldValidationError> {
  const RestaurantRegisterRequestTypeField.pure([super.value = '']) : super.pure();
  const RestaurantRegisterRequestTypeField.dirty([super.value = '']) : super.dirty();

  @override
  RestaurantRegisterRequestTypeFieldValidationError? validator(String value) {
    if (value.isEmpty) return RestaurantRegisterRequestTypeFieldValidationError.empty;
    return null;
  }
}

class RestaurantRegisterRequestFacilitiesField extends FormzInput<String, RestaurantRegisterRequestFacilitiesFieldValidationError> {
  const RestaurantRegisterRequestFacilitiesField.pure([super.value = '']) : super.pure();
  const RestaurantRegisterRequestFacilitiesField.dirty([super.value = '']) : super.dirty();

  @override
  RestaurantRegisterRequestFacilitiesFieldValidationError? validator(String value) {
    if (value.isEmpty) return RestaurantRegisterRequestFacilitiesFieldValidationError.empty;
    return null;
  }
}

class RestaurantRegisterRequestMinOrderAmountField extends FormzInput<String, RestaurantRegisterRequestMinOrderAmountFieldValidationError> {
  const RestaurantRegisterRequestMinOrderAmountField.pure([super.value = '']) : super.pure();
  const RestaurantRegisterRequestMinOrderAmountField.dirty([super.value = '']) : super.dirty();

  @override
  RestaurantRegisterRequestMinOrderAmountFieldValidationError? validator(String value) {
    if (value.isEmpty) return RestaurantRegisterRequestMinOrderAmountFieldValidationError.empty;
    return null;
  }
}

class RestaurantRegisterRequestDishPriceForTwoField extends FormzInput<String, RestaurantRegisterRequestDishPriceForTwoFieldValidationError> {
  const RestaurantRegisterRequestDishPriceForTwoField.pure([super.value = '']) : super.pure();
  const RestaurantRegisterRequestDishPriceForTwoField.dirty([super.value = '']) : super.dirty();

  @override
  RestaurantRegisterRequestDishPriceForTwoFieldValidationError? validator(String value) {
    if (value.isEmpty) return RestaurantRegisterRequestDishPriceForTwoFieldValidationError.empty;
    return null;
  }
}

class RestaurantRegisterRequestFoodLicenseField extends FormzInput<String, RestaurantRegisterRequestFoodLicenseFieldValidationError> {
  const RestaurantRegisterRequestFoodLicenseField.pure([super.value = '']) : super.pure();
  const RestaurantRegisterRequestFoodLicenseField.dirty([super.value = '']) : super.dirty();

  @override
  RestaurantRegisterRequestFoodLicenseFieldValidationError? validator(String value) {
    if (value.isEmpty) return RestaurantRegisterRequestFoodLicenseFieldValidationError.empty;
    return null;
  }
}

class RestaurantRegisterRequestDeliveryTimeField extends FormzInput<String, RestaurantRegisterRequestDeliveryTimeFieldValidationError> {
  const RestaurantRegisterRequestDeliveryTimeField.pure([super.value = '']) : super.pure();
  const RestaurantRegisterRequestDeliveryTimeField.dirty([super.value = '']) : super.dirty();

  @override
  RestaurantRegisterRequestDeliveryTimeFieldValidationError? validator(String value) {
    if (value.isEmpty) return RestaurantRegisterRequestDeliveryTimeFieldValidationError.empty;
    return null;
  }
}

class RestaurantRegisterRequestEmailField extends FormzInput<String, RestaurantRegisterRequestEmailFieldValidationError> {
  const RestaurantRegisterRequestEmailField.pure([super.value = '']) : super.pure();

  const RestaurantRegisterRequestEmailField.dirty([super.value = '']) : super.dirty();

  static final _emailRegExp = RegExp(r'^[a-zA-Z\d.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z\d-]+(?:\.[a-zA-Z\d-]+)*$');

  @override
  RestaurantRegisterRequestEmailFieldValidationError? validator(String value) {
    return _emailRegExp.hasMatch(value) ? null : RestaurantRegisterRequestEmailFieldValidationError.invalid;
  }
}

class RestaurantRegisterRequestPasswordField extends FormzInput<String, RestaurantRegisterRequestPasswordFieldValidationError> {
  const RestaurantRegisterRequestPasswordField.pure([super.value = '']) : super.pure();
  const RestaurantRegisterRequestPasswordField.dirty([super.value = '']) : super.dirty();

  @override
  RestaurantRegisterRequestPasswordFieldValidationError? validator(String value) {
    if (value.isEmpty) return RestaurantRegisterRequestPasswordFieldValidationError.empty;
    return null;
  }
}

class RestaurantRegisterRequestFirstNameField extends FormzInput<String, RestaurantRegisterRequestFirstNameFieldValidationError> {
  const RestaurantRegisterRequestFirstNameField.pure([super.value = '']) : super.pure();
  const RestaurantRegisterRequestFirstNameField.dirty([super.value = '']) : super.dirty();

  @override
  RestaurantRegisterRequestFirstNameFieldValidationError? validator(String value) {
    if (value.isEmpty) return RestaurantRegisterRequestFirstNameFieldValidationError.empty;
    return null;
  }
}

class RestaurantRegisterRequestLastNameField extends FormzInput<String, RestaurantRegisterRequestLastNameFieldValidationError> {
  const RestaurantRegisterRequestLastNameField.pure([super.value = '']) : super.pure();
  const RestaurantRegisterRequestLastNameField.dirty([super.value = '']) : super.dirty();

  @override
  RestaurantRegisterRequestLastNameFieldValidationError? validator(String value) {
    if (value.isEmpty) return RestaurantRegisterRequestLastNameFieldValidationError.empty;
    return null;
  }
}

class RestaurantRegisterRequestCountryCodeField extends FormzInput<String, RestaurantRegisterRequestCountryCodeFieldValidationError> {
  const RestaurantRegisterRequestCountryCodeField.pure([super.value = '']) : super.pure();
  const RestaurantRegisterRequestCountryCodeField.dirty([super.value = '']) : super.dirty();

  @override
  RestaurantRegisterRequestCountryCodeFieldValidationError? validator(String value) {
    if (value.isEmpty) return RestaurantRegisterRequestCountryCodeFieldValidationError.empty;
    return null;
  }
}

class RestaurantRegisterRequestMobileNumberField extends FormzInput<String, RestaurantRegisterRequestMobileNumberFieldValidationError> {
  const RestaurantRegisterRequestMobileNumberField.pure([super.value = '']) : super.pure();
  const RestaurantRegisterRequestMobileNumberField.dirty([super.value = '']) : super.dirty();

  @override
  RestaurantRegisterRequestMobileNumberFieldValidationError? validator(String value) {
    if (value.isEmpty) return RestaurantRegisterRequestMobileNumberFieldValidationError.empty;
    return null;
  }
}

class RestaurantRegisterRequestLatitudeField extends FormzInput<String, RestaurantRegisterRequestLatitudeFieldValidationError> {
  const RestaurantRegisterRequestLatitudeField.pure([super.value = '']) : super.pure();
  const RestaurantRegisterRequestLatitudeField.dirty([super.value = '']) : super.dirty();

  @override
  RestaurantRegisterRequestLatitudeFieldValidationError? validator(String value) {
    if (value.isEmpty) return RestaurantRegisterRequestLatitudeFieldValidationError.empty;
    return null;
  }
}

class RestaurantRegisterRequestLongitudeField extends FormzInput<String, RestaurantRegisterRequestLongitudeFieldValidationError> {
  const RestaurantRegisterRequestLongitudeField.pure([super.value = '']) : super.pure();
  const RestaurantRegisterRequestLongitudeField.dirty([super.value = '']) : super.dirty();

  @override
  RestaurantRegisterRequestLongitudeFieldValidationError? validator(String value) {
    if (value.isEmpty) return RestaurantRegisterRequestLongitudeFieldValidationError.empty;
    return null;
  }
}

class RestaurantRegisterRequestCoverField extends FormzInput<String, RestaurantRegisterRequestCoverFieldValidationError> {
  const RestaurantRegisterRequestCoverField.pure([super.value = '']) : super.pure();
  const RestaurantRegisterRequestCoverField.dirty([super.value = '']) : super.dirty();

  @override
  RestaurantRegisterRequestCoverFieldValidationError? validator(String value) {
    if (value.isEmpty) return RestaurantRegisterRequestCoverFieldValidationError.empty;
    return null;
  }
}

class RestaurantRegisterRequestLogoField extends FormzInput<String, RestaurantRegisterRequestLogoFieldValidationError> {
  const RestaurantRegisterRequestLogoField.pure([super.value = '']) : super.pure();
  const RestaurantRegisterRequestLogoField.dirty([super.value = '']) : super.dirty();

  @override
  RestaurantRegisterRequestLogoFieldValidationError? validator(String value) {
    if (value.isEmpty) return RestaurantRegisterRequestLogoFieldValidationError.empty;
    return null;
  }
}

