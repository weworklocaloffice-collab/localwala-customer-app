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

part of 'restaurant_register_request_bloc.dart';

sealed class RestaurantRegisterRequestEvent {}

final class RestaurantRegisterRequestInitialEvent extends RestaurantRegisterRequestEvent {}

final class RestaurantRegisterRequestNameChangedEvent extends RestaurantRegisterRequestEvent {
  final String name;
  RestaurantRegisterRequestNameChangedEvent({required this.name});
}

final class RestaurantRegisterRequestNameUnfocusedEvent extends RestaurantRegisterRequestEvent {}

final class RestaurantRegisterRequestShortDescriptionChangedEvent extends RestaurantRegisterRequestEvent {
  final String shortDescription;
  RestaurantRegisterRequestShortDescriptionChangedEvent({required this.shortDescription});
}

final class RestaurantRegisterRequestShortDescriptionUnfocusedEvent extends RestaurantRegisterRequestEvent {}

final class RestaurantRegisterRequestAddressChangedEvent extends RestaurantRegisterRequestEvent {
  final String address;
  RestaurantRegisterRequestAddressChangedEvent({required this.address});
}

final class RestaurantRegisterRequestAddressUnfocusedEvent extends RestaurantRegisterRequestEvent {}

final class RestaurantRegisterRequestMinOrderAmountChangedEvent extends RestaurantRegisterRequestEvent {
  final String minOrderAmount;
  RestaurantRegisterRequestMinOrderAmountChangedEvent({required this.minOrderAmount});
}

final class RestaurantRegisterRequestMinOrderAmountUnfocusedEvent extends RestaurantRegisterRequestEvent {}

final class RestaurantRegisterRequestDishForTwoChangedEvent extends RestaurantRegisterRequestEvent {
  final String dishForTwo;
  RestaurantRegisterRequestDishForTwoChangedEvent({required this.dishForTwo});
}

final class RestaurantRegisterRequestDishForTwoUnfocusedEvent extends RestaurantRegisterRequestEvent {}

final class RestaurantRegisterRequestFoodLicenseChangedEvent extends RestaurantRegisterRequestEvent {
  final String license;
  RestaurantRegisterRequestFoodLicenseChangedEvent({required this.license});
}

final class RestaurantRegisterRequestFoodLicenseUnfocusedEvent extends RestaurantRegisterRequestEvent {}

final class RestaurantRegisterRequestEmailChangedEvent extends RestaurantRegisterRequestEvent {
  final String email;
  RestaurantRegisterRequestEmailChangedEvent({required this.email});
}

final class RestaurantRegisterRequestEmailUnfocusedEvent extends RestaurantRegisterRequestEvent {}

final class RestaurantRegisterRequestPasswordChangedEvent extends RestaurantRegisterRequestEvent {
  final String password;
  RestaurantRegisterRequestPasswordChangedEvent({required this.password});
}

final class RestaurantRegisterRequestPasswordUnfocusedEvent extends RestaurantRegisterRequestEvent {}

final class RestaurantRegisterRequestFirstNameChangedEvent extends RestaurantRegisterRequestEvent {
  final String firstName;
  RestaurantRegisterRequestFirstNameChangedEvent({required this.firstName});
}

final class RestaurantRegisterRequestFirstNameUnfocusedEvent extends RestaurantRegisterRequestEvent {}

final class RestaurantRegisterRequestLastNameChangedEvent extends RestaurantRegisterRequestEvent {
  final String lastName;
  RestaurantRegisterRequestLastNameChangedEvent({required this.lastName});
}

final class RestaurantRegisterRequestLastNameUnfocusedEvent extends RestaurantRegisterRequestEvent {}

final class RestaurantRegisterRequestCountryCodeChangedEvent extends RestaurantRegisterRequestEvent {
  final String countryCode;
  RestaurantRegisterRequestCountryCodeChangedEvent({required this.countryCode});
}

final class RestaurantRegisterRequestCountryCodeUnfocusedEvent extends RestaurantRegisterRequestEvent {}

final class RestaurantRegisterRequestMobileNumberChangedEvent extends RestaurantRegisterRequestEvent {
  final String mobileNumber;
  RestaurantRegisterRequestMobileNumberChangedEvent({required this.mobileNumber});
}

final class RestaurantRegisterRequestMobileNumberUnfocusedEvent extends RestaurantRegisterRequestEvent {}

final class RestaurantRegisterRequestHomeDeliveryChangeEvent extends RestaurantRegisterRequestEvent {
  final HomeDeliverySupportModel option;
  RestaurantRegisterRequestHomeDeliveryChangeEvent({required this.option});
}

final class RestaurantRegisterRequestTakeAwayChangeEvent extends RestaurantRegisterRequestEvent {
  final TakeAwaySupportModel option;
  RestaurantRegisterRequestTakeAwayChangeEvent({required this.option});
}

final class RestaurantRegisterRequestScheduleOrderChangeEvent extends RestaurantRegisterRequestEvent {
  final ScheduleOrderSupportModel option;
  RestaurantRegisterRequestScheduleOrderChangeEvent({required this.option});
}

