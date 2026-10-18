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

sealed class EditUserProfileEvent {}

final class EditUserProfileInitialEvent extends EditUserProfileEvent {}

final class EditUserProfileFirstNameChangedEvent extends EditUserProfileEvent {
  final String firstName;
  EditUserProfileFirstNameChangedEvent({required this.firstName});
}

final class EditUserProfileFirstNameUnfocusedEvent extends EditUserProfileEvent {}

final class EditUserProfileLastNameChangedEvent extends EditUserProfileEvent {
  final String lastName;
  EditUserProfileLastNameChangedEvent({required this.lastName});
}

final class EditUserProfileLastNameUnfocusedEvent extends EditUserProfileEvent {}

final class EditUserProfileSubmitEvent extends EditUserProfileEvent {}

final class EditUserProfileChangeGenderEvent extends EditUserProfileEvent {
  final UserProfileGenderModel gender;
  EditUserProfileChangeGenderEvent({required this.gender});
}

final class EditUserProfileAvatarSelectEvent extends EditUserProfileEvent {
  final String avatar;
  EditUserProfileAvatarSelectEvent({required this.avatar});
}

final class EditUserProfileUploadImageEvent extends EditUserProfileEvent {
  final XFile newImage;
  EditUserProfileUploadImageEvent({required this.newImage});
}

