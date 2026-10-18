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
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:formz/formz.dart';
import 'package:image_picker/image_picker.dart';
import 'package:user/app/core/config/api_request_service.dart';
import 'package:user/app/core/models/localities_by_city_model.dart';
import 'package:user/app/core/models/modal_navigation_back_response_model.dart';
import 'package:user/app/core/models/register_request_response_model.dart';
import 'package:user/app/core/models/request/check_restaurant_register_request_model.dart';
import 'package:user/app/core/models/request/restaurant_joining_request_model.dart';
import 'package:user/app/core/models/restaurant_register_request_basic_detail_model.dart';
import 'package:user/app/core/models/server_error_model.dart';
import 'package:user/app/core/models/translations/restaurant_register_request_form_translation.dart';
import 'package:user/app/core/models/upload_image_model.dart';
import 'package:user/app/core/models/user_settings_model.dart';
import 'package:user/app/core/repositories/auth_repository.dart';
import 'package:user/app/core/validations/restaurant_register_request_form.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

part 'restaurant_register_request_event.dart';
part 'restaurant_register_request_state.dart';

class RestaurantRegisterRequestBloc extends Bloc<RestaurantRegisterRequestEvent, RestaurantRegisterRequestState> {
  final AuthRepository _authRepository = AuthRepository();
  RestaurantRegisterRequestBloc()
    : super(
        RestaurantRegisterRequestState(
          model: RestaurantRegisterRequestBasicDetailModel(cities: [], licenses: [], subscriptionPackages: [], success: false, locale: ''),
          homeDelivery: HomeDeliverySupportModel(label: '', value: false),
          takeAway: TakeAwaySupportModel(label: '', value: false),
          scheduleOrder: ScheduleOrderSupportModel(label: '', value: false),
          selectedCity: RestaurantRegisterRequestCitiesModel(locale: ''),
          selectedLicense: RestaurantRegisterRequestLicenseModel(locale: ''),
          selectedLocality: LocalitiesFromCityModel(locale: ''),
        ),
      ) {
    on<RestaurantRegisterRequestInitialEvent>(_onRestaurantRegisterRequestInitialEvent);
    on<RestaurantRegisterRequestNameChangedEvent>(_onRestaurantRegisterRequestNameChangedEvent);
    on<RestaurantRegisterRequestNameUnfocusedEvent>(_onRestaurantRegisterRequestNameUnfocusedEvent);
    on<RestaurantRegisterRequestShortDescriptionChangedEvent>(_onRestaurantRegisterRequestShortDescriptionChangedEvent);
    on<RestaurantRegisterRequestShortDescriptionUnfocusedEvent>(_onRestaurantRegisterRequestShortDescriptionUnfocusedEvent);
    on<RestaurantRegisterRequestAddressChangedEvent>(_onRestaurantRegisterRequestAddressChangedEvent);
    on<RestaurantRegisterRequestAddressUnfocusedEvent>(_onRestaurantRegisterRequestAddressUnfocusedEvent);
    on<RestaurantRegisterRequestMinOrderAmountChangedEvent>(_onRestaurantRegisterRequestMinOrderAmountChangedEvent);
    on<RestaurantRegisterRequestMinOrderAmountUnfocusedEvent>(_onRestaurantRegisterRequestMinOrderAmountUnfocusedEvent);
    on<RestaurantRegisterRequestDishForTwoChangedEvent>(_onRestaurantRegisterRequestDishForTwoChangedEvent);
    on<RestaurantRegisterRequestDishForTwoUnfocusedEvent>(_onRestaurantRegisterRequestDishForTwoUnfocusedEvent);
    on<RestaurantRegisterRequestFoodLicenseChangedEvent>(_onRestaurantRegisterRequestFoodLicenseChangedEvent);
    on<RestaurantRegisterRequestFoodLicenseUnfocusedEvent>(_onRestaurantRegisterRequestFoodLicenseUnfocusedEvent);
    on<RestaurantRegisterRequestEmailChangedEvent>(_onRestaurantRegisterRequestEmailChangedEvent);
    on<RestaurantRegisterRequestEmailUnfocusedEvent>(_onRestaurantRegisterRequestEmailUnfocusedEvent);
    on<RestaurantRegisterRequestPasswordChangedEvent>(_onRestaurantRegisterRequestPasswordChangedEvent);
    on<RestaurantRegisterRequestPasswordUnfocusedEvent>(_onRestaurantRegisterRequestPasswordUnfocusedEvent);
    on<RestaurantRegisterRequestFirstNameChangedEvent>(_onRestaurantRegisterRequestFirstNameChangedEvent);
    on<RestaurantRegisterRequestFirstNameUnfocusedEvent>(_onRestaurantRegisterRequestFirstNameUnfocusedEvent);
    on<RestaurantRegisterRequestLastNameChangedEvent>(_onRestaurantRegisterRequestLastNameChangedEvent);
    on<RestaurantRegisterRequestLastNameUnfocusedEvent>(_onRestaurantRegisterRequestLastNameUnfocusedEvent);
    on<RestaurantRegisterRequestCountryCodeChangedEvent>(_onRestaurantRegisterRequestCountryCodeChangedEvent);
    on<RestaurantRegisterRequestCountryCodeUnfocusedEvent>(_onRestaurantRegisterRequestCountryCodeUnfocusedEvent);
    on<RestaurantRegisterRequestMobileNumberChangedEvent>(_onRestaurantRegisterRequestMobileNumberChangedEvent);
    on<RestaurantRegisterRequestMobileNumberUnfocusedEvent>(_onRestaurantRegisterRequestMobileNumberUnfocusedEvent);
    on<RestaurantRegisterRequestHomeDeliveryChangeEvent>(_onRestaurantRegisterRequestHomeDeliveryChangeEvent);
    on<RestaurantRegisterRequestTakeAwayChangeEvent>(_onRestaurantRegisterRequestTakeAwayChangeEvent);
    on<RestaurantRegisterRequestScheduleOrderChangeEvent>(_onRestaurantRegisterRequestScheduleOrderChangeEvent);
    on<RestaurantRegisterRequestCuisineChangeEvent>(_onRestaurantRegisterRequestCuisineChangeEvent);
    on<RestaurantRegisterRequestCusineUnfocusedEvent>(_onRestaurantRegisterRequestCusineUnfocusedEvent);
    on<RestaurantRegisterRequestTypeChangeEvent>(_onRestaurantRegisterRequestTypeChangeEvent);
    on<RestaurantRegisterRequestTypeUnfocusedEvent>(_onRestaurantRegisterRequestTypeUnfocusedEvent);
    on<RestaurantRegisterRequestFacilitiesChangeEvent>(_onRestaurantRegisterRequestFacilitiesChangeEvent);
    on<RestaurantRegisterRequestFacilityUnfocusedEvent>(_onRestaurantRegisterRequestFacilityUnfocusedEvent);
    on<RestaurantRegisterRequestDeliveryTimeChangeEvent>(_onRestaurantRegisterRequestDeliveryTimeChangeEvent);
    on<RestaurantRegisterRequestLicenseChangeEvent>(_onRestaurantRegisterRequestLicenseChangeEvent);
    on<RestaurantRegisterRequestCityChangeEvent>(_onRestaurantRegisterRequestCityChangeEvent);
    on<RestaurantRegisterRequestLocalityChangeEvent>(_onRestaurantRegisterRequestLocalityChangeEvent);
    on<RestaurantRegisterRequestLocationChangeEvent>(_onRestaurantRegisterRequestLocationChangeEvent);
    on<RestaurantRegisterRequestFormTextInputChangeEvent>(_onRestaurantRegisterRequestFormTextInputChangeEvent);
    on<RestaurantRegisterRequestFormCountryCodeChangeEvent>(_onRestaurantRegisterRequestFormCountryCodeChangeEvent);
    on<RestaurantRegisterRequestFormCheckboxChangeEvent>(_onRestaurantRegisterRequestFormCheckboxChangeEvent);
    on<RestaurantRegisterRequestUploadImageEvent>(_onRestaurantRegisterRequestUploadImageEvent);
    on<RestaurantRegisterRequestOnBackPageEvent>(_onRestaurantRegisterRequestOnBackPageEvent);
    on<RestaurantRegisterRequestSubmitEvent>(_onRestaurantRegisterRequestSubmitEvent);
    on<RestaurantRegisterRequestBusinessModelChangeEvent>(_onRestaurantRegisterRequestBusinessModelChangeEvent);
    on<RestaurantRegisterRequestChangeSubscriptionPackageEvent>(_onRestaurantRegisterRequestChangeSubscriptionPackageEvent);
    on<RestaurantRegisterRequestBusinessPlanSelectEvent>(_onRestaurantRegisterRequestBusinessPlanSelectEvent);
    on<RestaurantRegisterRequestChangePaymentMethodEvent>(_onRestaurantRegisterRequestChangePaymentMethodEvent);
    on<RestaurantRegisterRequestSocialLinkChangeEvent>(_onRestaurantRegisterRequestSocialLinkChangeEvent);
    on<RestaurantRegisterRequestCreateProfileRequestEvent>(_onRestaurantRegisterRequestCreateProfileRequestEvent);
  }

