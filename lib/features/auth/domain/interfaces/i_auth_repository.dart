import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_profile.dart';

abstract interface class IAuthRepository {
  Stream<AuthState> get authStateChanges;
  User? get currentUser;

  Future<UserProfile?> getProfile();
  Future<void> signIn({required String email, required String password});
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  });
  Future<void> signOut();
  Future<void> resetPasswordForEmail(String email);
  Future<void> updateProfile({String? fullName, String? phone});
}
