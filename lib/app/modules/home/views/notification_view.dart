import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class NotificationView extends StatefulWidget {
  const NotificationView({Key? key}) : super(key: key);

  @override
  State<NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView> {
  final List<NotificationData> _notifications = [
    NotificationData(
      title: 'Promo Spesial!',
      message: 'Dapatkan diskon 30% untuk sewa PS5 hari ini',
      time: '5 menit yang lalu',
      type: NotificationType.promo,
      isRead: false,
    ),
    NotificationData(
      title: 'Pesanan Selesai',
      message: 'Terima kasih telah menyewa PS4 Pro. Jangan lupa beri rating!',
      time: '2 jam yang lalu',
      type: NotificationType.order,
      isRead: false,
    ),
    NotificationData(
      title: 'Pengingat Pengembalian',
      message: 'PS4 Slim akan jatuh tempo besok pukul 15:00',
      time: '5 jam yang lalu',
      type: NotificationType.reminder,
      isRead: false,
    ),
    NotificationData(
      title: 'Produk Baru Tersedia',
      message: 'PS5 Slim sudah tersedia untuk disewa',
      time: '1 hari yang lalu',
      type: NotificationType.info,
      isRead: true,
    ),
    NotificationData(
      title: 'Pembayaran Berhasil',
      message: 'Pembayaran untuk sewa PS4 sebesar Rp 135.000 berhasil',
      time: '2 hari yang lalu',
      type: NotificationType.payment,
      isRead: true,
    ),
  ];

  void _markAsRead(int index) {
    setState(() {
      _notifications[index].isRead = true;
    });
  }

  void _deleteNotification(int index) {
    setState(() {
      _notifications.removeAt(index);
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification.isRead = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => !n.isRead).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: AppColors.textPrimary,
        ),
        title: const Text(
          'Notifikasi',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text(
                'Baca Semua',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: _notifications.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                return _buildNotificationItem(_notifications[index], index);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 100,
            color: AppColors.textSecondary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          const Text(
            'Tidak ada notifikasi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Notifikasi baru akan muncul di sini',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(NotificationData notification, int index) {
    return Dismissible(
      key: Key(notification.time + index.toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        _deleteNotification(index);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Notifikasi dihapus'),
            duration: const Duration(seconds: 2),
            backgroundColor: AppColors.textPrimary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      child: InkWell(
        onTap: () => _markAsRead(index),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: notification.isRead
                ? AppColors.cardBackground
                : AppColors.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: notification.isRead
                  ? Colors.transparent
                  : AppColors.primary.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _getNotificationColors(notification.type),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getNotificationIcon(notification.type),
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: notification.isRead
                                  ? FontWeight.w600
                                  : FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 14,
                          color: AppColors.textSecondary.withOpacity(0.7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          notification.time,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.promo:
        return Icons.local_offer_rounded;
      case NotificationType.order:
        return Icons.check_circle_rounded;
      case NotificationType.reminder:
        return Icons.alarm_rounded;
      case NotificationType.payment:
        return Icons.payment_rounded;
      case NotificationType.info:
        return Icons.info_rounded;
    }
  }

  List<Color> _getNotificationColors(NotificationType type) {
    switch (type) {
      case NotificationType.promo:
        return [AppColors.accent, AppColors.accent.withOpacity(0.7)];
      case NotificationType.order:
        return [Colors.green, Colors.green.withOpacity(0.7)];
      case NotificationType.reminder:
        return [Colors.orange, Colors.orange.withOpacity(0.7)];
      case NotificationType.payment:
        return [AppColors.primary, AppColors.primaryDark];
      case NotificationType.info:
        return [Colors.blue, Colors.blue.withOpacity(0.7)];
    }
  }
}

enum NotificationType { promo, order, reminder, payment, info }

class NotificationData {
  final String title;
  final String message;
  final String time;
  final NotificationType type;
  bool isRead;

  NotificationData({
    required this.title,
    required this.message,
    required this.time,
    required this.type,
    this.isRead = false,
  });
}
