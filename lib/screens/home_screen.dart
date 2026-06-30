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

  void _navigateToCreateTask() {
    Navigator.pushNamed(
      context,
      AppRoutes.createTask,
      arguments: _selectedDay,
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

              _buildHeader(),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

                      _buildCategoryGrid(userId),

                      const SizedBox(height: 20),

                      _buildCalendarStrip(),

                      const SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _isToday(_selectedDay)
                                ? "Today's Tasks"
                                : 'Tasks for ${DateFormat('MMM d').format(_selectedDay)}',
                            style: AppTextStyles.label.copyWith(fontSize: 14),
                          ),
                          Text(
                            DateFormat('EEEE').format(_selectedDay),
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      _buildTaskList(userId),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      floatingActionButton: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        width: double.infinity,
        height: 48,
        child: FloatingActionButton.extended(
          onPressed: _navigateToCreateTask,
          backgroundColor: AppColors.secondary,
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          icon: const Icon(Icons.add_rounded, color: AppColors.surface),
          label: Text(
            'Create new task',
            style: AppTextStyles.buttonMedium.copyWith(color: AppColors.surface),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello $_displayName,',
                  style: AppTextStyles.heading3.copyWith(fontSize: 19),
                ),
                const SizedBox(height: 2),
                Text(
                  'You have work today',
                  style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),

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
              width: 40,
              height: 40,
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
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid(String userId) {
    return StreamBuilder<List<TaskModel>>(
      stream: _taskService.getAllTasks(userId),
      builder: (context, snapshot) {
        final tasks = snapshot.data ?? [];
        final counts = <String, int>{};
        for (final task in tasks) {
          counts[task.category] = (counts[task.category] ?? 0) + 1;
        }

        if (counts.isEmpty) {
          return const SizedBox.shrink();
        }

        final categoryWidgets = <Widget>[];
        if (counts.containsKey('Project')) {
          categoryWidgets.add(CategoryCard.project(count: counts['Project']!));
        }
        if (counts.containsKey('Work')) {
          categoryWidgets.add(CategoryCard.work(count: counts['Work']!));
        }
        if (counts.containsKey('Daily Tasks')) {
          categoryWidgets.add(CategoryCard.dailyTasks(count: counts['Daily Tasks']!));
        }
        if (counts.containsKey('Groceries')) {
          categoryWidgets.add(CategoryCard.groceries(count: counts['Groceries']!));
        }

        if (categoryWidgets.isEmpty) {
          return const SizedBox.shrink();
        }

        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 2.4,
          children: categoryWidgets,
        );
      },
    );
  }

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

        final tasks = List<TaskModel>.from(snapshot.data ?? []);
        tasks.sort((a, b) {
          const priorityWeights = {'High': 0, 'Medium': 1, 'Low': 2};
          final weightA = priorityWeights[a.priority] ?? 2;
          final weightB = priorityWeights[b.priority] ?? 2;
          return weightA.compareTo(weightB);
        });

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
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.editTask,
                  arguments: task,
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
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
