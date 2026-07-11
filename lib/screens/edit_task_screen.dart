import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tick_it/config/theme.dart';
import 'package:tick_it/models/task_model.dart';
import 'package:tick_it/providers/task_provider.dart';

class EditTaskScreen extends StatefulWidget {
  final TaskModel task;

  const EditTaskScreen({super.key, required this.task});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  late DateTime _selectedDate;
  late String _selectedCategory;
  late String _selectedPriority;
  late String _startTime;
  late String _endTime;
  bool _isLoading = false;

  static const List<String> _timeSlots = [
    '12:00 AM', '12:30 AM', '01:00 AM', '01:30 AM',
    '02:00 AM', '02:30 AM', '03:00 AM', '03:30 AM',
    '04:00 AM', '04:30 AM', '05:00 AM', '05:30 AM',
    '06:00 AM', '06:30 AM', '07:00 AM', '07:30 AM',
    '08:00 AM', '08:30 AM', '09:00 AM', '09:30 AM',
    '10:00 AM', '10:30 AM', '11:00 AM', '11:30 AM',
    '12:00 PM', '12:30 PM', '01:00 PM', '01:30 PM',
    '02:00 PM', '02:30 PM', '03:00 PM', '03:30 PM',
    '04:00 PM', '04:30 PM', '05:00 PM', '05:30 PM',
    '06:00 PM', '06:30 PM', '07:00 PM', '07:30 PM',
    '08:00 PM', '08:30 PM', '09:00 PM', '09:30 PM',
    '10:00 PM', '10:30 PM', '11:00 PM', '11:30 PM',
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController = TextEditingController(text: widget.task.description);
    _selectedDate = widget.task.date;
    _selectedCategory = widget.task.category;
    _selectedPriority = widget.task.priority;
    _startTime = _timeSlots.contains(widget.task.startTime)
        ? widget.task.startTime
        : '09:00 AM';
    _endTime = _timeSlots.contains(widget.task.endTime)
        ? widget.task.endTime
        : '05:00 PM';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024, 1, 1),
      lastDate: DateTime(2030, 12, 31),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.secondary,
              onPrimary: AppColors.surface,
              surface: AppColors.surface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _handleSave() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter a task name',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.surface),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final updatedTask = widget.task.copyWith(
        title: _titleController.text.trim(),
        category: _selectedCategory,
        date: _selectedDate,
        startTime: _startTime,
        endTime: _endTime,
        priority: _selectedPriority,
        description: _descriptionController.text.trim(),
      );

      final taskProvider = context.read<TaskProvider>();
      final success = await taskProvider.updateTask(updatedTask);
      if (success) {
        if (mounted) Navigator.pop(context);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                taskProvider.errorMessage ?? 'Failed to update task.',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.surface),
              ),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to update task: $e',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.surface),
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),

                      Text('Task Name', style: AppTextStyles.label.copyWith(fontSize: 16)),
                      const SizedBox(height: 10),
                      _buildTaskNameField(),

                      const SizedBox(height: 24),

                      Text('Category', style: AppTextStyles.label.copyWith(fontSize: 16)),
                      const SizedBox(height: 10),
                      _buildCategoryChips(),

                      const SizedBox(height: 24),

                      Text('Date & Time', style: AppTextStyles.label.copyWith(fontSize: 16)),
                      const SizedBox(height: 10),
                      _buildDatePicker(),

                      const SizedBox(height: 20),
                      _buildTimeRow(),

                      const SizedBox(height: 24),

                      Text('Priority', style: AppTextStyles.label.copyWith(fontSize: 16)),
                      const SizedBox(height: 10),
                      _buildPriorityChips(),

                      const SizedBox(height: 24),

                      Text('Description', style: AppTextStyles.label.copyWith(fontSize: 16)),
                      const SizedBox(height: 10),
                      _buildDescriptionField(),

                      const SizedBox(height: 32),
                      _buildSaveButton(),
                      const SizedBox(height: 40),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_rounded),
            color: AppColors.textPrimary,
          ),
          Expanded(
            child: Text(
              'Edit your task',
              style: AppTextStyles.heading3.copyWith(fontSize: 20),
            ),
          ),
          IconButton(
            onPressed: _handleDelete,
            icon: const Icon(Icons.delete_outline_rounded),
            color: AppColors.error,
          ),
        ],
      ),
    );
  }

  Widget _buildTaskNameField() {
    return TextField(
      controller: _titleController,
      style: AppTextStyles.bodyMedium,
      decoration: InputDecoration(
        hintText: 'Enter task name',
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: AppColors.secondary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return Wrap(
      spacing: 10,
      runSpacing: 8,
      children: TaskModel.categories.map((cat) {
        final isSelected = cat == _selectedCategory;
        return GestureDetector(
          onTap: () => setState(() => _selectedCategory = cat),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.secondary : AppColors.surface,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: isSelected ? AppColors.secondary : AppColors.divider,
              ),
            ),
            child: Text(
              cat,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isSelected ? AppColors.surface : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                DateFormat('dd MMMM, EEEE').format(_selectedDate),
                style: AppTextStyles.bodyMedium,
              ),
            ),
            const Icon(
              Icons.calendar_today_rounded,
              color: AppColors.secondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeRow() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Start time', style: AppTextStyles.label.copyWith(fontSize: 14)),
              const SizedBox(height: 8),
              _buildTimeDropdown(_startTime, (val) {
                setState(() => _startTime = val);
              }),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('End time', style: AppTextStyles.label.copyWith(fontSize: 14)),
              const SizedBox(height: 8),
              _buildTimeDropdown(_endTime, (val) {
                setState(() => _endTime = val);
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeDropdown(String value, ValueChanged<String> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.divider),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.secondary),
          style: AppTextStyles.bodyMedium,
          items: _timeSlots.map((time) {
            return DropdownMenuItem(value: time, child: Text(time));
          }).toList(),
          onChanged: (val) {
            if (val != null) onChanged(val);
          },
        ),
      ),
    );
  }

  Widget _buildPriorityChips() {
    return Wrap(
      spacing: 10,
      children: TaskModel.priorities.map((p) {
        final isSelected = p == _selectedPriority;
        Color chipColor;
        switch (p) {
          case 'High':
            chipColor = AppColors.priorityHigh;
            break;
          case 'Medium':
            chipColor = AppColors.priorityMedium;
            break;
          default:
            chipColor = AppColors.secondary;
        }

        return GestureDetector(
          onTap: () => setState(() => _selectedPriority = p),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? chipColor : AppColors.surface,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: isSelected ? chipColor : AppColors.divider,
              ),
            ),
            child: Text(
              p,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isSelected ? AppColors.surface : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDescriptionField() {
    return TextField(
      controller: _descriptionController,
      style: AppTextStyles.bodyMedium,
      maxLines: 4,
      decoration: InputDecoration(
        hintText: 'Add a description for your task...',
        hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textHint),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.secondary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.all(18),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSave,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 2,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: AppColors.surface,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                'Save changes',
                style: AppTextStyles.buttonLarge.copyWith(fontSize: 17),
              ),
      ),
    );
  }

  void _handleDelete() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Task', style: AppTextStyles.heading3),
        content: Text(
          'Are you sure you want to delete "${widget.task.title}"?',
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
              Navigator.pop(dialogContext); // close dialog
              final taskProvider = context.read<TaskProvider>();
              final success = await taskProvider.deleteTask(
                widget.task.userId,
                widget.task.id,
              );
              if (success) {
                if (mounted) Navigator.pop(context); // pop screen
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        taskProvider.errorMessage ?? 'Failed to delete task.',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.surface),
                      ),
                      backgroundColor: AppColors.error,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                }
              }
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


}
