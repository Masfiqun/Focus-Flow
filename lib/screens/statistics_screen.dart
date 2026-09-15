import 'package:flutter/material.dart';

import '../theme/app_text_styles.dart';
import '../widgets/responsive_layout.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ResponsiveLayout(
        mobile: _buildMobile(),
        tablet: _buildTablet(),
      ),
    );
  }

  Widget _buildMobile() {
    return const Center(
      child: Text(
        'Statistics',
        style: AppTextStyles.heading1,
      ),
    );
  }

  Widget _buildTablet() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 700,
        ),
        child: const Text(
          'Statistics',
          style: AppTextStyles.heading1,
        ),
      ),
    );
  }
}