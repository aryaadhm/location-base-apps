import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_village/main.dart';

void main() {
  testWidgets('shows the Smart Village home experience', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const SmartVillageApp());
    await tester.pump();

    expect(find.text('Smart Village'), findsOneWidget);
    expect(find.text('Rumah Sakit'), findsOneWidget);
    expect(find.text('Puskesmas'), findsOneWidget);
    expect(find.text('Klinik'), findsOneWidget);
    expect(find.text('Peta Lokasi'), findsOneWidget);
  });
}
