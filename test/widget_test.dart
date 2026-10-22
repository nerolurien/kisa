import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kipit_apk/core/utils/haversine.dart';
import 'package:kipit_apk/core/theme/app_colors.dart';
import 'package:kipit_apk/core/widgets/bouncy_button.dart';

void main() {
  test('Haversine distance calculates correctly between coordinates', () {
    // Jakarta center to Bandung center (~117 km)
    final distance = KisaHaversine.calculateDistanceKm(
      lat1: -6.2088,
      lon1: 106.8456,
      lat2: -6.9175,
      lon2: 107.6191,
    );

    expect(distance, greaterThan(100.0));
    expect(distance, lessThan(130.0));

    final text = KisaHaversine.formatPartnerDistance(4.2, 'Fexa');
    expect(text, 'Fexa berjarak 4.2 km dari lokasimu');
  });

  testWidgets('BouncyButton renders and taps properly', (WidgetTester tester) async {
    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: BouncyButton(
              label: 'Sentuh Aku',
              onTap: () => tapped = true,
              backgroundColor: KisaColors.primaryRose,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Sentuh Aku'), findsOneWidget);
    await tester.tap(find.text('Sentuh Aku'));
    await tester.pumpAndSettle();
    expect(tapped, isTrue);
  });
}
