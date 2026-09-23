import 'package:flutter/material.dart';

import '../models/task.dart';
import '../services/task_storage_service.dart';
import '../theme/app_text_styles.dart';
import '../widgets/achievement_card.dart';
import '../widgets/productivity_score_card.dart';
import '../widgets/responsive_layout.dart';
import '../widgets/statistic_card.dart';
import '../widgets/weekly_chart.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  List<Task> _tasks = [];

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  void _loadStatistics() {
    final tasks = TaskStorageService.getTasks();

    setState(() {
      _tasks = tasks;
    });
  }

  // ------------------------------------------------------------
  // STATISTICS
  // ------------------------------------------------------------

  int get _totalTasks {
    return _tasks.length;
  }

  int get _completedTasks {
    return _tasks.where((task) => task.isCompleted).length;
  }

  int get _totalFocusMinutes {
    return _tasks
        .where((task) => task.isCompleted)
        .fold(
          0,
          (total, task) => total + task.duration,
        );
  }

  int get _completionPercentage {
    if (_totalTasks == 0) {
      return 0;
    }

    return ((_completedTasks / _totalTasks) * 100).round();
  }

  int get _productivityScore {
    if (_totalTasks == 0) {
      return 0;
    }

    return _completionPercentage;
  }

  int get _longestCompletedTask {
    final completedTasks = _tasks.where(
      (task) => task.isCompleted,
    );

    if (completedTasks.isEmpty) {
      return 0;
    }

    return completedTasks
        .map((task) => task.duration)
        .reduce(
          (current, next) => current > next ? current : next,
        );
  }

  String get _focusTimeLabel {
    final hours = _totalFocusMinutes ~/ 60;
    final minutes = _totalFocusMinutes % 60;

    if (hours == 0) {
      return '${minutes}m';
    }

    if (minutes == 0) {
      return '${hours}h';
    }

    return '${hours}h ${minutes}m';
  }

  String get _completionTrend {
    if (_totalTasks == 0) {
      return 'No tasks yet';
    }

    return '$_completedTasks of $_totalTasks completed';
  }

  String get _sessionTrend {
    if (_completedTasks == 0) {
      return 'No completed tasks';
    }

    if (_completedTasks == 1) {
      return '1 completed task';
    }

    return '$_completedTasks completed';
  }

  String get _productivityLabel {
    if (_totalTasks == 0) {
      return 'Start your first task';
    }

    if (_productivityScore >= 80) {
      return 'Great progress';
    }

    if (_productivityScore >= 50) {
      return 'Keep going';
    }

    return 'Build your momentum';
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

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

              ProductivityScoreCard(
                score: _productivityScore,
                label: _productivityLabel,
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

                  ProductivityScoreCard(
                    score: _productivityScore,
                    label: _productivityLabel,
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

  // ------------------------------------------------------------
  // HEADER
  // ------------------------------------------------------------

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

  // ------------------------------------------------------------
  // SECTION TITLE
  // ------------------------------------------------------------

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.heading2,
    );
  }

  // ------------------------------------------------------------
  // STATISTICS
  // ------------------------------------------------------------

  Widget _buildStatisticGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        if (width >= 650) {
          return Row(
            children: [
              Expanded(
                child: StatisticCard(
                  icon: Icons.schedule_rounded,
                  value: _focusTimeLabel,
                  label: 'Focus time',
                  trend: _totalFocusMinutes == 0
                      ? 'No completed focus'
                      : 'From completed tasks',
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: StatisticCard(
                  icon: Icons.check_circle_outline_rounded,
                  value: '$_completedTasks',
                  label: 'Sessions',
                  trend: _sessionTrend,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: StatisticCard(
                  icon: Icons.task_alt_rounded,
                  value: '$_completionPercentage%',
                  label: 'Completion',
                  trend: _completionTrend,
                ),
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: StatisticCard(
                icon: Icons.schedule_rounded,
                value: _focusTimeLabel,
                label: 'Focus time',
                trend: _totalFocusMinutes == 0
                    ? 'No completed focus'
                    : 'Completed tasks',
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: StatisticCard(
                icon: Icons.check_circle_outline_rounded,
                value: '$_completedTasks',
                label: 'Sessions',
                trend: _sessionTrend,
              ),
            ),
          ],
        );
      },
    );
  }
}