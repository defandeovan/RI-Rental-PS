import 'package:flutter/material.dart';

class DaftarPenyewaanPage extends StatefulWidget {
  const DaftarPenyewaanPage({Key? key}) : super(key: key);

  @override
  State<DaftarPenyewaanPage> createState() => _DaftarPenyewaanPageState();
}

class _DaftarPenyewaanPageState extends State<DaftarPenyewaanPage> {
  String _selectedFilter = 'Semua';
  final List<String> _filters = ['Semua', 'Aktif', 'Menunggu', 'Selesai', 'Dibatalkan'];

  // Data dummy penyewaan
  final List<Map<String, dynamic>> _penyewaan = [
    {
      'id': 'RNT001',
      'customer': 'Yanto Saputra',
      'phone': '081234567890',
      'unit': 'PS5 Digital Edition',
      'startDate': '2024-12-01',
      'endDate': '2024-12-05',
      'duration': '4 hari',
      'price': 1200000,
      'status': 'Aktif',
      'payment': 'Lunas',
    },
    {
      'id': 'RNT002',
      'customer': 'Yami Sukehiro',
      'phone': '081298765432',
      'unit': 'PS4 Slim 500GB',
      'startDate': '2024-12-02',
      'endDate': '2024-12-06',
      'duration': '4 hari',
      'price': 800000,
      'status': 'Menunggu',
      'payment': 'DP 50%',
    },
    {
      'id': 'RNT003',
      'customer': 'Budi Santoso',
      'phone': '081234509876',
      'unit': 'PS5 Standard + VR',
      'startDate': '2024-11-28',
      'endDate': '2024-12-01',
      'duration': '3 hari',
      'price': 1350000,
      'status': 'Selesai',
      'payment': 'Lunas',
    },
    {
      'id': 'RNT004',
      'customer': 'Andi Wijaya',
      'phone': '081223344556',
      'unit': 'PS4 Pro 1TB',
      'startDate': '2024-12-03',
      'endDate': '2024-12-08',
      'duration': '5 hari',
      'price': 1250000,
      'status': 'Aktif',
      'payment': 'Lunas',
    },
    {
      'id': 'RNT005',
      'customer': 'Siti Nurhaliza',
      'phone': '081298761234',
      'unit': 'PS5 Standard Edition',
      'startDate': '2024-12-04',
      'endDate': '2024-12-07',
      'duration': '3 hari',
      'price': 1050000,
      'status': 'Menunggu',
      'payment': 'Belum Bayar',
    },
    {
      'id': 'RNT006',
      'customer': 'Rudi Hermawan',
      'phone': '081234445566',
      'unit': 'PS4 Slim 1TB',
      'startDate': '2024-11-25',
      'endDate': '2024-11-29',
      'duration': '4 hari',
      'price': 880000,
      'status': 'Dibatalkan',
      'payment': 'Refund',
    },
  ];

