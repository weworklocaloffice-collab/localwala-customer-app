/*
 * WeWorkLocal
 * Hyperlocal Commerce, Delivery & Service Platform
 *
 * Copyright © 2026 WeWorkLocal.
 * All Rights Reserved.
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

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Every Dart source file must be valid UTF-8.
///
/// This guards a failure mode that is completely invisible until it is catastrophic.
///
/// `support_chat_view.dart` contained exactly ONE corrupt byte — `0x97`, a Windows-1252
/// em dash pasted into a doc comment — and the consequences were wildly out of proportion
/// to its size:
///
///   * `flutter analyze` reported `Target of URI doesn't exist` for that file. Not "invalid
///     encoding": NONEXISTENT. The analyzer silently drops a file it cannot decode, so the
///     error points at the *importing* line and lies about the cause.
///   * `app_route_config.dart` imports it, and roughly ninety other screens import
///     `app_route_config.dart`, so the whole application reported broken imports.
///   * `flutter build apk` SUCCEEDED throughout. The compiler and the analyzer disagree
///     about undecodable input, so the app shipped "green" while the analyzer screamed.
///     That disagreement is what made this look like a harmless analyzer false positive
///     for a long time — the strongest possible signal to stop assuming and go looking.
///   * A repo-wide search then found the truth in one step, where the compiler had not
///     pointed at it at all.
///
/// The cost of a single bad byte was a codebase that would not analyse. So this is checked
/// mechanically rather than left to whoever next pastes a smart quote from a PDF.
void main() {
  test('every Dart file in lib/ and test/ is valid UTF-8', () {
    final List<String> invalid = <String>[];

    for (final String dir in <String>['lib', 'test']) {
      final Directory root = Directory(dir);
      if (!root.existsSync()) continue;

      for (final FileSystemEntity entity in root.listSync(recursive: true)) {
        // `-File` deliberately: there is a DIRECTORY in this tree whose name ends in
        // `.dart`, and reading it as bytes throws, which would look exactly like a
        // corrupt file and send you hunting for a byte that is not there.
        if (entity is! File) continue;
        if (!entity.path.endsWith('.dart')) continue;

        final List<int> bytes = entity.readAsBytesSync();
        try {
          // `allowMalformed: false` makes the decoder throw instead of substituting
          // U+FFFD, which is the entire point — a lenient decode would pass this file.
          const Utf8Decoder decoder = Utf8Decoder(allowMalformed: false);
          decoder.convert(bytes);
        } on FormatException catch (e) {
          invalid.add('${entity.path} -> ${e.message}');
        }
      }
    }

    expect(
      invalid,
      isEmpty,
      reason: 'these files are not valid UTF-8, so the Dart analyzer treats them as '
          'NONEXISTENT and every file importing them reports a broken import, while '
          '`flutter build` may still succeed. Re-save them as UTF-8:\n'
          '${invalid.join('\n')}',
    );
  });

  test('the check actually detects a corrupt file', () {
    // A guard that cannot fail is worse than none — it is read as coverage. This builds
    // the exact shape that caused the outage and proves the decoder rejects it.
    const List<int> good = <int>[0x2F, 0x2F, 0x20, 0xE2, 0x80, 0x94, 0x0A]; // "// —\n"
    const List<int> bad = <int>[0x2F, 0x2F, 0x20, 0x97, 0x0A]; // "// \x97\n"

    expect(() => const Utf8Decoder(allowMalformed: false).convert(good), returnsNormally);
    expect(
      () => const Utf8Decoder(allowMalformed: false).convert(bad),
      throwsA(isA<FormatException>()),
    );
  });
}