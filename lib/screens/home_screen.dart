import 'package:flutter/material.dart';

import '../theme/app_text_styles.dart';
import '../widgets/responsive_layout.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ResponsiveLayout(
        mobile: _buildMobile(context),
        tablet: _buildTablet(context),
      ),
    );
  }

  Widget _buildMobile(BuildContext context) {
    return const Center(
      child: Text(
        'Home',
        style: AppTextStyles.heading1,
      ),
    );
  }

  Widget _buildTablet(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 700,
        ),
        child: const Center(
          child: Text(
            'Home',
            style: AppTextStyles.heading1,
          ),
        ),
      ),
    );
  }
}