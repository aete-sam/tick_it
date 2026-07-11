import 'package:flutter/material.dart';
import 'package:hydro_glass_nav_bar/hydro_glass_nav_bar.dart';
import 'package:tick_it/config/routes.dart';
import 'package:tick_it/screens/calendar_screen.dart';
import 'package:tick_it/screens/home_screen.dart';
import 'package:tick_it/screens/profile_screen.dart';
import 'package:tick_it/config/theme.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: const [
              HomeScreen(),
              CalendarScreen(),
              ProfileScreen(),
            ],
          ),
          
          Align(
            alignment: Alignment.bottomCenter,
            child: HydroGlassNavBar(
              controller: _tabController,
              indicatorColor: AppColors.primary,
              items: [
                HydroGlassNavItem(
                  label: 'Home',
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home_rounded,
                  glowColor: AppColors.primary,
                ),
                HydroGlassNavItem(
                  label: 'Calendar',
                  icon: Icons.calendar_month_outlined,
                  selectedIcon: Icons.calendar_month_rounded,
                  glowColor: AppColors.secondary,
                ),
                HydroGlassNavItem(
                  label: 'Profile',
                  icon: Icons.person_outline_rounded,
                  selectedIcon: Icons.person_rounded,
                  glowColor: AppColors.accent,
                ),
              ],
              fabConfig: HydroGlassNavBarFABConfig(
                icon: Icons.add_rounded,
                size: 56,
                actions: [
                  HydroGlassNavBarAction(
                    icon: Icons.edit_document,
                    label: 'Create Task',
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.createTask);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
