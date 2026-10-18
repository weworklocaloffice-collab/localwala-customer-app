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

enum DeliverymanRegisterRequestStatus { loading, fetched, basicFetched, initial, submit, submitSuccess, failure, uploadStarted, uploadSuccess, uploadFailed, customError, localityFetching, localityFetched, localityFailed }

extension DeliverymanRegisterRequestStatusX on DeliverymanRegisterRequestStatus {
  bool get isLoading => this == DeliverymanRegisterRequestStatus.loading;
  bool get isFetched => this == DeliverymanRegisterRequestStatus.fetched;
  bool get isBasicFetched => this == DeliverymanRegisterRequestStatus.basicFetched;
  bool get isInitial => this == DeliverymanRegisterRequestStatus.initial;
  bool get isSubmit => this == DeliverymanRegisterRequestStatus.submit;
  bool get isSubmitSuccess => this == DeliverymanRegisterRequestStatus.submitSuccess;
  bool get isFailure => this == DeliverymanRegisterRequestStatus.failure;
  bool get isUploadStarted => this == DeliverymanRegisterRequestStatus.uploadStarted;
  bool get isUploadSuccess => this == DeliverymanRegisterRequestStatus.uploadSuccess;
  bool get isUploadFailed => this == DeliverymanRegisterRequestStatus.uploadFailed;
  bool get isCustomError => this == DeliverymanRegisterRequestStatus.customError;
  bool get isLocalityFetching => this == DeliverymanRegisterRequestStatus.localityFetching;
  bool get isLocalityFetched => this == DeliverymanRegisterRequestStatus.localityFetched;
  bool get isLocalityFailed => this == DeliverymanRegisterRequestStatus.localityFailed;
}

final class DeliverymanRegisterRequestState {
  final DeliverymanRegisterRequestBasicDetailModel model;
  final DeliverymanRegisterRequestEmailField emailField;
  final DeliverymanRegisterRequestPasswordField passwordField;
  final DeliverymanRegisterRequestFirstNameField firstNameField;
  final DeliverymanRegisterRequestLastNameField lastNameField;
  final DeliverymanRegisterRequestCountryCodeField countryCodeField;
  final String flag;
  final DeliverymanRegisterRequestMobileNumberField mobileNumberField;
  final DeliverymanRegisterRequestCoverField coverImageField;
  final DeliverymanRegisterRequestIndentityProofField indentityProofField;
  final DeliverymanRegisterRequestAgeField ageField;
  final DeliverymanRegisterRequestDOBField dobField;
  final DeliverymanRegisterRequestIdentityNumberField identityNumberField;
  final DeliverymanRegisterRequestDrivingLicenseField drivingLicenseField;
  final DeliverymanRegisterRequestCitiesModel selectedCity;
  final List<DeliverymanRegisterRequestCitiesModel> cityList;
  final LocalitiesFromCityModel selectedLocality;
  final List<LocalitiesFromCityModel> localityList;
  final DeliverymanRegisterRequestLatitudeField latitudeField;
  final DeliverymanRegisterRequestLongitudeField longitudeField;
  final DeliverymanRegisterRequestVehicleModel selectedVehicle;
  final List<DeliverymanRegisterRequestVehicleModel> vehicleList;
  final DeliverymanRegisterRequestIdentityTypeModel identityType;
  final List<DeliverymanRegisterRequestIdentityTypeModel> identityTypeList;
  final DeliverymanRegisterRequestJobTypeModel jobType;
  final List<DeliverymanRegisterRequestJobTypeModel> jobTypeList;
  final List<DeliverymanFormElementConfigModel> formField;
  final bool isValid;
  final bool isFormSubmitted;
  final String uploadingImageTag;
  final String formUploadingImageUUID;
  final DeliverymanRegisterRequestStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const DeliverymanRegisterRequestState({
    required this.model,
    this.emailField = const DeliverymanRegisterRequestEmailField.pure(),
    this.passwordField = const DeliverymanRegisterRequestPasswordField.pure(),
    this.firstNameField = const DeliverymanRegisterRequestFirstNameField.pure(),
    this.lastNameField = const DeliverymanRegisterRequestLastNameField.pure(),
    this.countryCodeField = const DeliverymanRegisterRequestCountryCodeField.pure(),
    this.flag = '',
    this.mobileNumberField = const DeliverymanRegisterRequestMobileNumberField.pure(),
    this.coverImageField = const DeliverymanRegisterRequestCoverField.pure(),
    this.indentityProofField = const DeliverymanRegisterRequestIndentityProofField.pure(),
    this.ageField = const DeliverymanRegisterRequestAgeField.pure(),
    this.dobField = const DeliverymanRegisterRequestDOBField.pure(),
    this.identityNumberField = const DeliverymanRegisterRequestIdentityNumberField.pure(),
    this.drivingLicenseField = const DeliverymanRegisterRequestDrivingLicenseField.pure(),
    required this.selectedCity,
    this.cityList = const [],
    required this.selectedLocality,
    this.localityList = const [],
    this.latitudeField = const DeliverymanRegisterRequestLatitudeField.pure(),
    this.longitudeField = const DeliverymanRegisterRequestLongitudeField.pure(),
    required this.selectedVehicle,
    this.vehicleList = const [],
    required this.identityType,
    this.identityTypeList = const [],
    required this.jobType,
    this.jobTypeList = const [],
    this.formField = const [],
    this.isValid = false,
    this.isFormSubmitted = false,
    this.uploadingImageTag = 'cover',
    this.formUploadingImageUUID = '',
    this.status = DeliverymanRegisterRequestStatus.loading,
    this.statusCode = 0,
    this.alertMessage = '',
    this.extraMessage = '',
  });

