import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vital_arm_band_monitor/main.dart';

void main() {
  testWidgets('sign in opens the vital overview', (tester) async {
    await tester.pumpWidget(const VitalBandApp());

    await tester.enterText(
      find.byKey(const Key('signin-email')),
      'alex@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('signin-password')),
      'password',
    );
    await tester.scrollUntilVisible(
      find.text('Sign in'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Vital signs'), findsOneWidget);
    expect(find.text('72'), findsOneWidget);
    expect(find.text('97'), findsOneWidget);
    expect(find.text('Location & movement'), findsOneWidget);
  });

  testWidgets('sign-up supports fitness role and optional device pairing', (
    tester,
  ) async {
    await tester.pumpWidget(const VitalBandApp());
    await tester.scrollUntilVisible(
      find.text('Create account'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();

    expect(find.text('Caregiver'), findsOneWidget);
    expect(find.text('Fitness tracking'), findsOneWidget);
    expect(find.text('Relative'), findsOneWidget);
    expect(find.text('Personal health'), findsOneWidget);

    await tester.tap(find.byKey(const Key('role-fitness')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Create your account'), findsOneWidget);
    expect(find.byKey(const Key('signup-name')), findsOneWidget);
    expect(find.byKey(const Key('signup-email')), findsOneWidget);
    expect(find.byKey(const Key('signup-password')), findsOneWidget);
    await tester.enterText(find.byKey(const Key('signup-name')), 'Taylor Reed');
    await tester.enterText(
      find.byKey(const Key('signup-email')),
      'taylor@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('signup-password')),
      'securepass',
    );
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Pair your band'), findsOneWidget);
    await tester.tap(find.text('Enter demo app'));
    await tester.pumpAndSettle();
    expect(find.text('Activity'), findsOneWidget);
    expect(find.text('Your vital signs'), findsOneWidget);
  });
}
