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
import 'package:user/app/core/repositories/auth_repository.dart';

part 'cache_network_widget_event.dart';
part 'cache_network_widget_state.dart';

class CacheNetworkWidgetBloc extends Bloc<CacheNetworkWidgetEvent, CacheNetworkWidgetState> {
  final AuthRepository _authRepository = AuthRepository();
  CacheNetworkWidgetBloc() : super(const CacheNetworkWidgetState()) {
    on<CachedNetworkImageInitialEvent>(_onCachedNetworkImageInitialEvent);
  }

  FutureOr<void> _onCachedNetworkImageInitialEvent(CachedNetworkImageInitialEvent event, Emitter<CacheNetworkWidgetState> emit) async {
    final String mediaUrl = await _authRepository.getMediaUrl();
    emit(state.copyWith(mediaUrl: mediaUrl));
  }
}

