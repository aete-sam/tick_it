import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:tick_it/config/theme.dart';
import 'package:tick_it/config/routes.dart';
import 'package:tick_it/models/task_model.dart';
import 'package:tick_it/providers/auth_provider.dart';
import 'package:tick_it/providers/task_provider.dart';
import 'package:tick_it/widgets/category_card.dart';
import 'package:tick_it/widgets/task_tile.dart';
import 'package:tick_it/models/quote_model.dart';
import 'package:tick_it/services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.week;

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  
  Future<QuoteModel>? _quoteFuture;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();

    final authProvider = context.read<AuthProvider>();
    authProvider.loadDisplayName();

    final userId = authProvider.currentUser?.uid ?? '';
    if (userId.isNotEmpty) {
      final taskProvider = context.read<TaskProvider>();
      taskProvider.loadAllTasks(userId);
    }

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _animController.forward();
    _loadQuote();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _handleSignOut() async {
    await context.read<AuthProvider>().signOut();
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
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Task', style: AppTextStyles.heading3),
        content: Text(
          'Are you sure you want to delete "${task.title}"?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: AppTextStyles.buttonMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final authProvider = context.read<AuthProvider>();
              final taskProvider = context.read<TaskProvider>();
              await taskProvider.deleteTask(
                authProvider.currentUser!.uid,
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
    super.build(context);
    final authProvider = context.watch<AuthProvider>();
    final taskProvider = context.watch<TaskProvider>();
    final userId = authProvider.currentUser?.uid ?? '';

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
                      _buildQuoteCard(),
                      const SizedBox(height: 24),
                      Text(
                        "All Tasks",
                        style: AppTextStyles.label.copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      _buildTaskList(),
                      const SizedBox(height: 100), // padding for navbar
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final authProvider = context.watch<AuthProvider>();
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello ${authProvider.displayName},',
                  style: AppTextStyles.heading3.copyWith(fontSize: 19),
                ),
                const SizedBox(height: 2),
                Text(
                  'Here is your overview',
                  style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid() {
    final taskProvider = context.watch<TaskProvider>();
    final counts = taskProvider.categoryCounts;

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
          final authProvider = context.read<AuthProvider>();
          final userId = authProvider.currentUser?.uid ?? '';
          if (userId.isNotEmpty) {
            context.read<TaskProvider>().loadTasksByDate(userId, selectedDay);
          }
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
      ),
    );
  }

  Widget _buildTaskList() {
    final taskProvider = context.watch<TaskProvider>();

    if (taskProvider.isLoading) {
      return const Padding(
        padding: EdgeInsets.only(top: 40),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final tasks = taskProvider.allTasks;

    if (tasks.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.assignment_turned_in_rounded,
                size: 64,
                color: AppColors.textHint.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'No tasks yet',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textHint,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Tap + to create one!',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textHint,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tasks.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final task = tasks[index];
        return TaskTile(
          task: task,
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.editTask, arguments: task);
          },
          onToggleComplete: () => taskProvider.toggleComplete(task),
        );
      },
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  void _loadQuote() {
    setState(() {
      _quoteFuture = _apiService.fetchRandomQuote();
    });
  }

  Widget _buildQuoteCard() {
    return FutureBuilder<QuoteModel>(
      future: _quoteFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        } else if (snapshot.hasError) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: AppColors.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Failed to load quote',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ),
                  IconButton(
                    onPressed: _loadQuote,
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
            ),
          );
        } else if (snapshot.hasData) {
          final quote = snapshot.data!;
          return Card(
            color: AppColors.primaryLight.withValues(alpha: 0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.format_quote_rounded, color: AppColors.primary, size: 28),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '"${quote.quote}"',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _loadQuote,
                        icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '- ${quote.author}',
                      style: AppTextStyles.labelSmall.copyWith(color: AppColors.primaryDark),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
