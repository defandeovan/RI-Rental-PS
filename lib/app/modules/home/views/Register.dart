import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

import '../services/supabase_service.dart';


class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  final _supabaseService = SupabaseService.instance;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Pilih Foto Profil',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.photo_library, color: Color(0xFF6B4C7D)),
                  title: const Text('Pilih dari Galeri'),
                  onTap: () async {
                    Navigator.pop(context);
                    final XFile? image = await _picker.pickImage(
                      source: ImageSource.gallery,
                      maxWidth: 1024,
                      maxHeight: 1024,
                      imageQuality: 85,
                    );
                    if (image != null) {
                      setState(() {
                        _profileImage = File(image.path);
                      });
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_camera, color: Color(0xFF6B4C7D)),
                  title: const Text('Ambil Foto'),
                  onTap: () async {
                    Navigator.pop(context);
                    final XFile? image = await _picker.pickImage(
                      source: ImageSource.camera,
                      maxWidth: 1024,
                      maxHeight: 1024,
                      imageQuality: 85,
                    );
                    if (image != null) {
                      setState(() {
                        _profileImage = File(image.path);
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      print('Starting registration...');

      // 1. Sign up user
      final response = await _supabaseService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      print('Sign up response: ${response.user?.id}');

      if (response.user != null) {
        final userId = response.user!.id;

        // 2. Upload profile image (optional)
        String? profileImageUrl;
        if (_profileImage != null) {
          print('Uploading profile image...');
          profileImageUrl = await _supabaseService.uploadProfileImage(
            userId: userId,
            imageFile: _profileImage!,
          );
          print('Profile image uploaded: $profileImageUrl');
        }

        // 3. Create profile
        print('Creating profile...');
        final success = await _supabaseService.createProfile(
          userId: userId,
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          profileImageUrl: profileImageUrl,
        );

        print('Profile created: $success');

        if (success) {
          _showMessage('Registrasi berhasil! Silakan login.');

          // Kembali ke login setelah 1.5 detik
          await Future.delayed(const Duration(milliseconds: 1500));
          if (mounted) {
            Navigator.pop(context);
          }
        } else {
          throw Exception('Gagal membuat profil');
        }
      } else {
        throw Exception('User tidak ditemukan setelah registrasi');
      }
    } on AuthException catch (e) {
      print('Auth Exception: ${e.message}');
      String message = 'Registrasi gagal';

      if (e.message.contains('already registered') || e.message.contains('already exists')) {
        message = 'Email sudah terdaftar';
      } else if (e.message.contains('Password should be at least 6 characters')) {
        message = 'Password minimal 6 karakter';
      } else if (e.message.contains('Unable to validate email')) {
        message = 'Format email tidak valid';
      } else {
        message = 'Error: ${e.message}';
      }

      _showMessage(message, isError: true);
    } catch (e) {
      print('General Exception: $e');
      _showMessage('Terjadi kesalahan: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6B4B7E),
              Color(0xFF8B6B9E),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Register',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Form Container
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 20),

                          // Profile Photo
                          Center(
                            child: Stack(
                              children: [
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey[300],
                                    image: _profileImage != null
                                        ? DecorationImage(
                                      image: FileImage(_profileImage!),
                                      fit: BoxFit.cover,
                                    )
                                        : null,
                                  ),
                                  child: _profileImage == null
                                      ? const Icon(
                                    Icons.person,
                                    size: 60,
                                    color: Colors.white,
                                  )
                                      : null,
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: _pickImage,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF6B4B7E),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 40),

                          // Nama Field
                          const Text(
                            'NAMA',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              border: UnderlineInputBorder(),
                              hintText: 'Nama lengkap Anda',
                              hintStyle: TextStyle(color: Colors.grey),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Nama tidak boleh kosong';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 24),

                          // Email Field
                          const Text(
                            'Email',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              border: UnderlineInputBorder(),
                              hintText: 'Your email, e.g: johndoe@gmail.com',
                              hintStyle: TextStyle(color: Colors.grey),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Email tidak boleh kosong';
                              }
                              if (!value.contains('@')) {
                                return 'Email tidak valid';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 24),

                          // Phone Number Field
                          const Text(
                            'Phone Number',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              border: UnderlineInputBorder(),
                              hintText: 'Your phone number, e.g: +01 112 xxx xxx',
                              hintStyle: TextStyle(color: Colors.grey),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Nomor telepon tidak boleh kosong';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 24),

                          // Password Field
                          const Text(
                            'Password',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              border: const UnderlineInputBorder(),
                              hintText: 'Your password, at least 8 character',
                              hintStyle: const TextStyle(color: Colors.grey),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password tidak boleh kosong';
                              }
                              if (value.length < 8) {
                                return 'Password minimal 8 karakter';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 24),

                          // Confirm Password Field
                          const Text(
                            'Confirm Password',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            decoration: InputDecoration(
                              border: const UnderlineInputBorder(),
                              hintText: 'Re-type your password',
                              hintStyle: const TextStyle(color: Colors.grey),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword = !_obscureConfirmPassword;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Konfirmasi password tidak boleh kosong';
                              }
                              if (value != _passwordController.text) {
                                return 'Password tidak cocok';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 40),

                          // Register Button
                          ElevatedButton(
                            onPressed: _isLoading ? null : _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6B4B7E),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                                : const Text(
                              'Register',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Link ke Login
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Sudah punya akun? ',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 15,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text(
                                    'Login',
                                    style: TextStyle(
                                      color: Color(0xFF6B4B7E),
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}