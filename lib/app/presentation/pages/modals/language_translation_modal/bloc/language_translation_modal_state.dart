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

part of 'language_translation_modal_bloc.dart';

enum LanguageTranslationModalStatus { success, failure }

extension LanguageTranslationModalStatusX on LanguageTranslationModalStatus {
  bool get isSuccess => this == LanguageTranslationModalStatus.success;
  bool get isFailure => this == LanguageTranslationModalStatus.failure;
}

final class LanguageTranslationModalState {
  final String title;
  final String selectText;
  final String selected;
  final List<LanguageEntityModel> languages;
  final LanguageTranslationModalStatus status;
  final String alertMessage;
  final String extraMessage;
  const LanguageTranslationModalState({this.title = '', this.selectText = '', this.selected = '', this.languages = const [], this.status = LanguageTranslationModalStatus.success, this.alertMessage = '', this.extraMessage = ''});

  LanguageTranslationModalState copyWith({String? title, String? selectText, String? selected, List<LanguageEntityModel>? languages, LanguageTranslationModalStatus? status, String? alertMessage, String? extraMessage}) {
    return LanguageTranslationModalState(
      title: title ?? this.title,
      selectText: selectText ?? this.selectText,
      selected: selected ?? this.selected,
      languages: languages ?? this.languages,
      status: status ?? this.status,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}

