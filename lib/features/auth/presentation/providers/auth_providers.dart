import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/datasources/supabase_auth_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/interfaces/i_auth_repository.dart';
import '../../domain/models/user_profile.dart';

part 'auth_providers.g.dart';

@riverpod
SupabaseClient supabaseClient(Ref ref) => Supabase.instance.client;

@riverpod
IAuthRepository authRepository(Ref ref) {
  final client = ref.watch(supabaseClientProvider);
  return AuthRepositoryImpl(SupabaseAuthDataSource(client));
}

/// Emits the current auth state whenever login/logout occurs.
@riverpod
Stream<AuthState> authStateChanges(Ref ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
}

/// Current Supabase user — null if signed out.
/// Re-evaluates whenever [authStateChangesProvider] emits.
@riverpod
User? currentAuthUser(Ref ref) {
  ref.watch(authStateChangesProvider);
  return Supabase.instance.client.auth.currentUser;
}

/// Fetches the user's profile from Supabase.
/// Automatically re-runs when the auth user changes.
@riverpod
Future<UserProfile?> userProfile(Ref ref) async {
  final user = ref.watch(currentAuthUserProvider);
  if (user == null) return null;
  return ref.read(authRepositoryProvider).getProfile();
}
