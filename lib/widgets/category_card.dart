import 'package:flutter/material.dart';
import 'package:tick_it/config/theme.dart';

class CategoryCard extends StatelessWidget {
  final String title;
  final int taskCount;
  final IconData icon;
  final Color backgroundColor;
  final Color iconBackgroundColor;
  final VoidCallback? onTap;

  const CategoryCard({
    super.key,
    required this.title,
    required this.taskCount,
    required this.icon,
    required this.backgroundColor,
    required this.iconBackgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: backgroundColor.withValues(alpha: 0.5),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [

            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconBackgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: AppColors.surface,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),

            Expanded(
              child: Text(
                title,
                style: AppTextStyles.label.copyWith(fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            ),

            Text(
              '$taskCount',
              style: AppTextStyles.heading3.copyWith(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }

  factory CategoryCard.project({required int count, VoidCallback? onTap}) {
    return CategoryCard(
      title: 'Project',
      taskCount: count,
      icon: Icons.work_outline_rounded,
      backgroundColor: AppColors.categoryTeal,
      iconBackgroundColor: AppColors.categoryTealIcon,
      onTap: onTap,
    );
  }

  factory CategoryCard.work({required int count, VoidCallback? onTap}) {
    return CategoryCard(
      title: 'Work',
      taskCount: count,
      icon: Icons.laptop_mac_rounded,
      backgroundColor: AppColors.categoryPeach,
      iconBackgroundColor: AppColors.categoryPeachIcon,
      onTap: onTap,
    );
  }

  factory CategoryCard.dailyTasks({required int count, VoidCallback? onTap}) {
    return CategoryCard(
      title: 'Daily Tasks',
      taskCount: count,
      icon: Icons.checklist_rounded,
      backgroundColor: AppColors.categoryLavender,
      iconBackgroundColor: AppColors.categoryLavenderIcon,
      onTap: onTap,
    );
  }

  factory CategoryCard.groceries({required int count, VoidCallback? onTap}) {
    return CategoryCard(
      title: 'Groceries',
      taskCount: count,
      icon: Icons.shopping_cart_outlined,
      backgroundColor: AppColors.categoryMint,
      iconBackgroundColor: AppColors.categoryMintIcon,
      onTap: onTap,
    );
  }
}
