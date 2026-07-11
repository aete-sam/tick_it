import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:tick_it/config/routes.dart';
import 'package:tick_it/config/theme.dart';
import 'package:tick_it/providers/auth_provider.dart';
import 'package:tick_it/providers/task_provider.dart';
import 'package:tick_it/widgets/task_tile.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.week;

  @override
  void initState() {
    super.initState();
    // Load tasks for today initially
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTasksForDate(_selectedDay);
    });
  }

  void _loadTasksForDate(DateTime date) {
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.currentUser?.uid ?? '';
    if (userId.isNotEmpty) {
      context.read<TaskProvider>().loadTasksByDate(userId, date);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildCalendarStrip(),
                    const SizedBox(height: 24),
                    _buildSelectedDateHeader(),
                    const SizedBox(height: 12),
                    _buildTaskList(),
                    const SizedBox(height: 100), // padding for navbar
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Schedule',
              style: AppTextStyles.heading3.copyWith(fontSize: 24),
            ),
          ),
        ],
      ),
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
          CalendarFormat.month: 'Month',
        },
        headerStyle: HeaderStyle(
          formatButtonVisible: true,
          formatButtonTextStyle: AppTextStyles.labelSmall.copyWith(color: AppColors.primary),
          formatButtonDecoration: BoxDecoration(
            border: Border.all(color: AppColors.primaryLight),
            borderRadius: BorderRadius.circular(12),
          ),
          titleCentered: true,
          titleTextStyle: AppTextStyles.label,
          leftChevronIcon: const Icon(Icons.chevron_left_rounded, color: AppColors.primary),
          rightChevronIcon: const Icon(Icons.chevron_right_rounded, color: AppColors.primary),
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
          _loadTasksForDate(selectedDay);
        },
        onFormatChanged: (format) {
          setState(() {
            _calendarFormat = format;
          });
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
      ),
    );
  }

  Widget _buildSelectedDateHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          _isToday(_selectedDay)
              ? "Today's Schedule"
              : DateFormat('MMM d, yyyy').format(_selectedDay),
          style: AppTextStyles.label.copyWith(fontSize: 16),
        ),
        Text(
          DateFormat('EEEE').format(_selectedDay),
          style: AppTextStyles.bodySmall,
        ),
      ],
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

    if (taskProvider.tasks.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.event_available_rounded,
                size: 64,
                color: AppColors.textHint.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'No tasks scheduled',
                style: AppTextStyles.bodyLarge.copyWith(
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
      itemCount: taskProvider.tasks.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final task = taskProvider.tasks[index];
        return TaskTile(
          task: task,
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.editTask, arguments: task);
          },
          onToggleComplete: () => context.read<TaskProvider>().toggleComplete(task),
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
}
