import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

/// Firebase + Firestore entry points for this app.
///
/// Uses the **(default)** Firestore database in project
/// [projectId] — the same instance shown in Firebase Console → Firestore → Data.
abstract final class AppFirebase {
  static const String projectId = 'attendance-tracker-demoapp';

  /// `(default)` Cloud Firestore — collections: `users`, `locations`, `attendance`.
  static FirebaseFirestore get firestore => FirebaseFirestore.instance;

  static FirebaseApp get app => Firebase.app();
}
