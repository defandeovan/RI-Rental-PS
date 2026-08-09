
class RentalDuration {
  final int days;
  final String label;
  final int price;

  RentalDuration({
    required this.days,
    required this.label,
    required this.price,
  });

  // Pilihan durasi rental
  static final List<RentalDuration> durations = [
    RentalDuration(
      days: 1,
      label: '1 Hari',
      price: 50000,
    ),
    RentalDuration(
      days: 2,
      label: '2 Hari',
      price: 95000,
    ),
    RentalDuration(
      days: 3,
      label: '3 Hari',
      price: 135000,
    ),
    RentalDuration(
      days: 7,
      label: '1 Minggu',
      price: 300000,
    ),
    RentalDuration(
      days: 14,
      label: '2 Minggu',
      price: 550000,
    ),
    RentalDuration(
      days: 30,
      label: '1 Bulan',
      price: 1000000,
    ),
  ];
}

