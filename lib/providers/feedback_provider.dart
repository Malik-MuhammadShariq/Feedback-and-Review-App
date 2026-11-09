import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/feedback_model.dart';
import '../services/firestore_service.dart';

/// ─────────────────────────────────────────────────────────────
/// Service Provider
/// ─────────────────────────────────────────────────────────────
/// Exposes a singleton [FirestoreService] instance to the widget tree.
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

/// ─────────────────────────────────────────────────────────────
/// All Feedback Stream Provider (REAL-TIME)
/// ─────────────────────────────────────────────────────────────
/// ⚡ REAL-TIME SYNC: Uses Riverpod's [StreamProvider] backed by Firestore's
/// `.snapshots()` method. When any feedback document is added, modified,
/// or deleted, this provider automatically emits the updated list.
///
/// This powers the admin dashboard's live feedback feed — new reviews
/// appear instantly without pull-to-refresh.
///
/// Emits `AsyncValue<List<Feedback>>`:
///   - `AsyncData(List<Feedback>)` — the current list of all feedback
///   - `AsyncLoading` — while waiting for the first snapshot
///   - `AsyncError` — on Firestore errors
final allFeedbackProvider =
    StreamProvider<List<Feedback>>((ref) {
  final FirestoreService firestoreService =
      ref.watch(firestoreServiceProvider);

  // Transform the raw QuerySnapshot stream into a typed List<Feedback>
  return firestoreService.allFeedbackStream().map(
        (QuerySnapshot<Map<String, dynamic>> snapshot) =>
            FirestoreService.snapshotToList(snapshot),
      );
});

/// ─────────────────────────────────────────────────────────────
/// User-Specific Feedback Stream Provider (REAL-TIME)
/// ─────────────────────────────────────────────────────────────
/// ⚡ REAL-TIME: Family provider that creates a separate stream per user ID.
/// Each user's feedback history screen gets its own real-time stream that
/// updates as the user submits new feedback.
///
/// [userId] — the Firebase Auth UID passed as the family parameter.
///
/// Usage:
///   ref.watch(userFeedbackProvider(currentUser.uid))
final userFeedbackProvider =
    StreamProvider.family<List<Feedback>, String>((ref, userId) {
  final FirestoreService firestoreService =
      ref.watch(firestoreServiceProvider);

  return firestoreService.userFeedbackStream(userId).map(
        (QuerySnapshot<Map<String, dynamic>> snapshot) =>
            FirestoreService.snapshotToList(snapshot),
      );
});

/// ─────────────────────────────────────────────────────────────
/// Average Rating Provider
/// ─────────────────────────────────────────────────────────────
/// Calculates the mean rating across all feedback documents.
///
/// Uses a [FutureProvider] (not StreamProvider) because aggregation is
/// expensive to recompute on every change. The admin dashboard fetches
/// this once on load and can trigger manual refresh via pull-to-refresh.
///
/// Returns a `double` rounded to 1 decimal place (e.g., 4.3).
/// Returns 0.0 if no feedback exists yet.
final averageRatingProvider =
    FutureProvider<double>((ref) {
  final FirestoreService firestoreService =
      ref.watch(firestoreServiceProvider);
  return firestoreService.fetchAverageRating();
});
