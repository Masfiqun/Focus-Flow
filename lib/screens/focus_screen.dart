import 'dart:async';

import 'package:flutter/material.dart';

import '../models/focus_session.dart';
import '../models/task.dart';
import '../services/focus_session_storage_service.dart';
import '../services/task_storage_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/focus_mode_chip.dart';
import '../widgets/focus_timer.dart';
import '../widgets/responsive_layout.dart';
import '../widgets/session_task_card.dart';

enum FocusSessionResult {
  completed,
  skipped,
}

class FocusScreen extends StatefulWidget {
  final Task? task;

  const FocusScreen({
    super.key,
    this.task,
  });

  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> {
  static const int _defaultDurationMinutes = 25;

  // Persist a running session every 10 seconds instead
  // of writing to Hive every second.
  static const int _persistenceIntervalSeconds = 10;

  Timer? _timer;

  late int _totalSeconds;
  late int _remainingSeconds;

  late String _sessionId;
  late DateTime _startedAt;

  int _secondsSinceLastSave = 0;

  bool _isRunning = false;
  bool _hasCompleted = false;
  bool _isCompleting = false;

  Task? get _task => widget.task;

  String get _taskTitle {
    return _task?.title ?? 'Quick Focus Session';
  }

  String get _taskCategory {
    return _task?.category ?? 'Deep Work';
  }

  int get _durationMinutes {
    return _task?.duration ?? _defaultDurationMinutes;
  }

  double get _progress {
    if (_totalSeconds <= 0) {
      return 0;
    }

    final completedSeconds =
        _totalSeconds - _remainingSeconds;

    return (completedSeconds / _totalSeconds)
        .clamp(0.0, 1.0);
  }

  int get _completedSeconds {
    return _totalSeconds - _remainingSeconds;
  }

  @override
  void initState() {
    super.initState();

    _totalSeconds = _durationMinutes * 60;
    _remainingSeconds = _totalSeconds;

    _createNewSession();

    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // ------------------------------------------------------------
  // SESSION
  // ------------------------------------------------------------

  void _createNewSession() {
    _sessionId =
        DateTime.now().microsecondsSinceEpoch.toString();

    _startedAt = DateTime.now();

    _secondsSinceLastSave = 0;
  }

  Future<void> _saveCurrentSession({
    DateTime? completedAt,
  }) async {
    if (_completedSeconds <= 0 && !_hasCompleted) {
      return;
    }

    final session = FocusSession(
      id: _sessionId,
      taskId: _task?.id,
      taskTitle: _taskTitle,
      durationSeconds: _totalSeconds,
      completedSeconds: _completedSeconds,
      startedAt: _startedAt,
      completedAt: completedAt,
    );

    await FocusSessionStorageService.saveSession(
      session,
    );

    _secondsSinceLastSave = 0;
  }

  Future<void> _saveCompletedSession() async {
    final session = FocusSession(
      id: _sessionId,
      taskId: _task?.id,
      taskTitle: _taskTitle,
      durationSeconds: _totalSeconds,
      completedSeconds: _totalSeconds,
      startedAt: _startedAt,
      completedAt: DateTime.now(),
    );

    await FocusSessionStorageService.saveSession(
      session,
    );

    _secondsSinceLastSave = 0;
  }

  Future<void> _markTaskCompleted() async {
    final task = _task;

    if (task == null) {
      return;
    }

    if (task.isCompleted) {
      return;
    }

    final completedTask = task.copyWith(
      isCompleted: true,
    );

    await TaskStorageService.updateTask(
      completedTask,
    );
  }

  // ------------------------------------------------------------
  // TIMER
  // ------------------------------------------------------------

  void _startTimer() {
    if (_isRunning || _hasCompleted) {
      return;
    }

    setState(() {
      _isRunning = true;
    });

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (!mounted) {
          return;
        }

        if (_remainingSeconds <= 1) {
          _timer?.cancel();

          setState(() {
            _remainingSeconds = 0;
            _isRunning = false;
            _hasCompleted = true;
          });

          _completeSession();

          return;
        }

        setState(() {
          _remainingSeconds--;
        });

        _secondsSinceLastSave++;

        // Persist a running session every 10 seconds.
        if (_secondsSinceLastSave >=
            _persistenceIntervalSeconds) {
          _saveCurrentSession();
        }
      },
    );
  }

  void _pauseTimer() {
    if (!_isRunning) {
      return;
    }

    _timer?.cancel();

    setState(() {
      _isRunning = false;
    });

    // Always save immediately when the user pauses.
    _saveCurrentSession();
  }

  void _toggleTimer() {
    if (_hasCompleted) {
      return;
    }

    if (_isRunning) {
      _pauseTimer();
    } else {
      _startTimer();
    }
  }

  void _resetTimer() {
    if (_isCompleting) {
      return;
    }

    _timer?.cancel();

    setState(() {
      _remainingSeconds = _totalSeconds;
      _isRunning = false;
      _hasCompleted = false;
    });

    _createNewSession();

    _startTimer();
  }

  // ------------------------------------------------------------
  // SESSION COMPLETION
  // ------------------------------------------------------------

  Future<void> _completeSession() async {
    if (!_hasCompleted || _isCompleting) {
      return;
    }

    _isCompleting = true;

    _timer?.cancel();

    await _saveCompletedSession();

    await _markTaskCompleted();

    if (!mounted) {
      return;
    }

    await _showCompletionDialog();

    if (!mounted) {
      return;
    }

    Navigator.pop(
      context,
      FocusSessionResult.completed,
    );
  }

