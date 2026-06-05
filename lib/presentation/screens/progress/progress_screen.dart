import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:level_bot/core/theme/app_colors.dart';
import 'package:level_bot/core/theme/app_text_styles.dart';
import 'package:level_bot/core/utils/formatters.dart';
import 'package:level_bot/domain/entities/personal_record_entity.dart';
import 'package:level_bot/domain/entities/workout_session_entity.dart';
import 'package:level_bot/presentation/providers/auth_provider.dart';
import 'package:level_bot/presentation/providers/workout_provider.dart';
import 'package:level_bot/presentation/widgets/common/app_loading.dart';
import 'package:level_bot/presentation/widgets/common/app_error.dart';

class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.progress),
        centerTitle: false,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.overviewTab),
            Tab(text: l10n.recordsTab),
            Tab(text: l10n.bodyTab),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _OverviewTab(),
          _RecordsTab(),
          _BodyTab(),
        ],
      ),
    );
  }
}

// ─── Overview Tab ─────────────────────────────────────────────────────────────

class _OverviewTab extends ConsumerStatefulWidget {
  const _OverviewTab();

  @override
  ConsumerState<_OverviewTab> createState() => _OverviewTabState();
}

class _OverviewTabState extends ConsumerState<_OverviewTab> {
  int _selectedDays = 30;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final userId = ref.watch(currentUserProvider)?.id ?? '';
    final historyAsync = ref.watch(workoutHistoryProvider(userId));

    return historyAsync.when(
      loading: () => const Center(child: AppLoading()),
      error: (e, _) => Center(child: AppError(message: e.toString())),
      data: (allSessions) {
          final cutoff = DateTime.now().subtract(Duration(days: _selectedDays));
          final sessions = allSessions
              .where((s) => s.startedAt.isAfter(cutoff))
              .toList()
            ..sort((a, b) => a.startedAt.compareTo(b.startedAt));

          final totalWorkouts = sessions.length;
          final totalVolume = sessions.fold<double>(
            0,
            (sum, s) => sum + s.totalVolume,
          );
          final totalDurationSecs = sessions.fold<int>(
            0,
            (sum, s) => sum + s.durationSeconds,
          );
          final avgDurationSecs = totalWorkouts > 0
              ? (totalDurationSecs / totalWorkouts).round()
              : 0;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 7, label: Text('7D')),
                  ButtonSegment(value: 30, label: Text('30D')),
                  ButtonSegment(value: 90, label: Text('3M')),
                  ButtonSegment(value: 365, label: Text('1Y')),
                ],
                selected: {_selectedDays},
                onSelectionChanged: (val) =>
                    setState(() => _selectedDays = val.first),
              ),
              const SizedBox(height: 20),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.6,
                children: [
                  _StatCard(
                    label: l10n.workouts,
                    value: totalWorkouts.toString(),
                    icon: Icons.fitness_center_rounded,
                    color: AppColors.primary,
                  ),
                  _StatCard(
                    label: l10n.totalVolume,
                    value: Formatters.formatVolume(totalVolume),
                    icon: Icons.bar_chart_rounded,
                    color: AppColors.secondary,
                  ),
                  _StatCard(
                    label: l10n.totalDurationLabel,
                    value: Formatters.formatDuration(Duration(seconds: totalDurationSecs)),
                    icon: Icons.timer_outlined,
                    color: AppColors.accent,
                  ),
                  _StatCard(
                    label: l10n.avgDurationLabel,
                    value: Formatters.formatDuration(Duration(seconds: avgDurationSecs)),
                    icon: Icons.av_timer_rounded,
                    color: AppColors.back,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (sessions.isNotEmpty) ...[
                Text(l10n.volumeOverTime, style: AppTextStyles.titleMedium),
                const SizedBox(height: 12),
                SizedBox(
                  height: 200,
                  child: _VolumeLineChart(sessions: sessions),
                ),
                const SizedBox(height: 24),
                Text(l10n.workoutsPerDay, style: AppTextStyles.titleMedium),
                const SizedBox(height: 12),
                SizedBox(
                  height: 180,
                  child: _WorkoutsBarChart(sessions: sessions),
                ),
              ] else
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.show_chart_rounded,
                          size: 64,
                          color: AppColors.textTertiaryDark,
                        ),
                        const SizedBox(height: 16),
                        Text(l10n.noWorkoutsInPeriod, style: AppTextStyles.titleMedium),
                        const SizedBox(height: 8),
                        Text(
                          l10n.completeWorkoutsForStats,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondaryDark,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
    );
  }
}

