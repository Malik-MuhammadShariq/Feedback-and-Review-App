import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/app_constants.dart';
import '../models/feedback_model.dart';

/// Wraps Firebase Firestore to provide a clean API for feedback operations.
///
/// Key design decisions:
///   - `allFeedbackStream()` uses Firestore's `.snapshots()` for REAL-TIME
///     updates. The admin dashboard subscribes to this stream and instantly
///     sees new feedback without manual refresh.
///   - All timestamps use `FieldValue.serverTimestamp()` for consistent
///     ordering regardless of client clock differences.
class FirestoreService {
  final FirebaseFirestore _firestore;

  /// Constructor allows dependency injection for testing.
  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Reference to the feedback collection.
  CollectionReference<Map<String, dynamic>> get _feedbackCollection =>
      _firestore.collection(CollectionNames.feedback);

  /// Adds a new feedback document to Firestore.
  ///
  /// The [Feedback.toMap()] method sets `timestamp` to a server timestamp,
  /// ensuring accurate ordering in subsequent queries.
  ///
  /// Throws on Firestore write errors.
  Future<void> addFeedback(Feedback feedback) async {
    try {
      await _feedbackCollection.add(feedback.toMap());
    } catch (e) {
      throw Exception('Failed to submit feedback: $e');
    }
  }

  /// Real-time stream of ALL feedback documents, ordered by timestamp descending.
  ///
  /// ⚡ REAL-TIME: Uses Firestore's `.snapshots()` which pushes updates
  /// to all subscribed listeners whenever documents are added, modified,
  /// or deleted. This powers the admin dashboard's live feed — new reviews
  /// appear instantly without pull-to-refresh.
  ///
  /// Returns a stream of `QuerySnapshot` that maps to `List<Feedback>`
  /// in the provider layer.
  Stream<QuerySnapshot<Map<String, dynamic>>> allFeedbackStream() {
    return _feedbackCollection
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  /// Real-time stream of feedback documents for a specific user.
  ///
  /// ⚡ REAL-TIME: Same live-update behavior as [allFeedbackStream],
  /// but filtered to only the current user's submissions. Powers the
  /// user's feedback history screen.
  ///
  /// [userId] — the Firebase Auth UID of the user whose feedback to fetch.
  Stream<QuerySnapshot<Map<String, dynamic>>> userFeedbackStream(
      String userId) {
    return _feedbackCollection
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  /// Calculates the average rating across all feedback documents.
  ///
  /// ⚠️ This is a one-shot fetch (not a stream) because aggregation is
  /// expensive to recompute on every change. The admin dashboard calls
  /// this once on load and again on manual refresh.
  ///
  /// Returns `0.0` if no feedback exists yet.
  /// Returns a `double` rounded to 1 decimal place.
  Future<double> fetchAverageRating() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await _feedbackCollection.get();

      if (snapshot.docs.isEmpty) return 0.0;

      double totalRating = 0;
      int count = 0;

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final rating = (data['rating'] as num?)?.toDouble() ?? 0;
        totalRating += rating;
        count++;
      }

      // Round to 1 decimal place for clean display
      return double.parse((totalRating / count).toStringAsFixed(1));
    } catch (e) {
      // Return 0.0 on error rather than crashing the dashboard
      return 0.0;
    }
  }

  /// Converts a Firestore [QuerySnapshot] into a typed [List<Feedback>].
  ///
  /// Utility method used by providers to transform raw Firestore data
  /// into the app's domain model.
  static List<Feedback> snapshotToList(
      QuerySnapshot<Map<String, dynamic>> snapshot) {
    return snapshot.docs.map((doc) => Feedback.fromFirestore(doc)).toList();
  }
}
