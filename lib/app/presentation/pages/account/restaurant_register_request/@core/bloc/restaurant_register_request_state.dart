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

enum RestaurantRegisterRequestStatus {
  loading,
  fetched,
  basicFetched,
  locationChange,
  initial,
  submit,
  submitSuccess,
  payment,
  paymentSuccess,
  makePayment,
  failure,
  backPage,
  uploadStarted,
  uploadSuccess,
  uploadFailed,
  changeDetailFromModal,
  customError,
  localityFetching,
  localityFetched,
  localityFailed,
}

extension RestaurantRegisterRequestStatusX on RestaurantRegisterRequestStatus {
  bool get isLoading => this == RestaurantRegisterRequestStatus.loading;
  bool get isFetched => this == RestaurantRegisterRequestStatus.fetched;
  bool get isBasicFetched => this == RestaurantRegisterRequestStatus.basicFetched;
  bool get isLocationChange => this == RestaurantRegisterRequestStatus.locationChange;
  bool get isInitial => this == RestaurantRegisterRequestStatus.initial;
  bool get isSubmit => this == RestaurantRegisterRequestStatus.submit;
  bool get isSubmitSuccess => this == RestaurantRegisterRequestStatus.submitSuccess;
  bool get isPayment => this == RestaurantRegisterRequestStatus.payment;
  bool get isPaymentSuccess => this == RestaurantRegisterRequestStatus.paymentSuccess;
  bool get isMakePayment => this == RestaurantRegisterRequestStatus.makePayment;
  bool get isFailure => this == RestaurantRegisterRequestStatus.failure;
  bool get isBackPage => this == RestaurantRegisterRequestStatus.backPage;
  bool get isUploadStarted => this == RestaurantRegisterRequestStatus.uploadStarted;
  bool get isUploadSuccess => this == RestaurantRegisterRequestStatus.uploadSuccess;
  bool get isUploadFailed => this == RestaurantRegisterRequestStatus.uploadFailed;
  bool get isChangeDetailFromModal => this == RestaurantRegisterRequestStatus.changeDetailFromModal;
  bool get isCustomError => this == RestaurantRegisterRequestStatus.customError;
  bool get isLocalityFetching => this == RestaurantRegisterRequestStatus.localityFetching;
  bool get isLocalityFetched => this == RestaurantRegisterRequestStatus.localityFetched;
  bool get isLocalityFailed => this == RestaurantRegisterRequestStatus.localityFailed;
}

