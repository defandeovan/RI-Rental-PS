import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import 'home_content.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _navAnimationController;

  final List<NavItem> _navItems = [
    NavItem(Icons.home_rounded, Icons.home_outlined, 'Home'),
    NavItem(Icons.favorite_rounded, Icons.favorite_border_rounded, 'Favorite'),
    NavItem(Icons.local_offer_rounded, Icons.local_offer_outlined, 'Promo'),
    NavItem(Icons.person_rounded, Icons.person_outline_rounded, 'Profile'),
  ];

  @override
  void initState() {
    super.initState();
    _navAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _navAnimationController.forward();
  }

  @override
  void dispose() {
    _navAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _getSelectedPage(),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _getSelectedPage() {
    switch (_selectedIndex) {
      case 0:
        return const HomeContent();
      case 1:
        return _buildPlaceholderPage('Favorite', Icons.favorite);
      case 2:
        return _buildPlaceholderPage('Promo', Icons.local_offer);
      case 3:
        return _buildPlaceholderPage('Profile', Icons.person);
      default:
        return const HomeContent();
    }
  }

  Widget _buildPlaceholderPage(String title, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: AppColors.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Coming Soon',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 24),
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(
            _navItems.length,
                (index) => _buildNavItem(index, _navItems[index]),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, NavItem item) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onNavItemTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOutCubic,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.25) : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return ScaleTransition(
              scale: animation,
              child: child,
            );
          },
          child: Icon(
            isSelected ? item.activeIcon : item.inactiveIcon,
            key: ValueKey('${index}_$isSelected'),
            color: Colors.white,
            size: 26,
          ),
        ),
      ),
    );
  }

  void _onNavItemTapped(int index) {
    if (_selectedIndex != index) {
      HapticFeedback.selectionClick();

      setState(() {
        _selectedIndex = index;
      });

      // Smooth animation replay
      _navAnimationController.reset();
      _navAnimationController.forward();
    }
  }
}

class NavItem {
  final IconData activeIcon;
  final IconData inactiveIcon;
  final String label;

  NavItem(this.activeIcon, this.inactiveIcon, this.label);
}