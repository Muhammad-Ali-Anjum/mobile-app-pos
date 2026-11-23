import 'package:flutter_test/flutter_test.dart';
import 'package:next_planners_pos/main.dart';

void main() {
  testWidgets('Initial screen is Login screen with Super Admin registration policy', (WidgetTester tester) async {
    // Build app
    await tester.pumpWidget(const NextPlannersPosApp());

    // Verify Login Screen appears first
    expect(find.text('Welcome Back!'), findsOneWidget);
    expect(find.text('NEXT PLANNERS'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);

    // Verify registration policy message exists
    expect(find.text('Public registration is closed. All shops are registered and provisioned by the Super Admin.'), findsOneWidget);
  });
}