final class RestaurantRegisterRequestState {
  final int currentPageIndex;
  final RestaurantRegisterRequestBasicDetailModel model;
  final RestaurantRegisterRequestNameField nameField;
  final RestaurantRegisterRequestShortDescriptionField shortDescriptionField;
  final RestaurantRegisterRequestAddressField addressField;
  final RestaurantRegisterRequestCuisineField cuisineField;
  final RestaurantRegisterRequestTypeField typeField;
  final RestaurantRegisterRequestFacilitiesField facilitiesField;
  final RestaurantRegisterRequestMinOrderAmountField minOrderAmountField;
  final RestaurantRegisterRequestDishPriceForTwoField dishPriceForTwoField;
  final RestaurantRegisterRequestFoodLicenseField licenseField;
  final RestaurantRegisterRequestDeliveryTimeField deliveryTimeField;
  final RestaurantRegisterRequestEmailField emailField;
  final RestaurantRegisterRequestPasswordField passwordField;
  final RestaurantRegisterRequestFirstNameField firstNameField;
  final RestaurantRegisterRequestLastNameField lastNameField;
  final RestaurantRegisterRequestCountryCodeField countryCodeField;
  final String flag;
  final RestaurantRegisterRequestMobileNumberField mobileNumberField;
  final RestaurantRegisterRequestLatitudeField latitudeField;
  final RestaurantRegisterRequestLongitudeField longitudeField;
  final RestaurantRegisterRequestCoverField coverField;
  final RestaurantRegisterRequestLogoField logoField;
  final HomeDeliverySupportModel homeDelivery;
  final List<HomeDeliverySupportModel> homeDeliveryList;
  final TakeAwaySupportModel takeAway;
  final List<TakeAwaySupportModel> takeAwayList;
  final ScheduleOrderSupportModel scheduleOrder;
  final List<ScheduleOrderSupportModel> scheduleOrderList;
  final RestaurantRegisterRequestCitiesModel selectedCity;
  final List<RestaurantRegisterRequestCitiesModel> cityList;
  final LocalitiesFromCityModel selectedLocality;
  final List<LocalitiesFromCityModel> localityList;
  final RestaurantRegisterRequestLicenseModel selectedLicense;
  final List<RestaurantRegisterRequestLicenseModel> licenseList;
  final List<FormElementConfigModel> formField;
  final String cuisineNames;
  final String cuisineIds;
  final String typeName;
  final String typeIds;
  final String facilitiesName;
  final String facilitiesIds;
  final bool isValid;
  final bool isFormSubmitted;
  final String uploadingImageTag;
  final String formUploadingImageUUID;
  final String businessModel;
  final String selectedPackage;
  final bool haveTrial;
  final int trialPeriod;
  final double payAmount;
  final String paymentId;
  final String socialFacebook;
  final String socialInstagram;
  final String socialX;
  final String socialYoutube;
  final String socialLinkedIn;
  final String socialPinterest;
  final List<RestaurantRegisterRequestFormTranslations> translations;
  final String paymentURL;
  final RestaurantRegisterRequestStatus status;
  final String alertMessage;
  final int statusCode;
  final String extraMessage;
  const RestaurantRegisterRequestState({
    this.currentPageIndex = 0,
    required this.model,
    this.nameField = const RestaurantRegisterRequestNameField.pure(),
    this.shortDescriptionField = const RestaurantRegisterRequestShortDescriptionField.pure(),
    this.addressField = const RestaurantRegisterRequestAddressField.pure(),
    this.cuisineField = const RestaurantRegisterRequestCuisineField.pure(),
    this.typeField = const RestaurantRegisterRequestTypeField.pure(),
    this.facilitiesField = const RestaurantRegisterRequestFacilitiesField.pure(),
    this.minOrderAmountField = const RestaurantRegisterRequestMinOrderAmountField.pure(),
    this.dishPriceForTwoField = const RestaurantRegisterRequestDishPriceForTwoField.pure(),
    this.licenseField = const RestaurantRegisterRequestFoodLicenseField.pure(),
    this.deliveryTimeField = const RestaurantRegisterRequestDeliveryTimeField.pure(),
    this.emailField = const RestaurantRegisterRequestEmailField.pure(),
    this.passwordField = const RestaurantRegisterRequestPasswordField.pure(),
    this.firstNameField = const RestaurantRegisterRequestFirstNameField.pure(),
    this.lastNameField = const RestaurantRegisterRequestLastNameField.pure(),
    this.countryCodeField = const RestaurantRegisterRequestCountryCodeField.pure(),
    this.flag = '',
    this.mobileNumberField = const RestaurantRegisterRequestMobileNumberField.pure(),
    this.latitudeField = const RestaurantRegisterRequestLatitudeField.pure(),
    this.longitudeField = const RestaurantRegisterRequestLongitudeField.pure(),
    this.coverField = const RestaurantRegisterRequestCoverField.pure(),
    this.logoField = const RestaurantRegisterRequestLogoField.pure(),
    required this.homeDelivery,
    this.homeDeliveryList = const [],
    required this.takeAway,
    this.takeAwayList = const [],
    required this.scheduleOrder,
    this.scheduleOrderList = const [],
    required this.selectedCity,
    this.cityList = const [],
    required this.selectedLocality,
    this.localityList = const [],
    required this.selectedLicense,
    this.licenseList = const [],
    this.formField = const [],
    this.cuisineNames = '',
    this.cuisineIds = '',
    this.typeName = '',
    this.typeIds = '',
    this.facilitiesName = '',
    this.facilitiesIds = '',
    this.isValid = false,
    this.isFormSubmitted = false,
    this.uploadingImageTag = 'logo',
    this.formUploadingImageUUID = '',
    this.businessModel = 'commission',
    this.selectedPackage = '',
    this.haveTrial = false,
    this.trialPeriod = 0,
    this.payAmount = 0.0,
    this.paymentId = '',
    this.translations = const [],
    this.paymentURL = '',
    this.socialFacebook = '',
    this.socialInstagram = '',
    this.socialX = '',
    this.socialYoutube = '',
    this.socialLinkedIn = '',
    this.socialPinterest = '',
    this.status = RestaurantRegisterRequestStatus.loading,
    this.alertMessage = '',
    this.statusCode = 0,
    this.extraMessage = '',
  });

