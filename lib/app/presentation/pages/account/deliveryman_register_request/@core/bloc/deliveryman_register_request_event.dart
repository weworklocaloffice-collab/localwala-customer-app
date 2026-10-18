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

part of 'deliveryman_register_request_bloc.dart';

sealed class DeliverymanRegisterRequestEvent {}

final class DeliverymanRegisterRequestInitialEvent extends DeliverymanRegisterRequestEvent {}

final class DeliverymanRegisterRequestEmailChangedEvent extends DeliverymanRegisterRequestEvent {
  final String email;
  DeliverymanRegisterRequestEmailChangedEvent({required this.email});
}

final class DeliverymanRegisterRequestEmailUnfocusedEvent extends DeliverymanRegisterRequestEvent {}

final class DeliverymanRegisterRequestPasswordChangedEvent extends DeliverymanRegisterRequestEvent {
  final String password;
  DeliverymanRegisterRequestPasswordChangedEvent({required this.password});
}

final class DeliverymanRegisterRequestPasswordUnfocusedEvent extends DeliverymanRegisterRequestEvent {}

final class DeliverymanRegisterRequestFirstNameChangedEvent extends DeliverymanRegisterRequestEvent {
  final String firstName;
  DeliverymanRegisterRequestFirstNameChangedEvent({required this.firstName});
}

final class DeliverymanRegisterRequestFirstNameUnfocusedEvent extends DeliverymanRegisterRequestEvent {}

final class DeliverymanRegisterRequestLastNameChangedEvent extends DeliverymanRegisterRequestEvent {
  final String lastName;
  DeliverymanRegisterRequestLastNameChangedEvent({required this.lastName});
}

final class DeliverymanRegisterRequestLastNameUnfocusedEvent extends DeliverymanRegisterRequestEvent {}

final class DeliverymanRegisterRequestCountryCodeChangedEvent extends DeliverymanRegisterRequestEvent {
  final String countryCode;
  DeliverymanRegisterRequestCountryCodeChangedEvent({required this.countryCode});
}

final class DeliverymanRegisterRequestCountryCodeUnfocusedEvent extends DeliverymanRegisterRequestEvent {}

final class DeliverymanRegisterRequestMobileNumberChangedEvent extends DeliverymanRegisterRequestEvent {
  final String mobileNumber;
  DeliverymanRegisterRequestMobileNumberChangedEvent({required this.mobileNumber});
}

final class DeliverymanRegisterRequestMobileNumberUnfocusedEvent extends DeliverymanRegisterRequestEvent {}

final class DeliverymanRegisterRequestAgeChangedEvent extends DeliverymanRegisterRequestEvent {
  final String age;
  DeliverymanRegisterRequestAgeChangedEvent({required this.age});
}

final class DeliverymanRegisterRequestAgeUnfocusedEvent extends DeliverymanRegisterRequestEvent {}

final class DeliverymanRegisterRequestDOBChangedEvent extends DeliverymanRegisterRequestEvent {
  final String dob;
  DeliverymanRegisterRequestDOBChangedEvent({required this.dob});
}

final class DeliverymanRegisterRequestDOBUnfocusedEvent extends DeliverymanRegisterRequestEvent {}

final class DeliverymanRegisterRequestIdentityNumberChangedEvent extends DeliverymanRegisterRequestEvent {
  final String identity;
  DeliverymanRegisterRequestIdentityNumberChangedEvent({required this.identity});
}

final class DeliverymanRegisterRequestIdentityNumberUnfocusedEvent extends DeliverymanRegisterRequestEvent {}

final class DeliverymanRegisterRequestIdentityTypeChangeEvent extends DeliverymanRegisterRequestEvent {
  final DeliverymanRegisterRequestIdentityTypeModel identity;
  DeliverymanRegisterRequestIdentityTypeChangeEvent({required this.identity});
}

final class DeliverymanRegisterRequestJobTypeChangeEvent extends DeliverymanRegisterRequestEvent {
  final DeliverymanRegisterRequestJobTypeModel jobType;
  DeliverymanRegisterRequestJobTypeChangeEvent({required this.jobType});
}

final class DeliverymanRegisterRequestCityChangeEvent extends DeliverymanRegisterRequestEvent {
  final DeliverymanRegisterRequestCitiesModel city;
  DeliverymanRegisterRequestCityChangeEvent({required this.city});
}

final class DeliverymanRegisterRequestLocalityChangeEvent extends DeliverymanRegisterRequestEvent {
  final LocalitiesFromCityModel locality;
  DeliverymanRegisterRequestLocalityChangeEvent({required this.locality});
}

final class DeliverymanRegisterRequestVehicleChangeEvent extends DeliverymanRegisterRequestEvent {
  final DeliverymanRegisterRequestVehicleModel vehicle;
  DeliverymanRegisterRequestVehicleChangeEvent({required this.vehicle});
}

final class DeliverymanRegisterRequestUploadImageEvent extends DeliverymanRegisterRequestEvent {
  final XFile newImage;
  final String uploadImageTag;
  final int formIndex;
  final String formUploadingImageUUID;
  DeliverymanRegisterRequestUploadImageEvent({required this.newImage, required this.uploadImageTag, required this.formIndex, required this.formUploadingImageUUID});
}

final class DeliverymanRegisterRequestFormTextInputChangeEvent extends DeliverymanRegisterRequestEvent {
  final int formIndex;
  final String value;
  DeliverymanRegisterRequestFormTextInputChangeEvent({required this.formIndex, required this.value});
}

final class DeliverymanRegisterRequestFormCountryCodeChangeEvent extends DeliverymanRegisterRequestEvent {
  final int formIndex;
  final String value;
  DeliverymanRegisterRequestFormCountryCodeChangeEvent({required this.formIndex, required this.value});
}

final class DeliverymanRegisterRequestFormCheckboxChangeEvent extends DeliverymanRegisterRequestEvent {
  final int formIndex;
  final int checkboxIndex;
  DeliverymanRegisterRequestFormCheckboxChangeEvent({required this.formIndex, required this.checkboxIndex});
}

final class DeliverymanRegisterRequestSubmitEvent extends DeliverymanRegisterRequestEvent {}

