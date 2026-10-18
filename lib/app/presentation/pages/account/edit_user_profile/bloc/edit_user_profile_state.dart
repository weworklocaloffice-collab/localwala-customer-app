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

part of 'edit_user_profile_bloc.dart';

enum EditUserProfileStatus { loading, success, failure, changeDetail, submit, submitSuccess, submitFailed, uploadStarted, uploadFailed, uploadSuccess }

extension EditUserProfileStatusX on EditUserProfileStatus {
  bool get isLoading => this == EditUserProfileStatus.loading;
  bool get isSuccess => this == EditUserProfileStatus.success;
  bool get isFailure => this == EditUserProfileStatus.failure;
  bool get isChangeDetail => this == EditUserProfileStatus.changeDetail;
  bool get isSubmit => this == EditUserProfileStatus.submit;
  bool get isSubmitSuccess => this == EditUserProfileStatus.submitSuccess;
  bool get isSubmitFailed => this == EditUserProfileStatus.submitFailed;
  bool get isUploadStarted => this == EditUserProfileStatus.uploadStarted;
  bool get isUploadFailed => this == EditUserProfileStatus.uploadFailed;
  bool get isUploadSuccess => this == EditUserProfileStatus.uploadSuccess;
}

final class EditUserProfileState {
  final UserProfileReponseModel model;
  final String userId;
  final UserProfileEmailField email;
  final UserProfileFirstNameField firstName;
  final UserProfileLastNameField lastName;
  final UserProfileCountryCodeField countryCode;
  final String flag;
  final UserProfileMobileNumberField mobile;
  final String image;
  final UserProfileGenderModel gender;
  final bool isValid;
  final List<UserProfileGenderModel> genderList;
  final EditUserProfileStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const EditUserProfileState({
    required this.model,
    this.userId = '',
    this.email = const UserProfileEmailField.pure(),
    this.firstName = const UserProfileFirstNameField.pure(),
    this.lastName = const UserProfileLastNameField.pure(),
    this.countryCode = const UserProfileCountryCodeField.pure(),
    this.flag = '',
    this.mobile = const UserProfileMobileNumberField.pure(),
    this.image = '',
    required this.gender,
    this.isValid = false,
    this.genderList = const [],
    this.status = EditUserProfileStatus.loading,
    this.statusCode = 0,
    this.alertMessage = '',
    this.extraMessage = '',
  });

  EditUserProfileState copyWith({
    UserProfileReponseModel? model,
    String? userId,
    UserProfileEmailField? email,
    UserProfileFirstNameField? firstName,
    UserProfileLastNameField? lastName,
    UserProfileCountryCodeField? countryCode,
    String? flag,
    UserProfileMobileNumberField? mobile,
    String? image,
    UserProfileGenderModel? gender,
    bool? isValid,
    List<UserProfileGenderModel>? genderList,
    EditUserProfileStatus? status,
    int? statusCode,
    String? alertMessage,
    String? extraMessage,
  }) {
    return EditUserProfileState(
      model: model ?? this.model,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      countryCode: countryCode ?? this.countryCode,
      flag: flag ?? this.flag,
      mobile: mobile ?? this.mobile,
      image: image ?? this.image,
      gender: gender ?? this.gender,
      isValid: isValid ?? this.isValid,
      genderList: genderList ?? this.genderList,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}

class UserProfileGenderModel {
  String? label;
  String? value;

  UserProfileGenderModel({this.label, this.value});

  UserProfileGenderModel.fromJson(Map<String, dynamic> json) {
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

