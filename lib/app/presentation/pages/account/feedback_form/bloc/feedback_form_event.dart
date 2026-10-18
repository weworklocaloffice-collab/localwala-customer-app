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

sealed class FeedbackFormEvent {}

final class FeedbackFormInitialEvent extends FeedbackFormEvent {}

final class FeedbackFormNameChangedEvent extends FeedbackFormEvent {
  final String name;
  FeedbackFormNameChangedEvent({required this.name});
}

final class FeedbackFormNameUnfocusedEvent extends FeedbackFormEvent {}

final class FeedbackFormCountryCodeChangedEvent extends FeedbackFormEvent {
  final String flag;
  final String countryCode;
  FeedbackFormCountryCodeChangedEvent({required this.flag, required this.countryCode});
}

final class FeedbackFormNumberChangedEvent extends FeedbackFormEvent {
  final String number;
  FeedbackFormNumberChangedEvent({required this.number});
}

final class FeedbackFormNumberUnfocusedEvent extends FeedbackFormEvent {}

final class FeedbackFormEmailChangedEvent extends FeedbackFormEvent {
  final String email;
  FeedbackFormEmailChangedEvent({required this.email});
}

final class FeedbackFormEmailUnfocusedEvent extends FeedbackFormEvent {}

final class FeedbackFormDescriptionChangedEvent extends FeedbackFormEvent {
  final String text;
  FeedbackFormDescriptionChangedEvent({required this.text});
}

final class FeedbackFormDescriptionUnfocusedEvent extends FeedbackFormEvent {}

final class FeedbackFormSubmitEvent extends FeedbackFormEvent {}

