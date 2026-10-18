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

part of 'social_account_verification_modal_bloc.dart';

enum SocialAccountVerificationModalStatus { initial, success, failure, inProgress, loaded, verify, verifyWeb, referral }

extension SocialAccountVerificationModalStatusX on SocialAccountVerificationModalStatus {
  bool get isInitial => this == SocialAccountVerificationModalStatus.initial;
  bool get isSuccess => this == SocialAccountVerificationModalStatus.success;
  bool get isFailure => this == SocialAccountVerificationModalStatus.failure;
  bool get isInProgress => this == SocialAccountVerificationModalStatus.inProgress;
  bool get isLoaded => this == SocialAccountVerificationModalStatus.loaded;
}

final class SocialAccountVerificationModalState {
  final SocialAccountVerificationFirstNameField firstName;
  final SocialAccountVerificationLastNameField lastName;
  final SocialAccountVerificationCountryCodeField countryCode;
  final String flag;
  final SocialAccountVerificationMobileNumberField mobileNumber;
  final bool isValid;
  final SocialAccountVerificationModalStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const SocialAccountVerificationModalState({
    this.firstName = const SocialAccountVerificationFirstNameField.pure(),
    this.lastName = const SocialAccountVerificationLastNameField.pure(),
    this.countryCode = const SocialAccountVerificationCountryCodeField.pure(),
    this.flag = '',
    this.mobileNumber = const SocialAccountVerificationMobileNumberField.pure(),
    this.isValid = false,
    this.status = SocialAccountVerificationModalStatus.initial,
    this.statusCode = 0,
    this.alertMessage = '',
    this.extraMessage = '',
  });

  SocialAccountVerificationModalState copyWith({
    SocialAccountVerificationFirstNameField? firstName,
    SocialAccountVerificationLastNameField? lastName,
    SocialAccountVerificationCountryCodeField? countryCode,
    String? flag,
    SocialAccountVerificationMobileNumberField? mobileNumber,
    bool? isValid,
    SocialAccountVerificationModalStatus? status,
    int? statusCode,
    String? alertMessage,
    String? extraMessage,
  }) {
    return SocialAccountVerificationModalState(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      countryCode: countryCode ?? this.countryCode,
      flag: flag ?? this.flag,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      isValid: isValid ?? this.isValid,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}

