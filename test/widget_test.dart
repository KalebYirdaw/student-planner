import 'package:flutter_test/flutter_test.dart';

import 'package:student_planner/app.dart';

void main() {
  testWidgets('Student Planner loads successfully', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const StudentPlannerApp());

    expect(find.text('Student Planner'), findsOneWidget);
  });
}
