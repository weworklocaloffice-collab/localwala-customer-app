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

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:user/app/core/models/request/update_locale_request_model.dart';
import 'package:user/app/core/repositories/auth_repository.dart';
import 'package:user/app/env.dart';

part 'language_translation_modal_event.dart';
part 'language_translation_modal_state.dart';

class LanguageTranslationModalBloc extends Bloc<LanguageTranslationModalEvent, LanguageTranslationModalState> {
  final AuthRepository _authRepository = AuthRepository();
  LanguageTranslationModalBloc() : super(const LanguageTranslationModalState()) {
    on<LanguageTranslationModalInitialEvent>(_onLanguageTranslationModalInitialEvent);
    on<LanguageTranslationModalChangeEvent>(_onLanguageTranslationModalChangeEvent);
    on<LanguageTranslationModalSubmitEvent>(_onLanguageTranslationModalSubmitEvent);
  }

  FutureOr<void> _onLanguageTranslationModalInitialEvent(LanguageTranslationModalInitialEvent event, Emitter<LanguageTranslationModalState> emit) async {
    await _authRepository.saveEvent('visited_screen', {"screen": "languages"}, 'languages_screen', 'languages_screen');
    final int indexOfLanguage = AppSupportedLanguagesModel.languages.indexWhere((element) => element.code == event.selected);
    if (indexOfLanguage != -1) {
      emit(state.copyWith(title: AppSupportedLanguagesModel.languages[indexOfLanguage].title, selectText: AppSupportedLanguagesModel.languages[indexOfLanguage].selectText));
    }
    emit(state.copyWith(selected: event.selected, languages: AppSupportedLanguagesModel.languages, status: LanguageTranslationModalStatus.success));
  }

  FutureOr<void> _onLanguageTranslationModalChangeEvent(LanguageTranslationModalChangeEvent event, Emitter<LanguageTranslationModalState> emit) async {
    final int indexOfLanguage = AppSupportedLanguagesModel.languages.indexWhere((element) => element.code == event.code);
    if (indexOfLanguage != -1) {
      emit(state.copyWith(title: AppSupportedLanguagesModel.languages[indexOfLanguage].title, selectText: AppSupportedLanguagesModel.languages[indexOfLanguage].selectText, selected: event.code));
    }
  }

  FutureOr<void> _onLanguageTranslationModalSubmitEvent(LanguageTranslationModalSubmitEvent event, Emitter<LanguageTranslationModalState> emit) async {
    final bool isAuthorized = await _authRepository.isAuthorized();
    if (isAuthorized) {
      final String uid = await _authRepository.userId();
      UpdateLocaleRequestModel param = UpdateLocaleRequestModel(id: uid, locale: state.selected);
      await _authRepository.updateLocale(param);
    }
  }
}

