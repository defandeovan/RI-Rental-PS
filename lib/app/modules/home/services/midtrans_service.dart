import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

class MidtransService {
 

static String get _serverKey => 'SB-Mid-server-s8G899IlsKSK-CliYZ7XHzKO';

static bool get _isProduction => false;
  // Base URLs
  static String get _baseUrl => _isProduction
      ? 'https://api.midtrans.com/v2'
      : 'https://api.sandbox.midtrans.com/v2';

  static String get _snapUrl => _isProduction
      ? 'https://app.midtrans.com/snap/v1'
      : 'https://app.sandbox.midtrans.com/snap/v1';

  /// Generate Snap Token untuk transaksi
  static Future<Map<String, dynamic>> createTransaction({
    required String orderId,
    required int grossAmount,
    required Map<String, dynamic> customerDetails,
    required List<Map<String, dynamic>> itemDetails,
    String? paymentType, // Tambahan parameter untuk specify payment type
  }) async {
    try {
      final url = Uri.parse('$_snapUrl/transactions');

      // Encode Server Key untuk Basic Auth
      final auth = base64Encode(utf8.encode('$_serverKey:'));

      // Enabled payments restriction removed to show all available methods
      // specified in the Midtrans Dashboard.

      final body = {
        'transaction_details': {
          'order_id': orderId,
          'gross_amount': grossAmount,
        },
        'customer_details': customerDetails,
        'item_details': itemDetails,
      };

      print('Creating transaction with body: ${jsonEncode(body)}');

      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Basic $auth',
        },
        body: jsonEncode(body),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'token': data['token'],
          'redirect_url': data['redirect_url'],
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to create transaction: ${response.body}',
        };
      }
    } catch (e) {
      print('Error in createTransaction: $e');
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Cek status transaksi
  static Future<Map<String, dynamic>> checkTransactionStatus(String orderId) async {
    try {
      final url = Uri.parse('$_baseUrl/$orderId/status');
      final auth = base64Encode(utf8.encode('$_serverKey:'));

      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Basic $auth',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'transaction_status': data['transaction_status'],
          'fraud_status': data['fraud_status'],
          'status_message': data['status_message'],
          'data': data,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to check status: ${response.body}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Cancel transaksi
  static Future<Map<String, dynamic>> cancelTransaction(String orderId) async {
    try {
      final url = Uri.parse('$_baseUrl/$orderId/cancel');
      final auth = base64Encode(utf8.encode('$_serverKey:'));

      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Basic $auth',
        },
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Transaction cancelled',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to cancel: ${response.body}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Generate signature untuk verifikasi notifikasi
  static String generateSignature(String orderId, String statusCode, String grossAmount) {
    final input = '$orderId$statusCode$grossAmount$_serverKey';
    return sha512.convert(utf8.encode(input)).toString();
  }

  /// Verifikasi notifikasi dari Midtrans
  static bool verifyNotification(
      String orderId,
      String statusCode,
      String grossAmount,
      String signatureKey,
      ) {
    final generatedSignature = generateSignature(orderId, statusCode, grossAmount);
    return generatedSignature == signatureKey;
  }

  /// Get payment name dari payment type
  static String getPaymentName(String paymentType) {
    switch (paymentType) {
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
      default:
        return 'Unknown Payment Method';
    }
  }
}
