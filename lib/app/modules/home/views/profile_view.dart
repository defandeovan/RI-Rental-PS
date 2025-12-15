import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/supabase_service.dart';
import '../theme/app_colors.dart';
import 'OrderHistoryScreen.dart';
import 'login.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final _supabaseService = SupabaseService.instance;
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = true;

  File? _newProfileImage;
  String? _currentImageUrl;
  String _userName = '';
  String _userEmail = '';
  String _userPhone = '';
  String _userGender = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);

    try {
      final userId = _supabaseService.userId;
      if (userId != null) {
        final profile = await _supabaseService.getProfile(userId);

        if (profile != null) {
          setState(() {
            _userName = profile['name'] ?? '';
            _userEmail = profile['email'] ?? '';
            _userPhone = profile['phone'] ?? '';
            _currentImageUrl = profile['profile_image_url'];
            _userGender = profile['gender'] ?? '';
          });
        }
      }
    } catch (e) {
      print('Error loading profile: $e');
    } finally {
      setState(() => _isLoading = false);
    }
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
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Ganti Foto Profil',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildImageSourceOption(
                      icon: Icons.photo_library,
                      label: 'Galeri',
                      onTap: () async {
                        Navigator.pop(context);
                        final XFile? image = await _picker.pickImage(
                          source: ImageSource.gallery,
                          maxWidth: 1024,
                          maxHeight: 1024,
                          imageQuality: 85,
                        );
                        if (image != null) {
                          _updateProfileImage(File(image.path));
                        }
                      },
                    ),
                    _buildImageSourceOption(
                      icon: Icons.camera_alt,
                      label: 'Kamera',
                      onTap: () async {
                        Navigator.pop(context);
                        final XFile? image = await _picker.pickImage(
                          source: ImageSource.camera,
                          maxWidth: 1024,
                          maxHeight: 1024,
                          imageQuality: 85,
                        );
                        if (image != null) {
                          _updateProfileImage(File(image.path));
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _updateProfileImage(File imageFile) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );

    try {
      final userId = _supabaseService.userId;
      if (userId == null) throw Exception('User tidak ditemukan');

      final newImageUrl = await _supabaseService.uploadProfileImage(
        userId: userId,
        imageFile: imageFile,
      );

      if (newImageUrl != null) {
        await _supabaseService.updateProfile(
          userId: userId,
          data: {'profile_image_url': newImageUrl},
        );

        setState(() {
          _currentImageUrl = newImageUrl;
          _newProfileImage = null;
        });

        Navigator.pop(context); // Close loading dialog
        _showMessage('Foto profil berhasil diperbarui!');
      }
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      _showMessage('Gagal memperbarui foto profil', isError: true);
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Keluar',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('Apakah Anda yakin ingin keluar dari akun?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _supabaseService.signOut();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
        );
      }
    }
  }

  void _navigateToEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(
          currentName: _userName,
          currentPhone: _userPhone,
          currentGender: _userGender,
          onSaved: () {
            _loadProfile();
          },
        ),
      ),
    );
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Profil',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    IconButton(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout),
                      color: AppColors.error,
                      tooltip: 'Keluar',
                    ),
                  ],
                ),
              ),

              // Profile Picture & Info
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.3),
                              width: 3,
                            ),
                          ),
                          child: ClipOval(
                            child: _currentImageUrl != null
                                ? Image.network(
                              _currentImageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildDefaultAvatar();
                              },
                            )
                                : _buildDefaultAvatar(),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _userName.isNotEmpty ? _userName : 'User',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _userEmail,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Menu Items
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _buildMenuItem(
                      icon: Icons.person_outline,
                      title: 'Edit Profil',
                      subtitle: 'Ubah informasi pribadi Anda',
                      onTap: _navigateToEditProfile,
                    ),
                    _buildDivider(),
                    _buildMenuItem(
                      icon: Icons.phone_outlined,
                      title: 'Nomor Telepon',
                      subtitle: _userPhone.isNotEmpty ? _userPhone : 'Belum diisi',
                      onTap: _navigateToEditProfile,
                    ),
                    _buildDivider(),
                    _buildMenuItem(
                      icon: Icons.wc_outlined,
                      title: 'Jenis Kelamin',
                      subtitle: _userGender.isNotEmpty ? _userGender : 'Belum diisi',
                      onTap: _navigateToEditProfile,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Settings Section
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _buildMenuItem(
                      icon: Icons.receipt_long_outlined,
                      title: 'Riwayat & Status Pesanan',
                      subtitle: 'Lihat semua pesanan Anda',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const OrderHistoryScreen(),
                          ),
                        );
                      },
                    ),
                    _buildDivider(),
                    _buildMenuItem(
                      icon: Icons.lock_outline,
                      title: 'Ubah Password',
                      subtitle: 'Perbarui password Anda',
                      onTap: () {
                        // TODO: Navigate to change password
                        _showMessage('Fitur akan segera hadir', isError: true);
                      },
                    ),
                    _buildDivider(),
                    _buildMenuItem(
                      icon: Icons.help_outline,
                      title: 'Bantuan',
                      subtitle: 'Pusat bantuan dan FAQ',
                      onTap: () {
                        // TODO: Navigate to help
                        _showMessage('Fitur akan segera hadir', isError: true);
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Logout Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: OutlinedButton(
                  onPressed: _logout,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 54),
                    side: const BorderSide(color: AppColors.error, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout, color: AppColors.error),
                      SizedBox(width: 8),
                      Text(
                        'Keluar dari Akun',
                        style: TextStyle(
                          color: AppColors.error,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 100), // Space for bottom nav
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: AppColors.primary.withOpacity(0.1),
      child: const Icon(
        Icons.person,
        size: 60,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.primary, size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey[600],
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: Colors.grey[400],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Divider(
        height: 1,
        color: Colors.grey[300],
      ),
    );
  }
}

// ============================================
// EDIT PROFILE SCREEN
// ============================================

class EditProfileScreen extends StatefulWidget {
  final String currentName;
  final String currentPhone;
  final String currentGender;
  final VoidCallback onSaved;

  const EditProfileScreen({
    Key? key,
    required this.currentName,
    required this.currentPhone,
    required this.currentGender,
    required this.onSaved,
  }) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late String _selectedGender;

  final _supabaseService = SupabaseService.instance;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _phoneController = TextEditingController(text: widget.currentPhone);
    _selectedGender = widget.currentGender.isNotEmpty
        ? widget.currentGender
        : 'Laki-laki';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final userId = _supabaseService.userId;
      if (userId == null) throw Exception('User tidak ditemukan');

      final success = await _supabaseService.updateProfile(
        userId: userId,
        data: {
          'name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'gender': _selectedGender,
        },
      );

      if (success) {
        widget.onSaved();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil berhasil diperbarui!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Profil',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Nama Field
            const Text(
              'Nama Lengkap',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Masukkan nama lengkap',
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nama tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Phone Field
            const Text(
              'Nomor Telepon',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: 'Contoh: +62812345678',
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nomor telepon tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Gender Field
            const Text(
              'Jenis Kelamin',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildGenderOption('Laki-laki', Icons.male),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildGenderOption('Perempuan', Icons.female),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // Save Button
            SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isSaving
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Text(
                  'Simpan Perubahan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderOption(String gender, IconData icon) {
    final isSelected = _selectedGender == gender;
    return InkWell(
      onTap: () => setState(() => _selectedGender = gender),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey[600],
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              gender,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}