  FutureOr<void> _onRestaurantRegisterRequestInitialEvent(RestaurantRegisterRequestInitialEvent event, Emitter<RestaurantRegisterRequestState> emit) async {
    try {
      emit(state.copyWith(status: RestaurantRegisterRequestStatus.loading));
      await _authRepository.saveEvent('visited_screen', {"screen": "restaurant_register_request"}, 'restaurant_register_request_screen', 'restaurant_register_request_screen');
      DioApiResponse response = await _authRepository.getRestaurantRegisterRequestBasicDetail();
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        final String locale = await _authRepository.getLocale();
        RestaurantRegisterRequestBasicDetailModel data = RestaurantRegisterRequestBasicDetailModel.fromJson(myMap, locale.toString());
        String defaultCountryCode = '';
        String flag = '';
        await _authRepository.getDefaultCountryCode().then((value) {
          if (value != '' && value.isNotEmpty) {
            try {
              Map<String, dynamic>? myMap = jsonDecode(value) as Map<String, dynamic>;
              AppDefaultCountryCodeConfigModel countryCodeData = AppDefaultCountryCodeConfigModel.fromJson(myMap);
              defaultCountryCode = countryCodeData.dialCode!;
              flag = countryCodeData.flag!;
            } catch (e, stacktrace) {
              if (!kIsWeb) {
                FirebaseCrashlytics.instance.recordError(e, stacktrace);
              }
            }
          }
        });
        String latitude = '0';
        String longitude = '0';

        HomeDeliverySupportModel homeDeliveryTrue = HomeDeliverySupportModel(label: 'dd_yes_home_delivery', value: true);
        HomeDeliverySupportModel homeDeliveryFalse = HomeDeliverySupportModel(label: 'dd_no_home_delivery', value: false);
        List<HomeDeliverySupportModel> homeDeliveryListOption = <HomeDeliverySupportModel>[];
        homeDeliveryListOption.clear();
        homeDeliveryListOption.add(homeDeliveryTrue);
        homeDeliveryListOption.add(homeDeliveryFalse);

        TakeAwaySupportModel takeAwayTrue = TakeAwaySupportModel(label: 'dd_yes_takeaway', value: true);
        TakeAwaySupportModel takeAwayFalse = TakeAwaySupportModel(label: 'dd_no_takeaway', value: false);
        List<TakeAwaySupportModel> takeAwayListOption = <TakeAwaySupportModel>[];
        takeAwayListOption.clear();
        takeAwayListOption.add(takeAwayTrue);
        takeAwayListOption.add(takeAwayFalse);

        ScheduleOrderSupportModel scheduleOrderTrue = ScheduleOrderSupportModel(label: 'dd_yes_schedule_order', value: true);
        ScheduleOrderSupportModel scheduleOrderFalse = ScheduleOrderSupportModel(label: 'dd_no_schedule_order', value: false);
        List<ScheduleOrderSupportModel> scheduleOrderOption = <ScheduleOrderSupportModel>[];
        scheduleOrderOption.clear();
        scheduleOrderOption.add(scheduleOrderTrue);
        scheduleOrderOption.add(scheduleOrderFalse);

        List<RestaurantRegisterRequestCitiesModel> cityList = <RestaurantRegisterRequestCitiesModel>[];
        cityList.clear();
        for (var element in data.cities!) {
          cityList.add(element);
        }

        if (cityList.isNotEmpty) {
          latitude = cityList.first.location!.coordinates![1].toString();
          longitude = cityList.first.location!.coordinates![0].toString();
        }

        List<RestaurantRegisterRequestLicenseModel> licenseList = <RestaurantRegisterRequestLicenseModel>[];
        licenseList.clear();
        for (var element in data.licenses!) {
          licenseList.add(element);
        }

        const deliveryTime = RestaurantRegisterRequestDeliveryTimeField.dirty('10 to 20 min');
        final countryCode = RestaurantRegisterRequestCountryCodeField.dirty(defaultCountryCode);
        final latitudeField = RestaurantRegisterRequestLatitudeField.dirty(latitude);
        final longitudeField = RestaurantRegisterRequestLongitudeField.dirty(longitude);

        List<FormElementConfigModel> formFieldList = <FormElementConfigModel>[];
        formFieldList.clear();
        if (data.joiningForm!.success! == true && data.joiningForm!.result!.restaurantForm!.isNotEmpty) {
          for (var element in data.joiningForm!.result!.restaurantForm!) {
            List<FormElementItemConfigModel> checkboxItems = <FormElementItemConfigModel>[];
            checkboxItems.clear();
            if (element.type! == 'choose' && element.items!.isNotEmpty) {
              for (var checkboxItemElement in element.items!) {
                FormElementItemConfigModel checkboxFieldParam = FormElementItemConfigModel(name: checkboxItemElement.name, value: false);
                checkboxItems.add(checkboxFieldParam);
              }
            }
            FormElementConfigModel fieldParam = FormElementConfigModel(
              uuid: element.uuid!,
              isRequired: element.isRequired!,
              type: element.type!,
              title: element.title!,
              placeholder: element.placeholder!,
              value: '',
              items: checkboxItems,
              extraValue: element.type! == 'phone' ? defaultCountryCode : '',
            );
            formFieldList.add(fieldParam);
          }
        }
        emit(
          state.copyWith(
            countryCodeField: countryCode,
            deliveryTimeField: deliveryTime,
            latitudeField: latitudeField,
            longitudeField: longitudeField,
            flag: flag,
            homeDelivery: homeDeliveryListOption.first,
            homeDeliveryList: homeDeliveryListOption,
            takeAway: takeAwayListOption.first,
            takeAwayList: takeAwayListOption,
            scheduleOrder: scheduleOrderOption.first,
            scheduleOrderList: scheduleOrderOption,
            selectedCity: cityList.first,
            cityList: cityList,
            selectedLocality: LocalitiesFromCityModel(id: '', name: '', translations: [], locale: locale.toString()),
            localityList: [],
            selectedLicense: licenseList.first,
            licenseList: licenseList,
            model: data,
            formField: formFieldList,
            businessModel: data.settings!.commissionBasedSystem! == false ? 'subscription' : 'commission',
            status: RestaurantRegisterRequestStatus.basicFetched,
          ),
        );

        if (cityList.isNotEmpty) {
          add(RestaurantRegisterRequestCityChangeEvent(city: cityList.first));
        }
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: RestaurantRegisterRequestStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: RestaurantRegisterRequestStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onRestaurantRegisterRequestNameChangedEvent(RestaurantRegisterRequestNameChangedEvent event, Emitter<RestaurantRegisterRequestState> emit) {
    final name = RestaurantRegisterRequestNameField.dirty(event.name);
    emit(
      state.copyWith(
        nameField: name.isValid ? name : RestaurantRegisterRequestNameField.pure(event.name),
        status: RestaurantRegisterRequestStatus.initial,
        isValid: Formz.validate([
          name,
          state.shortDescriptionField,
          state.addressField,
          state.cuisineField,
          state.typeField,
          state.facilitiesField,
          state.minOrderAmountField,
          state.dishPriceForTwoField,
          state.licenseField,
          state.deliveryTimeField,
          state.emailField,
          state.passwordField,
          state.firstNameField,
          state.lastNameField,
          state.countryCodeField,
          state.mobileNumberField,
          state.latitudeField,
          state.longitudeField,
          state.coverField,
          state.logoField,
        ]),
      ),
    );
  }

  FutureOr<void> _onRestaurantRegisterRequestNameUnfocusedEvent(RestaurantRegisterRequestNameUnfocusedEvent event, Emitter<RestaurantRegisterRequestState> emit) async {
    final name = RestaurantRegisterRequestNameField.dirty(state.nameField.value);
    emit(
      state.copyWith(
        nameField: name,
        status: RestaurantRegisterRequestStatus.initial,
        isValid: Formz.validate([
          name,
          state.shortDescriptionField,
          state.addressField,
          state.cuisineField,
          state.typeField,
          state.facilitiesField,
          state.minOrderAmountField,
          state.dishPriceForTwoField,
          state.licenseField,
          state.deliveryTimeField,
          state.emailField,
          state.passwordField,
          state.firstNameField,
          state.lastNameField,
          state.countryCodeField,
          state.mobileNumberField,
          state.latitudeField,
          state.longitudeField,
          state.coverField,
          state.logoField,
        ]),
      ),
    );
  }

  FutureOr<void> _onRestaurantRegisterRequestShortDescriptionChangedEvent(RestaurantRegisterRequestShortDescriptionChangedEvent event, Emitter<RestaurantRegisterRequestState> emit) async {
    final shortDescription = RestaurantRegisterRequestShortDescriptionField.dirty(event.shortDescription);
    emit(
      state.copyWith(
        shortDescriptionField: shortDescription.isValid ? shortDescription : RestaurantRegisterRequestShortDescriptionField.pure(event.shortDescription),
        status: RestaurantRegisterRequestStatus.initial,
        isValid: Formz.validate([
          shortDescription,
          state.nameField,
          state.addressField,
          state.cuisineField,
          state.typeField,
          state.facilitiesField,
          state.minOrderAmountField,
          state.dishPriceForTwoField,
          state.licenseField,
          state.deliveryTimeField,
          state.emailField,
          state.passwordField,
          state.firstNameField,
          state.lastNameField,
          state.countryCodeField,
          state.mobileNumberField,
          state.latitudeField,
          state.longitudeField,
          state.coverField,
          state.logoField,
        ]),
      ),
    );
  }

  FutureOr<void> _onRestaurantRegisterRequestShortDescriptionUnfocusedEvent(RestaurantRegisterRequestShortDescriptionUnfocusedEvent event, Emitter<RestaurantRegisterRequestState> emit) async {
    final shortDescription = RestaurantRegisterRequestShortDescriptionField.dirty(state.shortDescriptionField.value);
    emit(
      state.copyWith(
        shortDescriptionField: shortDescription,
        status: RestaurantRegisterRequestStatus.initial,
        isValid: Formz.validate([
          shortDescription,
          state.nameField,
          state.addressField,
          state.cuisineField,
          state.typeField,
          state.facilitiesField,
          state.minOrderAmountField,
          state.dishPriceForTwoField,
          state.licenseField,
          state.deliveryTimeField,
          state.emailField,
          state.passwordField,
          state.firstNameField,
          state.lastNameField,
          state.countryCodeField,
          state.mobileNumberField,
          state.latitudeField,
          state.longitudeField,
          state.coverField,
          state.logoField,
        ]),
      ),
    );
  }

  FutureOr<void> _onRestaurantRegisterRequestAddressChangedEvent(RestaurantRegisterRequestAddressChangedEvent event, Emitter<RestaurantRegisterRequestState> emit) async {
    final address = RestaurantRegisterRequestAddressField.dirty(event.address);
    emit(
      state.copyWith(
        addressField: address.isValid ? address : RestaurantRegisterRequestAddressField.pure(event.address),
        status: RestaurantRegisterRequestStatus.initial,
        isValid: Formz.validate([
          address,
          state.shortDescriptionField,
          state.nameField,
          state.cuisineField,
          state.typeField,
          state.facilitiesField,
          state.minOrderAmountField,
          state.dishPriceForTwoField,
          state.licenseField,
          state.deliveryTimeField,
          state.emailField,
          state.passwordField,
          state.firstNameField,
          state.lastNameField,
          state.countryCodeField,
          state.mobileNumberField,
          state.latitudeField,
          state.longitudeField,
          state.coverField,
          state.logoField,
        ]),
      ),
    );
  }

  FutureOr<void> _onRestaurantRegisterRequestAddressUnfocusedEvent(RestaurantRegisterRequestAddressUnfocusedEvent event, Emitter<RestaurantRegisterRequestState> emit) async {
    final address = RestaurantRegisterRequestAddressField.dirty(state.addressField.value);
    emit(
      state.copyWith(
        addressField: address,
        status: RestaurantRegisterRequestStatus.initial,
        isValid: Formz.validate([
          address,
          state.nameField,
          state.shortDescriptionField,
          state.cuisineField,
          state.typeField,
          state.facilitiesField,
          state.minOrderAmountField,
          state.dishPriceForTwoField,
          state.licenseField,
          state.deliveryTimeField,
          state.emailField,
          state.passwordField,
          state.firstNameField,
          state.lastNameField,
          state.countryCodeField,
          state.mobileNumberField,
          state.latitudeField,
          state.longitudeField,
          state.coverField,
          state.logoField,
        ]),
      ),
    );
  }

  FutureOr<void> _onRestaurantRegisterRequestMinOrderAmountChangedEvent(RestaurantRegisterRequestMinOrderAmountChangedEvent event, Emitter<RestaurantRegisterRequestState> emit) async {
    final minOrderAmount = RestaurantRegisterRequestMinOrderAmountField.dirty(event.minOrderAmount);
    emit(
      state.copyWith(
        minOrderAmountField: minOrderAmount.isValid ? minOrderAmount : RestaurantRegisterRequestMinOrderAmountField.pure(event.minOrderAmount),
        status: RestaurantRegisterRequestStatus.initial,
        isValid: Formz.validate([
          minOrderAmount,
          state.shortDescriptionField,
          state.nameField,
          state.cuisineField,
          state.typeField,
          state.facilitiesField,
          state.addressField,
          state.dishPriceForTwoField,
          state.licenseField,
          state.deliveryTimeField,
          state.emailField,
          state.passwordField,
          state.firstNameField,
          state.lastNameField,
          state.countryCodeField,
          state.mobileNumberField,
          state.latitudeField,
          state.longitudeField,
          state.coverField,
          state.logoField,
        ]),
      ),
    );
  }

  FutureOr<void> _onRestaurantRegisterRequestMinOrderAmountUnfocusedEvent(RestaurantRegisterRequestMinOrderAmountUnfocusedEvent event, Emitter<RestaurantRegisterRequestState> emit) async {
    final minOrderAmount = RestaurantRegisterRequestMinOrderAmountField.dirty(state.minOrderAmountField.value);
    emit(
      state.copyWith(
        minOrderAmountField: minOrderAmount,
        status: RestaurantRegisterRequestStatus.initial,
        isValid: Formz.validate([
          minOrderAmount,
          state.nameField,
          state.shortDescriptionField,
          state.cuisineField,
          state.typeField,
          state.facilitiesField,
          state.addressField,
          state.dishPriceForTwoField,
          state.licenseField,
          state.deliveryTimeField,
          state.emailField,
          state.passwordField,
          state.firstNameField,
          state.lastNameField,
          state.countryCodeField,
          state.mobileNumberField,
          state.latitudeField,
          state.longitudeField,
          state.coverField,
          state.logoField,
        ]),
      ),
    );
  }

  FutureOr<void> _onRestaurantRegisterRequestDishForTwoChangedEvent(RestaurantRegisterRequestDishForTwoChangedEvent event, Emitter<RestaurantRegisterRequestState> emit) async {
    final dishForTwo = RestaurantRegisterRequestDishPriceForTwoField.dirty(event.dishForTwo);
    emit(
      state.copyWith(
        dishPriceForTwoField: dishForTwo.isValid ? dishForTwo : RestaurantRegisterRequestDishPriceForTwoField.pure(event.dishForTwo),
        status: RestaurantRegisterRequestStatus.initial,
        isValid: Formz.validate([
          dishForTwo,
          state.shortDescriptionField,
          state.nameField,
          state.cuisineField,
          state.typeField,
          state.facilitiesField,
          state.addressField,
          state.minOrderAmountField,
          state.licenseField,
          state.deliveryTimeField,
          state.emailField,
          state.passwordField,
          state.firstNameField,
          state.lastNameField,
          state.countryCodeField,
          state.mobileNumberField,
          state.latitudeField,
          state.longitudeField,
          state.coverField,
          state.logoField,
        ]),
      ),
    );
  }

  FutureOr<void> _onRestaurantRegisterRequestDishForTwoUnfocusedEvent(RestaurantRegisterRequestDishForTwoUnfocusedEvent event, Emitter<RestaurantRegisterRequestState> emit) async {
    final dishForTwo = RestaurantRegisterRequestDishPriceForTwoField.dirty(state.dishPriceForTwoField.value);
    emit(
      state.copyWith(
        dishPriceForTwoField: dishForTwo,
        status: RestaurantRegisterRequestStatus.initial,
        isValid: Formz.validate([
          dishForTwo,
          state.nameField,
          state.shortDescriptionField,
          state.cuisineField,
          state.typeField,
          state.facilitiesField,
          state.addressField,
          state.minOrderAmountField,
          state.licenseField,
          state.deliveryTimeField,
          state.emailField,
          state.passwordField,
          state.firstNameField,
          state.lastNameField,
          state.countryCodeField,
          state.mobileNumberField,
          state.latitudeField,
          state.longitudeField,
          state.coverField,
          state.logoField,
        ]),
      ),
    );
  }

  FutureOr<void> _onRestaurantRegisterRequestFoodLicenseChangedEvent(RestaurantRegisterRequestFoodLicenseChangedEvent event, Emitter<RestaurantRegisterRequestState> emit) async {
    final license = RestaurantRegisterRequestFoodLicenseField.dirty(event.license);
    emit(
      state.copyWith(
        licenseField: license.isValid ? license : RestaurantRegisterRequestFoodLicenseField.pure(event.license),
        status: RestaurantRegisterRequestStatus.initial,
        isValid: Formz.validate([
          license,
          state.shortDescriptionField,
          state.nameField,
          state.cuisineField,
          state.typeField,
          state.facilitiesField,
          state.addressField,
          state.minOrderAmountField,
          state.dishPriceForTwoField,
          state.deliveryTimeField,
          state.emailField,
          state.passwordField,
          state.firstNameField,
          state.lastNameField,
          state.countryCodeField,
          state.mobileNumberField,
          state.latitudeField,
          state.longitudeField,
          state.coverField,
          state.logoField,
        ]),
      ),
    );
  }

  FutureOr<void> _onRestaurantRegisterRequestFoodLicenseUnfocusedEvent(RestaurantRegisterRequestFoodLicenseUnfocusedEvent event, Emitter<RestaurantRegisterRequestState> emit) async {
    final license = RestaurantRegisterRequestFoodLicenseField.dirty(state.licenseField.value);
    emit(
      state.copyWith(
        licenseField: license,
        status: RestaurantRegisterRequestStatus.initial,
        isValid: Formz.validate([
          license,
          state.nameField,
          state.shortDescriptionField,
          state.cuisineField,
          state.typeField,
          state.facilitiesField,
          state.addressField,
          state.minOrderAmountField,
          state.dishPriceForTwoField,
          state.deliveryTimeField,
          state.emailField,
          state.passwordField,
          state.firstNameField,
          state.lastNameField,
          state.countryCodeField,
          state.mobileNumberField,
          state.latitudeField,
          state.longitudeField,
          state.coverField,
          state.logoField,
        ]),
      ),
    );
  }

  FutureOr<void> _onRestaurantRegisterRequestEmailChangedEvent(RestaurantRegisterRequestEmailChangedEvent event, Emitter<RestaurantRegisterRequestState> emit) async {
    final email = RestaurantRegisterRequestEmailField.dirty(event.email);
    emit(
      state.copyWith(
        emailField: email.isValid ? email : RestaurantRegisterRequestEmailField.pure(event.email),
        status: RestaurantRegisterRequestStatus.initial,
        isValid: Formz.validate([
          email,
          state.shortDescriptionField,
          state.nameField,
          state.cuisineField,
          state.typeField,
          state.facilitiesField,
          state.addressField,
          state.minOrderAmountField,
          state.dishPriceForTwoField,
          state.deliveryTimeField,
          state.licenseField,
          state.passwordField,
          state.firstNameField,
          state.lastNameField,
          state.countryCodeField,
          state.mobileNumberField,
          state.latitudeField,
          state.longitudeField,
          state.coverField,
          state.logoField,
        ]),
      ),
    );
  }

  FutureOr<void> _onRestaurantRegisterRequestEmailUnfocusedEvent(RestaurantRegisterRequestEmailUnfocusedEvent event, Emitter<RestaurantRegisterRequestState> emit) async {
    final email = RestaurantRegisterRequestEmailField.dirty(state.emailField.value);
    emit(
      state.copyWith(
        emailField: email,
        status: RestaurantRegisterRequestStatus.initial,
        isValid: Formz.validate([
          email,
          state.nameField,
          state.shortDescriptionField,
          state.cuisineField,
          state.typeField,
          state.facilitiesField,
          state.addressField,
          state.minOrderAmountField,
          state.dishPriceForTwoField,
          state.deliveryTimeField,
          state.licenseField,
          state.passwordField,
          state.firstNameField,
          state.lastNameField,
          state.countryCodeField,
          state.mobileNumberField,
          state.latitudeField,
          state.longitudeField,
          state.coverField,
          state.logoField,
        ]),
      ),
    );
  }

  FutureOr<void> _onRestaurantRegisterRequestPasswordChangedEvent(RestaurantRegisterRequestPasswordChangedEvent event, Emitter<RestaurantRegisterRequestState> emit) async {
    final password = RestaurantRegisterRequestPasswordField.dirty(event.password);
    emit(
      state.copyWith(
        passwordField: password.isValid ? password : RestaurantRegisterRequestPasswordField.pure(event.password),
        status: RestaurantRegisterRequestStatus.initial,
        isValid: Formz.validate([
          password,
          state.shortDescriptionField,
          state.nameField,
          state.cuisineField,
          state.typeField,
          state.facilitiesField,
          state.addressField,
          state.minOrderAmountField,
          state.dishPriceForTwoField,
          state.deliveryTimeField,
          state.licenseField,
          state.emailField,
          state.firstNameField,
          state.lastNameField,
          state.countryCodeField,
          state.mobileNumberField,
          state.latitudeField,
          state.longitudeField,
          state.coverField,
          state.logoField,
        ]),
      ),
    );
  }

  FutureOr<void> _onRestaurantRegisterRequestPasswordUnfocusedEvent(RestaurantRegisterRequestPasswordUnfocusedEvent event, Emitter<RestaurantRegisterRequestState> emit) async {
    final password = RestaurantRegisterRequestPasswordField.dirty(state.passwordField.value);
    emit(
      state.copyWith(
        passwordField: password,
        status: RestaurantRegisterRequestStatus.initial,
        isValid: Formz.validate([
          password,
          state.nameField,
          state.shortDescriptionField,
          state.cuisineField,
          state.typeField,
          state.facilitiesField,
          state.addressField,
          state.minOrderAmountField,
          state.dishPriceForTwoField,
          state.deliveryTimeField,
          state.licenseField,
          state.emailField,
          state.firstNameField,
          state.lastNameField,
          state.countryCodeField,
          state.mobileNumberField,
          state.latitudeField,
          state.longitudeField,
          state.coverField,
          state.logoField,
        ]),
      ),
    );
  }

  FutureOr<void> _onRestaurantRegisterRequestFirstNameChangedEvent(RestaurantRegisterRequestFirstNameChangedEvent event, Emitter<RestaurantRegisterRequestState> emit) async {
    final firstName = RestaurantRegisterRequestFirstNameField.dirty(event.firstName);
    emit(
      state.copyWith(
        firstNameField: firstName.isValid ? firstName : RestaurantRegisterRequestFirstNameField.pure(event.firstName),
        status: RestaurantRegisterRequestStatus.initial,
        isValid: Formz.validate([
          firstName,
          state.shortDescriptionField,
          state.nameField,
          state.cuisineField,
          state.typeField,
          state.facilitiesField,
          state.addressField,
          state.minOrderAmountField,
          state.dishPriceForTwoField,
          state.deliveryTimeField,
          state.licenseField,
          state.emailField,
          state.passwordField,
          state.lastNameField,
          state.countryCodeField,
          state.mobileNumberField,
          state.latitudeField,
          state.longitudeField,
          state.coverField,
          state.logoField,
        ]),
      ),
    );
  }

  FutureOr<void> _onRestaurantRegisterRequestFirstNameUnfocusedEvent(RestaurantRegisterRequestFirstNameUnfocusedEvent event, Emitter<RestaurantRegisterRequestState> emit) async {
    final firstName = RestaurantRegisterRequestFirstNameField.dirty(state.firstNameField.value);
    emit(
      state.copyWith(
        firstNameField: firstName,
        status: RestaurantRegisterRequestStatus.initial,
        isValid: Formz.validate([
          firstName,
          state.nameField,
          state.shortDescriptionField,
          state.cuisineField,
          state.typeField,
          state.facilitiesField,
          state.addressField,
          state.minOrderAmountField,
          state.dishPriceForTwoField,
          state.deliveryTimeField,
          state.licenseField,
          state.emailField,
          state.passwordField,
          state.lastNameField,
          state.countryCodeField,
          state.mobileNumberField,
          state.latitudeField,
          state.longitudeField,
          state.coverField,
          state.logoField,
        ]),
      ),
    );
  }

  FutureOr<void> _onRestaurantRegisterRequestLastNameChangedEvent(RestaurantRegisterRequestLastNameChangedEvent event, Emitter<RestaurantRegisterRequestState> emit) async {
    final lastName = RestaurantRegisterRequestLastNameField.dirty(event.lastName);
    emit(
      state.copyWith(
        lastNameField: lastName.isValid ? lastName : RestaurantRegisterRequestLastNameField.pure(event.lastName),
        status: RestaurantRegisterRequestStatus.initial,
        isValid: Formz.validate([
          lastName,
          state.shortDescriptionField,
          state.nameField,
          state.cuisineField,
          state.typeField,
          state.facilitiesField,
          state.addressField,
          state.minOrderAmountField,
          state.dishPriceForTwoField,
          state.deliveryTimeField,
          state.licenseField,
          state.emailField,
          state.passwordField,
          state.firstNameField,
          state.countryCodeField,
          state.mobileNumberField,
          state.latitudeField,
          state.longitudeField,
          state.coverField,
          state.logoField,
        ]),
      ),
    );
  }

  FutureOr<void> _onRestaurantRegisterRequestLastNameUnfocusedEvent(RestaurantRegisterRequestLastNameUnfocusedEvent event, Emitter<RestaurantRegisterRequestState> emit) async {
    final lastName = RestaurantRegisterRequestLastNameField.dirty(state.lastNameField.value);
    emit(
      state.copyWith(
        lastNameField: lastName,
        status: RestaurantRegisterRequestStatus.initial,
        isValid: Formz.validate([
          lastName,
          state.nameField,
          state.shortDescriptionField,
          state.cuisineField,
          state.typeField,
          state.facilitiesField,
          state.addressField,
          state.minOrderAmountField,
          state.dishPriceForTwoField,
          state.deliveryTimeField,
          state.licenseField,
          state.emailField,
          state.passwordField,
          state.firstNameField,
          state.countryCodeField,
          state.mobileNumberField,
          state.latitudeField,
          state.longitudeField,
          state.coverField,
          state.logoField,
        ]),
      ),
    );
  }

  FutureOr<void> _onRestaurantRegisterRequestCountryCodeChangedEvent(RestaurantRegisterRequestCountryCodeChangedEvent event, Emitter<RestaurantRegisterRequestState> emit) async {
    final countryCode = RestaurantRegisterRequestCountryCodeField.dirty(event.countryCode);
    emit(
      state.copyWith(
        countryCodeField: countryCode.isValid ? countryCode : RestaurantRegisterRequestCountryCodeField.pure(event.countryCode),
        status: RestaurantRegisterRequestStatus.initial,
        isValid: Formz.validate([
          countryCode,
          state.shortDescriptionField,
          state.nameField,
          state.cuisineField,
          state.typeField,
          state.facilitiesField,
          state.addressField,
          state.minOrderAmountField,
          state.dishPriceForTwoField,
          state.deliveryTimeField,
          state.licenseField,
          state.emailField,
          state.passwordField,
          state.firstNameField,
          state.lastNameField,
          state.mobileNumberField,
          state.latitudeField,
          state.longitudeField,
          state.coverField,
          state.logoField,
        ]),
      ),
    );
  }

  FutureOr<void> _onRestaurantRegisterRequestCountryCodeUnfocusedEvent(RestaurantRegisterRequestCountryCodeUnfocusedEvent event, Emitter<RestaurantRegisterRequestState> emit) async {
    final countryCode = RestaurantRegisterRequestCountryCodeField.dirty(state.countryCodeField.value);
    emit(
      state.copyWith(
        countryCodeField: countryCode,
        status: RestaurantRegisterRequestStatus.initial,
        isValid: Formz.validate([
          countryCode,
          state.nameField,
          state.shortDescriptionField,
          state.cuisineField,
          state.typeField,
          state.facilitiesField,
          state.addressField,
          state.minOrderAmountField,
          state.dishPriceForTwoField,
          state.deliveryTimeField,
          state.licenseField,
          state.emailField,
          state.passwordField,
          state.firstNameField,
          state.lastNameField,
          state.mobileNumberField,
          state.latitudeField,
          state.longitudeField,
          state.coverField,
          state.logoField,
        ]),
      ),
    );
  }

  FutureOr<void> _onRestaurantRegisterRequestMobileNumberChangedEvent(RestaurantRegisterRequestMobileNumberChangedEvent event, Emitter<RestaurantRegisterRequestState> emit) async {
    final mobileNumber = RestaurantRegisterRequestMobileNumberField.dirty(event.mobileNumber);
    emit(
      state.copyWith(
        mobileNumberField: mobileNumber.isValid ? mobileNumber : RestaurantRegisterRequestMobileNumberField.pure(event.mobileNumber),
        status: RestaurantRegisterRequestStatus.initial,
        isValid: Formz.validate([
          mobileNumber,
          state.shortDescriptionField,
          state.nameField,
          state.cuisineField,
          state.typeField,
          state.facilitiesField,
          state.addressField,
          state.minOrderAmountField,
          state.dishPriceForTwoField,
          state.deliveryTimeField,
          state.licenseField,
          state.emailField,
          state.passwordField,
          state.firstNameField,
          state.lastNameField,
          state.countryCodeField,
          state.latitudeField,
          state.longitudeField,
          state.coverField,
          state.logoField,
        ]),
      ),
    );
  }

  FutureOr<void> _onRestaurantRegisterRequestMobileNumberUnfocusedEvent(RestaurantRegisterRequestMobileNumberUnfocusedEvent event, Emitter<RestaurantRegisterRequestState> emit) async {
    final mobileNumber = RestaurantRegisterRequestMobileNumberField.dirty(state.mobileNumberField.value);
    emit(
      state.copyWith(
        mobileNumberField: mobileNumber,
        status: RestaurantRegisterRequestStatus.initial,
        isValid: Formz.validate([
          mobileNumber,
          state.nameField,
          state.shortDescriptionField,
          state.cuisineField,
          state.typeField,
          state.facilitiesField,
          state.addressField,
          state.minOrderAmountField,
          state.dishPriceForTwoField,
          state.deliveryTimeField,
          state.licenseField,
          state.emailField,
          state.passwordField,
          state.firstNameField,
          state.lastNameField,
          state.countryCodeField,
          state.latitudeField,
          state.longitudeField,
          state.coverField,
          state.logoField,
        ]),
      ),
    );
  }

  FutureOr<void> _onRestaurantRegisterRequestHomeDeliveryChangeEvent(RestaurantRegisterRequestHomeDeliveryChangeEvent event, Emitter<RestaurantRegisterRequestState> emit) async {
    emit(state.copyWith(homeDelivery: event.option, status: RestaurantRegisterRequestStatus.initial));
  }

  FutureOr<void> _onRestaurantRegisterRequestTakeAwayChangeEvent(RestaurantRegisterRequestTakeAwayChangeEvent event, Emitter<RestaurantRegisterRequestState> emit) async {
    emit(state.copyWith(takeAway: event.option, status: RestaurantRegisterRequestStatus.initial));
  }

  FutureOr<void> _onRestaurantRegisterRequestScheduleOrderChangeEvent(RestaurantRegisterRequestScheduleOrderChangeEvent event, Emitter<RestaurantRegisterRequestState> emit) async {
    emit(state.copyWith(scheduleOrder: event.option, status: RestaurantRegisterRequestStatus.initial));
  }

  FutureOr<void> _onRestaurantRegisterRequestCuisineChangeEvent(RestaurantRegisterRequestCuisineChangeEvent event, Emitter<RestaurantRegisterRequestState> emit) async {
    final cuisine = RestaurantRegisterRequestCuisineField.dirty(event.param.ids!);
    emit(
      state.copyWith(
        cuisineField: cuisine.isValid ? cuisine : RestaurantRegisterRequestCuisineField.pure(event.param.ids!),
        cuisineIds: event.param.ids!,
        cuisineNames: event.param.names!,
        status: RestaurantRegisterRequestStatus.changeDetailFromModal,
        isValid: Formz.validate([
          cuisine,
          state.shortDescriptionField,
          state.nameField,
          state.mobileNumberField,
          state.typeField,
          state.facilitiesField,
          state.addressField,
          state.minOrderAmountField,
          state.dishPriceForTwoField,
          state.deliveryTimeField,
          state.licenseField,
          state.emailField,
          state.passwordField,
          state.firstNameField,
          state.lastNameField,
          state.countryCodeField,
          state.latitudeField,
          state.longitudeField,
          state.coverField,
          state.logoField,
        ]),
      ),
    );
  }

  FutureOr<void> _onRestaurantRegisterRequestCusineUnfocusedEvent(RestaurantRegisterRequestCusineUnfocusedEvent event, Emitter<RestaurantRegisterRequestState> emit) async {
    final cuisineField = RestaurantRegisterRequestCuisineField.dirty(state.cuisineField.value);
    emit(
      state.copyWith(
        cuisineField: cuisineField,
        status: RestaurantRegisterRequestStatus.initial,
        isValid: Formz.validate([
          cuisineField,
          state.nameField,
          state.shortDescriptionField,
          state.mobileNumberField,
          state.typeField,
          state.facilitiesField,
          state.addressField,
          state.minOrderAmountField,
          state.dishPriceForTwoField,
          state.deliveryTimeField,
          state.licenseField,
          state.emailField,
          state.passwordField,
          state.firstNameField,
          state.lastNameField,
          state.countryCodeField,
          state.latitudeField,
          state.longitudeField,
          state.coverField,
          state.logoField,
        ]),
      ),
    );
  }

  FutureOr<void> _onRestaurantRegisterRequestTypeChangeEvent(RestaurantRegisterRequestTypeChangeEvent event, Emitter<RestaurantRegisterRequestState> emit) async {
    final type = RestaurantRegisterRequestTypeField.dirty(event.param.ids!);
    emit(
      state.copyWith(
        typeField: type.isValid ? type : RestaurantRegisterRequestTypeField.pure(event.param.ids!),
        typeIds: event.param.ids!,
        typeName: event.param.names!,
        status: RestaurantRegisterRequestStatus.changeDetailFromModal,
        isValid: Formz.validate([
          type,
          state.shortDescriptionField,
          state.nameField,
          state.mobileNumberField,
          state.cuisineField,
          state.facilitiesField,
          state.addressField,
          state.minOrderAmountField,
          state.dishPriceForTwoField,
          state.deliveryTimeField,
          state.licenseField,
          state.emailField,
          state.passwordField,
          state.firstNameField,
          state.lastNameField,
          state.countryCodeField,
          state.latitudeField,
          state.longitudeField,
          state.coverField,
          state.logoField,
        ]),
      ),
    );
  }

  FutureOr<void> _onRestaurantRegisterRequestTypeUnfocusedEvent(RestaurantRegisterRequestTypeUnfocusedEvent event, Emitter<RestaurantRegisterRequestState> emit) async {
    final typeField = RestaurantRegisterRequestTypeField.dirty(state.typeField.value);
    emit(
      state.copyWith(
        typeField: typeField,
        status: RestaurantRegisterRequestStatus.initial,
        isValid: Formz.validate([
          typeField,
          state.nameField,
          state.shortDescriptionField,
          state.mobileNumberField,
          state.cuisineField,
          state.facilitiesField,
          state.addressField,
          state.minOrderAmountField,
          state.dishPriceForTwoField,
          state.deliveryTimeField,
          state.licenseField,
          state.emailField,
          state.passwordField,
          state.firstNameField,
          state.lastNameField,
          state.countryCodeField,
          state.latitudeField,
          state.longitudeField,
          state.coverField,
          state.logoField,
        ]),
      ),
    );
  }

  FutureOr<void> _onRestaurantRegisterRequestFacilitiesChangeEvent(RestaurantRegisterRequestFacilitiesChangeEvent event, Emitter<RestaurantRegisterRequestState> emit) async {
    final facilities = RestaurantRegisterRequestFacilitiesField.dirty(event.param.ids!);
    emit(
      state.copyWith(
        facilitiesField: facilities.isValid ? facilities : RestaurantRegisterRequestFacilitiesField.pure(event.param.ids!),
        facilitiesIds: event.param.ids!,
        facilitiesName: event.param.names!,
        status: RestaurantRegisterRequestStatus.changeDetailFromModal,
        isValid: Formz.validate([
          facilities,
          state.shortDescriptionField,
          state.nameField,
          state.mobileNumberField,
          state.cuisineField,
          state.typeField,
          state.addressField,
          state.minOrderAmountField,
          state.dishPriceForTwoField,
          state.deliveryTimeField,
          state.licenseField,
          state.emailField,
          state.passwordField,
          state.firstNameField,
          state.lastNameField,
          state.countryCodeField,
          state.latitudeField,
          state.longitudeField,
          state.coverField,
          state.logoField,
        ]),
      ),
    );
  }

  FutureOr<void> _onRestaurantRegisterRequestFacilityUnfocusedEvent(RestaurantRegisterRequestFacilityUnfocusedEvent event, Emitter<RestaurantRegisterRequestState> emit) async {
    final facilityField = RestaurantRegisterRequestFacilitiesField.dirty(state.facilitiesField.value);
    emit(
      state.copyWith(
        facilitiesField: facilityField,
        status: RestaurantRegisterRequestStatus.initial,
        isValid: Formz.validate([
          facilityField,
          state.nameField,
          state.shortDescriptionField,
          state.mobileNumberField,
          state.cuisineField,
          state.typeField,
          state.addressField,
          state.minOrderAmountField,
          state.dishPriceForTwoField,
          state.deliveryTimeField,
          state.licenseField,
          state.emailField,
          state.passwordField,
          state.firstNameField,
          state.lastNameField,
          state.countryCodeField,
          state.latitudeField,
          state.longitudeField,
          state.coverField,
          state.logoField,
        ]),
      ),
    );
  }

  FutureOr<void> _onRestaurantRegisterRequestDeliveryTimeChangeEvent(RestaurantRegisterRequestDeliveryTimeChangeEvent event, Emitter<RestaurantRegisterRequestState> emit) async {
    final deliveryTime = RestaurantRegisterRequestDeliveryTimeField.dirty(event.time);
    emit(
      state.copyWith(
        deliveryTimeField: deliveryTime.isValid ? deliveryTime : RestaurantRegisterRequestDeliveryTimeField.pure(event.time),
        status: RestaurantRegisterRequestStatus.changeDetailFromModal,
        isValid: Formz.validate([
          deliveryTime,
          state.shortDescriptionField,
          state.nameField,
          state.cuisineField,
          state.typeField,
          state.facilitiesField,
          state.addressField,
          state.minOrderAmountField,
          state.dishPriceForTwoField,
          state.mobileNumberField,
          state.licenseField,
          state.emailField,
          state.passwordField,
          state.firstNameField,
          state.lastNameField,
          state.countryCodeField,
          state.latitudeField,
          state.longitudeField,
          state.coverField,
          state.logoField,
        ]),
      ),
    );
  }

  FutureOr<void> _onRestaurantRegisterRequestLicenseChangeEvent(RestaurantRegisterRequestLicenseChangeEvent event, Emitter<RestaurantRegisterRequestState> emit) async {
    emit(state.copyWith(selectedLicense: event.option, status: RestaurantRegisterRequestStatus.initial));
  }

  FutureOr<void> _onRestaurantRegisterRequestCityChangeEvent(RestaurantRegisterRequestCityChangeEvent event, Emitter<RestaurantRegisterRequestState> emit) async {
    try {
      emit(state.copyWith(selectedCity: event.city, status: RestaurantRegisterRequestStatus.localityFetching));
      DioApiResponse response = await _authRepository.localityByCity(event.city.id!);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        final String locale = await _authRepository.getLocale();
        RegisterRequestLocalitiesModel data = RegisterRequestLocalitiesModel.fromJson(myMap, locale.toString());
        if (data.localities!.isNotEmpty) {
          emit(
            state.copyWith(
              latitudeField: RestaurantRegisterRequestLatitudeField.pure(data.localities!.first.location!.coordinates![1].toString()),
              longitudeField: RestaurantRegisterRequestLongitudeField.pure(data.localities!.first.location!.coordinates![0].toString()),
              selectedLocality: data.localities!.first,
              localityList: data.localities!,
              status: RestaurantRegisterRequestStatus.localityFetched,
            ),
          );
        } else {
          final String locale = await _authRepository.getLocale();
          emit(
            state.copyWith(
              latitudeField: RestaurantRegisterRequestLatitudeField.pure(event.city.location!.coordinates![1].toString()),
              longitudeField: RestaurantRegisterRequestLongitudeField.pure(event.city.location!.coordinates![0].toString()),
              selectedLocality: LocalitiesFromCityModel(id: '', name: '', translations: [], locale: locale.toString()),
              localityList: [],
              status: RestaurantRegisterRequestStatus.localityFetched,
            ),
          );
        }
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: RestaurantRegisterRequestStatus.localityFailed, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: RestaurantRegisterRequestStatus.localityFailed, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onRestaurantRegisterRequestLocalityChangeEvent(RestaurantRegisterRequestLocalityChangeEvent event, Emitter<RestaurantRegisterRequestState> emit) async {
    emit(
      state.copyWith(
        selectedLocality: event.locality,
        latitudeField: RestaurantRegisterRequestLatitudeField.pure(event.locality.location!.coordinates![1].toString()),
        longitudeField: RestaurantRegisterRequestLongitudeField.pure(event.locality.location!.coordinates![0].toString()),
        status: RestaurantRegisterRequestStatus.basicFetched,
      ),
    );
  }

  FutureOr<void> _onRestaurantRegisterRequestLocationChangeEvent(RestaurantRegisterRequestLocationChangeEvent event, Emitter<RestaurantRegisterRequestState> emit) async {
    emit(
      state.copyWith(
        latitudeField: RestaurantRegisterRequestLatitudeField.pure(event.latitude.toString()),
        longitudeField: RestaurantRegisterRequestLongitudeField.pure(event.longitude.toString()),
        status: RestaurantRegisterRequestStatus.locationChange,
      ),
    );
  }

  FutureOr<void> _onRestaurantRegisterRequestFormTextInputChangeEvent(RestaurantRegisterRequestFormTextInputChangeEvent event, Emitter<RestaurantRegisterRequestState> emit) async {
    state.formField[event.formIndex].value = event.value;
    emit(state.copyWith(formField: [...state.formField], status: RestaurantRegisterRequestStatus.initial));
  }

  FutureOr<void> _onRestaurantRegisterRequestFormCountryCodeChangeEvent(RestaurantRegisterRequestFormCountryCodeChangeEvent event, Emitter<RestaurantRegisterRequestState> emit) async {
    state.formField[event.formIndex].extraValue = event.value;
    emit(state.copyWith(formField: [...state.formField], status: RestaurantRegisterRequestStatus.initial));
  }

  FutureOr<void> _onRestaurantRegisterRequestFormCheckboxChangeEvent(RestaurantRegisterRequestFormCheckboxChangeEvent event, Emitter<RestaurantRegisterRequestState> emit) async {
    if (state.formField[event.formIndex].type! == 'choose' && state.formField[event.formIndex].items!.isNotEmpty) {
      state.formField[event.formIndex].items![event.checkboxIndex].value = !state.formField[event.formIndex].items![event.checkboxIndex].value!;
      emit(state.copyWith(formField: [...state.formField], status: RestaurantRegisterRequestStatus.initial));
    }
  }

  FutureOr<void> _onRestaurantRegisterRequestUploadImageEvent(RestaurantRegisterRequestUploadImageEvent event, Emitter<RestaurantRegisterRequestState> emit) async {
    try {
      emit(state.copyWith(status: RestaurantRegisterRequestStatus.uploadStarted, uploadingImageTag: event.uploadImageTag, formUploadingImageUUID: event.formUploadingImageUUID));
      DioApiResponse response = await _authRepository.uploadMediaImagePublic(event.newImage, '');
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        UploadImageModel data = UploadImageModel.fromJson(myMap);
        if (event.uploadImageTag == 'logo') {
          final logo = RestaurantRegisterRequestLogoField.dirty(data.path!);
          emit(
            state.copyWith(
              logoField: logo.isValid ? logo : RestaurantRegisterRequestLogoField.pure(data.path!),
              status: RestaurantRegisterRequestStatus.uploadSuccess,
              isValid: Formz.validate([
                logo,
                state.shortDescriptionField,
                state.nameField,
                state.cuisineField,
                state.typeField,
                state.facilitiesField,
                state.addressField,
                state.minOrderAmountField,
                state.dishPriceForTwoField,
                state.deliveryTimeField,
                state.emailField,
                state.passwordField,
                state.firstNameField,
                state.lastNameField,
                state.countryCodeField,
                state.mobileNumberField,
                state.latitudeField,
                state.longitudeField,
                state.coverField,
                state.licenseField,
              ]),
            ),
          );
        } else if (event.uploadImageTag == 'cover') {
          final cover = RestaurantRegisterRequestCoverField.dirty(data.path!);
          emit(
            state.copyWith(
              coverField: cover.isValid ? cover : RestaurantRegisterRequestCoverField.pure(data.path!),
              status: RestaurantRegisterRequestStatus.uploadSuccess,
              isValid: Formz.validate([
                cover,
                state.shortDescriptionField,
                state.nameField,
                state.cuisineField,
                state.typeField,
                state.facilitiesField,
                state.addressField,
                state.minOrderAmountField,
                state.dishPriceForTwoField,
                state.deliveryTimeField,
                state.emailField,
                state.passwordField,
                state.firstNameField,
                state.lastNameField,
                state.countryCodeField,
                state.mobileNumberField,
                state.latitudeField,
                state.longitudeField,
                state.coverField,
                state.logoField,
              ]),
            ),
          );
        } else if (event.uploadImageTag == 'form') {
          state.formField[event.formIndex].value = data.path!;
          emit(state.copyWith(formField: [...state.formField], status: RestaurantRegisterRequestStatus.uploadSuccess));
        }
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: RestaurantRegisterRequestStatus.uploadFailed, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: RestaurantRegisterRequestStatus.uploadFailed, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onRestaurantRegisterRequestOnBackPageEvent(RestaurantRegisterRequestOnBackPageEvent event, Emitter<RestaurantRegisterRequestState> emit) async {
    final int newPageIndex = state.currentPageIndex - 1;
    emit(state.copyWith(currentPageIndex: newPageIndex, status: RestaurantRegisterRequestStatus.backPage));
  }

  FutureOr<void> _onRestaurantRegisterRequestSubmitEvent(RestaurantRegisterRequestSubmitEvent event, Emitter<RestaurantRegisterRequestState> emit) async {
    try {
      emit(state.copyWith(isFormSubmitted: true));
      final int indexOfRequiredField = state.formField.indexWhere((element) => element.isRequired! == true && element.value == '' && element.type! != 'choose');
      final name = RestaurantRegisterRequestNameField.dirty(state.nameField.value);
      final shortDescription = RestaurantRegisterRequestShortDescriptionField.dirty(state.shortDescriptionField.value);
      final address = RestaurantRegisterRequestAddressField.dirty(state.addressField.value);
      final cuisine = RestaurantRegisterRequestCuisineField.dirty(state.cuisineField.value);
      final type = RestaurantRegisterRequestTypeField.dirty(state.typeField.value);
      final facility = RestaurantRegisterRequestFacilitiesField.dirty(state.facilitiesField.value);
      final minOrderAmount = RestaurantRegisterRequestMinOrderAmountField.dirty(state.minOrderAmountField.value);
      final dishForTwo = RestaurantRegisterRequestDishPriceForTwoField.dirty(state.dishPriceForTwoField.value);
      final license = RestaurantRegisterRequestFoodLicenseField.dirty(state.licenseField.value);
      final deliveryTime = RestaurantRegisterRequestDeliveryTimeField.dirty(state.deliveryTimeField.value);
      final email = RestaurantRegisterRequestEmailField.dirty(state.emailField.value);
      final password = RestaurantRegisterRequestPasswordField.dirty(state.passwordField.value);
      final firstName = RestaurantRegisterRequestFirstNameField.dirty(state.firstNameField.value);
      final lastName = RestaurantRegisterRequestLastNameField.dirty(state.lastNameField.value);
      final countryCode = RestaurantRegisterRequestCountryCodeField.dirty(state.countryCodeField.value);
      final mobileNumber = RestaurantRegisterRequestMobileNumberField.dirty(state.mobileNumberField.value);
      final latitude = RestaurantRegisterRequestLatitudeField.dirty(state.latitudeField.value);
      final longitude = RestaurantRegisterRequestLongitudeField.dirty(state.longitudeField.value);
      final cover = RestaurantRegisterRequestCoverField.dirty(state.coverField.value);
      final logo = RestaurantRegisterRequestLogoField.dirty(state.logoField.value);
      emit(
        state.copyWith(
          nameField: name,
          shortDescriptionField: shortDescription,
          addressField: address,
          cuisineField: cuisine,
          typeField: type,
          facilitiesField: facility,
          minOrderAmountField: minOrderAmount,
          dishPriceForTwoField: dishForTwo,
          licenseField: license,
          deliveryTimeField: deliveryTime,
          emailField: email,
          passwordField: password,
          firstNameField: firstName,
          lastNameField: lastName,
          countryCodeField: countryCode,
          mobileNumberField: mobileNumber,
          latitudeField: latitude,
          longitudeField: longitude,
          coverField: cover,
          logoField: logo,
          status: RestaurantRegisterRequestStatus.initial,
          isValid: Formz.validate([
            name,
            shortDescription,
            address,
            cuisine,
            type,
            facility,
            minOrderAmount,
            dishForTwo,
            license,
            deliveryTime,
            email,
            password,
            firstName,
            lastName,
            countryCode,
            mobileNumber,
            latitude,
            longitude,
            cover,
            logo,
          ]),
        ),
      );
      if (state.isValid &&
          state.nameField.value.isNotEmpty &&
          state.shortDescriptionField.value.isNotEmpty &&
          state.addressField.value.isNotEmpty &&
          state.cuisineField.value.isNotEmpty &&
          state.typeField.value.isNotEmpty &&
          state.facilitiesField.value.isNotEmpty &&
          state.minOrderAmountField.value.isNotEmpty &&
          state.dishPriceForTwoField.value.isNotEmpty &&
          state.licenseField.value.isNotEmpty &&
          state.deliveryTimeField.value.isNotEmpty &&
          state.emailField.value.isNotEmpty &&
          state.passwordField.value.isNotEmpty &&
          state.firstNameField.value.isNotEmpty &&
          state.lastNameField.value.isNotEmpty &&
          state.countryCodeField.value.isNotEmpty &&
          state.mobileNumberField.value.isNotEmpty &&
          state.latitudeField.value.isNotEmpty &&
          state.longitudeField.value.isNotEmpty &&
          state.coverField.value.isNotEmpty &&
          state.logoField.value.isNotEmpty &&
          indexOfRequiredField == -1) {
        emit(state.copyWith(status: RestaurantRegisterRequestStatus.submit));
        CheckRestaurantRegisterStatusRequestModel param = CheckRestaurantRegisterStatusRequestModel(
          email: state.emailField.value.toString(),
          countryCode: state.countryCodeField.value.toString(),
          mobile: state.mobileNumberField.value.toString(),
        );
        DioApiResponse response = await _authRepository.checkRegisterStatus(param);
        if (response.errorType == NetErrorType.none) {
          emit(state.copyWith(status: RestaurantRegisterRequestStatus.submitSuccess, translations: event.translations, currentPageIndex: 1));
        } else {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          ServerErrorModel data = ServerErrorModel.fromJson(myMap);
          emit(state.copyWith(status: RestaurantRegisterRequestStatus.customError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
        }
      } else {
        emit(state.copyWith(status: RestaurantRegisterRequestStatus.customError, statusCode: 0, alertMessage: 'Please fill all the required inputs', extraMessage: ''));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: RestaurantRegisterRequestStatus.customError, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onRestaurantRegisterRequestBusinessModelChangeEvent(RestaurantRegisterRequestBusinessModelChangeEvent event, Emitter<RestaurantRegisterRequestState> emit) async {
    emit(state.copyWith(businessModel: event.businessModel, status: RestaurantRegisterRequestStatus.initial));
  }

  FutureOr<void> _onRestaurantRegisterRequestChangeSubscriptionPackageEvent(RestaurantRegisterRequestChangeSubscriptionPackageEvent event, Emitter<RestaurantRegisterRequestState> emit) async {
    final int indexOfSubscriptionId = state.model.subscriptionPackages!.indexWhere((x) => x.id! == event.subscriptionPackage);
    bool haveTrial = false;
    double payAmount = 0.0;
    int trialPeriod = 0;
    if (indexOfSubscriptionId != -1) {
      haveTrial = state.model.subscriptionPackages![indexOfSubscriptionId].haveTrial!;
      trialPeriod = state.model.subscriptionPackages![indexOfSubscriptionId].trialValidity!;
      if (state.model.subscriptionPackages![indexOfSubscriptionId].discount! > 0) {
        payAmount = state.model.subscriptionPackages![indexOfSubscriptionId].offerPrice!;
      } else {
        payAmount = state.model.subscriptionPackages![indexOfSubscriptionId].price!;
      }
    }
    String paymentId = 'trial';
    if (haveTrial == false && state.model.payment!.primary != null && state.model.payment!.primary!.id!.isNotEmpty) {
      paymentId = state.model.payment!.primary!.id!;
    } else if (haveTrial == false && state.model.payment!.payments!.isNotEmpty) {
      paymentId = state.model.payment!.payments![0].id!;
    }
    emit(state.copyWith(selectedPackage: event.subscriptionPackage, haveTrial: haveTrial, paymentId: paymentId, payAmount: payAmount, trialPeriod: trialPeriod, status: RestaurantRegisterRequestStatus.initial));
  }

  FutureOr<void> _onRestaurantRegisterRequestBusinessPlanSelectEvent(RestaurantRegisterRequestBusinessPlanSelectEvent event, Emitter<RestaurantRegisterRequestState> emit) async {
    if (state.businessModel == 'subscription') {
      if (state.selectedPackage.isNotEmpty) {
        emit(state.copyWith(status: RestaurantRegisterRequestStatus.submitSuccess, currentPageIndex: 2));
      } else {
        emit(state.copyWith(statusCode: 0, alertMessage: 'Please select package', extraMessage: '', status: RestaurantRegisterRequestStatus.customError));
      }
    } else {
      add(RestaurantRegisterRequestCreateProfileRequestEvent());
    }
  }

  FutureOr<void> _onRestaurantRegisterRequestChangePaymentMethodEvent(RestaurantRegisterRequestChangePaymentMethodEvent event, Emitter<RestaurantRegisterRequestState> emit) async {
    emit(state.copyWith(paymentId: event.paymentId, status: RestaurantRegisterRequestStatus.initial));
  }

  FutureOr<void> _onRestaurantRegisterRequestSocialLinkChangeEvent(RestaurantRegisterRequestSocialLinkChangeEvent event, Emitter<RestaurantRegisterRequestState> emit) async {
    if (event.type == 'facebook') {
      emit(state.copyWith(socialFacebook: event.value, status: RestaurantRegisterRequestStatus.initial));
    } else if (event.type == 'instagram') {
      emit(state.copyWith(socialInstagram: event.value, status: RestaurantRegisterRequestStatus.initial));
    } else if (event.type == 'x') {
      emit(state.copyWith(socialX: event.value, status: RestaurantRegisterRequestStatus.initial));
    } else if (event.type == 'youtube') {
      emit(state.copyWith(socialYoutube: event.value, status: RestaurantRegisterRequestStatus.initial));
    } else if (event.type == 'linkedin') {
      emit(state.copyWith(socialLinkedIn: event.value, status: RestaurantRegisterRequestStatus.initial));
    } else if (event.type == 'pinterest') {
      emit(state.copyWith(socialPinterest: event.value, status: RestaurantRegisterRequestStatus.initial));
    }
  }

  FutureOr<void> _onRestaurantRegisterRequestCreateProfileRequestEvent(RestaurantRegisterRequestCreateProfileRequestEvent event, Emitter<RestaurantRegisterRequestState> emit) async {
    try {
      List<RestaurantJoiningFormElementModel> filledFormElement = <RestaurantJoiningFormElementModel>[];
      for (var item in state.formField) {
        List<RestaurantJoiningFormElementOptionModel> fieldItemElement = <RestaurantJoiningFormElementOptionModel>[];
        fieldItemElement.clear();
        if (item.type! == 'choose') {
          item.value = item.title!;
          for (var subItem in item.items!) {
            RestaurantJoiningFormElementOptionModel formElementOptionModel = RestaurantJoiningFormElementOptionModel(name: subItem.name!, value: subItem.value!);
            fieldItemElement.add(formElementOptionModel);
          }
        }
        RestaurantJoiningFormElementModel formElementModel = RestaurantJoiningFormElementModel(
          fieldName: item.title!,
          fieldType: item.type!,
          fieldValue: item.type == 'phone' ? '${item.extraValue} ${item.value!}' : item.value!,
          fieldItems: fieldItemElement,
        );
        filledFormElement.add(formElementModel);
      }
      final String appLocale = await _authRepository.getLocale();
      RestaurantJoiningRequestModel param = RestaurantJoiningRequestModel(
        email: state.emailField.value.toString(),
        password: state.passwordField.value.toString(),
        firstName: state.firstNameField.value.toString(),
        lastName: state.lastNameField.value.toString(),
        countryCode: state.countryCodeField.value.toString(),
        mobile: state.mobileNumberField.value.toString(),
        name: state.nameField.value.toString(),
        address: state.addressField.value.toString(),
        shortDescription: state.shortDescriptionField.value.toString(),
        cuisine: state.cuisineField.value.toString(),
        logo: state.logoField.value.toString(),
        cover: state.coverField.value.toString(),
        city: state.selectedCity.id!.isNotEmpty ? state.selectedCity.id! : '',
        locality: state.selectedLocality.id!.isNotEmpty ? state.selectedLocality.id! : '',
        latitude: state.latitudeField.value.toString(),
        longitude: state.longitudeField.value.toString(),
        locationType: 'Point',
        approxDeliveryTime: state.deliveryTimeField.value.toString(),
        dishPriceForTwo: state.dishPriceForTwoField.value.toString(),
        takeAway: state.takeAway.value,
        restaurantType: state.typeField.value.toString(),
        restaurantFacility: state.facilitiesField.value.toString(),
        acceptScheduleDelivery: state.scheduleOrder.value,
        acceptHomeDelivery: state.homeDelivery.value,
        minOrderAmount: state.minOrderAmountField.value.toString(),
        license: state.selectedLicense.id!.isNotEmpty ? state.selectedLicense.id! : '',
        licenseId: state.licenseField.value.toString(),
        businessType: state.businessModel,
        subscriptionId: state.selectedPackage,
        translations: state.translations,
        paymentId: state.paymentId,
        formElement: filledFormElement,
        locale: appLocale,
        socialFacebook: state.socialFacebook,
        socialInstagram: state.socialInstagram,
        socialX: state.socialX,
        socialYoutube: state.socialYoutube,
        socialLinkedIn: state.socialLinkedIn,
        socialPinterest: state.socialPinterest,
      );
      emit(state.copyWith(status: RestaurantRegisterRequestStatus.payment));
      DioApiResponse response = await _authRepository.registerRequest(param);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        RegisterRequestResponseModel registerResponse = RegisterRequestResponseModel.fromJson(myMap);
        if (registerResponse.status == 'offline') {
          emit(state.copyWith(status: RestaurantRegisterRequestStatus.paymentSuccess));
        } else {
          emit(state.copyWith(status: RestaurantRegisterRequestStatus.makePayment, paymentURL: registerResponse.payLink));
        }
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: RestaurantRegisterRequestStatus.customError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: RestaurantRegisterRequestStatus.customError, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }
}

