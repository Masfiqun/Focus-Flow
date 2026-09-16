import 'package:flutter/material.dart';

import '../theme/app_text_styles.dart';
import '../widgets/achievement_card.dart';
import '../widgets/productivity_score_card.dart';
import '../widgets/responsive_layout.dart';
import '../widgets/statistic_card.dart';
import '../widgets/weekly_chart.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

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
          padding: const EdgeInsets.fromLTRB(
            20,
            20,
            20,
            32,
          ),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildHeader(),
              const SizedBox(height: 24),
              const ProductivityScoreCard(
                score: 86,
                label: '',
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Overview'),
              const SizedBox(height: 12),
              _buildStatisticGrid(),
              const SizedBox(height: 24),
              const WeeklyChart(),
              const SizedBox(height: 24),
              _buildSectionTitle('Achievement'),
              const SizedBox(height: 12),
              const AchievementCard(),
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
                  const ProductivityScoreCard(
                    score: 86,
                    label: '',
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Overview'),
                  const SizedBox(height: 12),
                  _buildStatisticGrid(),
                  const SizedBox(height: 24),
                  const WeeklyChart(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Achievement'),
                  const SizedBox(height: 12),
                  const AchievementCard(),
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
        Text(
          'Your Progress',
          style: AppTextStyles.heading1,
        ),
        const SizedBox(height: 6),
        Text(
          'See how your focus is improving over time.',
          style: AppTextStyles.bodySecondary,
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.heading2,
    );
  }

  Widget _buildStatisticGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        if (width >= 650) {
          return Row(
            children: [
              const Expanded(
                child: StatisticCard(
                  icon: Icons.schedule_rounded,
                  value: '18h 42m',
                  label: 'Focus time',
                  trend: '+18% this week',
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: StatisticCard(
                  icon: Icons.check_circle_outline_rounded,
                  value: '42',
                  label: 'Sessions',
                  trend: '+8 this week',
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: StatisticCard(
                  icon: Icons.task_alt_rounded,
                  value: '86%',
                  label: 'Completion',
                  trend: '+6% this week',
                ),
              ),
            ],
          );
        }

        return Row(
          children: [
            const Expanded(
              child: StatisticCard(
                icon: Icons.schedule_rounded,
                value: '18h 42m',
                label: 'Focus time',
                trend: '+18%',
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: StatisticCard(
                icon: Icons.check_circle_outline_rounded,
                value: '42',
                label: 'Sessions',
                trend: '+8',
              ),
            ),
          ],
        );
      },
    );
  }
}
