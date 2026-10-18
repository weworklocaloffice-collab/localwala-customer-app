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
 * This source code, including all associated assets,
 * APIs, databases, business logic, designs, and
 * documentation, is proprietary to WeWorkLocal.
 *
 * Unauthorized copying, modification, distribution,
 * publication, resale, reverse engineering, or use of
 * this software without prior written authorization is
 * strictly prohibited.
 */

import 'package:user/app/core/config/api_endpoints.dart';
import 'package:user/app/core/config/api_request_service.dart';

/// Customer reels API. Returns raw [DioApiResponse] per repo convention —
/// parsing into [ReelModel] happens in the bloc. Comment listing stays here
/// for the comments bottom-sheet to call directly.
class ReelsRepository {
  final ApiRequestService _api = ApiRequestService();

  Future<DioApiResponse> getFeed({int page = 1, int limit = 10}) async {
    return _api.get(
      '${ApiEndPoints.v1request.reelsFeed}?page=$page&limit=$limit',
    );
  }

  Future<DioApiResponse> toggleLike(String reelId) async {
    return _api.post(ApiEndPoints.v1request.reelLike(reelId));
  }

  Future<DioApiResponse> toggleSave(String reelId) async {
    return _api.post(ApiEndPoints.v1request.reelSave(reelId));
  }

  Future<DioApiResponse> recordShare(String reelId) async {
    return _api.post(ApiEndPoints.v1request.reelShare(reelId));
  }

  Future<DioApiResponse> recordView(
    String reelId, {
    int watchedMs = 0,
    bool completed = false,
  }) async {
    return _api.post(
      ApiEndPoints.v1request.reelView(reelId),
      body: {'watchedMs': watchedMs, 'completed': completed},
    );
  }

  Future<DioApiResponse> addComment(String reelId, String content) async {
    return _api.post(
      ApiEndPoints.v1request.reelComment(reelId),
      body: {'content': content},
    );
  }

  Future<DioApiResponse> getComments(
    String reelId, {
    int page = 1,
    int limit = 10,
  }) async {
    return _api.get(
      '${ApiEndPoints.v1request.reelComments(reelId)}?page=$page&limit=$limit',
    );
  }

  Future<DioApiResponse> reportReel(
    String reelId,
    String reason, {
    String? details,
  }) async {
    return _api.post(
      ApiEndPoints.v1request.reelReport(reelId),
      body: {'reason': reason, 'details': details},
    );
  }
}
