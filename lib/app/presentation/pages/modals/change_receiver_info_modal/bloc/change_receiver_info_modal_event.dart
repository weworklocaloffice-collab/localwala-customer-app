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

part of 'change_receiver_info_modal_bloc.dart';

sealed class ChangeReceiverInfoModalEvent {}

final class ChangeReceiverInfoModalInitialEvent extends ChangeReceiverInfoModalEvent {
  final String orderTo;
  final String addressTitle;
  final String addressSubtitle;
  final String receiverName;
  final String receiverCountryCode;
  final String receiverPhoneNumber;
  ChangeReceiverInfoModalInitialEvent({required this.orderTo, required this.addressTitle, required this.addressSubtitle, required this.receiverName, required this.receiverCountryCode, required this.receiverPhoneNumber});
}

final class ChangeReceiverNameChanged extends ChangeReceiverInfoModalEvent {
  final String name;
  ChangeReceiverNameChanged({required this.name});
}

final class ChangeReceiverNameUnfocused extends ChangeReceiverInfoModalEvent {}

final class ChangeReceiverCountryCodeChanged extends ChangeReceiverInfoModalEvent {
  final String flag;
  final String countryCode;
  ChangeReceiverCountryCodeChanged({required this.flag, required this.countryCode});
}

final class ChangeReceiverNumberChanged extends ChangeReceiverInfoModalEvent {
  final String number;
  ChangeReceiverNumberChanged({required this.number});
}

final class ChangeReceiverNumberUnfocused extends ChangeReceiverInfoModalEvent {}

final class ChangeReceiverSubmitted extends ChangeReceiverInfoModalEvent {}

