import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:feedback_review_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build the app wrapped in ProviderScope and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(child: FeedbackReviewApp()),
    );
    await tester.pump();
    // Verify that the app renders without crashing.
    expect(find.byType(FeedbackReviewApp), findsOneWidget);
  });
}
