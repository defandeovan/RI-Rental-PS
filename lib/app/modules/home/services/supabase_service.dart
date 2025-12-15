import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance => _instance ??= SupabaseService._();

  SupabaseService._();

  SupabaseClient get client => Supabase.instance.client;

  // Initialize Supabase
  static Future<void> initialize() async {
    await Supabase.initialize(
      url:
          'https://jlmabquazdbdmmdvjdxv.supabase.co', // Ganti dengan URL Supabase Anda
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpsbWFicXVhemRiZG1tZHZqZHh2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ0ODYxODIsImV4cCI6MjA4MDA2MjE4Mn0.om59YSXS-ZmVhvu_R4U7WWE-hY1Eind_5ogrKhUA3P0', // Ganti dengan Anon Key Anda
    );
  }

  // Auth Methods
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final response = await client.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: null, // Tidak perlu email confirmation
      );
      print('SignUp Response: ${response.user?.id}');
      return response;
    } catch (e) {
      print('SignUp Error: $e');
      rethrow;
    }
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      print('SignIn Response: ${response.user?.id}');
      return response;
    } catch (e) {
      print('SignIn Error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await client.auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await client.auth.resetPasswordForEmail(email);
  }

  // User Methods
  User? get currentUser => client.auth.currentUser;

  bool get isLoggedIn => currentUser != null;

  String? get userId => currentUser?.id;

  String? get userEmail => currentUser?.email;

  // Profile Methods
  Future<Map<String, dynamic>?> getProfile(String userId) async {
    try {
      final response = await client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      return response;
    } catch (e) {
      print('Error getting profile: $e');
      return null;
    }
  }

  Future<bool> createProfile({
    required String userId,
    required String name,
    required String email,
    required String phone,
    String? profileImageUrl,
  }) async {
    try {
      await client.from('profiles').insert({
        'id': userId,
        'name': name,
        'email': email,
        'phone': phone,
        'profile_image_url': profileImageUrl,
        'created_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      print('Error creating profile: $e');
      return false;
    }
  }

  Future<bool> updateProfile({
    required String userId,
    Map<String, dynamic>? data,
  }) async {
    try {
      await client.from('profiles').update(data!).eq('id', userId);
      return true;
    } catch (e) {
      print('Error updating profile: $e');
      return false;
    }
  }

  // Storage Methods
  Future<String?> uploadProfileImage({
    required String userId,
    required File imageFile,
  }) async {
    try {
      final String fileName =
          '$userId-${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String path = 'avatars/$fileName';

      await client.storage.from('profiles').upload(path, imageFile);

      final String imageUrl = client.storage
          .from('profiles')
          .getPublicUrl(path);

      return imageUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<bool> deleteProfileImage(String filePath) async {
    try {
      await client.storage.from('profiles').remove([filePath]);
      return true;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }

  // Auth State Stream
  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;
}
