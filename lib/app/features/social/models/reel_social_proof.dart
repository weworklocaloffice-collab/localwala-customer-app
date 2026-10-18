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

/// One matched contact who liked a reel. Arrives embedded in the feed —
/// the app never fetches this per reel.
class SocialProofPerson {
  final String userId;
  final String name;
  final String? avatarUrl;

  const SocialProofPerson({
    required this.userId,
    required this.name,
    this.avatarUrl,
  });

  factory SocialProofPerson.fromJson(Map<String, dynamic> json) {
    return SocialProofPerson(
      userId: json['userId'] as String,
      name: (json['name'] as String?) ?? 'Localwala user',
      avatarUrl: json['avatarUrl'] as String?,
    );
  }
}

/// Token-templated proof sentence shared by every locale. `names` carries the
/// visible people in order; `total` counts every matched liker.
String formatProofText({
  required List<String> names,
  required int total,
  required String one,
  required String two,
  required String manyOne,
  required String manyOther,
}) {
  if (total <= 0 || names.isEmpty) {
    return '';
  }
  if (total == 1) {
    return one.replaceAll('{name}', names.first);
  }
  if (total == 2 && names.length >= 2) {
    return two.replaceAll('{first}', names[0]).replaceAll('{second}', names[1]);
  }
  final first = names[0];
  final second = names.length > 1 ? names[1] : null;
  final others = total - (second == null ? 1 : 2);
  if (second == null || others <= 0) {
    return one.replaceAll('{name}', first);
  }
  final template = others == 1 ? manyOne : manyOther;
  return template
      .replaceAll('{first}', first)
      .replaceAll('{second}', second)
      .replaceAll('{others}', '$others');
}

/// `people` holds at most 3 entries; `total` counts every matched liker.
class ReelSocialProof {
  final List<SocialProofPerson> people;
  final int total;

  const ReelSocialProof({required this.people, required this.total});

  factory ReelSocialProof.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ReelSocialProof(people: [], total: 0);
    final raw = (json['people'] as List?) ?? [];
    return ReelSocialProof(
      people: raw
          .map((e) => SocialProofPerson.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num?)?.toInt() ?? 0,
    );
  }

  /// Subtle one-liner for under the reel. Empty when nobody matched.
  ///
  /// Templates come from the caller so the sentence localizes — token names
  /// are `{name}`, `{first}`, `{second}` and `{others}`.
  String displayText() {
    return formatProofText(
      names: people.map((person) => person.name).toList(),
      total: total,
      one: '{name} liked this',
      two: '{first} and {second} liked this',
      manyOne: '{first}, {second} and 1 other liked this',
      manyOther: '{first}, {second} and {others} others liked this',
    );
  }
}
