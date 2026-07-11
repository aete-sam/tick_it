import 'package:flutter/material.dart';
import 'package:tick_it/config/routes.dart';
import 'package:tick_it/screens/calendar_screen.dart';
import 'package:tick_it/screens/home_screen.dart';
import 'package:tick_it/screens/profile_screen.dart';
import 'package:tick_it/config/theme.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    CalendarScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primaryLight.withValues(alpha: 0.3),
        destinations: [
          NavigationDestination(
            icon: SvgPicture.asset('assets/icons/home.svg', width: 24, height: 24, colorFilter: const ColorFilter.mode(AppColors.textHint, BlendMode.srcIn)),
            selectedIcon: SvgPicture.asset('assets/icons/home.svg', width: 24, height: 24, colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn)),
            label: 'Home',
          ),
          NavigationDestination(
            icon: SvgPicture.asset('assets/icons/schedule.svg', width: 24, height: 24, colorFilter: const ColorFilter.mode(AppColors.textHint, BlendMode.srcIn)),
            selectedIcon: SvgPicture.asset('assets/icons/schedule.svg', width: 24, height: 24, colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn)),
            label: 'Calendar',
          ),
          NavigationDestination(
            icon: SvgPicture.asset('assets/icons/user.svg', width: 24, height: 24, colorFilter: const ColorFilter.mode(AppColors.textHint, BlendMode.srcIn)),
            selectedIcon: SvgPicture.asset('assets/icons/user.svg', width: 24, height: 24, colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn)),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.createTask);
        },
        backgroundColor: AppColors.primary,
        elevation: 4,
        child: const Icon(Icons.add_rounded, color: AppColors.surface, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