  RestaurantRegisterRequestState copyWith({
    int? currentPageIndex,
    RestaurantRegisterRequestBasicDetailModel? model,
    RestaurantRegisterRequestNameField? nameField,
    RestaurantRegisterRequestShortDescriptionField? shortDescriptionField,
    RestaurantRegisterRequestAddressField? addressField,
    RestaurantRegisterRequestCuisineField? cuisineField,
    RestaurantRegisterRequestTypeField? typeField,
    RestaurantRegisterRequestFacilitiesField? facilitiesField,
    RestaurantRegisterRequestMinOrderAmountField? minOrderAmountField,
    RestaurantRegisterRequestDishPriceForTwoField? dishPriceForTwoField,
    RestaurantRegisterRequestFoodLicenseField? licenseField,
    RestaurantRegisterRequestDeliveryTimeField? deliveryTimeField,
    RestaurantRegisterRequestEmailField? emailField,
    RestaurantRegisterRequestPasswordField? passwordField,
    RestaurantRegisterRequestFirstNameField? firstNameField,
    RestaurantRegisterRequestLastNameField? lastNameField,
    RestaurantRegisterRequestCountryCodeField? countryCodeField,
    String? flag,
    RestaurantRegisterRequestMobileNumberField? mobileNumberField,
    RestaurantRegisterRequestLatitudeField? latitudeField,
    RestaurantRegisterRequestLongitudeField? longitudeField,
    RestaurantRegisterRequestCoverField? coverField,
    RestaurantRegisterRequestLogoField? logoField,
    HomeDeliverySupportModel? homeDelivery,
    List<HomeDeliverySupportModel>? homeDeliveryList,
    TakeAwaySupportModel? takeAway,
    List<TakeAwaySupportModel>? takeAwayList,
    ScheduleOrderSupportModel? scheduleOrder,
    List<ScheduleOrderSupportModel>? scheduleOrderList,
    RestaurantRegisterRequestCitiesModel? selectedCity,
    List<RestaurantRegisterRequestCitiesModel>? cityList,
    LocalitiesFromCityModel? selectedLocality,
    List<LocalitiesFromCityModel>? localityList,
    RestaurantRegisterRequestLicenseModel? selectedLicense,
    List<RestaurantRegisterRequestLicenseModel>? licenseList,
    List<FormElementConfigModel>? formField,
    String? cuisineNames,
    String? cuisineIds,
    String? typeName,
    String? typeIds,
    String? facilitiesName,
    String? facilitiesIds,
    bool? isValid,
    bool? isFormSubmitted,
    String? uploadingImageTag,
    String? formUploadingImageUUID,
    String? businessModel,
    String? selectedPackage,
    bool? haveTrial,
    int? trialPeriod,
    double? payAmount,
    String? paymentId,
    List<RestaurantRegisterRequestFormTranslations>? translations,
    String? paymentURL,
    String? socialFacebook,
    String? socialInstagram,
    String? socialX,
    String? socialYoutube,
    String? socialLinkedIn,
    String? socialPinterest,
    RestaurantRegisterRequestStatus? status,
    String? alertMessage,
    int? statusCode,
    String? extraMessage,
  }) {
    return RestaurantRegisterRequestState(
      currentPageIndex: currentPageIndex ?? this.currentPageIndex,
      model: model ?? this.model,
      nameField: nameField ?? this.nameField,
      shortDescriptionField: shortDescriptionField ?? this.shortDescriptionField,
      addressField: addressField ?? this.addressField,
      cuisineField: cuisineField ?? this.cuisineField,
      typeField: typeField ?? this.typeField,
      facilitiesField: facilitiesField ?? this.facilitiesField,
      minOrderAmountField: minOrderAmountField ?? this.minOrderAmountField,
      dishPriceForTwoField: dishPriceForTwoField ?? this.dishPriceForTwoField,
      licenseField: licenseField ?? this.licenseField,
      deliveryTimeField: deliveryTimeField ?? this.deliveryTimeField,
      emailField: emailField ?? this.emailField,
      passwordField: passwordField ?? this.passwordField,
      firstNameField: firstNameField ?? this.firstNameField,
      lastNameField: lastNameField ?? this.lastNameField,
      countryCodeField: countryCodeField ?? this.countryCodeField,
      flag: flag ?? this.flag,
      mobileNumberField: mobileNumberField ?? this.mobileNumberField,
      latitudeField: latitudeField ?? this.latitudeField,
      longitudeField: longitudeField ?? this.longitudeField,
      coverField: coverField ?? this.coverField,
      logoField: logoField ?? this.logoField,
      homeDelivery: homeDelivery ?? this.homeDelivery,
      homeDeliveryList: homeDeliveryList ?? this.homeDeliveryList,
      takeAway: takeAway ?? this.takeAway,
      takeAwayList: takeAwayList ?? this.takeAwayList,
      scheduleOrder: scheduleOrder ?? this.scheduleOrder,
      scheduleOrderList: scheduleOrderList ?? this.scheduleOrderList,
      selectedCity: selectedCity ?? this.selectedCity,
      cityList: cityList ?? this.cityList,
      selectedLocality: selectedLocality ?? this.selectedLocality,
      localityList: localityList ?? this.localityList,
      selectedLicense: selectedLicense ?? this.selectedLicense,
      licenseList: licenseList ?? this.licenseList,
      formField: formField ?? this.formField,
      cuisineNames: cuisineNames ?? this.cuisineNames,
      cuisineIds: cuisineIds ?? this.cuisineIds,
      typeName: typeName ?? this.typeName,
      typeIds: typeIds ?? this.typeIds,
      facilitiesName: facilitiesName ?? this.facilitiesName,
      facilitiesIds: facilitiesIds ?? this.facilitiesIds,
      isValid: isValid ?? this.isValid,
      isFormSubmitted: isFormSubmitted ?? this.isFormSubmitted,
      uploadingImageTag: uploadingImageTag ?? this.uploadingImageTag,
      formUploadingImageUUID: formUploadingImageUUID ?? this.formUploadingImageUUID,
      businessModel: businessModel ?? this.businessModel,
      selectedPackage: selectedPackage ?? this.selectedPackage,
      haveTrial: haveTrial ?? this.haveTrial,
      trialPeriod: trialPeriod ?? this.trialPeriod,
      payAmount: payAmount ?? this.payAmount,
      paymentId: paymentId ?? this.paymentId,
      translations: translations ?? this.translations,
      paymentURL: paymentURL ?? this.paymentURL,
      socialFacebook: socialFacebook ?? this.socialFacebook,
      socialInstagram: socialInstagram ?? this.socialInstagram,
      socialX: socialX ?? this.socialX,
      socialYoutube: socialYoutube ?? this.socialYoutube,
      socialLinkedIn: socialLinkedIn ?? this.socialLinkedIn,
      socialPinterest: socialPinterest ?? this.socialPinterest,
      status: status ?? this.status,
      alertMessage: alertMessage ?? this.alertMessage,
      statusCode: statusCode ?? this.statusCode,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}

class HomeDeliverySupportModel {
  bool? value;
  String? label;

  HomeDeliverySupportModel({this.value, this.label});

  HomeDeliverySupportModel.fromJson(Map<String, dynamic> json) {
    value = json['value'];
    label = json['label'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['value'] = value;
    data['label'] = label;
    return data;
  }
}

class TakeAwaySupportModel {
  bool? value;
  String? label;

  TakeAwaySupportModel({this.value, this.label});

  TakeAwaySupportModel.fromJson(Map<String, dynamic> json) {
    value = json['value'];
    label = json['label'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['value'] = value;
    data['label'] = label;
    return data;
  }
}

class ScheduleOrderSupportModel {
  bool? value;
  String? label;

  ScheduleOrderSupportModel({this.value, this.label});

  ScheduleOrderSupportModel.fromJson(Map<String, dynamic> json) {
    value = json['value'];
    label = json['label'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['value'] = value;
    data['label'] = label;
    return data;
  }
}

class FormElementConfigModel {
  String? uuid;
  bool? isRequired;
  String? type;
  String? title;
  String? placeholder;
  String? value;
  String? extraValue;
  List<FormElementItemConfigModel>? items;

  FormElementConfigModel({this.uuid, this.isRequired, this.type, this.title, this.placeholder, this.items, this.value, this.extraValue});

  FormElementConfigModel.fromJson(Map<String, dynamic> json) {
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
      items = <FormElementItemConfigModel>[];
      json['items'].forEach((v) {
        items!.add(FormElementItemConfigModel.fromJson(v));
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

class FormElementItemConfigModel {
  String? name;
  bool? value;

  FormElementItemConfigModel({this.name, this.value});

  FormElementItemConfigModel.fromJson(Map<String, dynamic> json) {
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

