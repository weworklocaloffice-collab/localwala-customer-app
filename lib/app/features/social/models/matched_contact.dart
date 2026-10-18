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

/// A registered Localwala user found in the device address book.
/// The phone number itself never crosses the wire — matching is hash-only.
class MatchedContact {
  final String userId;
  final String displayName;
  final String? avatarUrl;

  const MatchedContact({
    required this.userId,
    required this.displayName,
    this.avatarUrl,
  });

  factory MatchedContact.fromJson(Map<String, dynamic> json) {
    return MatchedContact(
      userId: json['userId'] as String,
      displayName: (json['displayName'] as String?) ?? 'Localwala user',
      avatarUrl: json['avatarUrl'] as String?,
    );
  }
}
