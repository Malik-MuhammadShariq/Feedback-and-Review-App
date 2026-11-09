import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a single feedback / review submission.
///
/// Stored in the `feedback` Firestore collection. The [timestamp] field is
/// set server-side via [FieldValue.serverTimestamp] to ensure accurate
/// ordering regardless of the client's local clock.
///
/// ⚠️ Firestore `Timestamp` → Dart `DateTime` conversion:
/// Firestore stores dates as `Timestamp` objects (seconds + nanoseconds
/// since epoch). The `.toDate()` method converts them to Dart `DateTime`.
/// We use a null-safe fallback to `DateTime.now()` in case the field is
/// missing or malformed, preventing runtime crashes.
class Feedback {
  final String id;
  final String userId;
  final String userName;
  final int rating; // 1–5 stars
  final String comment;
  final String category; // Task / Course / Service
  final DateTime timestamp;

  const Feedback({
    required this.id,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.category,
    required this.timestamp,
  });

  /// Creates a [Feedback] from a Firestore document snapshot.
  ///
  /// Handles the `Timestamp` → `DateTime` conversion safely:
  ///   1. Reads the raw `Timestamp?` from the data map.
  ///   2. If non-null, calls `.toDate()` to get a Dart `DateTime`.
  ///   3. If null or on any parsing error, falls back to `DateTime.now()`.
  ///
  /// The `rating` is cast through `num` first because Firestore may return
  /// it as `int` or `double` depending on the platform.
  factory Feedback.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final Map<String, dynamic> data = doc.data() ?? {};

    // Safe Timestamp → DateTime conversion with fallback
    final Timestamp? rawTimestamp = data['timestamp'] as Timestamp?;
    final DateTime parsedTimestamp =
        rawTimestamp?.toDate() ?? DateTime.now();

    return Feedback(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      userName: data['userName'] as String? ?? 'Anonymous',
      rating: (data['rating'] as num?)?.toInt() ?? 0,
      comment: data['comment'] as String? ?? '',
      category: data['category'] as String? ?? 'Task',
      timestamp: parsedTimestamp,
    );
  }

  /// Serializes this feedback to a Firestore-compatible map.
  ///
  /// [timestamp] is set to a server timestamp so Firestore assigns the
  /// authoritative write time — this is critical for correct ordering in
  /// the admin dashboard's real-time stream.
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'rating': rating,
      'comment': comment,
      'category': category,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }

  /// Short label like "4★" for compact display.
  String get ratingLabel => '$rating★';

  @override
  String toString() =>
      'Feedback(id: $id, user: $userName, rating: $rating★, category: $category)';
}
