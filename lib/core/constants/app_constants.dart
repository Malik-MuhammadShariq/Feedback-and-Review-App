/// App-wide constants: Firestore collection names, feedback categories,
/// user role values, and reusable UI strings.
///
/// Centralized here to avoid scattering magic strings across the codebase.
library;

/// Firestore collection names used throughout the app.
class CollectionNames {
  static const String users = 'users';
  static const String feedback = 'feedback';
}

/// The three categories a user can submit feedback for.
/// Used in dropdowns, model validation, and chart grouping.
class FeedbackCategories {
  static const String task = 'Task';
  static const String course = 'Course';
  static const String service = 'Service';

  /// Ordered list for dropdowns and iteration.
  static const List<String> all = [task, course, service];
}

/// User role values stored in the `users` Firestore document's `role` field.
///
/// After login, the app reads this field dynamically from Firestore to
/// determine routing — no hardcoded UID whitelist needed.
class UserRoles {
  static const String user = 'user';
  static const String admin = 'admin';
}

/// Reusable UI strings and error messages.
class AppStrings {
  static const String appTitle = 'Feedback Review';
  static const String noFeedbackTitle = 'No feedback yet';
  static const String noFeedbackSubtitle =
      'Submitted reviews will appear here in real time.';
  static const String genericError =
      'Something went wrong. Please try again.';
  static const String submitSuccess = 'Feedback submitted successfully!';
  static const String loading = 'Loading...';
}

/// Lottie animation asset paths (must match files in assets/lottie/).
class LottieAssets {
  static const String loading = 'assets/lottie/loading.json';
  static const String success = 'assets/lottie/success.json';
  static const String empty = 'assets/lottie/empty.json';
}
