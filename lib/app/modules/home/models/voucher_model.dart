class VoucherModel {
  final dynamic id;
  final String code;
  final int discountPercent;
  final String description;
  final DateTime validUntil;

  VoucherModel({
    this.id,
    required this.code,
    required this.discountPercent,
    required this.description,
    required this.validUntil,
  });

  // Mengubah JSON menjadi object VoucherModel
  factory VoucherModel.fromJson(Map<String, dynamic> json) {
    return VoucherModel(
      id: json['id'],
      code: json['code'] ?? '',
      discountPercent: json['discount_percent'] ?? 0,
      description: json['description'] ?? '',
      validUntil: DateTime.parse(json['valid_until']),
    );
  }

  // Mengubah object VoucherModel menjadi JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'code': code,
      'discount_percent': discountPercent,
      'description': description,
      'valid_until': validUntil.toIso8601String(),
    };
  }

  // Mengecek apakah voucher masih berlaku
  bool get isValid {
    return DateTime.now().isBefore(validUntil);
  }

  // Menghitung nominal diskon
  int calculateDiscount(int totalPrice) {
    return (totalPrice * discountPercent) ~/ 100;
  }

  // Menghitung harga setelah diskon
  int calculateFinalPrice(int totalPrice) {
    final discount = calculateDiscount(totalPrice);
    return totalPrice - discount;
  }
}
