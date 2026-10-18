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

import 'package:flutter/material.dart';
import 'package:user/app/features/social/models/reel_social_proof.dart';
import 'package:user/gen/l10n/app_localizations.dart';

/// Subtle social-proof line under a reel: up to two overlapping avatars plus
/// the one-liner ("Rahul and Priya liked this"). Renders nothing when nobody
/// the viewer knows liked the reel.
class SocialProofRow extends StatelessWidget {
  final ReelSocialProof proof;
  final TextStyle? textStyle;
  final double avatarRadius;

  const SocialProofRow({
    super.key,
    required this.proof,
    this.textStyle,
    this.avatarRadius = 10,
  });

  /// Localized proof sentence via the generated ICU methods — token
  /// replacement in Dart would duplicate what gen_l10n already does.
  String _localizedText(AppLocalizations translate) {
    final names = proof.people.map((person) => person.name).toList();
    if (proof.total <= 0 || names.isEmpty) {
      return '';
    }
    if (proof.total == 1) {
      return translate.proof_liked_one(names.first);
    }
    if (proof.total == 2 && names.length >= 2) {
      return translate.proof_liked_two(names[0], names[1]);
    }
    final second = names.length > 1 ? names[1] : null;
    final others = proof.total - (second == null ? 1 : 2);
    if (second == null || others <= 0) {
      return translate.proof_liked_one(names.first);
    }
    if (others == 1) {
      return translate.proof_liked_many_one(names[0], second);
    }
    return translate.proof_liked_many_other(names[0], others, second);
  }

  @override
  Widget build(BuildContext context) {
    final translate = AppLocalizations.of(context)!;
    final text = _localizedText(translate);
    if (text.isEmpty) return const SizedBox.shrink();
    final avatars = proof.people.take(2).toList();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (avatars.isNotEmpty)
          SizedBox(
            width: avatarRadius * 2 + (avatars.length - 1) * avatarRadius,
            height: avatarRadius * 2,
            child: Stack(
              children: [
                for (var i = 0; i < avatars.length; i++)
                  Positioned(
                    left: i * avatarRadius,
                    child: _ProofAvatar(
                      person: avatars[i],
                      radius: avatarRadius,
                    ),
                  ),
              ],
            ),
          ),
        if (avatars.isNotEmpty) const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            style: textStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _ProofAvatar extends StatelessWidget {
  final SocialProofPerson person;
  final double radius;

  const _ProofAvatar({required this.person, required this.radius});

  @override
  Widget build(BuildContext context) {
    final url = person.avatarUrl;
    final initial = person.name.isNotEmpty
        ? person.name.characters.first.toUpperCase()
        : '?';
    return CircleAvatar(
      radius: radius,
      backgroundImage: url != null && url.isNotEmpty ? NetworkImage(url) : null,
      child: url == null || url.isEmpty
          ? Text(initial, style: TextStyle(fontSize: radius))
          : null,
    );
  }
}
