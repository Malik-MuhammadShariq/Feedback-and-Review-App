/// Form validation helpers shared across auth and feedback forms.
///
/// All methods follow the Flutter form-validation convention:
///   - Return `null` when the value is valid.
///   - Return a user-friendly error string when invalid.
library;

class Validators {
  /// Validates an email address using a standard regex pattern.
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email';
    }
    final RegExp emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validates a password — minimum 6 characters (Firebase Auth requirement).
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  /// Validates a non-empty display name with minimum length.
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your name';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  /// Validates a feedback comment — must be between 5 and 500 characters.
  static String? validateComment(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please write a comment';
    }
    if (value.trim().length < 5) {
      return 'Comment must be at least 5 characters';
    }
    if (value.trim().length > 500) {
      return 'Comment must be under 500 characters';
    }
    return null;
  }
}
