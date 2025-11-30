<<<<<<< HEAD
// ==================== FILE: notifikasi_admin_page.dart ====================

import 'package:flutter/material.dart';

class NotifikasiAdminPage extends StatefulWidget {
  const NotifikasiAdminPage({Key? key}) : super(key: key);

  @override
  State<NotifikasiAdminPage> createState() => _NotifikasiAdminPageState();
}

class _NotifikasiAdminPageState extends State<NotifikasiAdminPage> {
  final List<NotificationItem> notifications = [
    NotificationItem(
      type: 'Chat Baru',
      title: 'Pesan Baru Diterima!',
      message: 'User RNT-13345 mengirim PS5 Mulai Dari 2024 Pusat 00.00',
      date: '21 Okt 2025',
      time: '09:10 WIB',
      badgeColor: const Color(0xFF6B4C7D),
      isUnread: true,
    ),
    NotificationItem(
      type: 'Pembayaran',
      title: 'Pembayaran Telah Dikonfirmasi',
      message: 'User RNT-12345 Telah membayar Sewa Sebesar Rp30.000',
      date: '20 Okt 2025',
      time: '09:10 WIB',
      badgeColor: const Color(0xFF4CAF50),
      isUnread: true,
    ),
    NotificationItem(
      type: 'Pengembalian',
      title: 'Pengembalian Terlambat',
      message: 'User RNT-2223 Belum Mengembalikan PS5 Lebih Tempo 10 Okt 2025',
      date: '18 Okt 2025',
      time: '14:30 WIB',
      badgeColor: const Color(0xFFF44336),
      isUnread: false,
    ),
    NotificationItem(
      type: 'Pembayaran',
      title: 'Menunggu Konfirmasi',
      message: 'User RNT-9988 menunggu konfirmasi pembayaran Rp50.000',
      date: '17 Okt 2025',
      time: '11:20 WIB',
      badgeColor: const Color(0xFFFF9800),
      isUnread: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D2D2D)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Notifikasi Admin',
          style: TextStyle(
            color: Color(0xFF2D2D2D),
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Color(0xFF6B4C7D)),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Semua',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D2D2D),
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                return _buildNotificationCard(notifications[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(NotificationItem item) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: item.badgeColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        item.type,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (item.isUnread)
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Color(0xFF4CAF50),
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D2D2D),
                    letterSpacing: 0.2,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.message,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF2D2D2D).withOpacity(0.7),
                    letterSpacing: 0.2,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${item.date} - ${item.time}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF9E9E9E),
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NotificationItem {
  final String type;
  final String title;
  final String message;
  final String date;
  final String time;
  final Color badgeColor;
  final bool isUnread;

  NotificationItem({
    required this.type,
    required this.title,
    required this.message,
    required this.date,
    required this.time,
    required this.badgeColor,
    required this.isUnread,
  });
=======
// ==================== FILE: notifikasi_admin_page.dart ====================

import 'package:flutter/material.dart';

class NotifikasiAdminPage extends StatefulWidget {
  const NotifikasiAdminPage({Key? key}) : super(key: key);

  @override
  State<NotifikasiAdminPage> createState() => _NotifikasiAdminPageState();
}

class _NotifikasiAdminPageState extends State<NotifikasiAdminPage> {
  final List<NotificationItem> notifications = [
    NotificationItem(
      type: 'Chat Baru',
      title: 'Pesan Baru Diterima!',
      message: 'User RNT-13345 mengirim PS5 Mulai Dari 2024 Pusat 00.00',
      date: '21 Okt 2025',
      time: '09:10 WIB',
      badgeColor: const Color(0xFF6B4C7D),
      isUnread: true,
    ),
    NotificationItem(
      type: 'Pembayaran',
      title: 'Pembayaran Telah Dikonfirmasi',
      message: 'User RNT-12345 Telah membayar Sewa Sebesar Rp30.000',
      date: '20 Okt 2025',
      time: '09:10 WIB',
      badgeColor: const Color(0xFF4CAF50),
      isUnread: true,
    ),
    NotificationItem(
      type: 'Pengembalian',
      title: 'Pengembalian Terlambat',
      message: 'User RNT-2223 Belum Mengembalikan PS5 Lebih Tempo 10 Okt 2025',
      date: '18 Okt 2025',
      time: '14:30 WIB',
      badgeColor: const Color(0xFFF44336),
      isUnread: false,
    ),
    NotificationItem(
      type: 'Pembayaran',
      title: 'Menunggu Konfirmasi',
      message: 'User RNT-9988 menunggu konfirmasi pembayaran Rp50.000',
      date: '17 Okt 2025',
      time: '11:20 WIB',
      badgeColor: const Color(0xFFFF9800),
      isUnread: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D2D2D)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Notifikasi Admin',
          style: TextStyle(
            color: Color(0xFF2D2D2D),
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Color(0xFF6B4C7D)),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Semua',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D2D2D),
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                return _buildNotificationCard(notifications[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(NotificationItem item) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: item.badgeColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        item.type,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (item.isUnread)
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Color(0xFF4CAF50),
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D2D2D),
                    letterSpacing: 0.2,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.message,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF2D2D2D).withOpacity(0.7),
                    letterSpacing: 0.2,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${item.date} - ${item.time}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF9E9E9E),
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NotificationItem {
  final String type;
  final String title;
  final String message;
  final String date;
  final String time;
  final Color badgeColor;
  final bool isUnread;

  NotificationItem({
    required this.type,
    required this.title,
    required this.message,
    required this.date,
    required this.time,
    required this.badgeColor,
    required this.isUnread,
  });
>>>>>>> bdd0db5a76c25fd67354bf213a944ddbefca5af0
}