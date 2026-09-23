import 'package:flutter/material.dart';

import '../models/task.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({
    super.key,
  });

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController();

  String _selectedCategory = 'Study';

  final List<String> _categories = const [
    'Study',
    'Work',
    'Personal',
    'Health',
    'Other',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();

    super.dispose();
  }

  void _createTask() {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final task = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _selectedCategory,
      duration: int.parse(
        _durationController.text.trim(),
      ),
    );

    Navigator.pop(context, task);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = _getHorizontalPadding(
              constraints.maxWidth,
            );

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                AppSpacing.lg,
                horizontalPadding,
                AppSpacing.huge,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 720,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(
                          height: AppSpacing.xxxl,
                        ),
                        _buildTitleField(),
                        const SizedBox(
                          height: AppSpacing.xl,
                        ),
                        _buildDescriptionField(),
                        const SizedBox(
                          height: AppSpacing.xl,
                        ),
                        _buildCategoryField(),
                        const SizedBox(
                          height: AppSpacing.xl,
                        ),
                        _buildDurationField(),
                        const SizedBox(
                          height: AppSpacing.xxxl,
                        ),
                        _buildCreateButton(),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: const Icon(
          Icons.arrow_back_rounded,
          color: AppColors.textPrimary,
        ),
      ),
      title: Text(
        'Add Task',
        style: AppTextStyles.heading3,
      ),
      centerTitle: false,
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Create a new task',
          style: AppTextStyles.heading1,
        ),
        const SizedBox(
          height: AppSpacing.sm,
        ),
        Text(
          'Plan your next focus session and stay productive.',
          style: AppTextStyles.bodySecondary,
        ),
      ],
    );
  }

  Widget _buildTitleField() {
    return _buildFieldLabel(
      label: 'Task Title',
      child: TextFormField(
        controller: _titleController,
        textInputAction: TextInputAction.next,
        maxLength: 60,
        style: const TextStyle(
          color: AppColors.textPrimary,
        ),
        decoration: _inputDecoration(
          hintText: 'e.g. Complete Flutter assignment',
          prefixIcon: Icons.task_alt_rounded,
        ),
        validator: (value) {
          final text = value?.trim() ?? '';

          if (text.isEmpty) {
            return 'Please enter a task title';
          }

          if (text.length < 3) {
            return 'Title must be at least 3 characters';
          }

          return null;
        },
      ),
    );
  }

  Widget _buildDescriptionField() {
    return _buildFieldLabel(
      label: 'Description',
      child: TextFormField(
        controller: _descriptionController,
        textInputAction: TextInputAction.newline,
        keyboardType: TextInputType.multiline,
        minLines: 4,
        maxLines: 6,
        maxLength: 300,
        style: const TextStyle(
          color: AppColors.textPrimary,
        ),
        decoration: _inputDecoration(
          hintText: 'Describe what you want to accomplish...',
          prefixIcon: Icons.notes_rounded,
          alignPrefixIconTop: true,
        ),
        validator: (value) {
          final text = value?.trim() ?? '';

          if (text.isEmpty) {
            return 'Please enter a description';
          }

          if (text.length < 5) {
            return 'Description must be at least 5 characters';
          }

          return null;
        },
      ),
    );
  }

  Widget _buildCategoryField() {
    return _buildFieldLabel(
      label: 'Category',
      child: DropdownButtonFormField<String>(
        value: _selectedCategory,
        dropdownColor: AppColors.surface,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 15,
        ),
        decoration: _inputDecoration(
          hintText: 'Select a category',
          prefixIcon: Icons.category_rounded,
        ),
        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: AppColors.textSecondary,
        ),
        items: _categories.map(
          (category) {
            return DropdownMenuItem<String>(
              value: category,
              child: Text(category),
            );
          },
        ).toList(),
        onChanged: (value) {
          if (value == null) {
            return;
          }

          setState(() {
            _selectedCategory = value;
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select a category';
          }

          return null;
        },
      ),
    );
  }

  Widget _buildDurationField() {
    return _buildFieldLabel(
      label: 'Focus Duration',
      child: TextFormField(
        controller: _durationController,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.done,
        maxLength: 3,
        style: const TextStyle(
          color: AppColors.textPrimary,
        ),
        decoration: _inputDecoration(
          hintText: 'e.g. 25',
          prefixIcon: Icons.timer_outlined,
          suffixText: 'minutes',
        ),
        validator: (value) {
          final text = value?.trim() ?? '';

          if (text.isEmpty) {
            return 'Please enter a duration';
          }

          final duration = int.tryParse(text);

          if (duration == null) {
            return 'Please enter a valid number';
          }

          if (duration < 1) {
            return 'Duration must be at least 1 minute';
          }

          if (duration > 180) {
            return 'Duration cannot exceed 180 minutes';
          }

          return null;
        },
      ),
    );
  }

  Widget _buildCreateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _createTask,
        icon: const Icon(
          Icons.add_task_rounded,
        ),
        label: const Text(
          'Create Task',
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(
            double.infinity,
            56,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              12,
            ),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel({
    required String label,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(
          height: AppSpacing.sm,
        ),
        child,
      ],
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData prefixIcon,
    bool alignPrefixIconTop = false,
    String? suffixText,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        color: AppColors.textMuted,
        fontSize: 14,
      ),
      prefixIcon: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 12,
          top: alignPrefixIconTop ? 16 : 0,
        ),
        child: Icon(
          prefixIcon,
          color: AppColors.textSecondary,
          size: 20,
        ),
      ),
      prefixIconConstraints: BoxConstraints(
        minWidth: 52,
        minHeight: alignPrefixIconTop ? 60 : 48,
      ),
      suffixText: suffixText,
      suffixStyle: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          12,
        ),
        borderSide: const BorderSide(
          color: AppColors.divider,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          12,
        ),
        borderSide: const BorderSide(
          color: AppColors.divider,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          12,
        ),
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          12,
        ),
        borderSide: const BorderSide(
          color: AppColors.error,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          12,
        ),
        borderSide: const BorderSide(
          color: AppColors.error,
          width: 1.5,
        ),
      ),
      errorStyle: const TextStyle(
        color: AppColors.error,
        fontSize: 12,
      ),
      counterStyle: const TextStyle(
        color: AppColors.textMuted,
        fontSize: 11,
      ),
    );
  }

  double _getHorizontalPadding(double width) {
    if (width < 360) {
      return 16;
    }

    if (width < 600) {
      return 20;
    }

    if (width < 900) {
      return 32;
    }

    return 40;
  }
}
