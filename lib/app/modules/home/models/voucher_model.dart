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

  factory VoucherModel.fromJson(Map<String, dynamic> json) {
    return VoucherModel(
      id: json['id'],
      code: json['code'],
      discountPercent: json['discount_percent'],
      description: json['description'],
      validUntil: DateTime.parse(json['valid_until']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'discount_percent': discountPercent,
      'description': description,
      'valid_until': validUntil.toIso8601String(),
    };
  }
}
