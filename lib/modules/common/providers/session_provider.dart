import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/utils/logger.dart';
import '/data/models/user_session.dart';
import '/data/repositories/auth_repository.dart';
import '/data/repositories/session_repository.dart';
import '/modules/auth/providers/auth_providers.dart';

final userSessionsProvider =
    StreamProvider.autoDispose<List<UserSession>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) {
    return Stream.value(const []);
  }
  return ref
      .watch(sessionRepositoryProvider)
      .watchUserSessions(user.uid);
});

/// Ensures a single active Firestore session while the user is signed in.
final sessionLifecycleProvider = Provider<void>((ref) {
  ref.listen(authStateProvider, (previous, next) async {
    final user = next.value;
    if (user == null) return;
    try {
      await ref.read(sessionRepositoryProvider).ensureActiveSession(user.uid);
    } catch (e, s) {
      Logger.error('Failed to ensure active session', e, s);
    }
  });
});

Future<void> startUserSession(WidgetRef ref, User user) async {
  await ref.read(sessionRepositoryProvider).ensureActiveSession(user.uid);
}

Future<void> endUserSessionAndSignOut(WidgetRef ref) async {
  final user = ref.read(authStateProvider).value;
  if (user != null) {
    await ref.read(sessionRepositoryProvider).endActiveSession(user.uid);
  }
  await ref.read(authRepositoryProvider).signOut();
}
