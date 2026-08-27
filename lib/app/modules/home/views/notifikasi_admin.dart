import 'package:flutter/material.dart';

class NotifikasiAdminPage extends StatefulWidget {
  const NotifikasiAdminPage({super.key});

  @override
  State<NotifikasiAdminPage> createState() => _NotifikasiAdminPageState();
}

class _NotifikasiAdminPageState extends State<NotifikasiAdminPage> {
  final TextEditingController _searchController = TextEditingController();

  final List<NotificationItem> _notifications = [
    NotificationItem(
      id: 'NTF-001',
      type: NotificationType.chat,
      title: 'Pesan Baru Diterima',
      message: 'User RNT-13345 mengirim pesan tentang penyewaan PS5.',
      date: '21 Okt 2025',
      time: '09:10 WIB',
      isUnread: true,
    ),
    NotificationItem(
      id: 'NTF-002',
      type: NotificationType.payment,
      title: 'Pembayaran Berhasil',
      message: 'User RNT-12345 telah membayar biaya sewa sebesar Rp300.000.',
      date: '20 Okt 2025',
      time: '09:10 WIB',
      isUnread: true,
    ),
    NotificationItem(
      id: 'NTF-003',
      type: NotificationType.returnLate,
      title: 'Pengembalian Terlambat',
      message:
          'User RNT-2223 belum mengembalikan PS5 dan telah melewati batas waktu.',
      date: '18 Okt 2025',
      time: '14:30 WIB',
      isUnread: false,
    ),
    NotificationItem(
      id: 'NTF-004',
      type: NotificationType.paymentPending,
      title: 'Pembayaran Menunggu Konfirmasi',
      message:
          'User RNT-9988 menunggu konfirmasi pembayaran sebesar Rp200.000.',
      date: '17 Okt 2025',
      time: '11:20 WIB',
      isUnread: false,
    ),
    NotificationItem(
      id: 'NTF-005',
      type: NotificationType.reservation,
      title: 'Reservasi Baru',
      message: 'User RNT-5566 melakukan reservasi PS4 untuk besok.',
      date: '16 Okt 2025',
      time: '16:45 WIB',
      isUnread: false,
    ),
    NotificationItem(
      id: 'NTF-006',
      type: NotificationType.chat,
      title: 'Pertanyaan dari Pelanggan',
      message: 'User RNT-7766 menanyakan ketersediaan PS5 untuk akhir pekan.',
      date: '15 Okt 2025',
      time: '13:25 WIB',
      isUnread: true,
    ),
    NotificationItem(
      id: 'NTF-007',
      type: NotificationType.payment,
      title: 'Pembayaran Diterima',
      message: 'Pembayaran rental dari RNT-4455 berhasil diterima.',
      date: '14 Okt 2025',
      time: '10:15 WIB',
      isUnread: false,
    ),
  ];

  String _searchQuery = '';
  NotificationFilter _activeFilter = NotificationFilter.all;

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ============================================================
  // GETTER
  // ============================================================

  int get _unreadCount {
    return _notifications.where((item) => item.isUnread).length;
  }

  List<NotificationItem> get _filteredNotifications {
    List<NotificationItem> result = List.from(_notifications);

    // Filter status
    if (_activeFilter == NotificationFilter.unread) {
      result = result.where((item) => item.isUnread).toList();
    } else if (_activeFilter == NotificationFilter.read) {
      result = result.where((item) => !item.isUnread).toList();
    }

    // Filter pencarian
    if (_searchQuery.isNotEmpty) {
      result = result.where((item) {
        final content = [
          item.title,
          item.message,
          item.type.label,
          item.id,
        ].join(' ').toLowerCase();

        return content.contains(_searchQuery);
      }).toList();
    }

    return result;
  }

  // ============================================================
  // MARK AS READ
  // ============================================================

  void _markAllAsRead() {
    if (_unreadCount == 0) return;

    setState(() {
      for (final notification in _notifications) {
        notification.isUnread = false;
      }
    });

    _showMessage(
      'Semua notifikasi telah ditandai sebagai dibaca',
      icon: Icons.done_all_rounded,
    );
  }

  void _markAsRead(NotificationItem item) {
    if (!item.isUnread) return;

    setState(() {
      item.isUnread = false;
    });
  }

  // ============================================================
  // DELETE
  // ============================================================

