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

part of 'complaints_modal_bloc.dart';

sealed class ComplaintsModalEvent {}

final class ComplaintsModalInitialEvent extends ComplaintsModalEvent {
  final String orderId;
  ComplaintsModalInitialEvent({required this.orderId});
}

final class ComplaintModalIssueWithEvent extends ComplaintsModalEvent {
  final ComplaintIssueWithListModel issueWith;
  ComplaintModalIssueWithEvent({required this.issueWith});
}

final class ComplaintModalReasonSelectEvent extends ComplaintsModalEvent {
  final ComplaintReasonListModel reason;
  ComplaintModalReasonSelectEvent({required this.reason});
}

final class ComplaintModalFoodSelectEvent extends ComplaintsModalEvent {
  final FoodInCartModel food;
  ComplaintModalFoodSelectEvent({required this.food});
}

final class ComplaintModalTitleChangedEvent extends ComplaintsModalEvent {
  final String title;
  ComplaintModalTitleChangedEvent({required this.title});
}

final class ComplaintModalTitleUnfocusedEvent extends ComplaintsModalEvent {}

final class ComplaintModalBriefChangedEvent extends ComplaintsModalEvent {
  final String brief;
  ComplaintModalBriefChangedEvent({required this.brief});
}

final class ComplaintModalBriefUnfocusedEvent extends ComplaintsModalEvent {}

final class ComplaintModalImageProofEvent extends ComplaintsModalEvent {}

final class ComplaintModalUploadImageEvent extends ComplaintsModalEvent {
  final XFile newImage;
  ComplaintModalUploadImageEvent({required this.newImage});
}

final class ComplaintModalRemoveUploadImageEvent extends ComplaintsModalEvent {
  final int index;
  ComplaintModalRemoveUploadImageEvent({required this.index});
}

final class ComplaintModalSubmittedEvent extends ComplaintsModalEvent {}

