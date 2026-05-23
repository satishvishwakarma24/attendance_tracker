import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/data/models/user_profile.dart';
import '/data/repositories/auth_repository.dart';
import '/data/repositories/user_repository.dart';

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

final userProfileProvider = StreamProvider<UserProfile?>((ref) {
  final user = ref.watch(authStateProvider).maybeWhen(
        data: (u) => u,
        orElse: () => null,
      );
  if (user == null) {
    return Stream.value(null);
  }
  return ref.watch(userRepositoryProvider).watchProfile(user.uid);
});

final isSuperAdminProvider = Provider<bool>((ref) {
  return ref.watch(userProfileProvider).value?.role.isSuperAdmin ?? false;
});
