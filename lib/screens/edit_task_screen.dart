import 'package:flutter/material.dart';

import '../models/task.dart';
import '../services/task_storage_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class EditTaskScreen extends StatefulWidget {
  final Task task;

  const EditTaskScreen({
    super.key,
    required this.task,
  });

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _durationController;

  late String _selectedCategory;

  bool _isSaving = false;

  final List<String> _categories = const [
    'Study',
    'Work',
    'Personal',
    'Health',
    'Other',
  ];

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(
      text: widget.task.title,
    );

    _descriptionController = TextEditingController(
      text: widget.task.description,
    );

    _durationController = TextEditingController(
      text: widget.task.duration.toString(),
    );

    _selectedCategory = _categories.contains(
      widget.task.category,
    )
        ? widget.task.category
        : 'Other';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();

    super.dispose();
  }

  // ------------------------------------------------------------
  // SAVE
  // ------------------------------------------------------------

  Future<void> _saveChanges() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final duration = int.tryParse(
      _durationController.text.trim(),
    );

    if (duration == null) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final updatedTask = widget.task.copyWith(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _selectedCategory,
      duration: duration,
    );

    try {
      await TaskStorageService.updateTask(
        updatedTask,
      );

      if (!mounted) {
        return;
      }

      Navigator.pop<Task>(
        context,
        updatedTask,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to save changes. Please try again.',
            style: AppTextStyles.body.copyWith(
              color: Colors.white,
            ),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.surfaceLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppRadius.medium,
            ),
          ),
        ),
      );
    }
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          tooltip: 'Back',
          onPressed: _isSaving
              ? null
              : () {
                  Navigator.pop(context);
                },
          icon: const Icon(
            Icons.arrow_back_rounded,
          ),
        ),
        title: Text(
          'Edit Task',
          style: AppTextStyles.heading3,
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: _getHorizontalPadding(
                  constraints.maxWidth,
                ),
                vertical: AppSpacing.lg,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 720,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        _buildIntro(),
                        const SizedBox(
                          height: AppSpacing.xl,
                        ),
                        _buildTitleField(),
                        const SizedBox(
                          height: AppSpacing.lg,
                        ),
                        _buildDescriptionField(),
                        const SizedBox(
                          height: AppSpacing.lg,
                        ),
                        _buildCategorySection(),
                        const SizedBox(
                          height: AppSpacing.lg,
                        ),
                        _buildDurationField(),
                        const SizedBox(
                          height: AppSpacing.xl,
                        ),
                        _buildFocusTip(),
                        const SizedBox(
                          height: AppSpacing.xl,
                        ),
                        _buildSaveButton(),
                        const SizedBox(
                          height: AppSpacing.xl,
                        ),
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

  // ------------------------------------------------------------
  // INTRO
  // ------------------------------------------------------------

  Widget _buildIntro() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Update your task',
          style: AppTextStyles.heading1,
        ),
        const SizedBox(
          height: AppSpacing.sm,
        ),
        Text(
          'Make changes to your task details and save them when you are ready.',
          style: AppTextStyles.bodySecondary,
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // TITLE
  // ------------------------------------------------------------

  Widget _buildTitleField() {
    return _buildFieldContainer(
      icon: Icons.title_rounded,
      child: TextFormField(
        controller: _titleController,
        textInputAction: TextInputAction.next,
        maxLength: 60,
        style: AppTextStyles.body,
        decoration: _inputDecoration(
          hintText: 'Enter task title',
          counterText: '',
        ),
        validator: (value) {
          final text = value?.trim() ?? '';

          if (text.isEmpty) {
            return 'Please enter a task title.';
          }

          if (text.length < 3) {
            return 'Title must be at least 3 characters.';
          }

          if (text.length > 60) {
            return 'Title must be 60 characters or less.';
          }

          return null;
        },
      ),
    );
  }

  // ------------------------------------------------------------
  // DESCRIPTION
  // ------------------------------------------------------------

  Widget _buildDescriptionField() {
    return _buildFieldContainer(
      icon: Icons.notes_rounded,
      child: TextFormField(
        controller: _descriptionController,
        textInputAction: TextInputAction.newline,
        minLines: 4,
        maxLines: 6,
        maxLength: 300,
        style: AppTextStyles.body,
        decoration: _inputDecoration(
          hintText: 'Describe what you need to accomplish',
          counterText: '',
        ),
        validator: (value) {
          final text = value?.trim() ?? '';

          if (text.isEmpty) {
            return 'Please enter a description.';
          }

          if (text.length < 5) {
            return 'Description must be at least 5 characters.';
          }

          if (text.length > 300) {
            return 'Description must be 300 characters or less.';
          }

          return null;
        },
      ),
    );
  }

  // ------------------------------------------------------------
  // CATEGORY
  // ------------------------------------------------------------

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: AppTextStyles.heading3,
        ),
        const SizedBox(
          height: AppSpacing.md,
        ),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: _categories.map(
            (category) {
              final isSelected =
                  category == _selectedCategory;

              return _buildCategoryChip(
                category: category,
                isSelected: isSelected,
              );
            },
          ).toList(),
        ),
      ],
    );
  }

  Widget _buildCategoryChip({
    required String category,
    required bool isSelected,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(
        AppRadius.medium,
      ),
      onTap: _isSaving
          ? null
          : () {
              setState(() {
                _selectedCategory = category;
              });
            },
      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 180,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(
                  alpha: 0.16,
                )
              : AppColors.surface,
          borderRadius: BorderRadius.circular(
            AppRadius.medium,
          ),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.divider,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getCategoryIcon(category),
              size: 17,
              color: isSelected
                  ? AppColors.primaryLight
                  : AppColors.textSecondary,
            ),
            const SizedBox(
              width: AppSpacing.xs,
            ),
            Text(
              category,
              style: AppTextStyles.caption.copyWith(
                color: isSelected
                    ? AppColors.primaryLight
                    : AppColors.textSecondary,
                fontWeight: isSelected
                    ? FontWeight.w600
                    : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // DURATION
  // ------------------------------------------------------------

  Widget _buildDurationField() {
    return _buildFieldContainer(
      icon: Icons.timer_outlined,
      child: TextFormField(
        controller: _durationController,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.done,
        maxLength: 3,
        style: AppTextStyles.body,
        decoration: _inputDecoration(
          hintText: 'Duration in minutes',
          suffixText: 'min',
          counterText: '',
        ),
        validator: (value) {
          final text = value?.trim() ?? '';

          if (text.isEmpty) {
            return 'Please enter a duration.';
          }

          final duration = int.tryParse(text);

          if (duration == null) {
            return 'Duration must be a number.';
          }

          if (duration < 1) {
            return 'Duration must be at least 1 minute.';
          }

          if (duration > 180) {
            return 'Duration cannot exceed 180 minutes.';
          }

          return null;
        },
        onFieldSubmitted: (_) {
          _saveChanges();
        },
      ),
    );
  }

  // ------------------------------------------------------------
  // FOCUS TIP
  // ------------------------------------------------------------

  Widget _buildFocusTip() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(
          alpha: 0.08,
        ),
        borderRadius: BorderRadius.circular(
          AppRadius.medium,
        ),
        border: Border.all(
          color: AppColors.primary.withValues(
            alpha: 0.20,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.lightbulb_outline_rounded,
            color: AppColors.primaryLight,
            size: 21,
          ),
          const SizedBox(
            width: AppSpacing.md,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Focus tip',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(
                  height: AppSpacing.xs,
                ),
                Text(
                  'Keep your task specific and achievable. '
                  'A clear goal makes it easier to stay focused.',
                  style: AppTextStyles.caption.copyWith(
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // SAVE BUTTON
  // ------------------------------------------------------------

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isSaving
            ? null
            : _saveChanges,
        icon: _isSaving
            ? const SizedBox(
                width: 19,
                height: 19,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(
                Icons.save_rounded,
                size: 19,
              ),
        label: Text(
          _isSaving ? 'Saving...' : 'Save Changes',
          style: AppTextStyles.button,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor:
              AppColors.primary.withValues(
            alpha: 0.55,
          ),
          disabledForegroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(
            double.infinity,
            54,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppRadius.medium,
            ),
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // FIELD CONTAINER
  // ------------------------------------------------------------

  Widget _buildFieldContainer({
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          AppRadius.medium,
        ),
        border: Border.all(
          color: AppColors.divider,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: 16,
            ),
            child: Icon(
              icon,
              size: 20,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(
            width: AppSpacing.sm,
          ),
          Expanded(
            child: child,
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // INPUT DECORATION
  // ------------------------------------------------------------

  InputDecoration _inputDecoration({
    required String hintText,
    String? suffixText,
    String? counterText,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: AppTextStyles.bodySecondary.copyWith(
        color: AppColors.textMuted,
      ),
      suffixText: suffixText,
      suffixStyle: AppTextStyles.bodySecondary.copyWith(
        color: AppColors.textSecondary,
      ),
      counterText: counterText,
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      errorBorder: InputBorder.none,
      focusedErrorBorder: InputBorder.none,
      contentPadding: const EdgeInsets.symmetric(
        vertical: 15,
      ),
      errorStyle: AppTextStyles.caption.copyWith(
        color: AppColors.error,
      ),
    );
  }

  // ------------------------------------------------------------
  // CATEGORY ICON
  // ------------------------------------------------------------

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'study':
        return Icons.school_outlined;

      case 'work':
        return Icons.work_outline_rounded;

      case 'personal':
        return Icons.person_outline_rounded;

      case 'health':
        return Icons.favorite_border_rounded;

      case 'other':
        return Icons.more_horiz_rounded;

      default:
        return Icons.category_outlined;
    }
  }

  // ------------------------------------------------------------
  // RESPONSIVE PADDING
  // ------------------------------------------------------------

  double _getHorizontalPadding(double width) {
    if (width < 360) {
      return 16;
    }

    if (width < 600) {
      return 20;
    }

    if (width < 900) {
      return 28;
    }

    return 40;
  }
}

