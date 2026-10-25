import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:user/app/core/models/real_estate_property_model.dart';
import 'package:user/app/presentation/pages/real_estate/widgets/categories_section.dart';
import 'package:user/gen/l10n/app_localizations.dart';

void main() {
  testWidgets('shows localized group labels instead of backend keys', (
    WidgetTester tester,
  ) async {
    String? selectedKey;
    final groups = CategoryGroups(
      byGroup: {
        'APARTMENT': const [
          GroupedCategory(key: 'APARTMENT', name: 'Apartments'),
        ],
        'PLOT': const [GroupedCategory(key: 'PLOT', name: 'Plots')],
        'COMMERCIAL': const [
          GroupedCategory(key: 'COMMERCIAL_OFFICE', name: 'Office'),
          GroupedCategory(key: 'COMMERCIAL_SHOP', name: 'Shop'),
          GroupedCategory(key: 'COMMERCIAL_SHOWROOM', name: 'Showroom'),
          GroupedCategory(key: 'COMMERCIAL_WAREHOUSE', name: 'Warehouse'),
          GroupedCategory(key: 'COMMERCIAL_LAND', name: 'Commercial Land'),
        ],
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(
          body: SingleChildScrollView(
            child: CategoriesSection(
              isLoading: false,
              error: null,
              groups: groups,
              onCategorySelected: (key, _) => selectedKey = key,
              onGroupHeaderTapped: (_, _) {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('Apartments'), findsOneWidget);
    expect(find.text('Plots'), findsOneWidget);
    expect(find.text('Commercial'), findsOneWidget);
    expect(find.text('APARTMENT'), findsNothing);
    expect(find.text('COMMERCIAL'), findsNothing);
    expect(find.text('+1 more'), findsOneWidget);
    expect(find.text('Commercial Land'), findsNothing);

    await tester.tap(find.text('Apartments'));
    expect(selectedKey, 'APARTMENT');
  });
}
