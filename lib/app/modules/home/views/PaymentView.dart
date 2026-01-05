import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:async';
import 'dart:math';
import '../theme/app_colors.dart';
import '../models/RentalDuration.dart';
import '../services/midtrans_service.dart';
import '../services/supabase_service.dart';
import '../models/voucher_model.dart';
import 'VoucherView.dart';
import 'OrderHistoryScreen.dart';

class PaymentView extends StatefulWidget {
  final String productName;
  final String productImage;
  final RentalDuration rentalDuration;

  const PaymentView({
    Key? key,
    required this.productName,
    required this.productImage,
    required this.rentalDuration,
  }) : super(key: key);

  @override
  State<PaymentView> createState() => _PaymentViewState();
}

class _PaymentViewState extends State<PaymentView> {
  // Timer related
  late Timer _timer;
  int _timeLeft = 3600; // 1 jam dalam detik

  // Services

  final _supabaseService = SupabaseService.instance;

  // View control
  bool _isProcessing = false;
  String? _orderId;
  VoucherModel? _selectedVoucher;

  @override
  void initState() {
    super.initState();
    _startTimer();
    // Generate Order ID awal
    _orderId = 'RENT-${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        if(mounted) {
           setState(() {
             _timeLeft--;
           });
        }
      } else {
        _timer.cancel();
        // Handle timeout
      }
    });
  }

  String _formatTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int secs = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String _formatCurrency(int amount) {
    return 'Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  int get _subtotal => widget.rentalDuration.price;
  int get _tax => (_subtotal * 0.1).toInt();
  int get _discount => _selectedVoucher != null ? (_subtotal * _selectedVoucher!.discountPercent / 100).toInt() : 0;
  int get _total => _subtotal + _tax - _discount;

  Future<void> _processPayment() async {
    setState(() => _isProcessing = true);

    try {
      final transaction = await MidtransService.createTransaction(
        orderId: _orderId!,
        grossAmount: _total,
        customerDetails: {
          'first_name': _supabaseService.currentUser?.email?.split('@')[0] ?? 'Guest', // Simple name extraction
          'email': _supabaseService.currentUser?.email ?? 'guest@example.com',
          'phone': '08123456789', // Placeholder needed by Midtrans often
        },
        itemDetails: [
          {
            'id': widget.productName.replaceAll(' ', '_'),
            'price': _total,
            'quantity': 1,
            'name': widget.productName,
          }
        ],
      );
      
      if (transaction['token'] != null && transaction['redirect_url'] != null) {
          _processMidtransPayment(transaction['redirect_url']);
      } else {
          throw Exception('Invalid transaction data');
      }

    } catch (e) {
      setState(() => _isProcessing = false);
      _showErrorDialog(e.toString());
    }
  }

  void _processMidtransPayment(String startUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Pembayaran'),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
          ),
          body: WebViewWidget(
            controller: WebViewController()
            ..setJavaScriptMode(JavaScriptMode.unrestricted)
            ..setBackgroundColor(const Color(0x00000000))
            ..setNavigationDelegate(
              NavigationDelegate(
                onPageStarted: (String url) {
                    if (url.contains('status_code=200') || url.contains('transaction_status=settlement')) {
                       _handlePaymentSuccess();
                    } else if (url.contains('status_code=202') || url.contains('transaction_status=deny')) {
                        // Failed
                        Navigator.pop(context); // Close webview
                        _showErrorDialog('Pembayaran ditolak atau gagal.');
                    }
                },
                onWebResourceError: (WebResourceError error) {},
              ),
            )
            ..loadRequest(Uri.parse(startUrl)),
          ),
        ),
      ),
    ).then((_) {
        // Upon returning from webview (if manually closed), check status one last time or just reset
        if (_isProcessing) { // If still processing, it means we didn't finish purely
            setState(() => _isProcessing = false);
        }
    });
  }

  Future<void> _handlePaymentSuccess() async {
      // 1. Create order in Supabase
      if (_supabaseService.userId != null) {
          await _supabaseService.createOrder({
              'id': _orderId,
              'user_id': _supabaseService.userId,
              'product_name': widget.productName,
              'product_image': widget.productImage, // Store asset path or url
              'rental_duration': widget.rentalDuration.label,
              'total_price': _total,
              'status': 'Selesai', // Assuming success immediately for demo
              'order_date': DateTime.now().toIso8601String(),
          });
      }

      // 2. Show Success Dialog
      // Need to find the context - since we are in a pushed route (WebView), we might need to pop first or use a key.
      // Easiest is to pop the webview returning a result.
      Navigator.pop(context); // Close WebView
      
      _showSuccessDialog();
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.success,
                  size: 48,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Pembayaran Berhasil!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Terima kasih telah menyewa di RI Rental PS',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    Navigator.push(context, MaterialPageRoute(builder: (c) => const OrderHistoryScreen()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Lihat Pesanan Saya'),
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
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  color: Colors.red,
                  size: 48,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Pembayaran Gagal',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Coba Lagi'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Pembayaran', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Timer Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                   const Icon(Icons.timer_outlined, color: Colors.orange),
                   const SizedBox(width: 12),
                   Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       const Text(
                         'Selesaikan pembayaran dalam',
                         style: TextStyle(fontSize: 12, color: Colors.orange),
                       ),
                       Text(
                         _formatTime(_timeLeft),
                         style: const TextStyle(
                           fontSize: 16,
                           fontWeight: FontWeight.bold,
                           color: Colors.deepOrange,
                         ),
                       ),
                     ],
                   )
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Order Summary
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Ringkasan Pesanan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          widget.productImage,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Container(color: Colors.grey[200], width: 60, height: 60),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.productName, style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text(widget.rentalDuration.label, style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Voucher Section
            GestureDetector(
              onTap: () async {
                 final voucher = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const VoucherView(isSelectionMode: true),
                    ),
                 );
                 if (voucher != null && voucher is VoucherModel) {
                     setState(() {
                         _selectedVoucher = voucher;
                     });
                 }
              },
              child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Row(
                      children: [
                          const Icon(Icons.local_offer_outlined, color: AppColors.primary),
                          const SizedBox(width: 12),
                          Expanded(
                              child: Text(
                                  _selectedVoucher != null ? '${_selectedVoucher!.code} applied' : 'Gunakan Voucher',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: _selectedVoucher != null ? AppColors.success : AppColors.textPrimary,
                                  ),
                              ),
                          ),
                          if (_selectedVoucher != null)
                             GestureDetector(
                                 onTap: () {
                                     setState(() => _selectedVoucher = null);
                                 },
                                 child: const Icon(Icons.close, color: Colors.grey),
                             )
                          else
                             const Icon(Icons.chevron_right, color: Colors.grey),
                      ],
                  ),
              ),
            ),

            const SizedBox(height: 20),

            // Price Details
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                 children: [
                    _buildPriceRow('Subtotal', _subtotal),
                    _buildPriceRow('Pajak (10%)', _tax),
                    if (_selectedVoucher != null)
                        _buildPriceRow('Diskon Voucher', -_discount, isNegative: true),
                    const Divider(height: 32),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                            const Text('Total Pembayaran', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text(_formatCurrency(_total), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary)),
                        ],
                    ),
                 ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -4))],
        ),
        child: ElevatedButton(
          onPressed: _isProcessing ? null : _processPayment,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: _isProcessing 
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text(
                  'BAYAR SEKARANG',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, int amount, {bool isNegative = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(
            '${isNegative ? '-' : ''}${_formatCurrency(amount)}',
            style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isNegative ? AppColors.success : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}