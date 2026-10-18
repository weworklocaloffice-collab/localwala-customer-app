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
import 'package:user/app/core/models/api_status_response_model.dart';
import 'package:user/app/core/models/request/update_user_profile_request_model.dart';
import 'package:user/app/core/models/server_error_model.dart';
import 'package:user/app/core/models/upload_image_model.dart';
import 'package:user/app/core/models/user_profile_response_model.dart';
import 'package:user/app/core/repositories/auth_repository.dart';
import 'package:user/app/core/validations/user_profile_form.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

part 'edit_user_profile_event.dart';
part 'edit_user_profile_state.dart';

class EditUserProfileBloc extends Bloc<EditUserProfileEvent, EditUserProfileState> {
  final AuthRepository _authRepository = AuthRepository();
  EditUserProfileBloc()
    : super(
        EditUserProfileState(
          model: UserProfileReponseModel(),
          gender: UserProfileGenderModel(label: '', value: ''),
        ),
      ) {
    on<EditUserProfileInitialEvent>(_onEditUserProfileInitialEvent);
    on<EditUserProfileFirstNameChangedEvent>(_onEditUserProfileFirstNameChangedEvent);
    on<EditUserProfileFirstNameUnfocusedEvent>(_onEditUserProfileFirstNameUnfocusedEvent);
    on<EditUserProfileLastNameChangedEvent>(_onEditUserProfileLastNameChangedEvent);
    on<EditUserProfileLastNameUnfocusedEvent>(_onEditUserProfileLastNameUnfocusedEvent);
    on<EditUserProfileChangeGenderEvent>(_onEditUserProfileChangeGenderEvent);
    on<EditUserProfileAvatarSelectEvent>(_onEditUserProfileAvatarSelectEvent);
    on<EditUserProfileUploadImageEvent>(_onEditUserProfileUploadImageEvent);
    on<EditUserProfileSubmitEvent>(_onEditUserProfileSubmitEvent);
  }

