import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:user/app/presentation/pages/home/@core/business_verticals.dart';
import 'package:user/app/presentation/pages/home/@core/widgets/business_vertical_strip.dart';

void main() {
  testWidgets('renders every vertical and reports taps', (WidgetTester tester) async {
    BusinessVertical? selected;
    const List<BusinessVertical> verticals = <BusinessVertical>[
      BusinessVertical(
        id: BusinessVerticalId.stores,
        label: 'Stores',
        icon: Icons.storefront_outlined,
      ),
      BusinessVertical(
        id: BusinessVerticalId.services,
        label: 'Services',
        icon: Icons.handyman_outlined,
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BusinessVerticalStrip(
            verticals: verticals,
            onSelected: (BusinessVertical vertical) => selected = vertical,
          ),
        ),
      ),
    );

    expect(find.text('Stores'), findsOneWidget);
    expect(find.text('Services'), findsOneWidget);

    await tester.tap(find.text('Services'));
    await tester.pump();

    expect(selected?.id, BusinessVerticalId.services);
  });
}
