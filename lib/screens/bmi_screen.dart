
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class BmiScreen extends StatefulWidget {
  const BmiScreen({super.key});

  @override
  State<BmiScreen> createState() => _BmiScreenState();
}

class _BmiScreenState extends State<BmiScreen> {
  final _formKey = GlobalKey<FormState>();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  double? _bmi;
  String? _category;
  String? _message;

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  String? _validateNumber(
    String? value, {
    required double min,
    required double max,
    required String label,
  }) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter your $label';
    }

    final number = double.tryParse(value.trim());

    if (number == null || !number.isFinite) {
      return 'Enter a valid number';
    }

    if (number < min || number > max) {
      return '$label must be between $min and $max';
    }

    return null;
  }

  void _calculateBmi() {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    final heightCm = double.parse(_heightController.text.trim());
    final weightKg = double.parse(_weightController.text.trim());
    final heightM = heightCm / 100;
    final bmi = weightKg / (heightM * heightM);

    String category;
    String message;

    if (bmi < 18.5) {
      category = 'Underweight';
      message =
          'Consider discussing your nutrition and health goals with a healthcare professional.';
    } else if (bmi < 25) {
      category = 'Healthy weight range';
      message =
          'Your BMI is within the standard healthy adult range. Continue supporting your wellbeing with balanced habits.';
    } else if (bmi < 30) {
      category = 'Overweight';
      message =
          'BMI is a screening measure. A healthcare professional can interpret it alongside your overall health.';
    } else {
      category = 'Obesity range';
      message =
          'BMI is not a diagnosis. Consider discussing your result with a healthcare professional.';
    }

    setState(() {
      _bmi = bmi;
      _category = category;
      _message = message;
    });
  }

  void _reset() {
    _heightController.clear();
    _weightController.clear();

    setState(() {
      _bmi = null;
      _category = null;
      _message = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'BMI Calculator',
          style: AppTextStyles.heading2,
        ),
        leading: IconButton(
          tooltip: 'Go back',
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
          color: AppColors.textPrimary,
        ),
      ),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final padding = constraints.maxWidth < 360
                ? 16.0
                : constraints.maxWidth < 600
                    ? 20.0
                    : constraints.maxWidth < 900
                        ? 32.0
                        : 40.0;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                padding,
                AppSpacing.lg,
                padding,
                AppSpacing.xxxl,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 680),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildIntroCard(),
                      const SizedBox(height: AppSpacing.xl),
                      _buildCalculatorCard(),
                      if (_bmi != null) ...[
                        const SizedBox(height: AppSpacing.xl),
                        _buildResultCard(),
                      ],
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'BMI is a screening tool, not a diagnosis. Adult BMI '
                        'categories may not apply to children, teenagers, '
                        'pregnant people, or all athletes.',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildIntroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
            child: const Icon(
              Icons.monitor_weight_outlined,
              color: AppColors.primaryLight,
              size: 26,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Understand your BMI',
                  style: AppTextStyles.heading3,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Enter your height and weight to calculate your '
                  'Body Mass Index.',
                  style: AppTextStyles.bodySecondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculatorCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: AppColors.divider),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your measurements',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: AppSpacing.xl),
            _buildNumberField(
              controller: _heightController,
              label: 'Height',
              hint: 'e.g. 170',
              suffix: 'cm',
              icon: Icons.height_rounded,
              validator: (value) => _validateNumber(
                value,
                min: 50,
                max: 250,
                label: 'height',
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildNumberField(
              controller: _weightController,
              label: 'Weight',
              hint: 'e.g. 65',
              suffix: 'kg',
              icon: Icons.monitor_weight_outlined,
              validator: (value) => _validateNumber(
                value,
                min: 10,
                max: 500,
                label: 'weight',
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _reset,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      minimumSize: const Size.fromHeight(52),
                      side: const BorderSide(
                        color: AppColors.divider,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppRadius.medium,
                        ),
                      ),
                    ),
                    child: Text(
                      'Reset',
                      style: AppTextStyles.button,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _calculateBmi,
                    icon: const Icon(
                      Icons.calculate_outlined,
                      size: 19,
                    ),
                    label: Text(
                      'Calculate BMI',
                      style: AppTextStyles.button,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppRadius.medium,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String suffix,
    required IconData icon,
    required String? Function(String?) validator,
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
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
          ),
          textInputAction: TextInputAction.next,
          style: AppTextStyles.body,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodySecondary,
            prefixIcon: Icon(
              icon,
              color: AppColors.textSecondary,
            ),
            suffixText: suffix,
            suffixStyle: AppTextStyles.bodySecondary,
            filled: true,
            fillColor: AppColors.background,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.lg,
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
                color: AppColors.primaryLight,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your result', style: AppTextStyles.heading3),
          const SizedBox(height: AppSpacing.xl),
          Center(
            child: Column(
              children: [
                Text(
                  _bmi!.toStringAsFixed(1),
                  style: AppTextStyles.heading1.copyWith(
                    color: AppColors.primaryLight,
                    fontSize: 48,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text('BMI', style: AppTextStyles.bodySecondary),
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    _category!,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.primaryLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _buildBmiScale(_bmi!),
          const SizedBox(height: AppSpacing.lg),
          Text(
            _message!,
            style: AppTextStyles.bodySecondary,
          ),
          const SizedBox(height: AppSpacing.lg),
          const Divider(color: AppColors.divider),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Adult BMI reference',
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildRangeRow('Underweight', 'Below 18.5'),
          _buildRangeRow('Healthy range', '18.5 – 24.9'),
          _buildRangeRow('Overweight', '25.0 – 29.9'),
          _buildRangeRow('Obesity range', '30.0 or above'),
        ],
      ),
    );
  }

  Widget _buildBmiScale(double bmi) {
    final marker = ((bmi - 15) / 25).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 10,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF5B8DEF),
                        Color(0xFF36B37E),
                        Color(0xFFFFC857),
                        Color(0xFFE85D75),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: (constraints.maxWidth - 14) * marker,
                  top: -3,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary,
                        width: 3,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('15', style: AppTextStyles.caption),
            Text('25', style: AppTextStyles.caption),
            Text('40', style: AppTextStyles.caption),
          ],
        ),
      ],
    );
  }

  Widget _buildRangeRow(String label, String range) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodySecondary,
            ),
          ),
          Text(
            range,
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
