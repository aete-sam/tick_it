import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tick_it/config/routes.dart';
import 'package:tick_it/config/theme.dart';
import 'package:tick_it/providers/auth_provider.dart';
import 'package:tick_it/providers/task_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final authProvider = context.watch<AuthProvider>();
    final taskProvider = context.watch<TaskProvider>();

    final user = authProvider.currentUser;
    final totalTasks = taskProvider.allTasks.length;
    final completedTasks = taskProvider.allTasks.where((t) => t.isCompleted).length;
    final pendingTasks = totalTasks - completedTasks;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    _buildAvatar(),
                    const SizedBox(height: 16),
                    Text(
                      authProvider.displayName,
                      style: AppTextStyles.heading2,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? '',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 40),
                    _buildStatsRow(totalTasks, completedTasks, pendingTasks),
                    const SizedBox(height: 40),
                    _buildSignOutButton(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Profile',
              style: AppTextStyles.heading3.copyWith(fontSize: 24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withValues(alpha: 0.15),
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primaryLight.withValues(alpha: 0.3),
          width: 3,
        ),
      ),
      child: const Icon(
        Icons.person_rounded,
        color: AppColors.primary,
        size: 50,
      ),
    );
  }

  Widget _buildStatsRow(int total, int completed, int pending) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatCard('Total', total.toString(), AppColors.primary),
        _buildStatCard('Done', completed.toString(), AppColors.success),
        _buildStatCard('Pending', pending.toString(), AppColors.warning),
      ],
    );
  }

  Widget _buildStatCard(String label, String count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            count,
            style: AppTextStyles.heading2.copyWith(color: color),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.labelSmall,
          ),
        ],
      ),
    );
  }

  Widget _buildSignOutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: () async {
          await context.read<AuthProvider>().signOut();
          if (context.mounted) {
            Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
          }
        },
        icon: const Icon(Icons.logout_rounded, size: 20),
        label: Text(
          'Sign Out',
          style: AppTextStyles.buttonLarge.copyWith(
            color: AppColors.error,
            fontSize: 17,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          side: const BorderSide(color: AppColors.error, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }
}
