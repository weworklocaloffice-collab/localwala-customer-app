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

part of 'products_review_bloc.dart';

enum ProductsReviewStatus { loading, empty, success, failure, customError }

extension ProductsReviewStatusX on ProductsReviewStatus {
  bool get isLoading => this == ProductsReviewStatus.loading;
  bool get isEmpty => this == ProductsReviewStatus.empty;
  bool get isSuccess => this == ProductsReviewStatus.success;
  bool get isFailure => this == ProductsReviewStatus.failure;
  bool get isCustomError => this == ProductsReviewStatus.customError;
}

final class ProductsReviewState {
  final String id;
  final String name;
  final String ratings;
  final FoodReviewsResponseModel detail;
  final int pageSize;
  final int currentPage;
  final bool loadMore;
  final ProductsReviewStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const ProductsReviewState({
    this.id = '',
    this.name = '',
    this.ratings = '0.0',
    required this.detail,
    required this.pageSize,
    this.currentPage = 0,
    this.loadMore = false,
    this.status = ProductsReviewStatus.loading,
    this.statusCode = 0,
    this.alertMessage = '',
    this.extraMessage = '',
  });

  ProductsReviewState copyWith({
    String? id,
    String? name,
    String? ratings,
    FoodReviewsResponseModel? detail,
    int? pageSize,
    int? currentPage,
    bool? loadMore,
    ProductsReviewStatus? status,
    int? statusCode,
    String? alertMessage,
    String? extraMessage,
  }) {
    return ProductsReviewState(
      id: id ?? this.id,
      name: name ?? this.name,
      ratings: ratings ?? this.ratings,
      detail: detail ?? this.detail,
      pageSize: pageSize ?? this.pageSize,
      currentPage: currentPage ?? this.currentPage,
      loadMore: loadMore ?? this.loadMore,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}

