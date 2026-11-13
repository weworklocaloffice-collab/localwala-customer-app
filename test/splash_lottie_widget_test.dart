import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';

void main() {
  testWidgets('Lottie.asset loads and plays splash.json end to end', (WidgetTester tester) async {
    final AnimationController controller = AnimationController(vsync: tester);
    LottieComposition? loaded;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Lottie.asset(
              'assets/jsons/splash.json',
              controller: controller,
              repeat: false,
              fit: BoxFit.contain,
              width: double.infinity,
              onLoaded: (composition) {
                loaded = composition;
                controller
                  ..duration = composition.duration
                  ..forward();
              },
            ),
          ),
        ),
      ),
    );

    expect(loaded, isNotNull, reason: 'onLoaded never fired — asset failed to load');
    expect(loaded!.duration, const Duration(seconds: 6));

    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(controller.status, AnimationStatus.completed, reason: 'animation did not run to completion');
  });
}
