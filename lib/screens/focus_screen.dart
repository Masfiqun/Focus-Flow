import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/focus_mode_chip.dart';
import '../widgets/focus_timer.dart';
import '../widgets/responsive_layout.dart';
import '../widgets/session_task_card.dart';

class FocusScreen extends StatelessWidget {
  const FocusScreen({super.key});

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
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildHeader(),
              const SizedBox(height: 28),

              _buildSessionLabel(),

              const SizedBox(height: 22),

              const Center(
                child: FocusTimer(
                  progress: 0.68,
                  timeText: '24:36',
                ),
              ),

              const SizedBox(height: 24),

              _buildProgressText(),

              const SizedBox(height: 24),

              const SessionTaskCard(
                title: 'OpenCV Practice',
                category: 'Computer Vision',
              ),

              const SizedBox(height: 20),

              const Center(
                child: FocusModeChip(
                  icon: Icons.volume_off_rounded,
                  label: 'Focus Mode',
                ),
              ),

              const SizedBox(height: 26),

              _buildControls(),

              const SizedBox(height: 20),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildTablet(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 850,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 700;

            if (isWide) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(32),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: _buildTimerSection(),
                    ),
                    const SizedBox(width: 40),
                    Expanded(
                      child: _buildDetailsSection(),
                    ),
                  ],
                ),
              );
            }

            return _buildTabletStacked();
          },
        ),
      ),
    );
  }

  Widget _buildTabletStacked() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(28),
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 30),
          _buildTimerSection(),
          const SizedBox(height: 28),
          _buildDetailsSection(),
        ],
      ),
    );
  }

  Widget _buildTimerSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSessionLabel(),
        const SizedBox(height: 22),
        const FocusTimer(
          progress: 0.68,
          timeText: '24:36',
          size: 280,
        ),
        const SizedBox(height: 24),
        _buildProgressText(),
      ],
    );
  }

  Widget _buildDetailsSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SessionTaskCard(
          title: 'OpenCV Practice',
          category: 'Computer Vision',
        ),
        const SizedBox(height: 20),
        const FocusModeChip(
          icon: Icons.volume_off_rounded,
          label: 'Focus Mode',
        ),
        const SizedBox(height: 26),
        _buildControls(),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.divider,
            ),
          ),
          child: const Icon(
            Icons.timer_outlined,
            size: 20,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 13),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Focus Session',
                style: AppTextStyles.heading2,
              ),
              SizedBox(height: 2),
              Text(
                'Stay focused. You got this.',
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSessionLabel() {
    return Text(
      'DEEP WORK',
      style: AppTextStyles.caption.copyWith(
        color: AppColors.primaryLight,
        fontWeight: FontWeight.w700,
        letterSpacing: 2,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildProgressText() {
    return Column(
      children: [
        const Text(
          '68% completed',
          style: AppTextStyles.bodySecondary,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        FractionallySizedBox(
          widthFactor: 0.72,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: const LinearProgressIndicator(
              value: 0.68,
              minHeight: 5,
              backgroundColor: AppColors.surfaceLight,
              valueColor: AlwaysStoppedAnimation(
                AppColors.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSecondaryControl(
          icon: Icons.restart_alt_rounded,
          onTap: () {},
        ),
        const SizedBox(width: 18),
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.28),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.pause_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
        const SizedBox(width: 18),
        _buildSecondaryControl(
          icon: Icons.skip_next_rounded,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildSecondaryControl({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.surface,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(
            icon,
            size: 21,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}