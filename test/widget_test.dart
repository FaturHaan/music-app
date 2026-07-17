import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_app/core/constants/app_constants.dart';
import 'package:music_app/features/library/widgets/source_badge.dart';

void main() {
  group('SourceBadge Widget Tests', () {
    testWidgets('Renders Local source badge correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: SourceBadge(source: AppConstants.sourceLocal),
        ),
      ));

      expect(find.text('Local'), findsOneWidget);
      expect(find.byIcon(Icons.sd_storage), findsOneWidget);
    });

    testWidgets('Renders SoundCloud source badge correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: SourceBadge(source: AppConstants.sourceSoundcloud),
        ),
      ));

      expect(find.text('SoundCloud'), findsOneWidget);
      expect(find.byIcon(Icons.cloud), findsOneWidget);
    });

    testWidgets('Renders iTunes source badge correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: SourceBadge(source: AppConstants.sourceItunes),
        ),
      ));

      expect(find.text('iTunes'), findsOneWidget);
      expect(find.byIcon(Icons.library_music), findsOneWidget);
    });
  });
}
