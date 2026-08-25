import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

class MidtransService {
  // ============================================================
  // KONFIGURASI
  // ============================================================

  // JANGAN simpan Server Key di aplikasi Flutter production.
  // Server Key seharusnya berada di backend.
  static const String _serverKey = 'YOUR_SERVER_KEY';

  // false = Sandbox
  // true  = Production
  static const bool _isProduction = false;

  // ============================================================
  // BASE URL
  // ============================================================

  static String get _baseUrl {
    return _isProduction
        ? 'https://api.midtrans.com/v2'
        : 'https://api.sandbox.midtrans.com/v2';
  }

  static String get _snapUrl {
    return _isProduction
        ? 'https://app.midtrans.com/snap/v1'
        : 'https://app.sandbox.midtrans.com/snap/v1';
  }

  // ============================================================
  // AUTHORIZATION
  // ============================================================

  static String get _authorization {
    final credentials = base64Encode(
      utf8.encode('$_serverKey:'),
    );

    return 'Basic $credentials';
  }

  // ============================================================
  // CREATE TRANSACTION
  // ============================================================

  /// Generate Snap Token untuk transaksi.
  static Future<Map<String, dynamic>> createTransaction({
    required String orderId,
    required int grossAmount,
    required Map<String, dynamic> customerDetails,
    required List<Map<String, dynamic>> itemDetails,
    String? paymentType,
  }) async {
    try {
      // Validasi order ID
      if (orderId.trim().isEmpty) {
        return {
          'success': false,
          'message': 'Order ID tidak boleh kosong.',
        };
      }

      // Validasi nominal
      if (grossAmount <= 0) {
        return {
          'success': false,
          'message': 'Gross amount harus lebih dari 0.',
        };
      }

      final url = Uri.parse('$_snapUrl/transactions');

      final body = <String, dynamic>{
        'transaction_details': {
          'order_id': orderId,
          'gross_amount': grossAmount,
        },
        'customer_details': customerDetails,
        'item_details': itemDetails,
      };

      // Jika paymentType diberikan,
      // tambahkan enabled_payments.
      if (paymentType != null && paymentType.isNotEmpty) {
        body['enabled_payments'] = [paymentType];
      }

      print('====================================');
      print('MIDTRANS CREATE TRANSACTION');
      print('URL: $url');
      print('Order ID: $orderId');
      print('Gross Amount: $grossAmount');
      print('Payment Type: $paymentType');
      print('Request Body: ${jsonEncode(body)}');
      print('====================================');

      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': _authorization,
        },
        body: jsonEncode(body),
      );

      print('Midtrans Status Code: ${response.statusCode}');
      print('Midtrans Response: ${response.body}');

      // Midtrans mengembalikan 201 ketika Snap token berhasil dibuat.
      if (response.statusCode == 201 ||
          response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return {
          'success': true,
          'token': data['token'],
          'redirect_url': data['redirect_url'],
          'data': data,
        };
      }

      // Coba membaca error JSON dari Midtrans
      String message = 'Gagal membuat transaksi.';

      try {
        final errorData = jsonDecode(response.body);

        if (errorData is Map<String, dynamic>) {
          if (errorData['error_messages'] != null) {
            message = errorData['error_messages'].toString();
          } else if (errorData['status_message'] != null) {
            message = errorData['status_message'].toString();
          } else {
            message = response.body;
          }
        }
      } catch (_) {
        message = response.body;
      }

      return {
        'success': false,
        'status_code': response.statusCode,
        'message': message,
        'data': response.body,
      };
    } catch (e) {
      print('Midtrans createTransaction error: $e');

      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  // ============================================================
  // CHECK TRANSACTION STATUS
  // ============================================================

  /// Mengecek status transaksi berdasarkan order ID.
  static Future<Map<String, dynamic>> checkTransactionStatus(
    String orderId,
  ) async {
    try {
      if (orderId.trim().isEmpty) {
        return {
          'success': false,
          'message': 'Order ID tidak boleh kosong.',
        };
      }

      final url = Uri.parse(
        '$_baseUrl/${Uri.encodeComponent(orderId)}/status',
      );

      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': _authorization,
        },
      );

      print('Check Status Code: ${response.statusCode}');
      print('Check Status Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return {
          'success': true,
          'transaction_status': data['transaction_status'],
          'fraud_status': data['fraud_status'],
          'status_message': data['status_message'],
          'payment_type': data['payment_type'],
          'data': data,
        };
      }

      return {
        'success': false,
        'status_code': response.statusCode,
        'message': 'Gagal mengecek status transaksi.',
        'data': response.body,
      };
    } catch (e) {
      print('Midtrans checkTransactionStatus error: $e');

      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  // ============================================================
  // CANCEL TRANSACTION
  // ============================================================

  /// Membatalkan transaksi berdasarkan order ID.
  static Future<Map<String, dynamic>> cancelTransaction(
    String orderId,
  ) async {
    try {
      if (orderId.trim().isEmpty) {
        return {
          'success': false,
          'message': 'Order ID tidak boleh kosong.',
        };
      }

      final url = Uri.parse(
        '$_baseUrl/${Uri.encodeComponent(orderId)}/cancel',
      );

      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': _authorization,
        },
      );

      print('Cancel Status Code: ${response.statusCode}');
      print('Cancel Response: ${response.body}');

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Transaction cancelled successfully.',
          'data': jsonDecode(response.body),
        };
      }

      return {
        'success': false,
        'status_code': response.statusCode,
        'message': 'Gagal membatalkan transaksi.',
        'data': response.body,
      };
    } catch (e) {
      print('Midtrans cancelTransaction error: $e');

      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  // ============================================================
  // GENERATE SIGNATURE
  // ============================================================

  /// Generate SHA-512 signature untuk verifikasi notifikasi Midtrans.
  static String generateSignature(
    String orderId,
    String statusCode,
    String grossAmount,
  ) {
    final input =
        '$orderId$statusCode$grossAmount$_serverKey';

    return sha512
        .convert(utf8.encode(input))
        .toString();
  }

  // ============================================================
  // VERIFY NOTIFICATION
  // ============================================================

  /// Memverifikasi signature dari notifikasi Midtrans.
  static bool verifyNotification({
    required String orderId,
    required String statusCode,
    required String grossAmount,
    required String signatureKey,
  }) {
    final generatedSignature = generateSignature(
      orderId,
      statusCode,
      grossAmount,
    );

    return generatedSignature == signatureKey;
  }

  // ============================================================
  // PAYMENT NAME
  // ============================================================

  /// Mengubah payment type menjadi nama yang lebih mudah dibaca.
  static String getPaymentName(String paymentType) {
    switch (paymentType.toLowerCase()) {
      case 'gopay':
        return 'GoPay';

      case 'dana':
        return 'DANA';

      case 'shopeepay':
        return 'ShopeePay';

      case 'qris':
        return 'QRIS';

      case 'bca_va':
        return 'BCA Virtual Account';

      case 'bni_va':
        return 'BNI Virtual Account';

      case 'bri_va':
        return 'BRI Virtual Account';

      case 'echannel':
        return 'Mandiri Virtual Account';

      case 'permata_va':
        return 'Permata Virtual Account';

      case 'credit_card':
        return 'Kartu Kredit/Debit';

      case 'cstore':
        return 'Convenience Store';

      case 'alfamart':
        return 'Alfamart';

      case 'indomaret':
        return 'Indomaret';

      default:
        return 'Unknown Payment Method';
    }
  }
}