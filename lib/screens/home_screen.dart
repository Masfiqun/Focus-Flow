import 'package:flutter/material.dart';

import '../widgets/focusflow_logo.dart';
import '../models/task.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_section_header.dart';
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

  double _horizontalPadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    if (width < 340) {
      return 16;
    }

    if (width < 400) {
      return 20;
    }

    return 24;
  }

  Widget _buildMobile(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            _horizontalPadding(context),
            20,
            _horizontalPadding(context),
            32,
          ),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildHeader(),
              const SizedBox(height: 24),
              const FocusProgressCard(
                focusedMinutes: 204,
                targetMinutes: 260,
              ),
              const SizedBox(height: 30),
              AppSectionHeader(
                title: "Today's Tasks",
                actionLabel: 'See all',
                onActionTap: () {},
              ),
              const SizedBox(height: 12),
              ..._tasks.map(
                (task) => Padding(
                  padding: const EdgeInsets.only(
                    bottom: 10,
                  ),
                  child: TaskCard(task: task),
                ),
              ),
              const SizedBox(height: 20),
              const AppSectionHeader(
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
              padding: const EdgeInsets.fromLTRB(
                32,
                28,
                32,
                40,
              ),
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
                  AppSectionHeader(
                    title: "Today's Tasks",
                    actionLabel: 'See all',
                    onActionTap: () {},
                  ),
                  const SizedBox(height: 12),
                  ..._tasks.map(
                    (task) => Padding(
                      padding: const EdgeInsets.only(
                        bottom: 10,
                      ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FocusFlowLogo(
          iconSize: 38,
        ),
        const SizedBox(height: 22),
        Text(
          'Good morning 👋',
          style: AppTextStyles.heading1,
        ),
        const SizedBox(height: 6),
        Text(
          "Let's focus on what matters.",
          style: AppTextStyles.bodySecondary,
        ),
      ],
    );
  }

  Widget _buildQuickStartGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isVeryNarrow = constraints.maxWidth < 340;

        final cardWidth = isVeryNarrow
            ? constraints.maxWidth
            : (constraints.maxWidth - 12) / 2;

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
        const AppSectionHeader(
          title: 'Quick Start',
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
