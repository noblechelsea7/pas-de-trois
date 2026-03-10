import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/interfaces/i_auth_repository.dart';
import '../../domain/models/user_profile.dart';
import '../datasources/supabase_auth_datasource.dart';

class AuthRepositoryImpl implements IAuthRepository {
  const AuthRepositoryImpl(this._dataSource);

  final SupabaseAuthDataSource _dataSource;

  @override
  Stream<AuthState> get authStateChanges => _dataSource.authStateChanges;

  @override
  User? get currentUser => _dataSource.currentUser;

  @override
  Future<UserProfile?> getProfile() async {
    final user = _dataSource.currentUser;
    if (user == null) return null;
    final data = await _dataSource.fetchProfile(user.id);
    if (data == null) return null;
    return UserProfile.fromJson(data);
  }

  @override
  Future<void> signIn({required String email, required String password}) =>
      _dataSource.signIn(email: email, password: password);

  @override
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  }) =>
      _dataSource.signUp(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
      );

  @override
  Future<void> signOut() => _dataSource.signOut();

  @override
  Future<void> resetPasswordForEmail(String email) =>
      _dataSource.resetPasswordForEmail(email);

  @override
  Future<void> updateProfile({String? fullName, String? phone}) async {
    final user = _dataSource.currentUser;
    if (user == null) return;
    final data = <String, dynamic>{};
    if (fullName != null) data['full_name'] = fullName;
    if (phone != null) data['phone'] = phone;
    if (data.isNotEmpty) {
      await _dataSource.updateProfile(user.id, data);
    }
  }
}
