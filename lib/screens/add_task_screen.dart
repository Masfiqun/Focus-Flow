import 'package:flutter/material.dart';

import '../models/task.dart';
import '../services/task_storage_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
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

  Future<void> _createTask() async {
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

    await TaskStorageService.saveTask(task);

    if (!mounted) {
      return;
    }

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
              keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                AppSpacing.lg,
                horizontalPadding,
                40,
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
                        _buildHeroSection(),

                        const SizedBox(
                          height: AppSpacing.xxxl,
                        ),

                        _buildSectionHeader(
                          icon: Icons.edit_note_rounded,
                          title: 'Task details',
                          subtitle:
                              'Tell FocusFlow what you want to accomplish.',
                        ),

                        const SizedBox(
                          height: AppSpacing.xl,
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
                          height: AppSpacing.xxl,
                        ),

                        _buildFocusTip(),

                        const SizedBox(
                          height: AppSpacing.xxxl,
                        ),

                        _buildCreateButton(),

                        const SizedBox(
                          height: AppSpacing.md,
                        ),

                        Center(
                          child: Text(
                            'You can always edit your plan later.',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.caption,
                          ),
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

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: Padding(
        padding: const EdgeInsets.only(
          left: 8,
        ),
        child: IconButton(
          tooltip: 'Go back',
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(
                AppRadius.small,
              ),
              border: Border.all(
                color: AppColors.divider,
              ),
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              size: 20,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
      title: Text(
        'New Task',
        style: AppTextStyles.heading3,
      ),
      centerTitle: false,
    );
  }

  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        22,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          AppRadius.extraLarge,
        ),
        border: Border.all(
          color: AppColors.primary.withValues(
            alpha: 0.28,
          ),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(
              alpha: 0.20,
            ),
            AppColors.surface,
            AppColors.surface,
          ],
          stops: const [
            0,
            0.55,
            1,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(
              alpha: 0.08,
            ),
            blurRadius: 30,
            spreadRadius: 0,
            offset: const Offset(
              0,
              12,
            ),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(
                alpha: 0.18,
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
            child: const Icon(
              Icons.auto_awesome_rounded,
              size: 25,
              color: AppColors.primaryLight,
            ),
          ),

          const SizedBox(
            width: AppSpacing.lg,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create your next focus session',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.heading2,
                ),

                const SizedBox(
                  height: AppSpacing.sm,
                ),

                Text(
                  'Break your goals into clear, focused tasks and make progress one session at a time.',
                  style: AppTextStyles.bodySecondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(
              AppRadius.small,
            ),
            border: Border.all(
              color: AppColors.divider,
            ),
          ),
          child: Icon(
            icon,
            size: 20,
            color: AppColors.primaryLight,
          ),
        ),

        const SizedBox(
          width: AppSpacing.md,
        ),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.heading3,
              ),
              const SizedBox(
                height: 2,
              ),
              Text(
                subtitle,
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTitleField() {
    return _buildFieldContainer(
      label: 'Task title',
      hint: 'Give your task a clear name',
      icon: Icons.task_alt_rounded,
      child: TextFormField(
        controller: _titleController,
        textInputAction: TextInputAction.next,
        maxLength: 60,
        style: AppTextStyles.body,
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
    return _buildFieldContainer(
      label: 'Description',
      hint: 'Add a little context to stay focused',
      icon: Icons.notes_rounded,
      child: TextFormField(
        controller: _descriptionController,
        textInputAction: TextInputAction.newline,
        keyboardType: TextInputType.multiline,
        minLines: 4,
        maxLines: 6,
        maxLength: 300,
        style: AppTextStyles.body,
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
    return _buildFieldContainer(
      label: 'Category',
      hint: 'Choose what this task belongs to',
      icon: Icons.category_rounded,
      child: DropdownButtonFormField<String>(
        value: _selectedCategory,
        dropdownColor: AppColors.surface,
        style: AppTextStyles.body,
        decoration: _inputDecoration(
          hintText: 'Select a category',
          prefixIcon: Icons.category_rounded,
        ),
        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: AppColors.textSecondary,
        ),
        borderRadius: BorderRadius.circular(
          AppRadius.medium,
        ),
        items: _categories.map(
          (category) {
            return DropdownMenuItem<String>(
              value: category,
              child: Row(
                children: [
                  _buildCategoryDot(category),
                  const SizedBox(
                    width: AppSpacing.sm,
                  ),
                  Text(
                    category,
                    style: AppTextStyles.body,
                  ),
                ],
              ),
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
    return _buildFieldContainer(
      label: 'Focus duration',
      hint: 'How long do you want to focus?',
      icon: Icons.timer_outlined,
      child: TextFormField(
        controller: _durationController,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.done,
        maxLength: 3,
        style: AppTextStyles.body,
        decoration: _inputDecoration(
          hintText: 'e.g. 25',
          prefixIcon: Icons.timer_outlined,
          suffixText: 'min',
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

  Widget _buildFieldContainer({
    required String label,
    required String hint,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(
                  alpha: 0.10,
                ),
                borderRadius: BorderRadius.circular(
                  AppRadius.small,
                ),
              ),
              child: Icon(
                icon,
                size: 16,
                color: AppColors.primaryLight,
              ),
            ),

            const SizedBox(
              width: AppSpacing.sm,
            ),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    hint,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(
          height: AppSpacing.md,
        ),

        child,
      ],
    );
  }

  Widget _buildFocusTip() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight.withValues(
          alpha: 0.65,
        ),
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
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(
                alpha: 0.12,
              ),
              borderRadius: BorderRadius.circular(
                AppRadius.small,
              ),
            ),
            child: const Icon(
              Icons.lightbulb_outline_rounded,
              size: 19,
              color: AppColors.warning,
            ),
          ),

          const SizedBox(
            width: AppSpacing.md,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Focus tip',
                  style: AppTextStyles.heading3.copyWith(
                    fontSize: 14,
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  'Keep your task specific and achievable. A clear goal makes it easier to stay focused.',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateButton() {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            AppRadius.medium,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(
                alpha: 0.25,
              ),
              blurRadius: 18,
              offset: const Offset(
                0,
                8,
              ),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: _createTask,
          icon: const Icon(
            Icons.arrow_forward_rounded,
            size: 20,
          ),
          label: Text(
            'Create Focus Task',
            style: AppTextStyles.button,
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                AppRadius.medium,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryDot(String category) {
    IconData icon;

    switch (category) {
      case 'Study':
        icon = Icons.school_outlined;
        break;

      case 'Work':
        icon = Icons.work_outline_rounded;
        break;

      case 'Personal':
        icon = Icons.person_outline_rounded;
        break;

      case 'Health':
        icon = Icons.favorite_border_rounded;
        break;

      default:
        icon = Icons.more_horiz_rounded;
    }

    return Icon(
      icon,
      size: 18,
      color: AppColors.primaryLight,
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
      hintStyle: AppTextStyles.bodySecondary.copyWith(
        color: AppColors.textMuted,
      ),
      filled: true,
      fillColor: AppColors.surface,
      counterStyle: AppTextStyles.caption,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      prefixIcon: Padding(
        padding: EdgeInsets.only(
          left: 14,
          right: 10,
          top: alignPrefixIconTop ? 14 : 0,
          bottom: alignPrefixIconTop ? 14 : 0,
        ),
        child: Icon(
          prefixIcon,
          size: 20,
          color: AppColors.textMuted,
        ),
      ),
      prefixIconConstraints: const BoxConstraints(
        minWidth: 50,
      ),
      suffixText: suffixText,
      suffixStyle: AppTextStyles.caption.copyWith(
        color: AppColors.primaryLight,
        fontWeight: FontWeight.w600,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          AppRadius.medium,
        ),
        borderSide: const BorderSide(
          color: AppColors.divider,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          AppRadius.medium,
        ),
        borderSide: const BorderSide(
          color: AppColors.divider,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          AppRadius.medium,
        ),
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          AppRadius.medium,
        ),
        borderSide: const BorderSide(
          color: AppColors.error,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          AppRadius.medium,
        ),
        borderSide: const BorderSide(
          color: AppColors.error,
          width: 1.5,
        ),
      ),
      errorStyle: AppTextStyles.caption.copyWith(
        color: AppColors.error,
        fontWeight: FontWeight.w500,
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