import 'package:flutter/material.dart';

import '../models/task.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/focus_progress_card.dart';
import '../widgets/quick_start_card.dart';
import '../widgets/responsive_layout.dart';
import '../widgets/task_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const List<Task> _tasks = [
    Task(
      title: 'Machine Learning Assignment',
      category: 'University',
      isCompleted: true,
      duration: 45,
    ),
    Task(
      title: 'Flutter UI Practice',
      category: 'Development',
      isCompleted: true,
      duration: 50,
    ),
    Task(
      title: 'OpenCV Practice',
      category: 'Computer Vision',
      isCompleted: false,
      duration: 40,
    ),
    Task(
      title: 'Read Research Paper',
      category: 'Research',
      isCompleted: false,
      duration: 30,
    ),
  ];

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
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildHeader(),
              const SizedBox(height: 24),

              const FocusProgressCard(
                focusedMinutes: 204,
                targetMinutes: 260,
              ),

              const SizedBox(height: 30),

              _buildSectionHeader(
                title: "Today's Tasks",
                action: 'See all',
              ),

              const SizedBox(height: 12),

              ..._tasks.map(
                (task) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: TaskCard(task: task),
                ),
              ),

              const SizedBox(height: 20),

              _buildSectionHeader(
                title: 'Quick Start',
              ),

              const SizedBox(height: 12),

              _buildQuickStartGrid(),

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
          maxWidth: 900,
        ),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(32, 28, 32, 40),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildHeader(),

                  const SizedBox(height: 28),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(
                        flex: 5,
                        child: FocusProgressCard(
                          focusedMinutes: 204,
                          targetMinutes: 260,
                        ),
                      ),

                      const SizedBox(width: 20),

                      Expanded(
                        flex: 4,
                        child: _buildTabletQuickStart(),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  _buildSectionHeader(
                    title: "Today's Tasks",
                    action: 'See all',
                  ),

                  const SizedBox(height: 12),

                  ..._tasks.map(
                    (task) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: TaskCard(task: task),
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Good morning 👋',
          style: AppTextStyles.heading1,
        ),
        SizedBox(height: 6),
        Text(
          "Let's focus on what matters.",
          style: AppTextStyles.bodySecondary,
        ),
      ],
    );
  }

  Widget _buildSectionHeader({
    required String title,
    String? action,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.heading2,
          ),
        ),
        if (action != null)
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
              ),
              minimumSize: const Size(0, 40),
            ),
            child: Text(
              action,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.primaryLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildQuickStartGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final cardWidth = (width - 12) / 2;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: cardWidth,
              child: QuickStartCard(
                title: 'Quick Focus',
                subtitle: 'Get started',
                minutes: 25,
                icon: Icons.bolt_rounded,
                onTap: () {},
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: QuickStartCard(
                title: 'Deep Work',
                subtitle: 'Long session',
                minutes: 50,
                icon: Icons.psychology_rounded,
                onTap: () {},
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTabletQuickStart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Quick Start',
          style: AppTextStyles.heading2,
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 135,
          child: Row(
            children: [
              Expanded(
                child: QuickStartCard(
                  title: 'Quick Focus',
                  subtitle: 'Get started',
                  minutes: 25,
                  icon: Icons.bolt_rounded,
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: QuickStartCard(
                  title: 'Deep Work',
                  subtitle: 'Long session',
                  minutes: 50,
                  icon: Icons.psychology_rounded,
                  onTap: () {},
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}