import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

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
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Pilih dari Galeri'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image = await _picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (image != null) {
                    setState(() {
                      _profileImage = File(image.path);
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Ambil Foto'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image = await _picker.pickImage(
                    source: ImageSource.camera,
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
        );
      },
    );
  }

  void _register() {
    if (_formKey.currentState!.validate()) {
      // Implementasi logika registrasi
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registrasi berhasil!'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Navigasi ke halaman berikutnya atau kembali ke login
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
    }
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
                            'Confirm Password',
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
                            onPressed: _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6B4B7E),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              'Register',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
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