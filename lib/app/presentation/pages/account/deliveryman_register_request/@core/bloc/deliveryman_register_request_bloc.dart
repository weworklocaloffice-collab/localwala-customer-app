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
import 'package:user/app/core/models/deliveryman_register_request_basic_detail_response_model.dart';
import 'package:user/app/core/models/localities_by_city_model.dart';
import 'package:user/app/core/models/request/deliveryman_joining_request_model.dart';
import 'package:user/app/core/models/server_error_model.dart';
import 'package:user/app/core/models/upload_image_model.dart';
import 'package:user/app/core/models/user_settings_model.dart';
import 'package:user/app/core/repositories/auth_repository.dart';
import 'package:user/app/core/validations/deliveryman_register_request_form.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

part 'deliveryman_register_request_event.dart';
part 'deliveryman_register_request_state.dart';

class DeliverymanRegisterRequestBloc extends Bloc<DeliverymanRegisterRequestEvent, DeliverymanRegisterRequestState> {
  final AuthRepository _authRepository = AuthRepository();
  DeliverymanRegisterRequestBloc()
    : super(
        DeliverymanRegisterRequestState(
          model: DeliverymanRegisterRequestBasicDetailModel(cities: [], vehicles: [], success: false, locale: ''),
          selectedCity: DeliverymanRegisterRequestCitiesModel(locale: ''),
          selectedLocality: LocalitiesFromCityModel(locale: ''),
          selectedVehicle: DeliverymanRegisterRequestVehicleModel(locale: ''),
          identityType: DeliverymanRegisterRequestIdentityTypeModel(label: '', value: ''),
          jobType: DeliverymanRegisterRequestJobTypeModel(label: '', value: ''),
        ),
      ) {
    on<DeliverymanRegisterRequestInitialEvent>(_onDeliverymanRegisterRequestInitialEvent);
    on<DeliverymanRegisterRequestEmailChangedEvent>(_onDeliverymanRegisterRequestEmailChangedEvent);
    on<DeliverymanRegisterRequestEmailUnfocusedEvent>(_onDeliverymanRegisterRequestEmailUnfocusedEvent);
    on<DeliverymanRegisterRequestPasswordChangedEvent>(_onDeliverymanRegisterRequestPasswordChangedEvent);
    on<DeliverymanRegisterRequestPasswordUnfocusedEvent>(_onDeliverymanRegisterRequestPasswordUnfocusedEvent);
    on<DeliverymanRegisterRequestFirstNameChangedEvent>(_onDeliverymanRegisterRequestFirstNameChangedEvent);
    on<DeliverymanRegisterRequestFirstNameUnfocusedEvent>(_onDeliverymanRegisterRequestFirstNameUnfocusedEvent);
    on<DeliverymanRegisterRequestLastNameChangedEvent>(_onDeliverymanRegisterRequestLastNameChangedEvent);
    on<DeliverymanRegisterRequestLastNameUnfocusedEvent>(_onDeliverymanRegisterRequestLastNameUnfocusedEvent);
    on<DeliverymanRegisterRequestCountryCodeChangedEvent>(_onDeliverymanRegisterRequestCountryCodeChangedEvent);
    on<DeliverymanRegisterRequestCountryCodeUnfocusedEvent>(_onDeliverymanRegisterRequestCountryCodeUnfocusedEvent);
    on<DeliverymanRegisterRequestMobileNumberChangedEvent>(_onDeliverymanRegisterRequestMobileNumberChangedEvent);
    on<DeliverymanRegisterRequestMobileNumberUnfocusedEvent>(_onDeliverymanRegisterRequestMobileNumberUnfocusedEvent);
    on<DeliverymanRegisterRequestAgeChangedEvent>(_onDeliverymanRegisterRequestAgeChangedEvent);
    on<DeliverymanRegisterRequestAgeUnfocusedEvent>(_onDeliverymanRegisterRequestAgeUnfocusedEvent);
    on<DeliverymanRegisterRequestDOBChangedEvent>(_onDeliverymanRegisterRequestDOBChangedEvent);
    on<DeliverymanRegisterRequestDOBUnfocusedEvent>(_onDeliverymanRegisterRequestDOBUnfocusedEvent);
    on<DeliverymanRegisterRequestIdentityNumberChangedEvent>(_onDeliverymanRegisterRequestIdentityNumberChangedEvent);
    on<DeliverymanRegisterRequestIdentityNumberUnfocusedEvent>(_onDeliverymanRegisterRequestIdentityNumberUnfocusedEvent);
    on<DeliverymanRegisterRequestJobTypeChangeEvent>(_onDeliverymanRegisterRequestJobTypeChangeEvent);
    on<DeliverymanRegisterRequestIdentityTypeChangeEvent>(_onDeliverymanRegisterRequestIdentityTypeChangeEvent);
    on<DeliverymanRegisterRequestCityChangeEvent>(_onDeliverymanRegisterRequestCityChangeEvent);
    on<DeliverymanRegisterRequestLocalityChangeEvent>(_onDeliverymanRegisterRequestLocalityChangeEvent);
    on<DeliverymanRegisterRequestVehicleChangeEvent>(_onDeliverymanRegisterRequestVehicleChangeEvent);
    on<DeliverymanRegisterRequestUploadImageEvent>(_onDeliverymanRegisterRequestUploadImageEvent);
    on<DeliverymanRegisterRequestFormTextInputChangeEvent>(_onDeliverymanRegisterRequestFormTextInputChangeEvent);
    on<DeliverymanRegisterRequestFormCountryCodeChangeEvent>(_onDeliverymanRegisterRequestFormCountryCodeChangeEvent);
    on<DeliverymanRegisterRequestFormCheckboxChangeEvent>(_onDeliverymanRegisterRequestFormCheckboxChangeEvent);
    on<DeliverymanRegisterRequestSubmitEvent>(_onDeliverymanRegisterRequestSubmitEvent);
  }