  DeliverymanRegisterRequestState copyWith({
    DeliverymanRegisterRequestBasicDetailModel? model,
    DeliverymanRegisterRequestEmailField? emailField,
    DeliverymanRegisterRequestPasswordField? passwordField,
    DeliverymanRegisterRequestFirstNameField? firstNameField,
    DeliverymanRegisterRequestLastNameField? lastNameField,
    DeliverymanRegisterRequestCountryCodeField? countryCodeField,
    String? flag,
    DeliverymanRegisterRequestMobileNumberField? mobileNumberField,
    DeliverymanRegisterRequestCoverField? coverImageField,
    DeliverymanRegisterRequestIndentityProofField? indentityProofField,
    DeliverymanRegisterRequestAgeField? ageField,
    DeliverymanRegisterRequestDOBField? dobField,
    DeliverymanRegisterRequestIdentityNumberField? identityNumberField,
    DeliverymanRegisterRequestDrivingLicenseField? drivingLicenseField,
    DeliverymanRegisterRequestCitiesModel? selectedCity,
    List<DeliverymanRegisterRequestCitiesModel>? cityList,
    LocalitiesFromCityModel? selectedLocality,
    List<LocalitiesFromCityModel>? localityList,
    DeliverymanRegisterRequestLatitudeField? latitudeField,
    DeliverymanRegisterRequestLongitudeField? longitudeField,
    DeliverymanRegisterRequestVehicleModel? selectedVehicle,
    List<DeliverymanRegisterRequestVehicleModel>? vehicleList,
    DeliverymanRegisterRequestIdentityTypeModel? identityType,
    List<DeliverymanRegisterRequestIdentityTypeModel>? identityTypeList,
    DeliverymanRegisterRequestJobTypeModel? jobType,
    List<DeliverymanRegisterRequestJobTypeModel>? jobTypeList,
    List<DeliverymanFormElementConfigModel>? formField,
    bool? isValid,
    bool? isFormSubmitted,
    String? uploadingImageTag,
    String? formUploadingImageUUID,
    DeliverymanRegisterRequestStatus? status,
    int? statusCode,
    String? alertMessage,
    String? extraMessage,
  }) {
    return DeliverymanRegisterRequestState(
      model: model ?? this.model,
      emailField: emailField ?? this.emailField,
      passwordField: passwordField ?? this.passwordField,
      firstNameField: firstNameField ?? this.firstNameField,
      lastNameField: lastNameField ?? this.lastNameField,
      countryCodeField: countryCodeField ?? this.countryCodeField,
      flag: flag ?? this.flag,
      mobileNumberField: mobileNumberField ?? this.mobileNumberField,
      coverImageField: coverImageField ?? this.coverImageField,
      indentityProofField: indentityProofField ?? this.indentityProofField,
      ageField: ageField ?? this.ageField,
      dobField: dobField ?? this.dobField,
      identityNumberField: identityNumberField ?? this.identityNumberField,
      drivingLicenseField: drivingLicenseField ?? this.drivingLicenseField,
      selectedCity: selectedCity ?? this.selectedCity,
      cityList: cityList ?? this.cityList,
      selectedLocality: selectedLocality ?? this.selectedLocality,
      localityList: localityList ?? this.localityList,
      latitudeField: latitudeField ?? this.latitudeField,
      longitudeField: longitudeField ?? this.longitudeField,
      selectedVehicle: selectedVehicle ?? this.selectedVehicle,
      vehicleList: vehicleList ?? this.vehicleList,
      identityType: identityType ?? this.identityType,
      identityTypeList: identityTypeList ?? this.identityTypeList,
      jobType: jobType ?? this.jobType,
      jobTypeList: jobTypeList ?? this.jobTypeList,
      formField: formField ?? this.formField,
      isValid: isValid ?? this.isValid,
      isFormSubmitted: isFormSubmitted ?? this.isFormSubmitted,
      uploadingImageTag: uploadingImageTag ?? this.uploadingImageTag,
      formUploadingImageUUID: formUploadingImageUUID ?? this.formUploadingImageUUID,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}

class DeliverymanRegisterRequestIdentityTypeModel {
  String? label;
  String? value;

  DeliverymanRegisterRequestIdentityTypeModel({this.label, this.value});

  DeliverymanRegisterRequestIdentityTypeModel.fromJson(Map<String, dynamic> json) {
    label = json['label'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['label'] = label;
    data['value'] = value;
    return data;
  }
}

class DeliverymanRegisterRequestJobTypeModel {
  String? label;
  String? value;

  DeliverymanRegisterRequestJobTypeModel({this.label, this.value});

  DeliverymanRegisterRequestJobTypeModel.fromJson(Map<String, dynamic> json) {
    label = json['label'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['label'] = label;
    data['value'] = value;
    return data;
  }
}

class DeliverymanFormElementConfigModel {
  String? uuid;
  bool? isRequired;
  String? type;
  String? title;
  String? placeholder;
  String? value;
  String? extraValue;
  List<DeliverymanFormElementItemConfigModel>? items;

  DeliverymanFormElementConfigModel({this.uuid, this.isRequired, this.type, this.title, this.placeholder, this.items, this.value, this.extraValue});

  DeliverymanFormElementConfigModel.fromJson(Map<String, dynamic> json) {
    uuid = json['uuid'];
    if (json['isRequired'] != null && (json['isRequired'] == true || json['isRequired'] == 'true')) {
      isRequired = true;
    } else {
      isRequired = false;
    }
    type = json['type'];
    title = json['title'];
    placeholder = json['placeholder'];
    if (json['items'] != null) {
      items = <DeliverymanFormElementItemConfigModel>[];
      json['items'].forEach((v) {
        items!.add(DeliverymanFormElementItemConfigModel.fromJson(v));
      });
    }
    value = json['value'];
    extraValue = json['extraValue'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['uuid'] = uuid;
    data['isRequired'] = isRequired;
    data['type'] = type;
    data['title'] = title;
    data['placeholder'] = placeholder;
    if (items != null) {
      data['items'] = items!.map((v) => v.toJson()).toList();
    }
    data['value'] = value;
    data['extraValue'] = extraValue;
    return data;
  }
}

class DeliverymanFormElementItemConfigModel {
  String? name;
  bool? value;

  DeliverymanFormElementItemConfigModel({this.name, this.value});

  DeliverymanFormElementItemConfigModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['value'] = value;
    return data;
  }
}

