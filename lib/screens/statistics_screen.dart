import 'package:flutter/material.dart';

import '../models/focus_session.dart';
import '../models/task.dart';
import '../services/focus_session_storage_service.dart';
import '../services/task_storage_service.dart';
import '../theme/app_text_styles.dart';
import '../widgets/achievement_card.dart';
import '../widgets/productivity_score_card.dart';
import '../widgets/responsive_layout.dart';
import '../widgets/statistic_card.dart';
import '../widgets/weekly_chart.dart';
import '../widgets/productivity_breakdown.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({
    super.key,
  });

  @override
  State<StatisticsScreen> createState() =>
      _StatisticsScreenState();
}

class _StatisticsScreenState
    extends State<StatisticsScreen> {
  List<Task> _tasks = [];
  List<FocusSession> _sessions = [];

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  void _loadStatistics() {
    final tasks = TaskStorageService.getTasks();
    final sessions =
        FocusSessionStorageService.getSessions();

    if (!mounted) {
      return;
    }

    setState(() {
      _tasks = tasks;
      _sessions = sessions;
    });
  }

  // ------------------------------------------------------------
  // TODAY
  // ------------------------------------------------------------

  List<FocusSession> get _todaySessions {
    final now = DateTime.now();

    return _sessions.where((session) {
      final date = session.startedAt;

      return date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;
    }).toList();
  }

  // ------------------------------------------------------------
  // STATISTICS
  // ------------------------------------------------------------

  int get _totalTasks {
    return _tasks.length;
  }

  int get _completedTasks {
    return _tasks
        .where((task) => task.isCompleted)
        .length;
  }

  int get _totalFocusSeconds {
    return _sessions.fold(
      0,
      (total, session) =>
          total + session.completedSeconds,
    );
  }

  int get _todayFocusSeconds {
    return _todaySessions.fold(
      0,
      (total, session) =>
          total + session.completedSeconds,
    );
  }

  int get _totalFocusMinutes {
    return _totalFocusSeconds ~/ 60;
  }

  int get _todayFocusMinutes {
    return _todayFocusSeconds ~/ 60;
  }

  double get _todayFocusScore {
    const dailyFocusTargetMinutes = 125;

    if (_todayFocusMinutes <= 0) {
      return 0;
    }

    return (_todayFocusMinutes /
            dailyFocusTargetMinutes *
            100)
        .clamp(0.0, 100.0);
  }

  int get _completedSessions {
    return _sessions
        .where((session) => session.isCompleted)
        .length;
  }

  int get _completionPercentage {
    if (_totalTasks == 0) {
      return 0;
    }

    return ((_completedTasks / _totalTasks) * 100)
        .round();
  }

  int get _productivityScore {
    if (_totalTasks == 0 &&
        _sessions.isEmpty) {
      return 0;
    }

    // ----------------------------------------------------------
    // 1. TASK COMPLETION SCORE
    // ----------------------------------------------------------

    // final taskScore = _totalTasks == 0
    //     ? 0.0
    //     : (_completedTasks / _totalTasks) * 100;

    // ----------------------------------------------------------
    // 2. FOCUS TIME SCORE
    // ----------------------------------------------------------
    //
    // Target: 125 minutes of actual focus time.
    //
    // Once the user reaches the target, this component is capped
    // at 100 instead of allowing the overall score to exceed 100.
    //

    // const dailyFocusTargetMinutes = 125;

    // final focusScore = _todayFocusScore;

    // ----------------------------------------------------------
    // 3. SESSION COMPLETION SCORE
    // ----------------------------------------------------------

    // final sessionScore = _sessions.isEmpty
    //     ? 0.0
    //     : (_completedSessions / _sessions.length) * 100;

    // ----------------------------------------------------------
    // FINAL SCORE
    // ----------------------------------------------------------

    final score =
        (_taskScore * 0.40) +
        (_focusScore * 0.40) +
        (_sessionScore * 0.20);

    return score.round().clamp(0, 100);
  }

  int get _longestFocusMinutes {
    if (_sessions.isEmpty) {
      return 0;
    }

    final longestSeconds = _sessions
        .map(
          (session) => session.completedSeconds,
        )
        .reduce(
          (current, next) =>
              current > next ? current : next,
        );

    return longestSeconds ~/ 60;
  }

  double get _taskScore {
    if (_totalTasks == 0) {
      return 0;
    }

    return ((_completedTasks / _totalTasks) * 100)
        .clamp(0.0, 100.0);
  }

  double get _focusScore {
    const dailyFocusTargetMinutes = 125;

    if (_todayFocusMinutes <= 0) {
      return 0;
    }

    return ((_todayFocusMinutes /
                dailyFocusTargetMinutes) *
            100)
        .clamp(0.0, 100.0);
  }

  double get _sessionScore {
    if (_sessions.isEmpty) {
      return 0;
    }

    return ((_completedSessions / _sessions.length) * 100)
        .clamp(0.0, 100.0);
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

  String get _todayFocusLabel {
    final hours = _todayFocusMinutes ~/ 60;
    final minutes = _todayFocusMinutes % 60;

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

    return '$_completedTasks of '
        '$_totalTasks completed';
  }

  String get _sessionTrend {
    if (_completedSessions == 0) {
      if (_sessions.isEmpty) {
        return 'No focus sessions';
      }

      return '${_sessions.length} partial';
    }

    return '$_completedSessions completed';
  }

  String get _productivityLabel {
    if (_totalTasks == 0 &&
        _sessions.isEmpty) {
      return 'Start your first session';
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
    return Scaffold(
      body: SafeArea(
        child: ResponsiveLayout(
          mobile: _buildMobile(context),
          tablet: _buildTablet(context),
        ),
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

              const SizedBox(height: 16),

              ProductivityBreakdown(
                taskScore: _taskScore,
                focusScore: _focusScore,
                sessionScore: _sessionScore,
              ),

              const SizedBox(height: 24),

              _buildTodayCard(),

              const SizedBox(height: 24),

              _buildSectionTitle('Overview'),

              const SizedBox(height: 12),

              _buildStatisticGrid(),

              const SizedBox(height: 24),

              WeeklyChart(
                sessions: _sessions,
              ),

              const SizedBox(height: 24),

              _buildSectionTitle('Achievement'),

              const SizedBox(height: 12),

              AchievementCard(
                tasks: _tasks,
                sessions: _sessions,
              ),

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

                  const SizedBox(height: 16),

                  ProductivityBreakdown(
                    taskScore: _taskScore,
                    focusScore: _focusScore,
                    sessionScore: _sessionScore,
                  ),

                  const SizedBox(height: 24),

                  _buildTodayCard(),

                  const SizedBox(height: 24),

                  _buildSectionTitle('Overview'),

                  const SizedBox(height: 12),

                  _buildStatisticGrid(),

                  const SizedBox(height: 24),

                  WeeklyChart(
                    sessions: _sessions,
                  ),

                  const SizedBox(height: 24),

                  _buildSectionTitle('Achievement'),

                  const SizedBox(height: 12),

                  AchievementCard(
                    tasks: _tasks,
                    sessions: _sessions,
                  ),
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
      crossAxisAlignment:
          CrossAxisAlignment.start,
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
  // TODAY CARD
  // ------------------------------------------------------------

  Widget _buildTodayCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF15131D),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF292633),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            "Today's Focus",
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: 6),
          Text(
            'Actual focus time recorded today.',
            style: AppTextStyles.bodySecondary,
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _buildTodayMetric(
                  icon: Icons.timer_outlined,
                  value: _todayFocusLabel,
                  label: 'Focus time',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTodayMetric(
                  icon: Icons.check_circle_outline_rounded,
                  value: '${_todaySessions.length}',
                  label: 'Sessions',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTodayMetric({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF211E2B),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFFA78BFA),
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: AppTextStyles.heading3,
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
        ],
      ),
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
                      ? 'No focus recorded'
                      : 'Actual focus time',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatisticCard(
                  icon:
                      Icons.check_circle_outline_rounded,
                  value: '$_completedSessions',
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
                    ? 'No focus recorded'
                    : 'Actual focus',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatisticCard(
                icon:
                    Icons.check_circle_outline_rounded,
                value: '$_completedSessions',
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