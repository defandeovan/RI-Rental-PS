import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance => _instance ??= SupabaseService._();

  SupabaseService._();

  SupabaseClient get client => Supabase.instance.client;

  // Notifier for favorites updates
  final ValueNotifier<bool> favoritesNotifier = ValueNotifier(false);


  // Initialize Supabase
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: 'https://jlmabquazdbdmmdvjdxv.supabase.co', // Ganti dengan URL Supabase Anda
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpsbWFicXVhemRiZG1tZHZqZHh2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ0ODYxODIsImV4cCI6MjA4MDA2MjE4Mn0.om59YSXS-ZmVhvu_R4U7WWE-hY1Eind_5ogrKhUA3P0', // Ganti dengan Anon Key Anda
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
      final String fileName = '$userId-${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String path = 'avatars/$fileName';

      await client.storage.from('profiles').upload(path, imageFile);

      final String imageUrl = client.storage.from('profiles').getPublicUrl(path);

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

  // Favorites Methods
  Future<List<String>> getFavorites(String userId) async {
    try {
      final response = await client
          .from('favorites')
          .select('product_id')
          .eq('user_id', userId);

      final List<dynamic> data = response;
      return data.map((e) => e['product_id'] as String).toList();
    } catch (e) {
      print('Error getting favorites: $e');
      return [];
    }
  }

  Future<bool> toggleFavorite(String userId, String productId) async {
    try {
      final exists = await client
          .from('favorites')
          .select()
          .eq('user_id', userId)
          .eq('product_id', productId)
          .maybeSingle();

      if (exists != null) {
        // Remove
        await client
            .from('favorites')
            .delete()
            .eq('user_id', userId)
            .eq('product_id', productId);
        favoritesNotifier.value = !favoritesNotifier.value; // Notify listeners
        return false; // Not favorite anymore
      } else {
        // Add
        await client.from('favorites').insert({
          'user_id': userId,
          'product_id': productId,
          'created_at': DateTime.now().toIso8601String(),
        });
        favoritesNotifier.value = !favoritesNotifier.value; // Notify listeners
        return true; // Is favorite now
      }
    } catch (e) {
      print('Error toggling favorite: $e');
      return false; // Assume fail/removed if error (simplified)
    }
  }

  Future<bool> isFavorite(String userId, String productId) async {
    try {
      final response = await client
          .from('favorites')
          .select()
          .eq('user_id', userId)
          .eq('product_id', productId)
          .maybeSingle();
      
      return response != null;
    } catch (e) {
      print('Error checking favorite: $e');
      return false;
    }
  }

  // Voucher Methods
  Future<List<Map<String, dynamic>>> getVouchers() async {
    try {
      final response = await client
          .from('vouchers')
          .select();
      
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      final data = List<Map<String, dynamic>>.from(response);



      if (data.isEmpty) {
        return _getDummyVouchers();
      }
      
      return data.where((v) {
        try {
           final validUntil = DateTime.parse(v['valid_until']);
           final validDate = DateTime(validUntil.year, validUntil.month, validUntil.day);
           return !validDate.isBefore(today);
        } catch (e) {
           return true; 
        }
      }).toList();
    } catch (e) {
      print('Error getting vouchers: $e');
      // Return dummy data on error too so user sees SOMETHING
      return _getDummyVouchers();
    }
  }

  List<Map<String, dynamic>> _getDummyVouchers() {
    return [
      {
        'id': 1,
        'code': 'NEWUSER50',
        'discount_percent': 50,
        'description': 'Diskon Pengguna Baru 50%',
        'min_purchase': 0,
        'valid_until': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
      },
      {
        'id': 2,
        'code': 'WEEKEND20',
        'discount_percent': 20,
        'description': 'Diskon Akhir Pekan 20%',
        'min_purchase': 50000,
        'valid_until': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
      },
      {
        'id': 3,
        'code': 'FLASHDEAL',
        'discount_percent': 30,
        'description': 'Flash Deal 30% OFF',
        'min_purchase': 100000,
        'valid_until': DateTime.now().add(const Duration(days: 1)).toIso8601String(),
      }
    ];
  }

  // Order Methods
  Future<bool> createOrder(Map<String, dynamic> orderData) async {
    try {
      await client.from('orders').insert(orderData);
      return true;
    } catch (e) {
      print('Error creating order: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getOrders(String userId) async {
    try {
      final response = await client
          .from('orders')
          .select()
          .eq('user_id', userId)
          .order('order_date', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting orders: $e');
      return [];
    }
  }

  // Auth State Stream
  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;
}