  FutureOr<void> _onDeliverymanRegisterRequestInitialEvent(DeliverymanRegisterRequestInitialEvent event, Emitter<DeliverymanRegisterRequestState> emit) async {
    try {
      emit(state.copyWith(status: DeliverymanRegisterRequestStatus.loading));
      await _authRepository.saveEvent('visited_screen', {"screen": "deliveryman_register_request"}, 'deliveryman_register_request_screen', 'deliveryman_register_request_screen');
      DioApiResponse response = await _authRepository.deliverymanGetBasicRegisterRequestDetail();
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        final String locale = await _authRepository.getLocale();
        DeliverymanRegisterRequestBasicDetailModel data = DeliverymanRegisterRequestBasicDetailModel.fromJson(myMap, locale.toString());
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

        List<DeliverymanRegisterRequestCitiesModel> cityList = <DeliverymanRegisterRequestCitiesModel>[];
        cityList.clear();
        for (var element in data.cities!) {
          cityList.add(element);
        }

        if (cityList.isNotEmpty) {
          latitude = cityList.first.location!.coordinates![1].toString();
          longitude = cityList.first.location!.coordinates![0].toString();
        }

        List<DeliverymanRegisterRequestVehicleModel> vehicleList = <DeliverymanRegisterRequestVehicleModel>[];
        vehicleList.clear();
        for (var element in data.vehicles!) {
          vehicleList.add(element);
        }

        List<DeliverymanFormElementConfigModel> formFieldList = <DeliverymanFormElementConfigModel>[];
        formFieldList.clear();
        if (data.joiningForm!.success! == true && data.joiningForm!.result!.deliverymanForm!.isNotEmpty) {
          for (var element in data.joiningForm!.result!.deliverymanForm!) {
            List<DeliverymanFormElementItemConfigModel> checkboxItems = <DeliverymanFormElementItemConfigModel>[];
            checkboxItems.clear();
            if (element.type! == 'choose' && element.items!.isNotEmpty) {
              for (var checkboxItemElement in element.items!) {
                DeliverymanFormElementItemConfigModel checkboxFieldParam = DeliverymanFormElementItemConfigModel(name: checkboxItemElement.name, value: false);
                checkboxItems.add(checkboxFieldParam);
              }
            }
            DeliverymanFormElementConfigModel fieldParam = DeliverymanFormElementConfigModel(
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

        DeliverymanRegisterRequestIdentityTypeModel passportIdentity = DeliverymanRegisterRequestIdentityTypeModel(label: 'dd_passport', value: 'passport');
        DeliverymanRegisterRequestIdentityTypeModel licenseIdentity = DeliverymanRegisterRequestIdentityTypeModel(label: 'dd_driving_license', value: 'license');
        DeliverymanRegisterRequestIdentityTypeModel nicIdentity = DeliverymanRegisterRequestIdentityTypeModel(label: 'dd_nic', value: 'nic');
        List<DeliverymanRegisterRequestIdentityTypeModel> identityTypeListOptions = <DeliverymanRegisterRequestIdentityTypeModel>[];
        identityTypeListOptions.clear();
        identityTypeListOptions.add(passportIdentity);
        identityTypeListOptions.add(licenseIdentity);
        identityTypeListOptions.add(nicIdentity);

        DeliverymanRegisterRequestJobTypeModel freelanceJobType = DeliverymanRegisterRequestJobTypeModel(label: 'dd_freelancer', value: 'freelancer');
        DeliverymanRegisterRequestJobTypeModel salaryJobType = DeliverymanRegisterRequestJobTypeModel(label: 'dd_salary', value: 'salary');
        List<DeliverymanRegisterRequestJobTypeModel> jobTypeListOptions = <DeliverymanRegisterRequestJobTypeModel>[];
        jobTypeListOptions.clear();
        jobTypeListOptions.add(freelanceJobType);
        jobTypeListOptions.add(salaryJobType);

        final countryCode = DeliverymanRegisterRequestCountryCodeField.dirty(defaultCountryCode);
        final latitudeField = DeliverymanRegisterRequestLatitudeField.dirty(latitude);
        final longitudeField = DeliverymanRegisterRequestLongitudeField.dirty(longitude);

        emit(
          state.copyWith(
            model: data,
            countryCodeField: countryCode,
            flag: flag,
            selectedCity: cityList.first,
            cityList: cityList,
            selectedLocality: LocalitiesFromCityModel(id: '', name: '', translations: [], locale: locale.toString()),
            localityList: [],
            latitudeField: latitudeField,
            longitudeField: longitudeField,
            formField: formFieldList,
            identityType: identityTypeListOptions.first,
            identityTypeList: identityTypeListOptions,
            selectedVehicle: vehicleList.first,
            vehicleList: vehicleList,
            jobType: jobTypeListOptions.first,
            jobTypeList: jobTypeListOptions,
            status: DeliverymanRegisterRequestStatus.basicFetched,
          ),
        );

        if (cityList.isNotEmpty) {
          add(DeliverymanRegisterRequestCityChangeEvent(city: cityList.first));
        }
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: DeliverymanRegisterRequestStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: DeliverymanRegisterRequestStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onDeliverymanRegisterRequestEmailChangedEvent(DeliverymanRegisterRequestEmailChangedEvent event, Emitter<DeliverymanRegisterRequestState> emit) async {
    final email = DeliverymanRegisterRequestEmailField.dirty(event.email);
    emit(
      state.copyWith(
        emailField: email.isValid ? email : DeliverymanRegisterRequestEmailField.pure(event.email),
        status: DeliverymanRegisterRequestStatus.initial,
        isValid: Formz.validate([
          email,
          state.passwordField,
          state.firstNameField,
          state.lastNameField,
          state.countryCodeField,
          state.mobileNumberField,
          state.coverImageField,
          state.drivingLicenseField,
          state.identityNumberField,
          state.indentityProofField,
          state.ageField,
          state.dobField,
          state.latitudeField,
          state.longitudeField,
        ]),
      ),
    );
  }

  FutureOr<void> _onDeliverymanRegisterRequestEmailUnfocusedEvent(DeliverymanRegisterRequestEmailUnfocusedEvent event, Emitter<DeliverymanRegisterRequestState> emit) async {
    final email = DeliverymanRegisterRequestEmailField.dirty(state.emailField.value);
    emit(
      state.copyWith(
        emailField: email,
        status: DeliverymanRegisterRequestStatus.initial,
        isValid: Formz.validate([
          email,
          state.passwordField,
          state.firstNameField,
          state.lastNameField,
          state.countryCodeField,
          state.mobileNumberField,
          state.coverImageField,
          state.drivingLicenseField,
          state.identityNumberField,
          state.indentityProofField,
          state.ageField,
          state.dobField,
          state.latitudeField,
          state.longitudeField,
        ]),
      ),
    );
  }

  FutureOr<void> _onDeliverymanRegisterRequestPasswordChangedEvent(DeliverymanRegisterRequestPasswordChangedEvent event, Emitter<DeliverymanRegisterRequestState> emit) async {
    final password = DeliverymanRegisterRequestPasswordField.dirty(event.password);
    emit(
      state.copyWith(
        passwordField: password.isValid ? password : DeliverymanRegisterRequestPasswordField.pure(event.password),
        status: DeliverymanRegisterRequestStatus.initial,
        isValid: Formz.validate([
          password,
          state.emailField,
          state.firstNameField,
          state.lastNameField,
          state.countryCodeField,
          state.mobileNumberField,
          state.coverImageField,
          state.drivingLicenseField,
          state.identityNumberField,
          state.indentityProofField,
          state.ageField,
          state.dobField,
          state.latitudeField,
          state.longitudeField,
        ]),
      ),
    );
  }

  FutureOr<void> _onDeliverymanRegisterRequestPasswordUnfocusedEvent(DeliverymanRegisterRequestPasswordUnfocusedEvent event, Emitter<DeliverymanRegisterRequestState> emit) async {
    final password = DeliverymanRegisterRequestPasswordField.dirty(state.passwordField.value);
    emit(
      state.copyWith(
        passwordField: password,
        status: DeliverymanRegisterRequestStatus.initial,
        isValid: Formz.validate([
          password,
          state.emailField,
          state.firstNameField,
          state.lastNameField,
          state.countryCodeField,
          state.mobileNumberField,
          state.coverImageField,
          state.drivingLicenseField,
          state.identityNumberField,
          state.indentityProofField,
          state.ageField,
          state.dobField,
          state.latitudeField,
          state.longitudeField,
        ]),
      ),
    );
  }

  FutureOr<void> _onDeliverymanRegisterRequestFirstNameChangedEvent(DeliverymanRegisterRequestFirstNameChangedEvent event, Emitter<DeliverymanRegisterRequestState> emit) async {
    final firstName = DeliverymanRegisterRequestFirstNameField.dirty(event.firstName);
    emit(
      state.copyWith(
        firstNameField: firstName.isValid ? firstName : DeliverymanRegisterRequestFirstNameField.pure(event.firstName),
        status: DeliverymanRegisterRequestStatus.initial,
        isValid: Formz.validate([
          firstName,
          state.emailField,
          state.passwordField,
          state.lastNameField,
          state.countryCodeField,
          state.mobileNumberField,
          state.coverImageField,
          state.drivingLicenseField,
          state.identityNumberField,
          state.indentityProofField,
          state.ageField,
          state.dobField,
          state.latitudeField,
          state.longitudeField,
        ]),
      ),
    );
  }

  FutureOr<void> _onDeliverymanRegisterRequestFirstNameUnfocusedEvent(DeliverymanRegisterRequestFirstNameUnfocusedEvent event, Emitter<DeliverymanRegisterRequestState> emit) async {
    final firstName = DeliverymanRegisterRequestFirstNameField.dirty(state.firstNameField.value);
    emit(
      state.copyWith(
        firstNameField: firstName,
        status: DeliverymanRegisterRequestStatus.initial,
        isValid: Formz.validate([
          firstName,
          state.emailField,
          state.passwordField,
          state.lastNameField,
          state.countryCodeField,
          state.mobileNumberField,
          state.coverImageField,
          state.drivingLicenseField,
          state.identityNumberField,
          state.indentityProofField,
          state.ageField,
          state.dobField,
          state.latitudeField,
          state.longitudeField,
        ]),
      ),
    );
  }

  FutureOr<void> _onDeliverymanRegisterRequestLastNameChangedEvent(DeliverymanRegisterRequestLastNameChangedEvent event, Emitter<DeliverymanRegisterRequestState> emit) async {
    final lastName = DeliverymanRegisterRequestLastNameField.dirty(event.lastName);
    emit(
      state.copyWith(
        lastNameField: lastName.isValid ? lastName : DeliverymanRegisterRequestLastNameField.pure(event.lastName),
        status: DeliverymanRegisterRequestStatus.initial,
        isValid: Formz.validate([
          lastName,
          state.emailField,
          state.passwordField,
          state.firstNameField,
          state.countryCodeField,
          state.mobileNumberField,
          state.coverImageField,
          state.drivingLicenseField,
          state.identityNumberField,
          state.indentityProofField,
          state.ageField,
          state.dobField,
          state.latitudeField,
          state.longitudeField,
        ]),
      ),
    );
  }

  FutureOr<void> _onDeliverymanRegisterRequestLastNameUnfocusedEvent(DeliverymanRegisterRequestLastNameUnfocusedEvent event, Emitter<DeliverymanRegisterRequestState> emit) async {
    final lastName = DeliverymanRegisterRequestLastNameField.dirty(state.lastNameField.value);
    emit(
      state.copyWith(
        lastNameField: lastName,
        status: DeliverymanRegisterRequestStatus.initial,
        isValid: Formz.validate([
          lastName,
          state.emailField,
          state.passwordField,
          state.firstNameField,
          state.countryCodeField,
          state.mobileNumberField,
          state.coverImageField,
          state.drivingLicenseField,
          state.identityNumberField,
          state.indentityProofField,
          state.ageField,
          state.dobField,
          state.latitudeField,
          state.longitudeField,
        ]),
      ),
    );
  }

  FutureOr<void> _onDeliverymanRegisterRequestCountryCodeChangedEvent(DeliverymanRegisterRequestCountryCodeChangedEvent event, Emitter<DeliverymanRegisterRequestState> emit) async {
    final countryCode = DeliverymanRegisterRequestCountryCodeField.dirty(event.countryCode);
    emit(
      state.copyWith(
        countryCodeField: countryCode.isValid ? countryCode : DeliverymanRegisterRequestCountryCodeField.pure(event.countryCode),
        status: DeliverymanRegisterRequestStatus.initial,
        isValid: Formz.validate([
          countryCode,
          state.emailField,
          state.passwordField,
          state.firstNameField,
          state.lastNameField,
          state.mobileNumberField,
          state.coverImageField,
          state.drivingLicenseField,
          state.identityNumberField,
          state.indentityProofField,
          state.ageField,
          state.dobField,
          state.latitudeField,
          state.longitudeField,
        ]),
      ),
    );
  }

  FutureOr<void> _onDeliverymanRegisterRequestCountryCodeUnfocusedEvent(DeliverymanRegisterRequestCountryCodeUnfocusedEvent event, Emitter<DeliverymanRegisterRequestState> emit) async {
    final countryCode = DeliverymanRegisterRequestCountryCodeField.dirty(state.countryCodeField.value);
    emit(
      state.copyWith(
        countryCodeField: countryCode,
        status: DeliverymanRegisterRequestStatus.initial,
        isValid: Formz.validate([
          countryCode,
          state.emailField,
          state.passwordField,
          state.firstNameField,
          state.lastNameField,
          state.mobileNumberField,
          state.coverImageField,
          state.drivingLicenseField,
          state.identityNumberField,
          state.indentityProofField,
          state.ageField,
          state.dobField,
          state.latitudeField,
          state.longitudeField,
        ]),
      ),
    );
  }

  FutureOr<void> _onDeliverymanRegisterRequestMobileNumberChangedEvent(DeliverymanRegisterRequestMobileNumberChangedEvent event, Emitter<DeliverymanRegisterRequestState> emit) async {
    final mobileNumber = DeliverymanRegisterRequestMobileNumberField.dirty(event.mobileNumber);
    emit(
      state.copyWith(
        mobileNumberField: mobileNumber.isValid ? mobileNumber : DeliverymanRegisterRequestMobileNumberField.pure(event.mobileNumber),
        status: DeliverymanRegisterRequestStatus.initial,
        isValid: Formz.validate([
          mobileNumber,
          state.emailField,
          state.passwordField,
          state.firstNameField,
          state.lastNameField,
          state.countryCodeField,
          state.coverImageField,
          state.drivingLicenseField,
          state.identityNumberField,
          state.indentityProofField,
          state.ageField,
          state.dobField,
          state.latitudeField,
          state.longitudeField,
        ]),
      ),
    );
  }

  FutureOr<void> _onDeliverymanRegisterRequestMobileNumberUnfocusedEvent(DeliverymanRegisterRequestMobileNumberUnfocusedEvent event, Emitter<DeliverymanRegisterRequestState> emit) async {
    final mobileNumber = DeliverymanRegisterRequestMobileNumberField.dirty(state.mobileNumberField.value);
    emit(
      state.copyWith(
        mobileNumberField: mobileNumber,
        status: DeliverymanRegisterRequestStatus.initial,
        isValid: Formz.validate([
          mobileNumber,
          state.emailField,
          state.passwordField,
          state.firstNameField,
          state.lastNameField,
          state.countryCodeField,
          state.coverImageField,
          state.drivingLicenseField,
          state.identityNumberField,
          state.indentityProofField,
          state.ageField,
          state.dobField,
          state.latitudeField,
          state.longitudeField,
        ]),
      ),
    );
  }

  FutureOr<void> _onDeliverymanRegisterRequestAgeChangedEvent(DeliverymanRegisterRequestAgeChangedEvent event, Emitter<DeliverymanRegisterRequestState> emit) async {
    final age = DeliverymanRegisterRequestAgeField.dirty(event.age);
    emit(
      state.copyWith(
        ageField: age.isValid ? age : DeliverymanRegisterRequestAgeField.pure(event.age),
        status: DeliverymanRegisterRequestStatus.initial,
        isValid: Formz.validate([
          age,
          state.emailField,
          state.passwordField,
          state.firstNameField,
          state.lastNameField,
          state.countryCodeField,
          state.coverImageField,
          state.drivingLicenseField,
          state.identityNumberField,
          state.indentityProofField,
          state.mobileNumberField,
          state.dobField,
          state.latitudeField,
          state.longitudeField,
        ]),
      ),
    );
  }

  FutureOr<void> _onDeliverymanRegisterRequestAgeUnfocusedEvent(DeliverymanRegisterRequestAgeUnfocusedEvent event, Emitter<DeliverymanRegisterRequestState> emit) async {
    final age = DeliverymanRegisterRequestAgeField.dirty(state.ageField.value);
    emit(
      state.copyWith(
        ageField: age,
        status: DeliverymanRegisterRequestStatus.initial,
        isValid: Formz.validate([
          age,
          state.emailField,
          state.passwordField,
          state.firstNameField,
          state.lastNameField,
          state.countryCodeField,
          state.coverImageField,
          state.drivingLicenseField,
          state.identityNumberField,
          state.indentityProofField,
          state.mobileNumberField,
          state.dobField,
          state.latitudeField,
          state.longitudeField,
        ]),
      ),
    );
  }

  FutureOr<void> _onDeliverymanRegisterRequestDOBChangedEvent(DeliverymanRegisterRequestDOBChangedEvent event, Emitter<DeliverymanRegisterRequestState> emit) async {
    final dob = DeliverymanRegisterRequestDOBField.dirty(event.dob);
    emit(
      state.copyWith(
        dobField: dob.isValid ? dob : DeliverymanRegisterRequestDOBField.pure(event.dob),
        status: DeliverymanRegisterRequestStatus.initial,
        isValid: Formz.validate([
          dob,
          state.emailField,
          state.passwordField,
          state.firstNameField,
          state.lastNameField,
          state.countryCodeField,
          state.coverImageField,
          state.drivingLicenseField,
          state.identityNumberField,
          state.indentityProofField,
          state.mobileNumberField,
          state.ageField,
          state.latitudeField,
          state.longitudeField,
        ]),
      ),
    );
  }

  FutureOr<void> _onDeliverymanRegisterRequestDOBUnfocusedEvent(DeliverymanRegisterRequestDOBUnfocusedEvent event, Emitter<DeliverymanRegisterRequestState> emit) async {
    final dob = DeliverymanRegisterRequestDOBField.dirty(state.dobField.value);
    emit(
      state.copyWith(
        dobField: dob,
        status: DeliverymanRegisterRequestStatus.initial,
        isValid: Formz.validate([
          dob,
          state.emailField,
          state.passwordField,
          state.firstNameField,
          state.lastNameField,
          state.countryCodeField,
          state.coverImageField,
          state.drivingLicenseField,
          state.identityNumberField,
          state.indentityProofField,
          state.mobileNumberField,
          state.ageField,
          state.latitudeField,
          state.longitudeField,
        ]),
      ),
    );
  }

  FutureOr<void> _onDeliverymanRegisterRequestIdentityNumberChangedEvent(DeliverymanRegisterRequestIdentityNumberChangedEvent event, Emitter<DeliverymanRegisterRequestState> emit) async {
    final identity = DeliverymanRegisterRequestIdentityNumberField.dirty(event.identity);
    emit(
      state.copyWith(
        identityNumberField: identity.isValid ? identity : DeliverymanRegisterRequestIdentityNumberField.pure(event.identity),
        status: DeliverymanRegisterRequestStatus.initial,
        isValid: Formz.validate([
          identity,
          state.emailField,
          state.passwordField,
          state.firstNameField,
          state.lastNameField,
          state.countryCodeField,
          state.coverImageField,
          state.drivingLicenseField,
          state.dobField,
          state.indentityProofField,
          state.mobileNumberField,
          state.ageField,
          state.latitudeField,
          state.longitudeField,
        ]),
      ),
    );
  }

  FutureOr<void> _onDeliverymanRegisterRequestIdentityNumberUnfocusedEvent(DeliverymanRegisterRequestIdentityNumberUnfocusedEvent event, Emitter<DeliverymanRegisterRequestState> emit) async {
    final identity = DeliverymanRegisterRequestIdentityNumberField.dirty(state.identityNumberField.value);
    emit(
      state.copyWith(
        identityNumberField: identity,
        status: DeliverymanRegisterRequestStatus.initial,
        isValid: Formz.validate([
          identity,
          state.emailField,
          state.passwordField,
          state.firstNameField,
          state.lastNameField,
          state.countryCodeField,
          state.coverImageField,
          state.drivingLicenseField,
          state.dobField,
          state.indentityProofField,
          state.mobileNumberField,
          state.ageField,
          state.latitudeField,
          state.longitudeField,
        ]),
      ),
    );
  }

  FutureOr<void> _onDeliverymanRegisterRequestJobTypeChangeEvent(DeliverymanRegisterRequestJobTypeChangeEvent event, Emitter<DeliverymanRegisterRequestState> emit) async {
    emit(state.copyWith(jobType: event.jobType, status: DeliverymanRegisterRequestStatus.initial));
  }

  FutureOr<void> _onDeliverymanRegisterRequestIdentityTypeChangeEvent(DeliverymanRegisterRequestIdentityTypeChangeEvent event, Emitter<DeliverymanRegisterRequestState> emit) async {
    emit(state.copyWith(identityType: event.identity, status: DeliverymanRegisterRequestStatus.initial));
  }

  FutureOr<void> _onDeliverymanRegisterRequestCityChangeEvent(DeliverymanRegisterRequestCityChangeEvent event, Emitter<DeliverymanRegisterRequestState> emit) async {
    try {
      emit(state.copyWith(selectedCity: event.city, status: DeliverymanRegisterRequestStatus.localityFetching));
      DioApiResponse response = await _authRepository.localityByCity(event.city.id!);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        final String locale = await _authRepository.getLocale();
        RegisterRequestLocalitiesModel data = RegisterRequestLocalitiesModel.fromJson(myMap, locale.toString());
        if (data.localities!.isNotEmpty) {
          emit(
            state.copyWith(
              latitudeField: DeliverymanRegisterRequestLatitudeField.pure(data.localities!.first.location!.coordinates![1].toString()),
              longitudeField: DeliverymanRegisterRequestLongitudeField.pure(data.localities!.first.location!.coordinates![0].toString()),
              selectedLocality: data.localities!.first,
              localityList: data.localities!,
              status: DeliverymanRegisterRequestStatus.localityFetched,
            ),
          );
        } else {
          final String locale = await _authRepository.getLocale();
          emit(
            state.copyWith(
              latitudeField: DeliverymanRegisterRequestLatitudeField.pure(event.city.location!.coordinates![1].toString()),
              longitudeField: DeliverymanRegisterRequestLongitudeField.pure(event.city.location!.coordinates![0].toString()),
              selectedLocality: LocalitiesFromCityModel(id: '', name: '', translations: [], locale: locale.toString()),
              localityList: [],
              status: DeliverymanRegisterRequestStatus.localityFetched,
            ),
          );
        }
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: DeliverymanRegisterRequestStatus.localityFailed, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: DeliverymanRegisterRequestStatus.localityFailed, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onDeliverymanRegisterRequestLocalityChangeEvent(DeliverymanRegisterRequestLocalityChangeEvent event, Emitter<DeliverymanRegisterRequestState> emit) async {
    emit(
      state.copyWith(
        selectedLocality: event.locality,
        latitudeField: DeliverymanRegisterRequestLatitudeField.pure(event.locality.location!.coordinates![1].toString()),
        longitudeField: DeliverymanRegisterRequestLongitudeField.pure(event.locality.location!.coordinates![0].toString()),
        status: DeliverymanRegisterRequestStatus.basicFetched,
      ),
    );
  }

  FutureOr<void> _onDeliverymanRegisterRequestVehicleChangeEvent(DeliverymanRegisterRequestVehicleChangeEvent event, Emitter<DeliverymanRegisterRequestState> emit) async {
    emit(state.copyWith(selectedVehicle: event.vehicle, status: DeliverymanRegisterRequestStatus.initial));
  }

  FutureOr<void> _onDeliverymanRegisterRequestUploadImageEvent(DeliverymanRegisterRequestUploadImageEvent event, Emitter<DeliverymanRegisterRequestState> emit) async {
    try {
      emit(state.copyWith(status: DeliverymanRegisterRequestStatus.uploadStarted, uploadingImageTag: event.uploadImageTag, formUploadingImageUUID: event.formUploadingImageUUID));
      DioApiResponse response = await _authRepository.uploadMediaImagePublic(event.newImage, '');
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        UploadImageModel data = UploadImageModel.fromJson(myMap);
        if (event.uploadImageTag == 'cover') {
          final cover = DeliverymanRegisterRequestCoverField.dirty(data.path!);
          emit(
            state.copyWith(
              coverImageField: cover.isValid ? cover : DeliverymanRegisterRequestCoverField.pure(data.path!),
              status: DeliverymanRegisterRequestStatus.uploadSuccess,
              isValid: Formz.validate([
                cover,
                state.emailField,
                state.passwordField,
                state.firstNameField,
                state.lastNameField,
                state.countryCodeField,
                state.identityNumberField,
                state.drivingLicenseField,
                state.dobField,
                state.indentityProofField,
                state.mobileNumberField,
                state.ageField,
              ]),
            ),
          );
        } else if (event.uploadImageTag == 'identityProof') {
          final identityProof = DeliverymanRegisterRequestIndentityProofField.dirty(data.path!);
          emit(
            state.copyWith(
              indentityProofField: identityProof.isValid ? identityProof : DeliverymanRegisterRequestIndentityProofField.pure(data.path!),
              status: DeliverymanRegisterRequestStatus.uploadSuccess,
              isValid: Formz.validate([
                identityProof,
                state.emailField,
                state.passwordField,
                state.firstNameField,
                state.lastNameField,
                state.countryCodeField,
                state.identityNumberField,
                state.drivingLicenseField,
                state.dobField,
                state.coverImageField,
                state.mobileNumberField,
                state.ageField,
              ]),
            ),
          );
        } else if (event.uploadImageTag == 'license') {
          final drivingLicense = DeliverymanRegisterRequestDrivingLicenseField.dirty(data.path!);
          emit(
            state.copyWith(
              drivingLicenseField: drivingLicense.isValid ? drivingLicense : DeliverymanRegisterRequestDrivingLicenseField.pure(data.path!),
              status: DeliverymanRegisterRequestStatus.uploadSuccess,
              isValid: Formz.validate([
                drivingLicense,
                state.emailField,
                state.passwordField,
                state.firstNameField,
                state.lastNameField,
                state.countryCodeField,
                state.identityNumberField,
                state.indentityProofField,
                state.dobField,
                state.coverImageField,
                state.mobileNumberField,
                state.ageField,
              ]),
            ),
          );
        } else if (event.uploadImageTag == 'form') {
          state.formField[event.formIndex].value = data.path!;
          emit(state.copyWith(formField: [...state.formField], status: DeliverymanRegisterRequestStatus.uploadSuccess));
        }
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: DeliverymanRegisterRequestStatus.uploadFailed, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: DeliverymanRegisterRequestStatus.uploadFailed, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onDeliverymanRegisterRequestFormTextInputChangeEvent(DeliverymanRegisterRequestFormTextInputChangeEvent event, Emitter<DeliverymanRegisterRequestState> emit) async {
    state.formField[event.formIndex].value = event.value;
    emit(state.copyWith(formField: [...state.formField], status: DeliverymanRegisterRequestStatus.initial));
  }

  FutureOr<void> _onDeliverymanRegisterRequestFormCountryCodeChangeEvent(DeliverymanRegisterRequestFormCountryCodeChangeEvent event, Emitter<DeliverymanRegisterRequestState> emit) async {
    state.formField[event.formIndex].extraValue = event.value;
    emit(state.copyWith(formField: [...state.formField], status: DeliverymanRegisterRequestStatus.initial));
  }

  FutureOr<void> _onDeliverymanRegisterRequestFormCheckboxChangeEvent(DeliverymanRegisterRequestFormCheckboxChangeEvent event, Emitter<DeliverymanRegisterRequestState> emit) async {
    if (state.formField[event.formIndex].type! == 'choose' && state.formField[event.formIndex].items!.isNotEmpty) {
      state.formField[event.formIndex].items![event.checkboxIndex].value = !state.formField[event.formIndex].items![event.checkboxIndex].value!;
      emit(state.copyWith(formField: [...state.formField], status: DeliverymanRegisterRequestStatus.initial));
    }
  }

  FutureOr<void> _onDeliverymanRegisterRequestSubmitEvent(DeliverymanRegisterRequestSubmitEvent event, Emitter<DeliverymanRegisterRequestState> emit) async {
    try {
      emit(state.copyWith(isFormSubmitted: true));
      final int indexOfRequiredField = state.formField.indexWhere((element) => element.isRequired! == true && element.value == '' && element.type! != 'choose');
      final email = DeliverymanRegisterRequestEmailField.dirty(state.emailField.value);
      final password = DeliverymanRegisterRequestPasswordField.dirty(state.passwordField.value);
      final firstName = DeliverymanRegisterRequestFirstNameField.dirty(state.firstNameField.value);
      final lastName = DeliverymanRegisterRequestLastNameField.dirty(state.lastNameField.value);
      final countryCode = DeliverymanRegisterRequestCountryCodeField.dirty(state.countryCodeField.value);
      final mobileNumber = DeliverymanRegisterRequestMobileNumberField.dirty(state.mobileNumberField.value);
      final cover = DeliverymanRegisterRequestCoverField.dirty(state.coverImageField.value);
      final identityProof = DeliverymanRegisterRequestIndentityProofField.dirty(state.indentityProofField.value);
      final age = DeliverymanRegisterRequestAgeField.dirty(state.ageField.value);
      final dob = DeliverymanRegisterRequestDOBField.dirty(state.dobField.value);
      final identityNumber = DeliverymanRegisterRequestIdentityNumberField.dirty(state.identityNumberField.value);
      final drivingLicense = DeliverymanRegisterRequestDrivingLicenseField.dirty(state.drivingLicenseField.value);
      final latitude = DeliverymanRegisterRequestLatitudeField.dirty(state.latitudeField.value);
      final longitude = DeliverymanRegisterRequestLongitudeField.dirty(state.longitudeField.value);
      emit(
        state.copyWith(
          emailField: email,
          passwordField: password,
          firstNameField: firstName,
          lastNameField: lastName,
          countryCodeField: countryCode,
          mobileNumberField: mobileNumber,
          coverImageField: cover,
          indentityProofField: identityProof,
          ageField: age,
          dobField: dob,
          identityNumberField: identityNumber,
          drivingLicenseField: drivingLicense,
          latitudeField: latitude,
          longitudeField: longitude,
          status: DeliverymanRegisterRequestStatus.initial,
          isValid: Formz.validate([email, password, firstName, lastName, countryCode, mobileNumber, cover, identityProof, age, dob, identityNumber, drivingLicense, latitude, longitude]),
        ),
      );
      if (state.isValid &&
          state.emailField.value.isNotEmpty &&
          state.passwordField.value.isNotEmpty &&
          state.firstNameField.value.isNotEmpty &&
          state.lastNameField.value.isNotEmpty &&
          state.countryCodeField.value.isNotEmpty &&
          state.mobileNumberField.value.isNotEmpty &&
          state.coverImageField.value.isNotEmpty &&
          state.indentityProofField.value.isNotEmpty &&
          state.ageField.value.isNotEmpty &&
          state.dobField.value.isNotEmpty &&
          state.identityNumberField.value.isNotEmpty &&
          state.drivingLicenseField.value.isNotEmpty &&
          state.latitudeField.value.isNotEmpty &&
          state.longitudeField.value.isNotEmpty &&
          indexOfRequiredField == -1) {
        List<DeliverymanJoiningFormElementModel> filledFormElement = <DeliverymanJoiningFormElementModel>[];
        for (var item in state.formField) {
          List<DeliverymanJoiningFormElementOptionModel> fieldItemElement = <DeliverymanJoiningFormElementOptionModel>[];
          fieldItemElement.clear();
          if (item.type! == 'choose') {
            item.value = item.title!;
            for (var subItem in item.items!) {
              DeliverymanJoiningFormElementOptionModel formElementOptionModel = DeliverymanJoiningFormElementOptionModel(name: subItem.name!, value: subItem.value!);
              fieldItemElement.add(formElementOptionModel);
            }
          }
          DeliverymanJoiningFormElementModel formElementModel = DeliverymanJoiningFormElementModel(
            fieldName: item.title!,
            fieldType: item.type!,
            fieldValue: item.type == 'phone' ? '${item.extraValue} ${item.value!}' : item.value!,
            fieldItems: fieldItemElement,
          );
          filledFormElement.add(formElementModel);
        }
        final String appLocale = await _authRepository.getLocale();
        DeliverymanJoiningRequestModel param = DeliverymanJoiningRequestModel(
          email: state.emailField.value.toString(),
          password: state.passwordField.value.toString(),
          firstName: state.firstNameField.value.toString(),
          lastName: state.lastNameField.value.toString(),
          countryCode: state.countryCodeField.value.toString(),
          mobile: state.mobileNumberField.value.toString(),
          city: state.selectedCity.id!.isNotEmpty ? state.selectedCity.id! : '',
          locality: state.selectedLocality.id!.isNotEmpty ? state.selectedLocality.id! : '',
          latitude: state.latitudeField.value.toString(),
          longitude: state.longitudeField.value.toString(),
          vehicle: state.selectedVehicle.id!.isNotEmpty ? state.selectedVehicle.id! : '',
          cover: state.coverImageField.value.toString(),
          age: state.ageField.value.toString(),
          dob: state.dobField.value.toString(),
          type: state.jobType.value.toString(),
          identity: state.identityType.value.toString(),
          identityNumber: state.identityNumberField.value.toString(),
          identityProof: state.indentityProofField.value.toString(),
          drivingLicense: state.drivingLicenseField.value.toString(),
          locationType: 'Point',
          formElement: filledFormElement,
          locale: appLocale,
        );
        emit(state.copyWith(status: DeliverymanRegisterRequestStatus.submit));
        DioApiResponse response = await _authRepository.delivermanJoiningRequest(param);
        if (response.errorType == NetErrorType.none) {
          emit(state.copyWith(status: DeliverymanRegisterRequestStatus.submitSuccess));
        } else {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          ServerErrorModel data = ServerErrorModel.fromJson(myMap);
          emit(state.copyWith(status: DeliverymanRegisterRequestStatus.customError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
        }
      } else {
        emit(state.copyWith(status: DeliverymanRegisterRequestStatus.customError, statusCode: 0, alertMessage: 'Please fill all the required inputs', extraMessage: ''));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: DeliverymanRegisterRequestStatus.customError, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }
}

