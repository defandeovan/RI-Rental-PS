import 'package:flutter/material.dart';
import '../theme/app_colors.dart';// Import model yang sama
import 'PaymentView.dart';
import '../models/RentalDuration.dart';

class BookingView extends StatefulWidget {
  final String productName;
  final String productImage;
  final RentalDuration rentalDuration;

  const BookingView({
    Key? key,
    required this.productName,
    required this.productImage,
    required this.rentalDuration,
  }) : super(key: key);

  @override
  State<BookingView> createState() => _BookingViewState();
}

class _BookingViewState extends State<BookingView> {
  DateTime _selectedDate = DateTime.now();
  String _selectedPackage = 'hourly';
  String _selectedTime = '08:00';
  int _hourlyDuration = 3;

  final List<PackageOption> _packages = [
    PackageOption(
      id: 'hourly',
      name: 'Hourly Package',
      price: 10000,
      duration: 'Per Hour',
      icon: Icons.access_time,
    ),
    PackageOption(
      id: 'daily',
      name: 'Daily Package',
      price: 200000,
      duration: 'Per Day',
      icon: Icons.calendar_today,
    ),
  ];

  final List<String> _timeSlots = [
    '08:00', '09:00', '10:00', '11:00', '12:00', '13:00',
    '14:00', '15:00', '16:00', '17:00', '18:00', '20:00', '21:00', '22:00',
  ];

  String _formatCurrency(int amount) {
    return 'Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  int _calculateTotal() {
    if (_selectedPackage == 'hourly') {
      return 10000 * _hourlyDuration;
    } else {
      return 200000;
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
          'Sewa PS',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
            color: AppColors.textPrimary,
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.share_outlined),
            color: AppColors.textPrimary,
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
                  _buildDatePicker(),
                  const SizedBox(height: 24),
                  _buildPackageSelection(),
                  const SizedBox(height: 24),
                  _buildTimeSelection(),
                  const SizedBox(height: 24),
                  if (_selectedPackage == 'hourly') _buildDurationSelection(),
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

  Widget _buildDatePicker() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Pilih Tanggal',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '${_selectedDate.month}/${_selectedDate.year}',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildCalendar(),
          const SizedBox(height: 16),
          _buildCalendarLegend(),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
    final lastDayOfMonth = DateTime(_selectedDate.year, _selectedDate.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    final startingWeekday = firstDayOfMonth.weekday % 7;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa']
              .map((day) => SizedBox(
            width: 35,
            child: Center(
              child: Text(
                day,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ))
              .toList(),
        ),
        const SizedBox(height: 8),
        ...List.generate((daysInMonth + startingWeekday) ~/ 7 + 1, (weekIndex) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (dayIndex) {
                final dayNumber = weekIndex * 7 + dayIndex - startingWeekday + 1;
                if (dayNumber < 1 || dayNumber > daysInMonth) {
                  return const SizedBox(width: 35, height: 35);
                }

                final date = DateTime(_selectedDate.year, _selectedDate.month, dayNumber);
                final isSelected = date.day == _selectedDate.day &&
                    date.month == _selectedDate.month &&
                    date.year == _selectedDate.year;
                final isToday = date.day == now.day &&
                    date.month == now.month &&
                    date.year == now.year;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDate = date;
                    });
                  },
                  child: Container(
                    width: 35,
                    height: 35,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : isToday
                          ? AppColors.primary.withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '$dayNumber',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? Colors.white
                              : isToday
                              ? AppColors.primary
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildCalendarLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem(AppColors.primary, 'Full'),
        const SizedBox(width: 16),
        _buildLegendItem(Colors.orange, 'On Venue'),
        const SizedBox(width: 16),
        _buildLegendItem(AppColors.success, 'Booking'),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildPackageSelection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pilih Paket',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ..._packages.map((package) => _buildPackageCard(package)),
        ],
      ),
    );
  }

  Widget _buildPackageCard(PackageOption package) {
    final isSelected = _selectedPackage == package.id;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPackage = package.id;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDark],
          )
              : null,
          color: isSelected ? null : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.transparent : AppColors.divider,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primary.withOpacity(0.3)
                  : AppColors.shadowLight,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.2)
                    : AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                package.icon,
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
                    package.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    package.duration,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected
                          ? Colors.white.withOpacity(0.8)
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              _formatCurrency(package.price),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSelection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pilih Jam',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _timeSlots.map((time) {
              final isSelected = _selectedTime == time;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedTime = time;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.divider,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    time,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDurationSelection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Durasi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider, width: 1),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowLight,
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Jam (Hour): $_hourlyDuration',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: _hourlyDuration > 1
                          ? () {
                        setState(() {
                          _hourlyDuration--;
                        });
                      }
                          : null,
                      icon: const Icon(Icons.remove_circle_outline),
                      color: AppColors.primary,
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _hourlyDuration++;
                        });
                      },
                      icon: const Icon(Icons.add_circle_outline),
                      color: AppColors.primary,
                    ),
                  ],
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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PaymentView(
                    productName: widget.productName,
                    productImage: widget.productImage,
                    rentalDuration: widget.rentalDuration,
                    selectedDate: _selectedDate,
                    selectedTime: _selectedTime,
                    packageType: _selectedPackage,
                    hourlyDuration: _hourlyDuration,
                    totalAmount: _calculateTotal(),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'CONFIRM',
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
}

class PackageOption {
  final String id;
  final String name;
  final int price;
  final String duration;
  final IconData icon;

  PackageOption({
    required this.id,
    required this.name,
    required this.price,
    required this.duration,
    required this.icon,
  });
}