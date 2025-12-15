// ==================== FILE: kelola_unit_page.dart ====================

import 'package:flutter/material.dart';

class KelolaUnitPage extends StatefulWidget {
  const KelolaUnitPage({Key? key}) : super(key: key);

  @override
  State<KelolaUnitPage> createState() => _KelolaUnitPageState();
}

class _KelolaUnitPageState extends State<KelolaUnitPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Data dummy untuk unit PS
  List<Map<String, dynamic>> units = [
    {
      'id': '01',
      'name': 'playstation 5',
      'type': 'ps 5',
      'price': '100 rb/hari',
      'status': 'tersedia',
      'condition': 'baik',
    },
    {
      'id': '01',
      'name': 'playstation 5',
      'type': 'ps 5',
      'price': '100 rb/hari',
      'status': 'tersedia',
      'condition': 'baik',
    },
    {
      'id': '01',
      'name': 'playstation 5',
      'type': '',
      'price': '',
      'status': 'tersedia',
      'condition': '',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Color(0xFF2D2D2D)),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: const Text(
          'sewa ps',
          style: TextStyle(
            color: Color(0xFF2D2D2D),
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              color: Color(0xFF2D2D2D),
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: Color(0xFF2D2D2D)),
            onPressed: () {},
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kelola Unit PS',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D2D2D),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 20),
            // Tombol Tambah Unit
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  _showAddUnitDialog();
                },
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  'Tambah Unit',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B4C7D),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // List Unit PS
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: units.length,
              itemBuilder: (context, index) {
                return _buildUnitCard(units[index]);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(color: Color(0xFF6B4C7D)),
            width: double.infinity,
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Icon(
                    Icons.admin_panel_settings,
                    color: Colors.white,
                    size: 40,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'PS Rental Admin',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildDrawerItem(Icons.home, 'Dashboard Utama', false, () {
                  Navigator.pop(context);
                }),
                _buildDrawerItem(
                  Icons.videogame_asset,
                  'Daftar Unit PS',
                  true,
                  () {},
                ),
                _buildDrawerItem(
                  Icons.shopping_cart,
                  'Daftar Penyewaan',
                  false,
                  () {},
                ),
                _buildDrawerItem(
                  Icons.people,
                  'Daftar Pelanggan',
                  false,
                  () {},
                ),
                _buildDrawerItem(Icons.description, 'Laporan', false, () {}),
                _buildDrawerItem(
                  Icons.bar_chart,
                  'Laporan Transaksi',
                  false,
                  () {},
                ),
                _buildDrawerItem(Icons.settings, 'Pengaturan', false, () {}),
                const Divider(height: 30),
                _buildDrawerItem(Icons.logout, 'Logout', false, () {
                  _showLogoutDialog();
                }, isLogout: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    IconData icon,
    String title,
    bool isActive,
    VoidCallback onTap, {
    bool isLogout = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF6B4C7D) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isLogout
              ? Colors.red
              : (isActive ? Colors.white : const Color(0xFF2D2D2D)),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isLogout
                ? Colors.red
                : (isActive ? Colors.white : const Color(0xFF2D2D2D)),
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            fontSize: 15,
            letterSpacing: 0.2,
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildUnitCard(Map<String, dynamic> unit) {
    bool isAvailable = unit['status'] == 'tersedia';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                unit['id'],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D2D2D),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isAvailable ? const Color(0xFF4CAF50) : Colors.red,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  unit['status'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            unit['name'],
            style: const TextStyle(fontSize: 15, color: Color(0xFF2D2D2D)),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (unit['type'].isNotEmpty)
                Expanded(
                  child: Text(
                    'Tipe : ${unit['type']}',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  ),
                ),
              if (unit['condition'].isNotEmpty)
                Text(
                  'Kondisi : ${unit['condition']}',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                ),
            ],
          ),
          if (unit['price'].isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Harga ${unit['price']}',
              style: const TextStyle(fontSize: 13, color: Color(0xFF2D2D2D)),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    _showEditUnitDialog(unit);
                  },
                  icon: const Icon(
                    Icons.edit,
                    size: 18,
                    color: Color(0xFF2D2D2D),
                  ),
                  label: const Text(
                    'edit',
                    style: TextStyle(
                      color: Color(0xFF2D2D2D),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: Colors.grey.shade400),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    _showDeleteDialog(unit);
                  },
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: Colors.red,
                  ),
                  label: const Text(
                    'hapus',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddUnitDialog() {
    final TextEditingController idController = TextEditingController();
    final TextEditingController nameController = TextEditingController();
    final TextEditingController typeController = TextEditingController();
    final TextEditingController priceController = TextEditingController();
    String selectedStatus = 'tersedia';
    String selectedCondition = 'baik';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('Tambah Unit Baru'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: idController,
                decoration: const InputDecoration(
                  labelText: 'ID Unit',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Unit UP',
                  //UP nanti di hapus
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: typeController,
                decoration: const InputDecoration(
                  labelText: 'Tipe',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: 'Harga per hari',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                units.add({
                  'id': idController.text,
                  'name': nameController.text,
                  'type': typeController.text,
                  'price': priceController.text,
                  'status': selectedStatus,
                  'condition': selectedCondition,
                });
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B4C7D),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Tambah', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditUnitDialog(Map<String, dynamic> unit) {
    final TextEditingController nameController = TextEditingController(
      text: unit['name'],
    );
    final TextEditingController typeController = TextEditingController(
      text: unit['type'],
    );
    final TextEditingController priceController = TextEditingController(
      text: unit['price'],
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('Edit Unit'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Unit',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: typeController,
                decoration: const InputDecoration(
                  labelText: 'Tipe',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: 'Harga per hari',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                unit['name'] = nameController.text;
                unit['type'] = typeController.text;
                unit['price'] = priceController.text;
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B4C7D),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(Map<String, dynamic> unit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('Hapus Unit'),
        content: Text('Apakah Anda yakin ingin menghapus ${unit['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                units.remove(unit);
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('Logout'),
        content: const Text('Apakah Anda yakin ingin keluar dari admin panel?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
