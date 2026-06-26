import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:tick_it/config/theme.dart';
import 'package:tick_it/config/routes.dart';
import 'package:tick_it/models/task_model.dart';
import 'package:tick_it/services/auth_service.dart';
import 'package:tick_it/services/task_service.dart';
import 'package:tick_it/widgets/category_card.dart';
import 'package:tick_it/widgets/task_tile.dart';

/// Home Screen — categories grid, calendar strip, today's tasks
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  final TaskService _taskService = TaskService();

  String _displayName = 'User';
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.week;

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadUserInfo() async {
    final name = await _authService.getDisplayName();
    if (mounted) {
      setState(() => _displayName = name);
    }
  }

  void _handleSignOut() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  void _showAddTaskDialog() {
    final titleController = TextEditingController();
    String selectedCategory = TaskModel.categories.first;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Text('New Task', style: AppTextStyles.heading3),
                const SizedBox(height: 20),

                // Task title
                TextField(
                  controller: titleController,
                  style: AppTextStyles.bodyMedium,
                  decoration: InputDecoration(
                    hintText: 'What needs to be done?',
                    prefixIcon: const Icon(
                      Icons.task_alt_rounded,
                      color: AppColors.primary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 16),

                // Category selector
                Text('Category', style: AppTextStyles.label),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: TaskModel.categories.map((cat) {
                    final isSelected = cat == selectedCategory;
                    return ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      selectedColor: AppColors.primaryLight.withValues(alpha: 0.2),
                      labelStyle: AppTextStyles.bodySmall.copyWith(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      side: BorderSide(
                        color:
                            isSelected ? AppColors.primary : AppColors.divider,
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setModalState(() => selectedCategory = cat);
                        }
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Add button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (titleController.text.trim().isEmpty) return;

                      final userId = _authService.currentUser?.uid;
                      if (userId == null) return;

                      final task = TaskModel(
                        id: '',
                        title: titleController.text.trim(),
                        category: selectedCategory,
                        date: _selectedDay,
                        startTime: '08:00 AM',
                        endTime: '12:00 PM',
                        userId: userId,
                      );

                      await _taskService.addTask(task);
                      if (context.mounted) Navigator.pop(context);
                    },
                    child: const Text('Add Task'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showDeleteConfirmation(TaskModel task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Task', style: AppTextStyles.heading3),
        content: Text(
          'Are you sure you want to delete "${task.title}"?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTextStyles.buttonMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _taskService.deleteTask(
                _authService.currentUser!.uid,
                task.id,
              );
            },
            child: Text(
              'Delete',
              style: AppTextStyles.buttonMedium.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = _authService.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // Header
              _buildHeader(),

              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),

                      // Category cards grid
                      _buildCategoryGrid(userId),

                      const SizedBox(height: 24),

                      // Calendar week strip
                      _buildCalendarStrip(),

                      const SizedBox(height: 20),

                      // Today's Tasks header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _isToday(_selectedDay)
                                ? "Today's Tasks"
                                : 'Tasks for ${DateFormat('MMM d').format(_selectedDay)}',
                            style: AppTextStyles.label.copyWith(fontSize: 16),
                          ),
                          Text(
                            DateFormat('EEEE').format(_selectedDay),
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Task list
                      _buildTaskList(userId),

                      const SizedBox(height: 100), // Bottom padding for FAB
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // Create new task button
      floatingActionButton: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        width: double.infinity,
        height: 56,
        child: FloatingActionButton.extended(
          onPressed: _showAddTaskDialog,
          backgroundColor: AppColors.secondary,
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          icon: const Icon(Icons.add_rounded, color: AppColors.surface),
          label: Text(
            'Create new task',
            style: AppTextStyles.buttonLarge,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  /// Build header with greeting and avatar
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello $_displayName,',
                  style: AppTextStyles.heading3,
                ),
                const SizedBox(height: 2),
                Text(
                  'You have work today',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),

          // Avatar / Menu
          PopupMenuButton(
            offset: const Offset(0, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Row(
                  children: [
                    const Icon(Icons.person_outline_rounded, size: 20),
                    const SizedBox(width: 10),
                    Text('Profile', style: AppTextStyles.bodyMedium),
                  ],
                ),
              ),
              PopupMenuItem(
                onTap: _handleSignOut,
                child: Row(
                  children: [
                    const Icon(Icons.logout_rounded,
                        size: 20, color: AppColors.error),
                    const SizedBox(width: 10),
                    Text(
                      'Sign Out',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primaryLight.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.person_rounded,
                color: AppColors.primary,
                size: 26,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build 2×2 category cards grid
  Widget _buildCategoryGrid(String userId) {
    return StreamBuilder<List<TaskModel>>(
      stream: _taskService.getAllTasks(userId),
      builder: (context, snapshot) {
        final tasks = snapshot.data ?? [];
        final counts = <String, int>{};
        for (final task in tasks) {
          if (!task.isCompleted) {
            counts[task.category] = (counts[task.category] ?? 0) + 1;
          }
        }

        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.4,
          children: [
            CategoryCard.project(count: counts['Project'] ?? 0),
            CategoryCard.work(count: counts['Work'] ?? 0),
            CategoryCard.dailyTasks(count: counts['Daily Tasks'] ?? 0),
            CategoryCard.groceries(count: counts['Groceries'] ?? 0),
          ],
        );
      },
    );
  }

  /// Build horizontal calendar week strip
  Widget _buildCalendarStrip() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2024, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        calendarFormat: _calendarFormat,
        startingDayOfWeek: StartingDayOfWeek.monday,
        availableCalendarFormats: const {
          CalendarFormat.week: 'Week',
        },
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: AppTextStyles.label,
          leftChevronIcon: const Icon(
            Icons.chevron_left_rounded,
            color: AppColors.primary,
          ),
          rightChevronIcon: const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.primary,
          ),
          headerPadding: const EdgeInsets.symmetric(vertical: 8),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: AppTextStyles.labelSmall,
          weekendStyle: AppTextStyles.labelSmall.copyWith(
            color: AppColors.secondary.withValues(alpha: 0.7),
          ),
        ),
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: AppColors.primaryLight.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          todayTextStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
          selectedDecoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          selectedTextStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.surface,
            fontWeight: FontWeight.w700,
          ),
          defaultTextStyle: AppTextStyles.bodyMedium,
          weekendTextStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.secondary.withValues(alpha: 0.8),
          ),
          outsideTextStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textHint,
          ),
          cellMargin: const EdgeInsets.all(4),
        ),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
      ),
    );
  }

  /// Build task list for selected day
  Widget _buildTaskList(String userId) {
    if (userId.isEmpty) {
      return _buildEmptyState();
    }

    return StreamBuilder<List<TaskModel>>(
      stream: _taskService.getTasksByDate(userId, _selectedDay),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 3,
              ),
            ),
          );
        }

        final tasks = snapshot.data ?? [];

        if (tasks.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return TaskTile(
              task: task,
              onToggleComplete: () => _taskService.toggleComplete(task),
              onEdit: () {
                // Edit screen will be built later
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Edit screen coming soon!',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.surface,
                      ),
                    ),
                    backgroundColor: AppColors.primary,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
              onDelete: () => _showDeleteConfirmation(task),
            );
          },
        );
      },
    );
  }

  /// Empty state when no tasks
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(
            Icons.task_alt_rounded,
            size: 64,
            color: AppColors.textHint.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No tasks for this day',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textHint,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tap the button below to add one!',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}