final class RestaurantRegisterRequestCuisineChangeEvent extends RestaurantRegisterRequestEvent {
  final ModalNavigationBackResponseModel param;
  RestaurantRegisterRequestCuisineChangeEvent({required this.param});
}

final class RestaurantRegisterRequestCusineUnfocusedEvent extends RestaurantRegisterRequestEvent {}

final class RestaurantRegisterRequestTypeChangeEvent extends RestaurantRegisterRequestEvent {
  final ModalNavigationBackResponseModel param;
  RestaurantRegisterRequestTypeChangeEvent({required this.param});
}

final class RestaurantRegisterRequestTypeUnfocusedEvent extends RestaurantRegisterRequestEvent {}

final class RestaurantRegisterRequestFacilitiesChangeEvent extends RestaurantRegisterRequestEvent {
  final ModalNavigationBackResponseModel param;
  RestaurantRegisterRequestFacilitiesChangeEvent({required this.param});
}

final class RestaurantRegisterRequestFacilityUnfocusedEvent extends RestaurantRegisterRequestEvent {}

final class RestaurantRegisterRequestDeliveryTimeChangeEvent extends RestaurantRegisterRequestEvent {
  final String time;
  RestaurantRegisterRequestDeliveryTimeChangeEvent({required this.time});
}

final class RestaurantRegisterRequestLicenseChangeEvent extends RestaurantRegisterRequestEvent {
  final RestaurantRegisterRequestLicenseModel option;
  RestaurantRegisterRequestLicenseChangeEvent({required this.option});
}

final class RestaurantRegisterRequestCityChangeEvent extends RestaurantRegisterRequestEvent {
  final RestaurantRegisterRequestCitiesModel city;
  RestaurantRegisterRequestCityChangeEvent({required this.city});
}

final class RestaurantRegisterRequestLocalityChangeEvent extends RestaurantRegisterRequestEvent {
  final LocalitiesFromCityModel locality;
  RestaurantRegisterRequestLocalityChangeEvent({required this.locality});
}

final class RestaurantRegisterRequestLocationChangeEvent extends RestaurantRegisterRequestEvent {
  final double latitude;
  final double longitude;
  RestaurantRegisterRequestLocationChangeEvent({required this.latitude, required this.longitude});
}

final class RestaurantRegisterRequestFormTextInputChangeEvent extends RestaurantRegisterRequestEvent {
  final int formIndex;
  final String value;
  RestaurantRegisterRequestFormTextInputChangeEvent({required this.formIndex, required this.value});
}

final class RestaurantRegisterRequestFormCountryCodeChangeEvent extends RestaurantRegisterRequestEvent {
  final int formIndex;
  final String value;
  RestaurantRegisterRequestFormCountryCodeChangeEvent({required this.formIndex, required this.value});
}

final class RestaurantRegisterRequestFormCheckboxChangeEvent extends RestaurantRegisterRequestEvent {
  final int formIndex;
  final int checkboxIndex;
  RestaurantRegisterRequestFormCheckboxChangeEvent({required this.formIndex, required this.checkboxIndex});
}

final class RestaurantRegisterRequestUploadImageEvent extends RestaurantRegisterRequestEvent {
  final XFile newImage;
  final String uploadImageTag;
  final int formIndex;
  final String formUploadingImageUUID;
  RestaurantRegisterRequestUploadImageEvent({required this.newImage, required this.uploadImageTag, required this.formIndex, required this.formUploadingImageUUID});
}

final class RestaurantRegisterRequestOnBackPageEvent extends RestaurantRegisterRequestEvent {}

final class RestaurantRegisterRequestSubmitEvent extends RestaurantRegisterRequestEvent {
  final List<RestaurantRegisterRequestFormTranslations> translations;
  RestaurantRegisterRequestSubmitEvent({required this.translations});
}

final class RestaurantRegisterRequestBusinessModelChangeEvent extends RestaurantRegisterRequestEvent {
  final String businessModel;
  RestaurantRegisterRequestBusinessModelChangeEvent({required this.businessModel});
}

final class RestaurantRegisterRequestChangeSubscriptionPackageEvent extends RestaurantRegisterRequestEvent {
  final String subscriptionPackage;
  RestaurantRegisterRequestChangeSubscriptionPackageEvent({required this.subscriptionPackage});
}

final class RestaurantRegisterRequestBusinessPlanSelectEvent extends RestaurantRegisterRequestEvent {}

final class RestaurantRegisterRequestChangePaymentMethodEvent extends RestaurantRegisterRequestEvent {
  final String paymentId;
  RestaurantRegisterRequestChangePaymentMethodEvent({required this.paymentId});
}

final class RestaurantRegisterRequestSocialLinkChangeEvent extends RestaurantRegisterRequestEvent {
  final String type;
  final String value;
  RestaurantRegisterRequestSocialLinkChangeEvent({required this.type, required this.value});
}

final class RestaurantRegisterRequestCreateProfileRequestEvent extends RestaurantRegisterRequestEvent {}

