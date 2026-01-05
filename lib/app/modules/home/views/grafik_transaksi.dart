import 'package:flutter/material.dart';
import 'dart:math' as math;

class GrafikTransaksiPage extends StatefulWidget {
  const GrafikTransaksiPage({Key? key}) : super(key: key);

  @override
  State<GrafikTransaksiPage> createState() => _GrafikTransaksiPageState();
}

class _GrafikTransaksiPageState extends State<GrafikTransaksiPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Data untuk grafik tren pendapatan (dalam juta)
  final List<double> trendData = [1.0, 1.5, 1.2, 2.0, 2.5, 1.8, 2.2];
  final List<String> daysLabels = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

  // Data untuk grafik batang total pendapatan per bulan (dalam juta)
  final List<double> monthlyRevenue = [5, 8, 12, 18, 35, 42, 48, 45, 38];
  final List<String> monthLabels = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep'];

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
            icon: const Icon(Icons.notifications_outlined, color: Color(0xFF2D2D2D)),
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
              'Grafik Pendapatan',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D2D2D),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 20),
            _buildStatsGrid(),
            const SizedBox(height: 24),
            _buildTrendChart(),
            const SizedBox(height: 24),
            _buildMonthlyChart(),
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
            decoration: const BoxDecoration(
              color: Color(0xFF6B4C7D),
            ),
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
                _buildDrawerItem(Icons.videogame_asset, 'Daftar Unit PS', false, () {}),
                _buildDrawerItem(Icons.shopping_cart, 'Daftar Penyewaan', false, () {}),
                _buildDrawerItem(Icons.people, 'Daftar Pelanggan', false, () {}),
                _buildDrawerItem(Icons.description, 'Laporan', false, () {}),
                _buildDrawerItem(Icons.bar_chart, 'Laporan Transaksi', false, () {}),
                _buildDrawerItem(Icons.trending_up, 'Grafik Transaksi', true, () {}),
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

  Widget _buildDrawerItem(IconData icon, String title, bool isActive, VoidCallback onTap, {bool isLogout = false}) {
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

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard('Total Pendapatan', 'RP. 16.8 M', const Color(0xFF4CAF50)),
        _buildStatCard('Total Unit PS', '24', const Color(0xFF2196F3)),
        _buildStatCard('Total pengguna', '150', const Color(0xFFFFA726)),
        _buildStatCard('Pengguna Sekarang', '3', const Color(0xFFEF5350)),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: iconColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF2D2D2D),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          const Text(
            'Tren Pendapatan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D2D2D),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: CustomPaint(
              painter: LineChartPainter(trendData, daysLabels),
              size: const Size(double.infinity, 200),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          const Text(
            'Total Pendapatan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D2D2D),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: CustomPaint(
              painter: BarChartPainter(monthlyRevenue, monthLabels),
              size: const Size(double.infinity, 200),
            ),
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
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter untuk Line Chart
class LineChartPainter extends CustomPainter {
  final List<double> data;
  final List<String> labels;

  LineChartPainter(this.data, this.labels);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF4CAF50)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = const Color(0xFF4CAF50).withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final dotPaint = Paint()
      ..color = const Color(0xFF4CAF50)
      ..style = PaintingStyle.fill;

    final gridPaint = Paint()
      ..color = Colors.grey.shade200
      ..strokeWidth = 1;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // Padding
    const double padding = 40;
    const double bottomPadding = 30;
    final double chartWidth = size.width - padding * 2;
    final double chartHeight = size.height - bottomPadding - padding;

    // Cari nilai max
    final maxValue = data.reduce(math.max);
    final step = chartWidth / (data.length - 1);

    // Gambar grid horizontal
    for (int i = 0; i <= 4; i++) {
      final y = padding + (chartHeight * i / 4);
      canvas.drawLine(
        Offset(padding, y),
        Offset(size.width - padding, y),
        gridPaint,
      );

      // Label sumbu Y
      final value = maxValue * (4 - i) / 4;
      textPainter.text = TextSpan(
        text: '${value.toStringAsFixed(1)}M',
        style: const TextStyle(
          color: Color(0xFF2D2D2D),
          fontSize: 10,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(5, y - textPainter.height / 2));
    }

    // Buat path untuk line dan fill
    final path = Path();
    final fillPath = Path();
    fillPath.moveTo(padding, size.height - bottomPadding);

    for (int i = 0; i < data.length; i++) {
      final x = padding + (step * i);
      final y = padding + chartHeight - (data[i] / maxValue * chartHeight);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    // Close fill path
    fillPath.lineTo(padding + chartWidth, size.height - bottomPadding);
    fillPath.close();

    // Draw fill area
    canvas.drawPath(fillPath, fillPaint);

    // Draw line
    canvas.drawPath(path, paint);

    // Draw dots dan labels
    for (int i = 0; i < data.length; i++) {
      final x = padding + (step * i);
      final y = padding + chartHeight - (data[i] / maxValue * chartHeight);

      // Draw dot
      canvas.drawCircle(Offset(x, y), 5, dotPaint);
      canvas.drawCircle(
        Offset(x, y),
        5,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );

      // Draw label
      textPainter.text = TextSpan(
        text: labels[i],
        style: const TextStyle(
          color: Color(0xFF2D2D2D),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, size.height - bottomPadding + 10),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom Painter untuk Bar Chart
class BarChartPainter extends CustomPainter {
  final List<double> data;
  final List<String> labels;

  BarChartPainter(this.data, this.labels);

  @override
  void paint(Canvas canvas, Size size) {
    final barPaint = Paint()
      ..color = const Color(0xFF2196F3)
      ..style = PaintingStyle.fill;

    final gridPaint = Paint()
      ..color = Colors.grey.shade200
      ..strokeWidth = 1;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // Padding
    const double padding = 40;
    const double bottomPadding = 30;
    final double chartWidth = size.width - padding * 2;
    final double chartHeight = size.height - bottomPadding - padding;

    // Cari nilai max
    final maxValue = data.reduce(math.max);
    final barWidth = chartWidth / data.length * 0.7;
    final spacing = chartWidth / data.length;

    // Gambar grid horizontal
    for (int i = 0; i <= 4; i++) {
      final y = padding + (chartHeight * i / 4);
      canvas.drawLine(
        Offset(padding, y),
        Offset(size.width - padding, y),
        gridPaint,
      );

      // Label sumbu Y
      final value = maxValue * (4 - i) / 4;
      textPainter.text = TextSpan(
        text: value.toInt().toString(),
        style: const TextStyle(
          color: Color(0xFF2D2D2D),
          fontSize: 10,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(5, y - textPainter.height / 2));
    }

    // Draw bars dan labels
    for (int i = 0; i < data.length; i++) {
      final x = padding + (spacing * i) + (spacing - barWidth) / 2;
      final barHeight = (data[i] / maxValue) * chartHeight;
      final y = padding + chartHeight - barHeight;

      // Draw bar dengan rounded top
      final rect = RRect.fromRectAndCorners(
        Rect.fromLTWH(x, y, barWidth, barHeight),
        topLeft: const Radius.circular(4),
        topRight: const Radius.circular(4),
      );
      canvas.drawRRect(rect, barPaint);

      // Draw label
      textPainter.text = TextSpan(
        text: labels[i],
        style: const TextStyle(
          color: Color(0xFF2D2D2D),
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          x + barWidth / 2 - textPainter.width / 2,
          size.height - bottomPadding + 10,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}