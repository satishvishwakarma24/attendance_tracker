import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_firebase.dart';

/// Shared Firestore instance — always the Console `(default)` database.
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return AppFirebase.firestore;
});