class _VolumeLineChart extends StatelessWidget {
  const _VolumeLineChart({required this.sessions});

  final List<WorkoutSessionEntity> sessions;

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) return const SizedBox.shrink();

    final spots = <FlSpot>[];
    for (int i = 0; i < sessions.length; i++) {
      spots.add(FlSpot(i.toDouble(), sessions[i].totalVolume));
    }

    final maxY = sessions
        .map((s) => s.totalVolume)
        .reduce((a, b) => a > b ? a : b);

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (sessions.length - 1).toDouble(),
        minY: 0,
        maxY: maxY * 1.2,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppColors.darkDivider,
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 48,
              getTitlesWidget: (value, meta) => Text(
                Formatters.formatVolume(value),
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textTertiaryDark,
                  fontSize: 10,
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              interval: (sessions.length / 5).ceilToDouble().clamp(1, double.infinity),
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= sessions.length) return const SizedBox.shrink();
                final date = sessions[idx].startedAt;
                return Text(
                  '${date.month}/${date.day}',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textTertiaryDark,
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.primary,
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: spots.length <= 20,
              getDotPainter: (spot, percent, bar, index) =>
                  FlDotCirclePainter(
                radius: 3,
                color: AppColors.primary,
                strokeWidth: 0,
                strokeColor: Colors.transparent,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary.withAlpha(80),
                  AppColors.primary.withAlpha(0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkoutsBarChart extends StatelessWidget {
  const _WorkoutsBarChart({required this.sessions});

  final List<WorkoutSessionEntity> sessions;

  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    final countsByDay = List.filled(7, 0);
    for (final session in sessions) {
      final weekday = session.startedAt.weekday - 1; // 0=Mon, 6=Sun
      countsByDay[weekday]++;
    }

    final maxY = countsByDay.reduce((a, b) => a > b ? a : b).toDouble();

    return BarChart(
      BarChartData(
        maxY: (maxY + 1).clamp(1, double.infinity),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppColors.darkDivider,
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= 7) return const SizedBox.shrink();
                return Text(
                  _weekdays[idx],
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textTertiaryDark,
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: 1,
              getTitlesWidget: (value, meta) {
                if (value == value.floorToDouble() && value >= 0) {
                  return Text(
                    value.toInt().toString(),
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textTertiaryDark,
                      fontSize: 10,
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        barGroups: List.generate(
          7,
          (index) => BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: countsByDay[index].toDouble(),
                color: countsByDay[index] > 0
                    ? AppColors.secondary
                    : AppColors.darkCard,
                width: 24,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 22),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: AppTextStyles.headlineSmall.copyWith(color: Colors.white),
              ),
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondaryDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Records Tab ──────────────────────────────────────────────────────────────

class _RecordsTab extends ConsumerStatefulWidget {
  const _RecordsTab();

  @override
  ConsumerState<_RecordsTab> createState() => _RecordsTabState();
}

class _RecordsTabState extends ConsumerState<_RecordsTab> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final userId = ref.watch(currentUserProvider)?.id ?? '';
    final recordsAsync = ref.watch(personalRecordsProvider(userId));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: l10n.searchExercisesHint,
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                    )
                  : null,
              isDense: true,
            ),
          ),
        ),
        Expanded(
          child: recordsAsync.when(
            loading: () => const Center(child: AppLoading()),
            error: (e, _) => Center(child: AppError(message: e.toString())),
            data: (records) {
                final filtered = _query.isEmpty
                    ? records
                    : records
                        .where((r) =>
                            r.exerciseName.toLowerCase().contains(_query))
                        .toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.emoji_events_outlined,
                          size: 64,
                          color: AppColors.textTertiaryDark,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _query.isEmpty
                              ? l10n.noRecordsYet
                              : l10n.noRecordsFound,
                          style: AppTextStyles.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _query.isEmpty
                              ? l10n.completeWorkoutsForPRs
                              : l10n.tryDifferentSearch,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondaryDark,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                // Sort by most recent
                final sorted = List.of(filtered)
                  ..sort((a, b) => b.achievedAt.compareTo(a.achievedAt));

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: sorted.length,
                  itemBuilder: (context, index) =>
                      _RecordCard(record: sorted[index]),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _RecordCard extends StatelessWidget {
  const _RecordCard({required this.record});

  final PersonalRecordEntity record;

  Color get _prColor {
    switch (record.type) {
      case PRType.maxWeight:
        return AppColors.primary;
      case PRType.maxReps:
        return AppColors.secondary;
      case PRType.maxVolume:
        return AppColors.back;
      case PRType.maxDuration:
        return AppColors.accent;
      case PRType.maxDistance:
        return AppColors.quads;
    }
  }

  String _prLabel(AppLocalizations l10n) {
    switch (record.type) {
      case PRType.maxWeight:
        return l10n.maxWeight;
      case PRType.maxReps:
        return l10n.maxReps;
      case PRType.maxVolume:
        return l10n.maxVolume;
      case PRType.maxDuration:
        return l10n.durationLabel;
      case PRType.maxDistance:
        return l10n.distance;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _prColor.withAlpha(40)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _prColor.withAlpha(30),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.emoji_events_rounded, color: _prColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.exerciseName,
                  style: AppTextStyles.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${record.weight?.toStringAsFixed(1) ?? '0'} kg × ${record.reps} reps',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondaryDark,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _prColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _prLabel(l10n),
                  style: AppTextStyles.labelSmall.copyWith(color: _prColor),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatDate(l10n, record.achievedAt),
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textTertiaryDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(AppLocalizations l10n, DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date).inDays;
    if (diff == 0) return l10n.today;
    if (diff == 1) return l10n.yesterday;
    if (diff < 30) return '${diff}d ago';
    return '${date.month}/${date.day}/${date.year}';
  }
}

// ─── Body Tab ─────────────────────────────────────────────────────────────────

class _BodyEntry {
  const _BodyEntry({
    required this.date,
    required this.weightKg,
    this.bodyFatPct,
    this.waistCm,
  });

  final DateTime date;
  final double weightKg;
  final double? bodyFatPct;
  final double? waistCm;
}

class _BodyTab extends ConsumerStatefulWidget {
  const _BodyTab();

  @override
  ConsumerState<_BodyTab> createState() => _BodyTabState();
}

class _BodyTabState extends ConsumerState<_BodyTab> {
  final List<_BodyEntry> _entries = [];
  final _weightController = TextEditingController();
  final _bodyFatController = TextEditingController();
  final _waistController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _weightController.dispose();
    _bodyFatController.dispose();
    _waistController.dispose();
    super.dispose();
  }

  void _showAddBodyStatSheet() {
    _weightController.clear();
    _bodyFatController.clear();
    _waistController.clear();
    _selectedDate = DateTime.now();
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            16,
            20,
            MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.darkDivider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(l10n.logBodyStats, style: AppTextStyles.titleLarge),
              const SizedBox(height: 16),
              TextButton.icon(
                icon: const Icon(Icons.calendar_today_outlined),
                label: Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                ),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setModalState(() => _selectedDate = picked);
                  }
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _weightController,
                decoration: InputDecoration(
                  labelText: l10n.weightKgRequired,
                  prefixIcon: const Icon(Icons.monitor_weight_outlined),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _bodyFatController,
                decoration: InputDecoration(
                  labelText: l10n.bodyFatOptional,
                  prefixIcon: const Icon(Icons.percent_rounded),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _waistController,
                decoration: InputDecoration(
                  labelText: l10n.waistCmOptional,
                  prefixIcon: const Icon(Icons.straighten_rounded),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final weight = double.tryParse(_weightController.text);
                    if (weight == null) return;
                    Navigator.pop(ctx);
                    setState(() {
                      _entries.add(_BodyEntry(
                        date: _selectedDate,
                        weightKg: weight,
                        bodyFatPct: double.tryParse(_bodyFatController.text),
                        waistCm: double.tryParse(_waistController.text),
                      ));
                      _entries.sort((a, b) => a.date.compareTo(b.date));
                    });
                  },
                  child: Text(l10n.save),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          children: [
            if (_entries.isNotEmpty) ...[
              Text(l10n.weightHistory, style: AppTextStyles.titleMedium),
              const SizedBox(height: 12),
              SizedBox(
                height: 200,
                child: _WeightLineChart(entries: _entries),
              ),
              const SizedBox(height: 20),
              _BmiCard(entries: _entries),
              const SizedBox(height: 20),
              Text(l10n.history, style: AppTextStyles.titleMedium),
              const SizedBox(height: 12),
              ...List.generate(
                _entries.length,
                (i) => _BodyEntryCard(
                  entry: _entries[_entries.length - 1 - i],
                  onDelete: () => setState(
                    () => _entries.removeAt(_entries.length - 1 - i),
                  ),
                ),
              ),
            ] else
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 80),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.monitor_weight_outlined,
                        size: 64,
                        color: AppColors.textTertiaryDark,
                      ),
                      const SizedBox(height: 16),
                      Text(l10n.noBodyStats, style: AppTextStyles.titleMedium),
                      const SizedBox(height: 8),
                      Text(
                        l10n.tapToLogBodyStats,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        Positioned(
          right: 20,
          bottom: 20,
          child: FloatingActionButton(
            onPressed: _showAddBodyStatSheet,
            child: const Icon(Icons.add_rounded),
          ),
        ),
      ],
    );
  }
}

class _WeightLineChart extends StatelessWidget {
  const _WeightLineChart({required this.entries});

  final List<_BodyEntry> entries;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox.shrink();

    final spots = List.generate(
      entries.length,
      (i) => FlSpot(i.toDouble(), entries[i].weightKg),
    );

    final minY = entries.map((e) => e.weightKg).reduce((a, b) => a < b ? a : b);
    final maxY = entries.map((e) => e.weightKg).reduce((a, b) => a > b ? a : b);
    final padding = (maxY - minY) * 0.2 + 1;

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (entries.length - 1).toDouble(),
        minY: minY - padding,
        maxY: maxY + padding,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(
            color: AppColors.darkDivider,
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 44,
              getTitlesWidget: (value, meta) => Text(
                '${value.toStringAsFixed(1)} kg',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textTertiaryDark,
                  fontSize: 10,
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              interval: (entries.length / 5).ceilToDouble().clamp(1, double.infinity),
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= entries.length) return const SizedBox.shrink();
                final date = entries[idx].date;
                return Text(
                  '${date.month}/${date.day}',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textTertiaryDark,
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.secondary,
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                radius: 4,
                color: AppColors.secondary,
                strokeWidth: 2,
                strokeColor: Colors.white,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.secondary.withAlpha(80),
                  AppColors.secondary.withAlpha(0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BmiCard extends StatelessWidget {
  const _BmiCard({required this.entries});

  final List<_BodyEntry> entries;

  @override
  Widget build(BuildContext context) {
    final latestWeight = entries.last.weightKg;
    // BMI requires height — show a placeholder if not available
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLocalizations.of(context)!.currentWeight, style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondaryDark,
                )),
                const SizedBox(height: 4),
                Text(
                  '${latestWeight.toStringAsFixed(1)} kg',
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          if (entries.length >= 2) ...[
            const SizedBox(width: 16),
            _WeightDelta(
              current: entries.last.weightKg,
              previous: entries.first.weightKg,
            ),
          ],
        ],
      ),
    );
  }
}

class _WeightDelta extends StatelessWidget {
  const _WeightDelta({required this.current, required this.previous});

  final double current;
  final double previous;

  @override
  Widget build(BuildContext context) {
    final delta = current - previous;
    final isPositive = delta >= 0;
    final color = isPositive ? AppColors.error : AppColors.success;

    return Column(
      children: [
        Icon(
          isPositive
              ? Icons.trending_up_rounded
              : Icons.trending_down_rounded,
          color: color,
        ),
        Text(
          '${isPositive ? '+' : ''}${delta.toStringAsFixed(1)} kg',
          style: AppTextStyles.labelMedium.copyWith(color: color),
        ),
        Text(
          AppLocalizations.of(context)!.totalLabel,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textTertiaryDark,
          ),
        ),
      ],
    );
  }
}

class _BodyEntryCard extends StatelessWidget {
  const _BodyEntryCard({required this.entry, required this.onDelete});

  final _BodyEntry entry;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Text(
                  '${entry.date.day}/${entry.date.month}/${entry.date.year}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondaryDark,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '${entry.weightKg.toStringAsFixed(1)} kg',
                  style: AppTextStyles.titleSmall,
                ),
                if (entry.bodyFatPct != null) ...[
                  const SizedBox(width: 12),
                  Text(
                    '${entry.bodyFatPct!.toStringAsFixed(1)}% BF',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                ],
                if (entry.waistCm != null) ...[
                  const SizedBox(width: 12),
                  Text(
                    '${entry.waistCm!.toStringAsFixed(0)} cm',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
            onPressed: onDelete,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}
