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

part of 'feedback_form_bloc.dart';

enum FeedbackFormStatus { initial, submit, success, failure }

extension FeedbackFormStatusX on FeedbackFormStatus {
  bool get isInitial => this == FeedbackFormStatus.initial;
  bool get isSuccess => this == FeedbackFormStatus.success;
  bool get isSubmit => this == FeedbackFormStatus.submit;
  bool get isFailure => this == FeedbackFormStatus.failure;
}

final class FeedbackFormState {
  final FeedbackFormEmailField userEmail;
  final FeedbackFormNameField userName;
  final FeedbackFormCountryCodeField userCountryCode;
  final String flag;
  final FeedbackFormNumberField userContact;
  final FeedbackFormShortDescriptionField shortDescritpion;
  final bool isValid;
  final FeedbackFormStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const FeedbackFormState({
    this.userEmail = const FeedbackFormEmailField.pure(),
    this.userName = const FeedbackFormNameField.pure(),
    this.userCountryCode = const FeedbackFormCountryCodeField.pure(),
    this.flag = '',
    this.userContact = const FeedbackFormNumberField.pure(),
    this.shortDescritpion = const FeedbackFormShortDescriptionField.pure(),
    this.isValid = false,
    this.status = FeedbackFormStatus.initial,
    this.statusCode = 0,
    this.alertMessage = '',
    this.extraMessage = '',
  });

  FeedbackFormState copyWith({
    FeedbackFormEmailField? userEmail,
    FeedbackFormNameField? userName,
    FeedbackFormCountryCodeField? userCountryCode,
    String? flag,
    FeedbackFormNumberField? userContact,
    FeedbackFormShortDescriptionField? shortDescritpion,
    bool? isValid,
    FeedbackFormStatus? status,
    int? statusCode,
    String? alertMessage,
    String? extraMessage,
  }) {
    return FeedbackFormState(
      userEmail: userEmail ?? this.userEmail,
      userName: userName ?? this.userName,
      userCountryCode: userCountryCode ?? this.userCountryCode,
      flag: flag ?? this.flag,
      userContact: userContact ?? this.userContact,
      shortDescritpion: shortDescritpion ?? this.shortDescritpion,
      isValid: isValid ?? this.isValid,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}

