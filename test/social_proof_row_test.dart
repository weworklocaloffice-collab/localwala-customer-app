import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:user/app/features/social/models/reel_social_proof.dart';
import 'package:user/app/features/social/widgets/social_proof_row.dart';
import 'package:user/gen/l10n/app_localizations.dart';

Widget wrap(ReelSocialProof proof) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: SocialProofRow(proof: proof)),
  );
}

void main() {
  testWidgets('renders avatars and text for two likers', (tester) async {
    const proof = ReelSocialProof(
      people: [
        SocialProofPerson(userId: 'u1', name: 'Rahul'),
        SocialProofPerson(userId: 'u2', name: 'Priya'),
      ],
      total: 2,
    );

    await tester.pumpWidget(wrap(proof));

    expect(find.text('Rahul and Priya liked this'), findsOneWidget);
    expect(find.byType(CircleAvatar), findsNWidgets(2));
  });

  testWidgets('renders nothing when there is no proof', (tester) async {
    const proof = ReelSocialProof(people: [], total: 0);

    await tester.pumpWidget(wrap(proof));

    expect(find.byType(Text), findsNothing);
    expect(find.byType(CircleAvatar), findsNothing);
  });

  testWidgets('shows initial fallback for missing avatar urls', (tester) async {
    const proof = ReelSocialProof(
      people: [SocialProofPerson(userId: 'u1', name: 'Rahul')],
      total: 1,
    );

    await tester.pumpWidget(wrap(proof));

    expect(find.text('Rahul liked this'), findsOneWidget);
    expect(find.text('R'), findsOneWidget);
  });
}