  Future<void> _skipSession() async {
    if (_hasCompleted || _isCompleting) {
      return;
    }

    _timer?.cancel();

    setState(() {
      _isRunning = false;
    });

    await _saveCurrentSession();

    if (!mounted) {
      return;
    }

    Navigator.pop(
      context,
      FocusSessionResult.skipped,
    );
  }

  // ------------------------------------------------------------
  // COMPLETION DIALOG
  // ------------------------------------------------------------

  Future<void> _showCompletionDialog() async {
    await Future<void>.delayed(Duration.zero);

    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(
                    alpha: 0.12,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Session Complete',
                  style: AppTextStyles.heading3,
                ),
              ),
            ],
          ),
          content: Text(
            'Great work! You completed your '
            '$_durationMinutes-minute focus session.',
            style: AppTextStyles.bodySecondary,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: Text(
                'Done',
                style: AppTextStyles.button.copyWith(
                  color: AppColors.primaryLight,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ------------------------------------------------------------
  // FORMATTING
  // ------------------------------------------------------------

  String _formatTime(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }

    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  String _formatCompletedTime() {
    final minutes = _completedSeconds ~/ 60;
    final seconds = _completedSeconds % 60;

    if (minutes == 0) {
      return '$seconds sec';
    }

    if (seconds == 0) {
      return '$minutes min';
    }

    return '$minutes min $seconds sec';
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ResponsiveLayout(
          mobile: _buildMobile(context),
          tablet: _buildTablet(context),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // MOBILE
  // ------------------------------------------------------------

  Widget _buildMobile(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            20,
            16,
            20,
            32,
          ),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildHeader(),

              const SizedBox(height: 28),

              _buildSessionLabel(),

              const SizedBox(height: 22),

              Center(
                child: FocusTimer(
                  progress: _progress,
                  timeText: _formatTime(
                    _remainingSeconds,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              _buildProgressText(),

              const SizedBox(height: 24),

              _buildTaskCard(),

              const SizedBox(height: 20),

              _buildFocusModeChip(),

              const SizedBox(height: 26),

              _buildControls(),

              const SizedBox(height: 20),
            ]),
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // TABLET
  // ------------------------------------------------------------

  Widget _buildTablet(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 850,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide =
                constraints.maxWidth >= 700;

            if (isWide) {
              return SingleChildScrollView(
                physics:
                    const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(32),
                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.center,
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

        FocusTimer(
          progress: _progress,
          timeText: _formatTime(
            _remainingSeconds,
          ),
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
        _buildTaskCard(),

        const SizedBox(height: 20),

        _buildFocusModeChip(),

        const SizedBox(height: 26),

        _buildControls(),
      ],
    );
  }

  // ------------------------------------------------------------
  // HEADER
  // ------------------------------------------------------------

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

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'Focus Session',
                style: AppTextStyles.heading2,
              ),

              const SizedBox(height: 2),

              Text(
                _isRunning
                    ? 'Stay focused. You got this.'
                    : _hasCompleted
                        ? 'Session completed. Great work!'
                        : 'Session paused.',
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // SESSION LABEL
  // ------------------------------------------------------------

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

  // ------------------------------------------------------------
  // PROGRESS
  // ------------------------------------------------------------

  Widget _buildProgressText() {
    final percentage = (_progress * 100).round();

    return Column(
      children: [
        Text(
          '$percentage% completed',
          style: AppTextStyles.bodySecondary,
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 8),

        FractionallySizedBox(
          widthFactor: 0.72,
          child: ClipRRect(
            borderRadius:
                BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: _progress,
              minHeight: 5,
              backgroundColor:
                  AppColors.surfaceLight,
              valueColor:
                  const AlwaysStoppedAnimation(
                AppColors.primary,
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),

        Text(
          '${_formatCompletedTime()} focused',
          style: AppTextStyles.caption,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // TASK
  // ------------------------------------------------------------

  Widget _buildTaskCard() {
    return SessionTaskCard(
      title: _taskTitle,
      category: _taskCategory,
    );
  }

  // ------------------------------------------------------------
  // FOCUS MODE
  // ------------------------------------------------------------

  Widget _buildFocusModeChip() {
    return const Center(
      child: FocusModeChip(
        icon: Icons.volume_off_rounded,
        label: 'Focus Mode',
      ),
    );
  }

  // ------------------------------------------------------------
  // CONTROLS
  // ------------------------------------------------------------

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSecondaryControl(
          icon: Icons.restart_alt_rounded,
          onTap: _resetTimer,
        ),

        const SizedBox(width: 18),

        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            color: _hasCompleted
                ? AppColors.success
                : AppColors.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: (_hasCompleted
                        ? AppColors.success
                        : AppColors.primary)
                    .withValues(alpha: 0.28),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: IconButton(
            onPressed: _hasCompleted
                ? _resetTimer
                : _toggleTimer,
            tooltip: _hasCompleted
                ? 'Restart session'
                : _isRunning
                    ? 'Pause session'
                    : 'Resume session',
            icon: Icon(
              _hasCompleted
                  ? Icons.replay_rounded
                  : _isRunning
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),

        const SizedBox(width: 18),

        _buildSecondaryControl(
          icon: Icons.skip_next_rounded,
          onTap: _skipSession,
        ),
      ],
    );
  }

  Widget _buildSecondaryControl({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Semantics(
      button: true,
      label: _getIconLabel(icon),
      child: Material(
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
      ),
    );
  }

  String _getIconLabel(IconData icon) {
    if (icon == Icons.restart_alt_rounded) {
      return 'Restart';
    }

    if (icon == Icons.skip_next_rounded) {
      return 'Skip';
    }

    return '';
  }
}
