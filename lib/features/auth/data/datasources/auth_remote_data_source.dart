import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> login(String email, String password);
  Future<Map<String, dynamic>> register(
      String email, String password, String name);
  Future<void> forgotPassword(String email);
  Future<void> logout();
  Future<Map<String, dynamic>?> getCurrentUserData();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabase;

  AuthRemoteDataSourceImpl({required this.supabase});

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw Exception('Login failed');
    }

    // Ambil data user dari tabel public.users
    final userData = await supabase
        .from('users')
        .select()
        .eq('id', response.user!.id)
        .single();

    return {
      'success': true,
      'token': response.session?.accessToken ?? '',
      'user': userData,
    };
  }

  @override
  Future<Map<String, dynamic>> register(
      String email, String password, String name) async {
    final response = await supabase.auth.signUp(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw Exception('Registration failed');
    }

    // Insert ke tabel public.users
    final userData = await supabase
        .from('users')
        .insert({
          'id': response.user!.id,
          'email': email,
          'name': name,
          'joined_at': DateTime.now().toIso8601String(),
          'biometric_enabled': false,
        })
        .select()
        .single();

    return {
      'success': true,
      'token': response.session?.accessToken ?? '',
      'user': userData,
    };
  }

  @override
  Future<void> forgotPassword(String email) async {
    await supabase.auth.resetPasswordForEmail(email);
  }

  @override
  Future<void> logout() async {
    await supabase.auth.signOut();
  }

  @override
  Future<Map<String, dynamic>?> getCurrentUserData() async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    final userData = await supabase
        .from('users')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    return userData;
  }
}