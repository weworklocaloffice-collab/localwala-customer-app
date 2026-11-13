import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('splash.json parses with the lottie package', () async {
    final ByteData data = await rootBundle.load('assets/jsons/splash.json');
    final LottieComposition composition = await LottieComposition.fromByteData(data);
    // ignore: avoid_print
    print('SIZE: ${composition.bounds}');
    // ignore: avoid_print
    print('DURATION: ${composition.duration}');
    // ignore: avoid_print
    print('FPS: ${composition.frameRate}');
    // ignore: avoid_print
    print('WARNINGS (${composition.warnings.length}):');
    for (final String w in composition.warnings) {
      // ignore: avoid_print
      print('  - $w');
    }
    expect(composition.duration, greaterThan(Duration.zero));
  });
}
