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

import 'package:user/app/features/social/models/reel_social_proof.dart';

/// Business target behind a reel's CTA. Deep-link wiring (label → app route)
/// belongs to the reel view; the model only carries what the API returns.
class ReelTarget {
  final String type;
  final String? refId;

  const ReelTarget({required this.type, this.refId});

  factory ReelTarget.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ReelTarget(type: '');
    return ReelTarget(
      type: (json['type'] as String?) ?? '',
      refId: json['refId']?.toString(),
    );
  }
}

class ReelCta {
  final String label;
  final bool overridden;

  const ReelCta({required this.label, this.overridden = false});

  factory ReelCta.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ReelCta(label: '');
    return ReelCta(
      label: (json['label'] as String?) ?? '',
      overridden: (json['overridden'] as bool?) ?? false,
    );
  }
}

/// Resolved business info behind `target.refId`, attached by the feed so the
/// app can deep-link without an extra round-trip. Restaurants are opened by
/// slug, foods by id + name.
class ReelTargetSummary {
  final String name;
  final String slug;
  final String image;
  final String restaurantId;
  final double? rating;
  final int? reviewCount;
  final bool? isOpen;
  final double? distanceKm;
  final List<String>? cuisines;
  final int? priceTier;

  const ReelTargetSummary({
    this.name = '',
    this.slug = '',
    this.image = '',
    this.restaurantId = '',
    this.rating,
    this.reviewCount,
    this.isOpen,
    this.distanceKm,
    this.cuisines,
    this.priceTier,
  });

  factory ReelTargetSummary.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ReelTargetSummary();
    return ReelTargetSummary(
      name: (json['name'] as String?) ?? '',
      slug: (json['slug'] as String?) ?? '',
      image: (json['image'] as String?) ?? '',
      restaurantId: (json['restaurantId'] as String?) ?? '',
      rating: (json['rating'] as num?)?.toDouble(),
      reviewCount: (json['reviewCount'] as num?)?.toInt(),
      isOpen: json['isOpen'] as bool?,
      distanceKm: (json['distanceKm'] as num?)?.toDouble(),
      cuisines: json['cuisines'] != null
          ? List<String>.from(json['cuisines'] as List)
          : null,
      priceTier: (json['priceTier'] as num?)?.toInt(),
    );
  }
}

/// One feed item from `GET v1/reels/feed`: reel content plus the embedded
/// social proof — the app never fetches proof per reel.
class ReelModel {
  final String id;
  final String videoUrl;
  final String? thumbnail;
  final String? caption;
  final List<String> hashtags;
  final String? vertical;
  final ReelTarget target;
  final ReelTargetSummary targetSummary;
  final ReelCta cta;
  final int likesCount;
  final int savesCount;
  final int sharesCount;
  final int commentsCount;
  final bool liked;
  final bool saved;
  final ReelSocialProof socialProof;

  const ReelModel({
    required this.id,
    required this.videoUrl,
    this.thumbnail,
    this.caption,
    this.hashtags = const [],
    this.vertical,
    this.target = const ReelTarget(type: ''),
    this.targetSummary = const ReelTargetSummary(),
    this.cta = const ReelCta(label: ''),
    this.likesCount = 0,
    this.savesCount = 0,
    this.sharesCount = 0,
    this.commentsCount = 0,
    this.liked = false,
    this.saved = false,
    this.socialProof = const ReelSocialProof(people: [], total: 0),
  });

  factory ReelModel.fromJson(Map<String, dynamic> json) {
    final rawTags = json['hashtags'];
    return ReelModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      videoUrl: (json['videoUrl'] as String?) ?? '',
      thumbnail:
          (json['thumbnail'] as String?) ??
          (json['media']?['thumbnailUrl'] as String?),
      caption: json['description'] as String? ?? json['caption'] as String?,
      hashtags: rawTags is List
          ? rawTags.map((e) => e.toString()).toList()
          : const [],
      vertical: json['vertical'] as String?,
      target: ReelTarget.fromJson(json['target'] as Map<String, dynamic>?),
      targetSummary: ReelTargetSummary.fromJson(
        json['targetSummary'] as Map<String, dynamic>?,
      ),
      cta: ReelCta.fromJson(json['cta'] as Map<String, dynamic>?),
      likesCount:
          (json['likesCount'] as num?)?.toInt() ??
          (json['likes'] as num?)?.toInt() ??
          0,
      savesCount: (json['saves'] as num?)?.toInt() ?? 0,
      sharesCount: (json['shares'] as num?)?.toInt() ?? 0,
      commentsCount: (json['comments'] as num?)?.toInt() ?? 0,
      socialProof: ReelSocialProof.fromJson(
        json['socialProof'] as Map<String, dynamic>?,
      ),
    );
  }

  ReelModel copyWith({
    int? likesCount,
    int? savesCount,
    int? sharesCount,
    int? commentsCount,
    bool? liked,
    bool? saved,
  }) {
    return ReelModel(
      id: id,
      videoUrl: videoUrl,
      thumbnail: thumbnail,
      caption: caption,
      hashtags: hashtags,
      vertical: vertical,
      target: target,
      targetSummary: targetSummary,
      cta: cta,
      likesCount: likesCount ?? this.likesCount,
      savesCount: savesCount ?? this.savesCount,
      sharesCount: sharesCount ?? this.sharesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      liked: liked ?? this.liked,
      saved: saved ?? this.saved,
      socialProof: socialProof,
    );
  }
}

/// One paginated feed response.
class ReelsFeedPage {
  final List<ReelModel> items;
  final int page;
  final int totalPages;
  final int totalResults;

  /// Set by the API when a signed-out visitor has used up the allowance the admin
  /// configured. The feed is then over, and the app shows a sign-in card rather than
  /// an end-of-scroll or a spinner that would page forever after the cap.
  final bool loginRequired;

  const ReelsFeedPage({
    required this.items,
    required this.page,
    required this.totalPages,
    required this.totalResults,
    this.loginRequired = false,
  });

  factory ReelsFeedPage.fromJson(Map<String, dynamic> json) {
    final raw = (json['results'] as List?) ?? [];
    return ReelsFeedPage(
      items: raw
          .map((e) => ReelModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      page: (json['page'] as num?)?.toInt() ?? 1,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
      totalResults: (json['totalResults'] as num?)?.toInt() ?? 0,
      loginRequired: json['loginRequired'] == true,
    );
  }

  bool get hasMore => page < totalPages;
}