  void _deleteNotification(NotificationItem item) {
    final originalIndex = _notifications.indexOf(item);

    setState(() {
      _notifications.remove(item);
    });

    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Notifikasi berhasil dihapus'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {
            setState(() {
              if (originalIndex >= 0 &&
                  originalIndex <= _notifications.length) {
                _notifications.insert(originalIndex, item);
              } else {
                _notifications.add(item);
              }
            });
          },
        ),
      ),
    );
  }

  // ============================================================
  // DELETE ALL
  // ============================================================

  Future<void> _deleteAllNotifications() async {
    if (_notifications.isEmpty) {
      _showMessage('Tidak ada notifikasi untuk dihapus');
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(
            'Hapus semua notifikasi?',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          content: const Text(
            'Semua notifikasi akan dihapus dari daftar. '
            'Tindakan ini dapat dibatalkan melalui tombol Undo.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Hapus Semua'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    final backup = List<NotificationItem>.from(_notifications);

    setState(() {
      _notifications.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Semua notifikasi telah dihapus'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {
            setState(() {
              _notifications.addAll(backup);
            });
          },
        ),
      ),
    );
  }

  // ============================================================
  // OPEN NOTIFICATION DETAIL
  // ============================================================

  void _openNotification(NotificationItem item) {
    _markAsRead(item);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _NotificationDetailSheet(item: item);
      },
    );
  }

  // ============================================================
  // FILTER
  // ============================================================

  void _changeFilter(NotificationFilter filter) {
    setState(() {
      _activeFilter = filter;
    });
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
    String message, {
    IconData icon = Icons.info_outline_rounded,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredNotifications;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildHeader(),

          _buildSearchBox(),

          _buildFilterBar(),

          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: filtered.isEmpty
                  ? _buildEmptyState()
                  : _buildNotificationList(filtered),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // APP BAR
  // ============================================================

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 1,
      leading: IconButton(
        tooltip: 'Kembali',
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Color(0xFF2D2D2D),
          size: 20,
        ),
        onPressed: () {
          Navigator.maybePop(context);
        },
      ),
      centerTitle: true,
      title: const Text(
        'Notifikasi',
        style: TextStyle(
          color: Color(0xFF242424),
          fontSize: 19,
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                tooltip: 'Notifikasi belum dibaca',
                onPressed: () {
                  _changeFilter(NotificationFilter.unread);
                },
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: Color(0xFF6B4C7D),
                  size: 26,
                ),
              ),
              if (_unreadCount > 0)
                Positioned(
                  right: 5,
                  top: 5,
                  child: Container(
                    constraints: const BoxConstraints(
                      minWidth: 19,
                      minHeight: 19,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE53935),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        _unreadCount > 99 ? '99+' : '$_unreadCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pusat Notifikasi',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF292929),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _unreadCount == 0
                      ? 'Semua notifikasi sudah dibaca'
                      : '$_unreadCount notifikasi belum dibaca',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          if (_unreadCount > 0)
            TextButton.icon(
              onPressed: _markAllAsRead,
              icon: const Icon(Icons.done_all_rounded, size: 17),
              label: const Text('Baca semua'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF6B4C7D),
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // SEARCH
  // ============================================================

  Widget _buildSearchBox() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 2, 20, 14),
      child: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Cari notifikasi...',
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
          prefixIcon: Icon(Icons.search_rounded, color: Colors.grey.shade500),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  tooltip: 'Hapus pencarian',
                  onPressed: () {
                    _searchController.clear();
                  },
                  icon: const Icon(Icons.close_rounded, size: 19),
                )
              : null,
          filled: true,
          fillColor: const Color(0xFFF5F5F7),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 13),
        ),
      ),
    );
  }

  // ============================================================
  // FILTER BAR
  // ============================================================

  Widget _buildFilterBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: Row(
        children: [
          _buildFilterChip(label: 'Semua', value: NotificationFilter.all),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: 'Belum Dibaca',
            value: NotificationFilter.unread,
            count: _unreadCount,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(label: 'Dibaca', value: NotificationFilter.read),
          const Spacer(),
          PopupMenuButton<NotificationType>(
            tooltip: 'Filter jenis',
            icon: const Icon(Icons.tune_rounded, color: Color(0xFF6B4C7D)),
            onSelected: (type) {
              setState(() {
                _activeFilter = NotificationFilter.type;
              });

              // Untuk filter tipe, pencarian digunakan sebagai
              // filter sementara.
              _searchController.text = type.label.toLowerCase();
            },
            itemBuilder: (context) {
              return NotificationType.values.map((type) {
                return PopupMenuItem<NotificationType>(
                  value: type,
                  child: Row(
                    children: [
                      Icon(type.icon, size: 20, color: type.color),
                      const SizedBox(width: 10),
                      Text(type.label),
                    ],
                  ),
                );
              }).toList();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required NotificationFilter value,
    int? count,
  }) {
    final selected = _activeFilter == value;

    return GestureDetector(
      onTap: () => _changeFilter(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF6B4C7D) : const Color(0xFFF2F2F4),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : const Color(0xFF555555),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (count != null && count > 0) ...[
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.white.withOpacity(0.2)
                      : const Color(0xFFE53935),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    color: selected ? Colors.white : Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ============================================================
  // NOTIFICATION LIST
  // ============================================================

  Widget _buildNotificationList(List<NotificationItem> items) {
    return ListView.separated(
      key: const ValueKey('notification_list'),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 30),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        return _buildNotificationCard(items[index]);
      },
    );
  }

  // ============================================================
  // NOTIFICATION CARD
  // ============================================================

  Widget _buildNotificationCard(NotificationItem item) {
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        return await showDialog<bool>(
              context: context,
              builder: (dialogContext) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  title: const Text(
                    'Hapus notifikasi?',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  content: Text('Notifikasi "${item.title}" akan dihapus.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(dialogContext, false);
                      },
                      child: const Text('Batal'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(dialogContext, true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Hapus'),
                    ),
                  ],
                );
              },
            ) ??
            false;
      },
      onDismissed: (_) {
        _deleteNotification(item);
      },
      background: _buildDeleteBackground(),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(17),
          onTap: () {
            _openNotification(item);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: item.isUnread ? const Color(0xFFF0EBF4) : Colors.white,
              borderRadius: BorderRadius.circular(17),
              border: Border.all(
                color: item.isUnread
                    ? const Color(0xFFE2D7E8)
                    : const Color(0xFFECECEF),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.035),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildNotificationIcon(item),

                const SizedBox(width: 13),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: item.isUnread
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                                color: const Color(0xFF282828),
                              ),
                            ),
                          ),
                          if (item.isUnread)
                            Container(
                              margin: const EdgeInsets.only(left: 8, top: 4),
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFFE53935),
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 5),

                      Text(
                        item.message,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.45,
                          color: Colors.grey.shade700,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Row(
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: 14,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '${item.date} • ${item.time}',
                            style: TextStyle(
                              fontSize: 10.5,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            item.type.label,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: item.type.color,
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
      ),
    );
  }

  Widget _buildNotificationIcon(NotificationItem item) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: item.type.color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(item.type.icon, color: item.type.color, size: 23),
    );
  }

  Widget _buildDeleteBackground() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red.shade600,
        borderRadius: BorderRadius.circular(17),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 22),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.delete_outline_rounded, color: Colors.white, size: 25),
          SizedBox(height: 3),
          Text(
            'Hapus',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState() {
    final isSearching = _searchQuery.isNotEmpty;

    return Center(
      key: const ValueKey('empty_state'),
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: const Color(0xFFF0EBF4),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(
                isSearching
                    ? Icons.search_off_rounded
                    : Icons.notifications_none_rounded,
                size: 44,
                color: const Color(0xFF6B4C7D),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              isSearching
                  ? 'Notifikasi tidak ditemukan'
                  : 'Belum ada notifikasi',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF333333),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              isSearching
                  ? 'Coba gunakan kata kunci lain untuk mencari notifikasi.'
                  : 'Semua aktivitas penting akan muncul di halaman ini.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                height: 1.5,
                color: Colors.grey.shade600,
              ),
            ),

            if (isSearching) ...[
              const SizedBox(height: 18),
              OutlinedButton(
                onPressed: () {
                  _searchController.clear();
                  _changeFilter(NotificationFilter.all);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF6B4C7D),
                ),
                child: const Text('Reset Pencarian'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ================================================================
// DETAIL NOTIFICATION SHEET
// ================================================================

class _NotificationDetailSheet extends StatelessWidget {
  final NotificationItem item;

  const _NotificationDetailSheet({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: item.type.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(item.type.icon, color: item.type.color, size: 26),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.type.label,
                        style: TextStyle(
                          color: item.type.color,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            const Text(
              'Detail Notifikasi',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),

            const SizedBox(height: 8),

            Text(
              item.message,
              style: TextStyle(
                fontSize: 13,
                height: 1.6,
                color: Colors.grey.shade700,
              ),
            ),

            const SizedBox(height: 18),

            Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.tag_rounded,
                    size: 17,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    item.id,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${item.date} • ${item.time}',
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B4C7D),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Tutup',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// ENUM FILTER
// ================================================================

enum NotificationFilter { all, unread, read, type }

// ================================================================
// NOTIFICATION TYPE
// ================================================================

enum NotificationType { chat, payment, paymentPending, returnLate, reservation }

extension NotificationTypeExtension on NotificationType {
  String get label {
    switch (this) {
      case NotificationType.chat:
        return 'Chat Baru';

      case NotificationType.payment:
        return 'Pembayaran';

      case NotificationType.paymentPending:
        return 'Menunggu Pembayaran';

      case NotificationType.returnLate:
        return 'Pengembalian';

      case NotificationType.reservation:
        return 'Reservasi';
    }
  }

  IconData get icon {
    switch (this) {
      case NotificationType.chat:
        return Icons.chat_bubble_outline_rounded;

      case NotificationType.payment:
        return Icons.payments_outlined;

      case NotificationType.paymentPending:
        return Icons.hourglass_empty_rounded;

      case NotificationType.returnLate:
        return Icons.warning_amber_rounded;

      case NotificationType.reservation:
        return Icons.calendar_month_outlined;
    }
  }

  Color get color {
    switch (this) {
      case NotificationType.chat:
        return const Color(0xFF6B4C7D);

      case NotificationType.payment:
        return const Color(0xFF2E9B57);

      case NotificationType.paymentPending:
        return const Color(0xFFF08A24);

      case NotificationType.returnLate:
        return const Color(0xFFD83A3A);

      case NotificationType.reservation:
        return const Color(0xFF3478C7);
    }
  }
}

// ================================================================
// MODEL
// ================================================================

class NotificationItem {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final String date;
  final String time;

  bool isUnread;

  NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.date,
    required this.time,
    required this.isUnread,
  });
}