  List<Map<String, dynamic>> get _filteredPenyewaan {
    if (_selectedFilter == 'Semua') {
      return _penyewaan;
    }
    return _penyewaan.where((item) => item['status'] == _selectedFilter).toList();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Aktif':
        return const Color(0xFF4CAF50);
      case 'Menunggu':
        return const Color(0xFFFF9800);
      case 'Selesai':
        return const Color(0xFF2196F3);
      case 'Dibatalkan':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  Color _getPaymentColor(String payment) {
    if (payment == 'Lunas') {
      return const Color(0xFF4CAF50);
    } else if (payment.contains('DP')) {
      return const Color(0xFFFF9800);
    } else if (payment == 'Refund') {
      return const Color(0xFF2196F3);
    } else {
      return const Color(0xFFF44336);
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
          'Daftar Penyewaan',
          style: TextStyle(
            color: Color(0xFF2D2D2D),
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Color(0xFF2D2D2D)),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF2D2D2D)),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          _buildStatsBar(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredPenyewaan.length,
              itemBuilder: (context, index) {
                return _buildPenyewaanCard(_filteredPenyewaan[index]);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAddPenyewaanDialog();
        },
        backgroundColor: const Color(0xFF6B4C7D),
        icon: const Icon(Icons.add),
        label: const Text('Buat Pesanan'),
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

  Widget _buildStatsBar() {
    final aktif = _penyewaan.where((item) => item['status'] == 'Aktif').length;
    final menunggu = _penyewaan.where((item) => item['status'] == 'Menunggu').length;
    final total = _penyewaan.length;

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem('Total', total.toString(), const Color(0xFF6B4C7D)),
          ),
          Container(width: 1, height: 40, color: const Color(0xFFEEEEEE)),
          Expanded(
            child: _buildStatItem('Aktif', aktif.toString(), const Color(0xFF4CAF50)),
          ),
          Container(width: 1, height: 40, color: const Color(0xFFEEEEEE)),
          Expanded(
            child: _buildStatItem('Menunggu', menunggu.toString(), const Color(0xFFFF9800)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF9E9E9E),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPenyewaanCard(Map<String, dynamic> item) {
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
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF6B4C7D), Color(0xFF8B5A9B)],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['id'],
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['customer'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    item['status'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInfoRow(Icons.videogame_asset, item['unit']),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.phone, item['phone']),
                const SizedBox(height: 12),
                _buildInfoRow(
                  Icons.calendar_today,
                  '${item['startDate']} s/d ${item['endDate']} (${item['duration']})',
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Pembayaran',
                          style: TextStyle(
                            color: Color(0xFF9E9E9E),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Rp ${item['price'].toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                          style: const TextStyle(
                            color: Color(0xFF6B4C7D),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getPaymentColor(item['payment']).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        item['payment'],
                        style: TextStyle(
                          color: _getPaymentColor(item['payment']),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
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
                      _showDetailDialog(item);
                    },
                    icon: const Icon(Icons.info_outline, size: 18),
                    label: const Text('Detail'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF2196F3),
                    ),
                  ),
                ),
                if (item['status'] == 'Menunggu') ...[
                  Container(
                    width: 1,
                    height: 24,
                    color: const Color(0xFFEEEEEE),
                  ),
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () {
                        _showConfirmDialog(item);
                      },
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      label: const Text('Konfirmasi'),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF4CAF50),
                      ),
                    ),
                  ),
                ],
                if (item['status'] == 'Aktif') ...[
                  Container(
                    width: 1,
                    height: 24,
                    color: const Color(0xFFEEEEEE),
                  ),
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () {
                        _showCompleteDialog(item);
                      },
                      icon: const Icon(Icons.done_all, size: 18),
                      label: const Text('Selesai'),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF6B4C7D),
                      ),
                    ),
                  ),
                ],
                Container(
                  width: 1,
                  height: 24,
                  color: const Color(0xFFEEEEEE),
                ),
                Expanded(
                  child: TextButton.icon(
                    onPressed: () {
                      _showCancelDialog(item);
                    },
                    icon: const Icon(Icons.cancel_outlined, size: 18),
                    label: const Text('Batal'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFF44336),
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

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: const Color(0xFF9E9E9E),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF2D2D2D),
              fontSize: 13,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ],
    );
  }

  void _showAddPenyewaanDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: const Text('Buat Pesanan Baru'),
        content: const Text('Fitur buat pesanan baru akan segera tersedia.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showDetailDialog(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Text('Detail Pesanan ${item['id']}'),
        content: const Text('Detail lengkap pesanan akan ditampilkan di sini.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showConfirmDialog(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: const Text('Konfirmasi Pesanan'),
        content: Text('Konfirmasi pesanan ${item['id']} dari ${item['customer']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pesanan berhasil dikonfirmasi'),
                  backgroundColor: Color(0xFF4CAF50),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Konfirmasi',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showCompleteDialog(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: const Text('Selesaikan Pesanan'),
        content: Text('Tandai pesanan ${item['id']} sebagai selesai?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pesanan telah diselesaikan'),
                  backgroundColor: Color(0xFF2196F3),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B4C7D),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Selesai',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: const Text('Batalkan Pesanan'),
        content: Text('Apakah Anda yakin ingin membatalkan pesanan ${item['id']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tidak'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pesanan telah dibatalkan'),
                  backgroundColor: Color(0xFFF44336),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF44336),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Ya, Batalkan',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}