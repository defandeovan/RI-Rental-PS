import 'package:flutter/material.dart';

class DaftarUnitPSPage extends StatefulWidget {
  const DaftarUnitPSPage({Key? key}) : super(key: key);

  @override
  State<DaftarUnitPSPage> createState() => _DaftarUnitPSPageState();
}

class _DaftarUnitPSPageState extends State<DaftarUnitPSPage> {
  String _selectedFilter = 'Semua';
  final List<String> _filters = ['Semua', 'Tersedia', 'Disewa', 'Maintenance'];

  // Data dummy unit PS
  final List<Map<String, dynamic>> _unitPS = [
    {
      'id': 'PS001',
      'name': 'PS5 Standard Edition',
      'type': 'PS5',
      'status': 'Tersedia',
      'price': 350000,
      'accessories': ['2 Stik', 'TV 43"', '5 Game'],
      'image': Icons.sports_esports,
    },
    {
      'id': 'PS002',
      'name': 'PS5 Digital Edition',
      'type': 'PS5',
      'status': 'Disewa',
      'price': 300000,
      'accessories': ['1 Stik', 'TV 32"'],
      'image': Icons.videogame_asset,
    },
    {
      'id': 'PS003',
      'name': 'PS4 Slim 500GB',
      'type': 'PS4',
      'status': 'Tersedia',
      'price': 200000,
      'accessories': ['2 Stik', 'TV 32"', '3 Game'],
      'image': Icons.sports_esports,
    },
    {
      'id': 'PS004',
      'name': 'PS4 Pro 1TB',
      'type': 'PS4',
      'status': 'Maintenance',
      'price': 250000,
      'accessories': ['2 Stik', 'TV 43"', '5 Game'],
      'image': Icons.videogame_asset,
    },
    {
      'id': 'PS005',
      'name': 'PS5 Standard + VR',
      'type': 'PS5',
      'status': 'Tersedia',
      'price': 450000,
      'accessories': ['2 Stik', 'VR Headset', 'TV 50"', '10 Game'],
      'image': Icons.sports_esports,
    },
    {
      'id': 'PS006',
      'name': 'PS4 Slim 1TB',
      'type': 'PS4',
      'status': 'Disewa',
      'price': 220000,
      'accessories': ['2 Stik', 'TV 32"', '5 Game'],
      'image': Icons.videogame_asset,
    },
  ];

  List<Map<String, dynamic>> get _filteredUnits {
    if (_selectedFilter == 'Semua') {
      return _unitPS;
    }
    return _unitPS.where((unit) => unit['status'] == _selectedFilter).toList();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Tersedia':
        return const Color(0xFF4CAF50);
      case 'Disewa':
        return const Color(0xFF2196F3);
      case 'Maintenance':
        return const Color(0xFFFF9800);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D2D2D)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Daftar Unit PS',
          style: TextStyle(
            color: Color(0xFF2D2D2D),
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF2D2D2D)),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredUnits.length,
              itemBuilder: (context, index) {
                return _buildUnitCard(_filteredUnits[index]);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAddUnitDialog();
        },
        backgroundColor: const Color(0xFF6B4C7D),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Unit'),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _filters.map((filter) {
            final isSelected = _selectedFilter == filter;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(filter),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedFilter = filter;
                  });
                },
                backgroundColor: Colors.grey[200],
                selectedColor: const Color(0xFF6B4C7D),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF2D2D2D),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildUnitCard(Map<String, dynamic> unit) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF6B4C7D), Color(0xFF8B5A9B)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(unit['image'], size: 40, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            unit['id'],
                            style: const TextStyle(
                              color: Color(0xFF9E9E9E),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(
                                unit['status'],
                              ).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              unit['status'],
                              style: TextStyle(
                                color: _getStatusColor(unit['status']),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        unit['name'],
                        style: const TextStyle(
                          color: Color(0xFF2D2D2D),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: (unit['accessories'] as List<String>)
                            .map(
                              (acc) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5F5F5),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  acc,
                                  style: const TextStyle(
                                    color: Color(0xFF2D2D2D),
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Rp ${unit['price'].toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} / hari',
                        style: const TextStyle(
                          color: Color(0xFF6B4C7D),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: () {
                      _showEditUnitDialog(unit);
                    },
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Edit'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF6B4C7D),
                    ),
                  ),
                ),
                Container(width: 1, height: 24, color: const Color(0xFFEEEEEE)),
                Expanded(
                  child: TextButton.icon(
                    onPressed: () {
                      _showDeleteDialog(unit);
                    },
                    icon: const Icon(Icons.delete, size: 18),
                    label: const Text('Hapus'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFF44336),
                    ),
                  ),
                ),
                Container(width: 1, height: 24, color: const Color(0xFFEEEEEE)),
                Expanded(
                  child: TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.info_outline, size: 18),
                    label: const Text('Detail'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF2196F3),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddUnitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('Tambah Unit PS Baru'),
        content: const Text('Fitur tambah unit PS akan segera tersedia.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showEditUnitDialog(Map<String, dynamic> unit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text('Edit ${unit['name']}'),
        content: const Text('Fitur edit unit PS akan segera tersedia.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
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
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${unit['name']} berhasil dihapus'),
                  backgroundColor: const Color(0xFF4CAF50),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF44336),
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
}
