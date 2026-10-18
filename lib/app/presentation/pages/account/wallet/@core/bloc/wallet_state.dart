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

part of 'wallet_bloc.dart';

enum WalletStatus { loading, success, failure, empty, unAuthorized, loadMoreError }

extension WalletStatusX on WalletStatus {
  bool get isLoading => this == WalletStatus.loading;
  bool get isSuccess => this == WalletStatus.success;
  bool get isFailure => this == WalletStatus.failure;
  bool get isEmpty => this == WalletStatus.empty;
  bool get isUnAuthorized => this == WalletStatus.unAuthorized;
  bool get isLoadMoreError => this == WalletStatus.loadMoreError;
}

final class WalletState {
  final WalletInfoModel wallet;
  final String toggleTransaction;
  final int pageSize;
  final int currentPage;
  final bool loadMore;
  final bool isAuthorized;
  final WalletStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const WalletState({
    required this.wallet,
    required this.pageSize,
    this.currentPage = 0,
    this.loadMore = false,
    this.isAuthorized = false,
    this.toggleTransaction = '',
    this.status = WalletStatus.loading,
    this.statusCode = 0,
    this.alertMessage = '',
    this.extraMessage = '',
  });

  WalletState copyWith({WalletInfoModel? wallet, String? toggleTransaction, int? pageSize, int? currentPage, bool? loadMore, bool? isAuthorized, WalletStatus? status, int? statusCode, String? alertMessage, String? extraMessage}) {
    return WalletState(
      wallet: wallet ?? this.wallet,
      toggleTransaction: toggleTransaction ?? this.toggleTransaction,
      pageSize: pageSize ?? this.pageSize,
      currentPage: currentPage ?? this.currentPage,
      loadMore: loadMore ?? this.loadMore,
      isAuthorized: isAuthorized ?? this.isAuthorized,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}

