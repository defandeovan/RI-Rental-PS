import 'package:flutter/material.dart';
import 'dart:async';
import '../models/RentalDuration.dart';
import '../theme/app_colors.dart';
import '../services/midtrans_service.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:math';

class PaymentView extends StatefulWidget {
  final String productName;
  final String productImage;
  final RentalDuration rentalDuration;
  final DateTime selectedDate;
  final String selectedTime;
  final String packageType;
  final int hourlyDuration;
  final int totalAmount;

  const PaymentView({
    Key? key,
    required this.productName,
    required this.productImage,
    required this.rentalDuration,
    required this.selectedDate,
    required this.selectedTime,
    required this.packageType,
    required this.hourlyDuration,
    required this.totalAmount,
  }) : super(key: key);

  @override
  State<PaymentView> createState() => _PaymentViewState();
}

class _PaymentViewState extends State<PaymentView> {
  String _selectedPayment = 'gopay';
  Timer? _countdownTimer;
  int _remainingSeconds = 1439; // 23:59 in seconds
  bool _isProcessing = false;
  String? _snapToken;
  String? _redirectUrl;
  String? _orderId;

  final List<PaymentMethod> _paymentMethods = [
    PaymentMethod(
      id: 'gopay',
      name: 'GoPay',
      logo: Icons.account_balance_wallet,
      type: 'E-Wallet',
      subtitle: 'Bayar dengan GoPay',
      midtransPaymentType: 'gopay',
    ),
    PaymentMethod(
      id: 'dana',
      name: 'DANA',
      logo: Icons.account_balance_wallet,
      type: 'E-Wallet',
      subtitle: 'Bayar dengan DANA',
      midtransPaymentType: 'dana',
    ),
    PaymentMethod(
      id: 'shopeepay',
      name: 'ShopeePay',
      logo: Icons.account_balance_wallet,
      type: 'E-Wallet',
      subtitle: 'Bayar dengan ShopeePay',
      midtransPaymentType: 'shopeepay',
    ),
    PaymentMethod(
      id: 'qris',
      name: 'QRIS',
      logo: Icons.qr_code_2,
      type: 'QR Payment',
      subtitle: 'Scan QR untuk bayar',
      midtransPaymentType: 'qris',
    ),
    PaymentMethod(
      id: 'bca_va',
      name: 'BCA Virtual Account',
      logo: Icons.account_balance,
      type: 'Bank Transfer',
      subtitle: 'Transfer via BCA VA',
      midtransPaymentType: 'bca_va',
    ),
    PaymentMethod(
      id: 'bni_va',
      name: 'BNI Virtual Account',
      logo: Icons.account_balance,
      type: 'Bank Transfer',
      subtitle: 'Transfer via BNI VA',
      midtransPaymentType: 'bni_va',
    ),
    PaymentMethod(
      id: 'bri_va',
      name: 'BRI Virtual Account',
      logo: Icons.account_balance,
      type: 'Bank Transfer',
      subtitle: 'Transfer via BRI VA',
      midtransPaymentType: 'bri_va',
    ),
    PaymentMethod(
      id: 'mandiri_va',
      name: 'Mandiri Virtual Account',
      logo: Icons.account_balance,
      type: 'Bank Transfer',
      subtitle: 'Transfer via Mandiri VA',
      midtransPaymentType: 'echannel',
    ),
    PaymentMethod(
      id: 'permata_va',
      name: 'Permata Virtual Account',
      logo: Icons.account_balance,
      type: 'Bank Transfer',
      subtitle: 'Transfer via Permata VA',
      midtransPaymentType: 'permata_va',
    ),
    PaymentMethod(
      id: 'credit_card',
      name: 'Kartu Kredit/Debit',
      logo: Icons.credit_card,
      type: 'Card Payment',
      subtitle: 'Visa, Mastercard, JCB',
      midtransPaymentType: 'credit_card',
    ),
    PaymentMethod(
      id: 'indomaret',
      name: 'Indomaret',
      logo: Icons.store,
      type: 'Convenience Store',
      subtitle: 'Bayar di Indomaret',
      midtransPaymentType: 'cstore',
    ),
    PaymentMethod(
      id: 'alfamart',
      name: 'Alfamart',
      logo: Icons.store,
      type: 'Convenience Store',
      subtitle: 'Bayar di Alfamart',
      midtransPaymentType: 'cstore',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startCountdown();
    _generateOrderId();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _generateOrderId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(9999);
    _orderId = 'ORDER-$timestamp-$random';
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        timer.cancel();
        _showTimeoutDialog();
      }
    });
  }

  String _formatCountdown() {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String _formatCurrency(int amount) {
    return 'Rp. ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _processPayment() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      await _processMidtransPayment();
    } catch (e) {
      _showErrorDialog('Terjadi kesalahan: $e');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _processMidtransPayment() async {
    // Tampilkan loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // Siapkan data customer
    final customerDetails = {
      'first_name': 'Customer',
      'last_name': 'PS Rental',
      'email': 'customer@example.com',
      'phone': '081234567890',
    };

    // Siapkan item details
    final itemDetails = [
      {
        'id': 'ps-rental-${widget.packageType}',
        'price': widget.totalAmount,
        'quantity': 1,
        'name': '${widget.productName} - ${widget.packageType == 'hourly' ? '${widget.hourlyDuration} Jam' : 'Harian'}',
      }
    ];

    // Dapatkan payment method yang dipilih
    final selectedMethod = _paymentMethods.firstWhere((m) => m.id == _selectedPayment);

    // Create transaction dengan Midtrans
    final result = await MidtransService.createTransaction(
      orderId: _orderId!,
      grossAmount: widget.totalAmount,
      customerDetails: customerDetails,
      itemDetails: itemDetails,
      paymentType: selectedMethod.midtransPaymentType,
    );

    // Tutup loading dialog
    Navigator.pop(context);

    if (result['success']) {
      setState(() {
        _snapToken = result['token'];
        _redirectUrl = result['redirect_url'];
      });

      // Buka payment page dengan WebView
      _openMidtransPaymentPage();
    } else {
      _showErrorDialog(result['message'] ?? 'Gagal membuat transaksi');
    }
  }

  void _openMidtransPaymentPage() {
    if (_redirectUrl == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MidtransPaymentPage(
          url: _redirectUrl!,
          orderId: _orderId!,
          paymentMethod: _selectedPayment,
          onFinish: (status) {
            Navigator.pop(context);
            if (status == 'success') {
              _showPaymentSuccessDialog();
            } else if (status == 'pending') {
              _showPaymentPendingDialog();
            } else {
              _showPaymentFailedDialog();
            }
          },
        ),
      ),
    );
  }

  Future<void> _checkPaymentStatus() async {
    if (_orderId == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    final result = await MidtransService.checkTransactionStatus(_orderId!);
    Navigator.pop(context);

    if (result['success']) {
      final transactionStatus = result['transaction_status'];

      if (transactionStatus == 'settlement' || transactionStatus == 'capture') {
        _showPaymentSuccessDialog();
      } else if (transactionStatus == 'pending') {
        _showPaymentPendingDialog();
      } else if (transactionStatus == 'deny' || transactionStatus == 'cancel' || transactionStatus == 'expire') {
        _showPaymentFailedDialog();
      }
    } else {
      _showErrorDialog('Gagal mengecek status pembayaran');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: AppColors.textPrimary,
        ),
        title: const Text(
          'Ringkasan Pesanan',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (_orderId != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _checkPaymentStatus,
              tooltip: 'Cek Status Pembayaran',
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOrderSummary(),
                  const SizedBox(height: 16),
                  _buildPriceDetails(),
                  const SizedBox(height: 16),
                  _buildPaymentMethods(),
                  const SizedBox(height: 16),
                  _buildPaymentInfo(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          _buildBottomButton(),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: AppColors.info,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Menunggu',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.info,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                'ID: ${_orderId?.substring(0, 15) ?? 'Loading'}...',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.divider, height: 1),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Produk',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Flexible(
                child: Text(
                  widget.productName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tanggal',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Text(
                _formatDate(widget.selectedDate),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Jam',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Text(
                widget.selectedTime,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Paket',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Text(
                widget.packageType == 'hourly' ? 'Hourly Package' : 'Daily Package',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          if (widget.packageType == 'hourly') ...[
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Durasi',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                Text(
                  '${widget.hourlyDuration} Jam',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPriceDetails() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF5F3FF), Color(0xFFE8E4FF)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Pembayaran',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _formatCurrency(widget.totalAmount),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pilih Metode Pembayaran',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          // E-Wallet Section
          _buildPaymentSection(
            'E-Wallet',
            _paymentMethods.where((m) => m.type == 'E-Wallet').toList(),
          ),
          const SizedBox(height: 16),

          // QR Payment Section
          _buildPaymentSection(
            'QR Payment',
            _paymentMethods.where((m) => m.type == 'QR Payment').toList(),
          ),
          const SizedBox(height: 16),

          // Bank Transfer Section
          _buildPaymentSection(
            'Bank Transfer',
            _paymentMethods.where((m) => m.type == 'Bank Transfer').toList(),
          ),
          const SizedBox(height: 16),

          // Card Payment Section
          _buildPaymentSection(
            'Kartu Kredit/Debit',
            _paymentMethods.where((m) => m.type == 'Card Payment').toList(),
          ),
          const SizedBox(height: 16),

          // Convenience Store Section
          _buildPaymentSection(
            'Convenience Store',
            _paymentMethods.where((m) => m.type == 'Convenience Store').toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSection(String title, List<PaymentMethod> methods) {
    if (methods.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider, width: 1),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowLight,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: methods.asMap().entries.map((entry) {
              final index = entry.key;
              final method = entry.value;
              final isLast = index == methods.length - 1;
              return Column(
                children: [
                  _buildPaymentMethodItem(method),
                  if (!isLast) const Divider(color: AppColors.divider, height: 1),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodItem(PaymentMethod method) {
    final isSelected = _selectedPayment == method.id;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedPayment = method.id;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                )
                    : LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.1),
                    AppColors.primary.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                method.logo,
                color: isSelected ? Colors.white : AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                  if (method.subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      method.subtitle!,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.grey,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Center(
                child: Icon(
                  Icons.circle,
                  size: 8,
                  color: Colors.white,
                ),
              )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentInfo() {
    final selectedMethod = _paymentMethods.firstWhere(
          (m) => m.id == _selectedPayment,
      orElse: () => _paymentMethods.first,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.info.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.info,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Anda akan melakukan pembayaran menggunakan ${selectedMethod.name}',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.info,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.access_time,
                  size: 18,
                  color: AppColors.warning,
                ),
                const SizedBox(width: 8),
                Text(
                  'Selesaikan dalam ',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.warning,
                  ),
                ),
                Text(
                  _formatCountdown(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border(
          top: BorderSide(color: AppColors.divider, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowMedium,
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isProcessing ? null : _processPayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: _isProcessing
                ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
                : const Text(
              'BAYAR SEKARANG',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showPaymentSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 50,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Pembayaran Berhasil!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Pesanan Anda telah dikonfirmasi',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Kembali ke Beranda',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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

  void _showPaymentPendingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.schedule,
                  color: AppColors.warning,
                  size: 50,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Pembayaran Pending',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Silakan selesaikan pembayaran Anda',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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

  void _showPaymentFailedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cancel,
                  color: AppColors.error,
                  size: 50,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Pembayaran Gagal',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Silakan coba lagi atau pilih metode pembayaran lain',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Coba Lagi',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showTimeoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Waktu Habis'),
        content: const Text('Waktu pembayaran telah habis. Silakan buat pesanan baru.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class PaymentMethod {
  final String id;
  final String name;
  final IconData logo;
  final String type;
  final String? subtitle;
  final String midtransPaymentType;

  PaymentMethod({
    required this.id,
    required this.name,
    required this.logo,
    required this.type,
    this.subtitle,
    required this.midtransPaymentType,
  });
}

// WebView Page untuk Midtrans Payment
class MidtransPaymentPage extends StatefulWidget {
  final String url;
  final String orderId;
  final String paymentMethod;
  final Function(String status) onFinish;

  const MidtransPaymentPage({
    Key? key,
    required this.url,
    required this.orderId,
    required this.paymentMethod,
    required this.onFinish,
  }) : super(key: key);

  @override
  State<MidtransPaymentPage> createState() => _MidtransPaymentPageState();
}

class _MidtransPaymentPageState extends State<MidtransPaymentPage> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });

            // Check if payment is completed based on URL
            if (url.contains('status_code=200') || url.contains('transaction_status=settlement')) {
              widget.onFinish('success');
            } else if (url.contains('status_code=201') || url.contains('transaction_status=pending')) {
              widget.onFinish('pending');
            } else if (url.contains('status_code=202') || url.contains('transaction_status=deny')) {
              widget.onFinish('failed');
            }
          },
          onWebResourceError: (WebResourceError error) {
            print('WebView error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pembayaran ${widget.paymentMethod.toUpperCase()}'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            _showCancelConfirmation();
          },
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  void _showCancelConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Batalkan Pembayaran?'),
        content: const Text('Apakah Anda yakin ingin membatalkan pembayaran ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tidak'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onFinish('cancelled');
            },
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );
  }
}