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
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:user/app/core/models/user_settings_model.dart';
import 'package:user/app/core/repositories/auth_repository.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

part 'country_code_modal_event.dart';
part 'country_code_modal_state.dart';

class CountryCodeModalBloc extends Bloc<CountryCodeModalEvent, CountryCodeModalState> {
  final AuthRepository _authRepository = AuthRepository();
  CountryCodeModalBloc() : super(CountryCodeModalState(info: AppDefaultCountryCodeConfigModel())) {
    on<CountryCodeModalInitialEvent>(_onCountryCodeModalInitialEvent);
    on<CountryCodeModalSearchEvent>(_onCountryCodeModalSearchEvent);
    on<CountryCodeModalSelectEvent>(_onCountryCodeModalSelectEvent);
    on<CountryCodeModalSaveEvent>(_onCountryCodeModalSaveEvent);
  }

  FutureOr<void> _onCountryCodeModalInitialEvent(CountryCodeModalInitialEvent event, Emitter<CountryCodeModalState> emit) async {
    try {
      await _authRepository.saveEvent('visited_screen', {"screen": "country_modal"}, 'country_modal_screen', 'country_modal_screen');
      emit(state.copyWith(selectedCountries: event.code, status: CountryCodeModalStatus.loading));
      await _authRepository.getCountryList().then((value) {
        final selected = value.firstWhere((element) => element.dialCode == event.code);
        emit(state.copyWith(countries: value, dummy: value, info: selected, status: CountryCodeModalStatus.success));
      });
    } catch (e, stacktrace) {
      emit(state.copyWith(status: CountryCodeModalStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onCountryCodeModalSelectEvent(CountryCodeModalSelectEvent event, Emitter<CountryCodeModalState> emit) async {
    emit(state.copyWith(selectedCountries: event.selected.dialCode, info: event.selected));
  }

  FutureOr<void> _onCountryCodeModalSaveEvent(CountryCodeModalSaveEvent event, Emitter<CountryCodeModalState> emit) async {
    var selected = state.countries.firstWhere((element) => element.dialCode == state.selectedCountries);
    emit(state.copyWith(info: selected, status: CountryCodeModalStatus.selected));
  }

  FutureOr<void> _onCountryCodeModalSearchEvent(CountryCodeModalSearchEvent event, Emitter<CountryCodeModalState> emit) async {
    if (event.searchText.isNotEmpty) {
      emit(state.copyWith(countries: [...state.dummy]));
      final String searchText = event.searchText.toLowerCase();
      final list = state.countries.where((element) => element.name!.toLowerCase().contains(searchText) || element.code!.toLowerCase().contains(searchText) || element.dialCode!.toLowerCase().contains(searchText)).toList();
      emit(state.copyWith(countries: [...list]));
    } else {
      emit(state.copyWith(countries: [...state.dummy]));
    }
  }
}

