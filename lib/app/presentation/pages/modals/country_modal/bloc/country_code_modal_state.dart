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

part of 'country_code_modal_bloc.dart';

enum CountryCodeModalStatus { loading, success, failure, selected }

extension CountryCodeModalStatusX on CountryCodeModalStatus {
  bool get isLoading => this == CountryCodeModalStatus.loading;
  bool get isSuccess => this == CountryCodeModalStatus.success;
  bool get isFailure => this == CountryCodeModalStatus.failure;
  bool get isSelected => this == CountryCodeModalStatus.selected;
}

final class CountryCodeModalState {
  final List<AppDefaultCountryCodeConfigModel> countries;
  final List<AppDefaultCountryCodeConfigModel> dummy;
  final String selectedCountries;
  final AppDefaultCountryCodeConfigModel info;
  final CountryCodeModalStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const CountryCodeModalState({
    this.countries = const [],
    this.dummy = const [],
    this.selectedCountries = '',
    required this.info,
    this.status = CountryCodeModalStatus.loading,
    this.statusCode = 0,
    this.alertMessage = '',
    this.extraMessage = '',
  });

  CountryCodeModalState copyWith({
    List<AppDefaultCountryCodeConfigModel>? countries,
    List<AppDefaultCountryCodeConfigModel>? dummy,
    String? selectedCountries,
    AppDefaultCountryCodeConfigModel? info,
    CountryCodeModalStatus? status,
    int? statusCode,
    String? alertMessage,
    String? extraMessage,
  }) {
    return CountryCodeModalState(
      countries: countries ?? this.countries,
      dummy: dummy ?? this.dummy,
      selectedCountries: selectedCountries ?? this.selectedCountries,
      info: info ?? this.info,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}