  FutureOr<void> _onEditUserProfileInitialEvent(EditUserProfileInitialEvent event, Emitter<EditUserProfileState> emit) async {
    try {
      final String userId = await _authRepository.userId();
      await _authRepository.saveEvent('visited_screen', {"screen": "update_user_profile"}, 'edit_user_profile_screen', 'edit_user_profile_screen');
      emit(state.copyWith(userId: userId, status: EditUserProfileStatus.loading));
      DioApiResponse response = await _authRepository.getMyProfile(userId.toString());
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ApiStatusResponseModel initialResponse = ApiStatusResponseModel.fromJson(myMap);
        if (!initialResponse.success!) {
          emit(state.copyWith(status: EditUserProfileStatus.failure, statusCode: 0, alertMessage: 'Something went wrong', extraMessage: ''));
        } else {
          UserProfileReponseModel profileResponse = UserProfileReponseModel.fromJson(myMap);
          String flag = '';
          await _authRepository.getCountryList().then((value) {
            final selected = value.firstWhere((element) => element.dialCode == '+${profileResponse.info!.countryCode!}');
            if (selected.dialCode != null && selected.flag != null) {
              flag = selected.flag!;
            }
          });
          final email = UserProfileEmailField.dirty(profileResponse.info!.email!);
          final firstName = UserProfileFirstNameField.dirty(profileResponse.info!.firstName!);
          final lastName = UserProfileLastNameField.dirty(profileResponse.info!.lastName!);
          final countryCode = UserProfileCountryCodeField.dirty('+${profileResponse.info!.countryCode!}');
          final mobile = UserProfileMobileNumberField.dirty(profileResponse.info!.mobile!);
          List<UserProfileGenderModel> genderList = <UserProfileGenderModel>[];
          genderList.clear();
          UserProfileGenderModel male = UserProfileGenderModel(label: 'dd_male', value: 'male');
          UserProfileGenderModel female = UserProfileGenderModel(label: 'dd_female', value: 'female');
          UserProfileGenderModel other = UserProfileGenderModel(label: 'dd_other', value: 'other');
          UserProfileGenderModel notDisclose = UserProfileGenderModel(label: 'dd_prefer_not_disclose', value: 'not-disclose');
          genderList.add(male);
          genderList.add(female);
          genderList.add(other);
          genderList.add(notDisclose);
          UserProfileGenderModel selectedGender = genderList.firstWhere((element) => element.value == profileResponse.info!.gender!);
          emit(
            state.copyWith(
              model: profileResponse,
              email: email.isValid ? email : UserProfileEmailField.pure(profileResponse.info!.email!),
              firstName: firstName.isValid ? firstName : UserProfileFirstNameField.pure(profileResponse.info!.firstName!),
              lastName: lastName.isValid ? lastName : UserProfileLastNameField.pure(profileResponse.info!.lastName!),
              countryCode: countryCode.isValid ? countryCode : UserProfileCountryCodeField.pure('+${profileResponse.info!.countryCode!}'),
              mobile: mobile.isValid ? mobile : UserProfileMobileNumberField.pure(profileResponse.info!.mobile!),
              flag: flag,
              image: profileResponse.info!.image!,
              genderList: genderList,
              gender: selectedGender,
              isValid: Formz.validate([email, firstName, lastName, countryCode, mobile]),
              status: EditUserProfileStatus.success,
            ),
          );
        }
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: EditUserProfileStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: EditUserProfileStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onEditUserProfileFirstNameChangedEvent(EditUserProfileFirstNameChangedEvent event, Emitter<EditUserProfileState> emit) async {
    final firstName = UserProfileFirstNameField.dirty(event.firstName);
    emit(
      state.copyWith(
        firstName: firstName.isValid ? firstName : UserProfileFirstNameField.pure(event.firstName),
        status: EditUserProfileStatus.changeDetail,
        isValid: Formz.validate([firstName, state.email, state.lastName, state.countryCode, state.mobile]),
      ),
    );
  }

  FutureOr<void> _onEditUserProfileFirstNameUnfocusedEvent(EditUserProfileFirstNameUnfocusedEvent event, Emitter<EditUserProfileState> emit) async {
    final firstName = UserProfileFirstNameField.dirty(state.firstName.value);
    emit(state.copyWith(firstName: firstName, status: EditUserProfileStatus.changeDetail, isValid: Formz.validate([firstName, state.email, state.lastName, state.countryCode, state.mobile])));
  }

  FutureOr<void> _onEditUserProfileLastNameChangedEvent(EditUserProfileLastNameChangedEvent event, Emitter<EditUserProfileState> emit) async {
    final lastName = UserProfileLastNameField.dirty(event.lastName);
    emit(
      state.copyWith(
        lastName: lastName.isValid ? lastName : UserProfileLastNameField.pure(event.lastName),
        status: EditUserProfileStatus.changeDetail,
        isValid: Formz.validate([lastName, state.email, state.firstName, state.countryCode, state.mobile]),
      ),
    );
  }

  FutureOr<void> _onEditUserProfileLastNameUnfocusedEvent(EditUserProfileLastNameUnfocusedEvent event, Emitter<EditUserProfileState> emit) async {
    final lastName = UserProfileLastNameField.dirty(state.lastName.value);
    emit(state.copyWith(lastName: lastName, status: EditUserProfileStatus.changeDetail, isValid: Formz.validate([lastName, state.email, state.firstName, state.countryCode, state.mobile])));
  }

  FutureOr<void> _onEditUserProfileChangeGenderEvent(EditUserProfileChangeGenderEvent event, Emitter<EditUserProfileState> emit) async {
    emit(state.copyWith(gender: event.gender, status: EditUserProfileStatus.changeDetail));
  }

  FutureOr<void> _onEditUserProfileAvatarSelectEvent(EditUserProfileAvatarSelectEvent event, Emitter<EditUserProfileState> emit) async {
    emit(state.copyWith(image: event.avatar, status: EditUserProfileStatus.changeDetail));
  }

  FutureOr<void> _onEditUserProfileUploadImageEvent(EditUserProfileUploadImageEvent event, Emitter<EditUserProfileState> emit) async {
    try {
      emit(state.copyWith(status: EditUserProfileStatus.uploadStarted));
      final String userId = await _authRepository.userId();
      DioApiResponse response = await _authRepository.uploadMediaImage(event.newImage, userId);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        UploadImageModel data = UploadImageModel.fromJson(myMap);
        emit(state.copyWith(status: EditUserProfileStatus.uploadSuccess, image: data.path!));
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: EditUserProfileStatus.uploadFailed, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: EditUserProfileStatus.uploadFailed, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onEditUserProfileSubmitEvent(EditUserProfileSubmitEvent event, Emitter<EditUserProfileState> emit) async {
    try {
      final firstName = UserProfileFirstNameField.dirty(state.firstName.value);
      final lastName = UserProfileLastNameField.dirty(state.lastName.value);
      emit(state.copyWith(firstName: firstName, lastName: lastName, status: EditUserProfileStatus.changeDetail, isValid: Formz.validate([firstName, lastName])));
      if (state.isValid && state.firstName.value.isNotEmpty && state.lastName.value.isNotEmpty) {
        emit(state.copyWith(status: EditUserProfileStatus.submit));
        UpdateUserProfileRequestModel param = UpdateUserProfileRequestModel(firstName: state.firstName.value, lastName: state.lastName.value, image: state.image, gender: state.gender.value!);
        DioApiResponse response = await _authRepository.updateMyProfile(state.userId, param);
        if (response.errorType == NetErrorType.none) {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          ApiStatusResponseModel initialResponse = ApiStatusResponseModel.fromJson(myMap);
          if (!initialResponse.success!) {
            emit(state.copyWith(status: EditUserProfileStatus.submitFailed, statusCode: 0, alertMessage: 'Something went wrong', extraMessage: ''));
          } else {
            await _authRepository.updateProfileInfo(state.firstName.value, state.lastName.value, state.image);
            emit(state.copyWith(status: EditUserProfileStatus.submitSuccess));
          }
        } else {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          ServerErrorModel data = ServerErrorModel.fromJson(myMap);
          emit(state.copyWith(status: EditUserProfileStatus.submitFailed, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
        }
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: EditUserProfileStatus.submitFailed, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }
}

