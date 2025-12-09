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
      message: 'User RNT-13345 mengirim pesan tentang sewa PS5',
      date: '21 Okt 2025',
      time: '09:10 WIB',
      badgeColor: const Color(0xFF6B4C7D),
      isUnread: true,
    ),
    NotificationItem(
      type: 'Pembayaran',
      title: 'Pembayaran Telah Dikonfirmasi',
      message: 'User RNT-12345 telah membayar sewa sebesar Rp 300.000',
      date: '20 Okt 2025',
      time: '09:10 WIB',
      badgeColor: const Color(0xFF4CAF50),
      isUnread: true,
    ),
    NotificationItem(
      type: 'Pengembalian',
      title: 'Pengembalian Terlambat',
      message: 'User RNT-2223 belum mengembalikan PS5, lewat tempo 10 Okt 2025',
      date: '18 Okt 2025',
      time: '14:30 WIB',
      badgeColor: const Color(0xFFF44336),
      isUnread: false,
    ),
    NotificationItem(
      type: 'Pembayaran',
      title: 'Menunggu Konfirmasi',
      message: 'User RNT-9988 menunggu konfirmasi pembayaran Rp 200.000',
      date: '17 Okt 2025',
      time: '11:20 WIB',
      badgeColor: const Color(0xFFFF9800),
      isUnread: false,
    ),
    NotificationItem(
      type: 'Reservasi',
      title: 'Reservasi Baru',
      message: 'User RNT-5566 melakukan reservasi PS4 untuk besok',
      date: '16 Okt 2025',
      time: '16:45 WIB',
      badgeColor: const Color(0xFF2196F3),
      isUnread: false,
    ),
  ];

  int get unreadCount => notifications.where((n) => n.isUnread).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D2D2D)),
          onPressed: () => Navigator.pop(context),
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
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications, color: Color(0xFF6B4C7D)),
                onPressed: () {},
              ),
              if (unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      '$unreadCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Color(0xFF2D2D2D)),
            onPressed: () {
              _showOptionsMenu();
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Semua Notifikasi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D2D2D),
                    letterSpacing: 0.3,
                  ),
                ),
                if (unreadCount > 0)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        for (var notification in notifications) {
                          notification.isUnread = false;
                        }
                      });
                    },
                    child: const Text(
                      'Tandai semua dibaca',
                      style: TextStyle(
                        color: Color(0xFF6B4C7D),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: notifications.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                return _buildNotificationCard(notifications[index], index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak ada notifikasi',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(NotificationItem item, int index) {
    return Dismissible(
      key: Key('notification_$index'),
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 28,
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        setState(() {
          notifications.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Notifikasi dihapus'),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                setState(() {
                  notifications.insert(index, item);
                });
              },
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: item.isUnread ? Colors.blue.shade50 : Colors.white,
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
            onTap: () {
              setState(() {
                item.isUnread = false;
              });
            },
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
                            color: Color(0xFF2196F3),
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: item.isUnread ? FontWeight.bold : FontWeight.w600,
                      color: const Color(0xFF2D2D2D),
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
      ),
    );
  }

  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.check_circle, color: Color(0xFF6B4C7D)),
              title: const Text('Tandai semua dibaca'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  for (var notification in notifications) {
                    notification.isUnread = false;
                  }
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_sweep, color: Colors.red),
              title: const Text('Hapus semua notifikasi'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  notifications.clear();
                });
              },
            ),
            const SizedBox(height: 10),
          ],
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
  bool isUnread;

  NotificationItem({
    required this.type,
    required this.title,
    required this.message,
    required this.date,
    required this.time,
    required this.badgeColor,
    required this.isUnread,
  });
}
