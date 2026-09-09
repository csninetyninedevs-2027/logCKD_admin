import 'dart:math' as math;
import 'dart:ui' show FontFeature;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/analytics_extras.dart';
import '../../../../shared/models/demographics.dart';
import '../../state/dashboard_provider.dart';

class DashboardAnalyticsSection extends ConsumerWidget {
  const DashboardAnalyticsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final demographicsAsync = ref.watch(demographicsProvider);
    final riskAsync = ref.watch(riskDistributionProvider);
    final summaryAsync = ref.watch(dashboardSummaryProvider);
    final months = ref.watch(signupTrendMonthsProvider);
    final signupAsync = ref.watch(signupTrendProvider(months));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Analytics',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Dense, readable views of growth, risk, demographics, CKD stages, and health factors.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const _LiveDataPill(),
          ],
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            const gap = 16.0;
            final columns = constraints.maxWidth >= 1040 ? 2 : 1;
            final width =
                (constraints.maxWidth - gap * (columns - 1)) / columns;

            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                SizedBox(
                  width: width,
                  child: _ChartCard(
                    title: 'Signup Trend',
                    tone: _ChartCardTone.tealAurora,
                    subtitle: 'Monthly registrations · showing exactly $months months',
                    accent: AppColors.primaryBright,
                    trailing: _RangeSelector(
                      months: months,
                      onChanged: (value) {
                        ref.read(signupTrendMonthsProvider.notifier).state = value;
                      },
                    ),
                    child: signupAsync.when(
                      loading: () => const _LoadingChart(),
                      error: (_, _) => _ErrorChart(
                        onRetry: () => ref.invalidate(signupTrendProvider(months)),
                      ),
                      data: (points) => _SignupChart(
                        points: _fillSignupMonths(points, months),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: width,
                  child: _ChartCard(
                    title: 'Risk Distribution',
                    tone: _ChartCardTone.coralAurora,
                    subtitle: 'Latest assessment category per assessed user',
                    accent: AppColors.coral,
                    child: riskAsync.when(
                      loading: () => const _LoadingChart(),
                      error: (_, _) => _ErrorChart(
                        onRetry: () => ref.invalidate(riskDistributionProvider),
                      ),
                      data: (rows) => _RiskChart(rows: rows),
                    ),
                  ),
                ),
                SizedBox(
                  width: width,
                  child: _ChartCard(
                    title: 'Age Distribution',
                    subtitle: 'Registered users grouped into backend age bands',
                    accent: AppColors.softBlue,
                    child: demographicsAsync.when(
                      loading: () => const _LoadingChart(),
                      error: (_, _) => _ErrorChart(
                        onRetry: () => ref.invalidate(demographicsProvider),
                      ),
                      data: (data) => _HorizontalCountChart(
                        counts: [
                          for (final row in data.ageBands)
                            LabeledCount(
                              label: _ageBandLabel(row.label),
                              count: row.count,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: width,
                  child: _ChartCard(
                    title: 'Sex Breakdown',
                    subtitle: 'User distribution by recorded sex',
                    accent: AppColors.primary,
                    child: demographicsAsync.when(
                      loading: () => const _LoadingChart(),
                      error: (_, _) => _ErrorChart(
                        onRetry: () => ref.invalidate(demographicsProvider),
                      ),
                      data: (data) => _HorizontalCountChart(
                        counts: [
                          for (final row in data.sexBreakdown)
                            LabeledCount(
                              label: _titleCase(row.label),
                              count: row.count,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: width,
                  child: _ChartCard(
                    title: 'CKD Stage Breakdown',
                    subtitle: 'Recorded CKD stage values',
                    accent: AppColors.warning,
                    child: demographicsAsync.when(
                      loading: () => const _LoadingChart(),
                      error: (_, _) => _ErrorChart(
                        onRetry: () => ref.invalidate(demographicsProvider),
                      ),
                      data: (data) => _HorizontalCountChart(
                        counts: [
                          for (final row in data.ckdStageBreakdown)
                            LabeledCount(
                              label: _stageLabel(row.label),
                              count: row.count,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: width,
                  child: _ChartCard(
                    title: 'Comorbidity Prevalence',
                    subtitle: 'Recorded health and family-history factors',
                    accent: AppColors.coral,
                    child: demographicsAsync.when(
                      loading: () => const _LoadingChart(),
                      error: (_, _) => _ErrorChart(
                        onRetry: () => ref.invalidate(demographicsProvider),
                      ),
                      data: (data) {
                        final c = data.comorbidities;
                        return _HorizontalCountChart(
                          counts: [
                            LabeledCount(label: 'Hypertension', count: c.hypertension),
                            LabeledCount(label: 'Diabetes', count: c.diabetes),
                            LabeledCount(label: 'Heart condition', count: c.heartCondition),
                            LabeledCount(label: 'Obesity history', count: c.obesityHistory),
                            LabeledCount(label: 'Family kidney disease', count: c.familyKidneyDisease),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(
                  width: width,
                  child: _ChartCard(
                    title: 'Health Status',
                    subtitle: 'Current user health-status values',
                    accent: AppColors.success,
                    child: summaryAsync.when(
                      loading: () => const _LoadingChart(),
                      error: (_, _) => _ErrorChart(
                        onRetry: () => ref.invalidate(dashboardSummaryProvider),
                      ),
                      data: (summary) => _HorizontalCountChart(
                        counts: [
                          for (final item in summary.healthStatusBreakdown)
                            LabeledCount(
                              label: _healthStatusLabel(item.healthStatus),
                              count: item.count,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _LiveDataPill extends StatelessWidget {
  const _LiveDataPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 7, color: AppColors.success),
          SizedBox(width: 7),
          Text(
            'LIVE DATA',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 8.5,
              fontWeight: FontWeight.w800,
              letterSpacing: .9,
            ),
          ),
        ],
      ),
    );
  }
}

class _RangeSelector extends StatelessWidget {
  const _RangeSelector({required this.months, required this.onChanged});

  final int months;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButton<int>(
        value: months,
        underline: const SizedBox.shrink(),
        borderRadius: BorderRadius.circular(10),
        dropdownColor: AppColors.surfaceRaised,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        items: const [
          DropdownMenuItem(value: 6, child: Text('6M')),
          DropdownMenuItem(value: 12, child: Text('12M')),
          DropdownMenuItem(value: 24, child: Text('24M')),
          DropdownMenuItem(value: 36, child: Text('36M')),
        ],
        onChanged: (value) {
          if (value != null) onChanged(value);
        },
      ),
    );
  }
}

enum _ChartCardTone {
  plain,
  tealAurora,
  coralAurora,
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.title,
    required this.subtitle,
    required this.child,
    required this.accent,
    this.trailing,
    this.tone = _ChartCardTone.plain,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final Color accent;
  final Widget? trailing;
  final _ChartCardTone tone;

  @override
  Widget build(BuildContext context) {
    final gradient = switch (tone) {
      _ChartCardTone.plain => null,
      _ChartCardTone.tealAurora => const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0C171B),
            Color(0xFF123039),
            Color(0xFF17263A),
            Color(0xFF251D25),
          ],
          stops: [0, .42, .72, 1],
        ),
      _ChartCardTone.coralAurora => const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF10181C),
            Color(0xFF10282C),
            Color(0xFF1B2635),
            Color(0xFF2A1E22),
          ],
          stops: [0, .39, .69, 1],
        ),
    };

    return Container(
      height: 332,
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: .94),
        gradient: gradient,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: tone == _ChartCardTone.plain
              ? AppColors.border
              : AppColors.borderStrong.withValues(alpha: .82),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .22),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(17),
        child: Stack(
          children: [
            if (tone != _ChartCardTone.plain) ...[
              Positioned(
                right: -72,
                top: -110,
                child: Container(
                  width: 290,
                  height: 290,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.softBlue.withValues(
                          alpha: tone == _ChartCardTone.tealAurora
                              ? .18
                              : .11,
                        ),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: -68,
                bottom: -150,
                child: Container(
                  width: 320,
                  height: 320,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primaryBright.withValues(alpha: .16),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                right: -16,
                bottom: -118,
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.coral.withValues(
                          alpha: tone == _ChartCardTone.coralAurora
                              ? .18
                              : .12,
                        ),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ],
            Positioned.fill(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 16, 16, 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 3,
                          height: 34,
                          decoration: BoxDecoration(
                            color: accent,
                            borderRadius: BorderRadius.circular(99),
                            boxShadow: tone == _ChartCardTone.plain
                                ? null
                                : [
                                    BoxShadow(
                                      color: accent.withValues(alpha: .32),
                                      blurRadius: 10,
                                    ),
                                  ],
                          ),
                        ),
                        const SizedBox(width: 11),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -.2,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                subtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: tone == _ChartCardTone.plain
                                      ? AppColors.textMuted
                                      : AppColors.textSecondary
                                          .withValues(alpha: .82),
                                  fontSize: 10.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (trailing != null) ...[
                          const SizedBox(width: 10),
                          trailing!,
                        ],
                      ],
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: AppColors.border.withValues(
                      alpha: tone == _ChartCardTone.plain ? 1 : .56,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
                      child: child,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _SignupChart extends StatelessWidget {
  const _SignupChart({required this.points});

  final List<SignupTrendPoint> points;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return const _EmptyChart();

    final maxCount = points.fold<int>(0, (maxValue, point) {
      return math.max(maxValue, point.count);
    });
    final interval = _niceInterval(maxCount);
    final maxY = math.max(interval * 4, _ceilToStep(maxCount, interval)).toDouble();
    final spots = [
      for (var i = 0; i < points.length; i++)
        FlSpot(i.toDouble(), points[i].count.toDouble()),
    ];
    final labelStep = points.length <= 8
        ? 1
        : points.length <= 16
            ? 2
            : points.length <= 26
                ? 3
                : 4;

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: math.max(1, points.length - 1).toDouble(),
        minY: 0,
        maxY: maxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: interval.toDouble(),
          getDrawingHorizontalLine: (_) => FlLine(
            color: AppColors.border.withValues(alpha: .62),
            strokeWidth: .8,
            dashArray: [3, 4],
          ),
          getDrawingVerticalLine: (_) => FlLine(
            color: AppColors.border.withValues(alpha: .34),
            strokeWidth: .7,
            dashArray: [2, 5],
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 34,
              interval: interval.toDouble(),
              getTitlesWidget: (value, meta) {
                if (value < 0 || value > maxY + .001) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    value.round().toString(),
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 9,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                final index = value.round();
                if (index < 0 || index >= points.length) {
                  return const SizedBox.shrink();
                }
                if (index % labelStep != 0 && index != points.length - 1) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _shortMonth(points[index].month),
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 8.5,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final index = spot.x.round();
                if (index < 0 || index >= points.length) return null;
                final point = points[index];
                return LineTooltipItem(
                  '${_readableMonth(point.month)}\n${point.count} signup${point.count == 1 ? '' : 's'}',
                  const TextStyle(
                    color: Colors.white,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                );
              }).toList();
            },
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.primaryBright,
            barWidth: 2.4,
            dotData: FlDotData(show: points.length <= 14),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary.withValues(alpha: .23),
                  AppColors.primary.withValues(alpha: .015),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RiskChart extends StatelessWidget {
  const _RiskChart({required this.rows});

  final List<RiskCategoryCount> rows;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return const _EmptyChart();

    final total = rows.fold<int>(0, (sum, row) => sum + row.count);

    return Row(
      children: [
        Expanded(
          flex: 5,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sectionsSpace: 3,
                  centerSpaceRadius: 48,
                  sections: [
                    for (final row in rows)
                      PieChartSectionData(
                        value: row.count.toDouble(),
                        color: AppTheme.riskColor(row.riskCategory),
                        title: '',
                        radius: 56,
                      ),
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$total',
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -.7,
                    ),
                  ),
                  const Text(
                    'ASSESSED',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      letterSpacing: .8,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 6,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final row in rows)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppTheme.riskColor(row.riskCategory),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          _titleCase(row.riskCategory),
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        '${row.count}',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(width: 7),
                      SizedBox(
                        width: 42,
                        child: Text(
                          '${_percentage(row.count, total)}%',
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 9.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HorizontalCountChart extends StatelessWidget {
  const _HorizontalCountChart({required this.counts});

  final List<LabeledCount> counts;

  @override
  Widget build(BuildContext context) {
    final visible = counts.where((item) => item.count >= 0).toList();
    if (visible.isEmpty) return const _EmptyChart();

    final maxCount = visible.fold<int>(1, (maxValue, item) {
      return math.max(maxValue, item.count);
    });
    final total = visible.fold<int>(0, (sum, item) => sum + item.count);

    return LayoutBuilder(
      builder: (context, constraints) {
        final rowHeight = math.min(42.0, constraints.maxHeight / visible.length);
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (final item in visible)
              SizedBox(
                height: rowHeight,
                child: _HorizontalBarRow(
                  item: item,
                  maxCount: maxCount,
                  total: total,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _HorizontalBarRow extends StatelessWidget {
  const _HorizontalBarRow({
    required this.item,
    required this.maxCount,
    required this.total,
  });

  final LabeledCount item;
  final int maxCount;
  final int total;

  @override
  Widget build(BuildContext context) {
    final ratio = maxCount <= 0 ? 0.0 : item.count / maxCount;
    final share = total <= 0 ? 0.0 : item.count / total * 100;

    return Tooltip(
      message: '${item.label}: ${item.count} (${share.toStringAsFixed(1)}%)',
      child: Row(
        children: [
          SizedBox(
            width: 118,
            child: Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSoft,
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(
                      color: AppColors.border.withValues(alpha: .75),
                    ),
                  ),
                ),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: ratio.clamp(0, 1).toDouble()),
                  duration: const Duration(milliseconds: 520),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) {
                    return FractionallySizedBox(
                      widthFactor: value,
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(99),
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.primaryDark,
                              AppColors.primaryBright,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: .18),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 30,
            child: Text(
              '${item.count}',
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingChart extends StatelessWidget {
  const _LoadingChart();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 28,
        height: 28,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}

class _ErrorChart extends StatelessWidget {
  const _ErrorChart({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.danger),
          const SizedBox(height: 6),
          const Text(
            'Unable to load this view.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
          ),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _EmptyChart extends StatelessWidget {
  const _EmptyChart();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.query_stats_rounded, size: 31, color: AppColors.textMuted),
          SizedBox(height: 8),
          Text(
            'No data yet',
            style: TextStyle(color: AppColors.textMuted, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

List<SignupTrendPoint> _fillSignupMonths(
  List<SignupTrendPoint> raw,
  int months,
) {
  final byMonth = {for (final point in raw) point.month: point.count};
  final now = DateTime.now();
  final start = DateTime(now.year, now.month - (months - 1));

  return List.generate(months, (index) {
    final date = DateTime(start.year, start.month + index);
    final key = '${date.year}-${date.month.toString().padLeft(2, '0')}';
    return SignupTrendPoint(month: key, count: byMonth[key] ?? 0);
  });
}

int _niceInterval(int maxValue) {
  if (maxValue <= 4) return 1;
  if (maxValue <= 12) return 3;
  if (maxValue <= 24) return 6;
  if (maxValue <= 40) return 10;
  if (maxValue <= 80) return 20;
  if (maxValue <= 200) return 50;

  final rough = maxValue / 4;
  final magnitude = math.pow(10, rough.toStringAsFixed(0).length - 1).toInt();
  return ((rough / magnitude).ceil() * magnitude).clamp(1, 1000000).toInt();
}

int _ceilToStep(int value, int step) {
  if (value <= 0) return step * 4;
  return ((value + step - 1) ~/ step) * step;
}

String _ageBandLabel(String raw) {
  switch (raw.trim().toLowerCase()) {
    case '0':
      return 'Under 18';
    case '18':
      return '18–29';
    case '30':
      return '30–44';
    case '45':
      return '45–59';
    case '60':
      return '60–74';
    case '75':
      return '75+';
    case 'unknown':
      return 'Unknown';
    default:
      return raw;
  }
}

String _stageLabel(String raw) {
  final cleaned = raw.trim().toLowerCase().replaceAll('_', ' ');
  if (RegExp(r'^\d+$').hasMatch(cleaned)) return 'Stage $cleaned';
  if (cleaned.startsWith('stage ')) return _titleCase(cleaned);
  return _titleCase(raw);
}

String _healthStatusLabel(String raw) {
  final normalized = raw.trim().toLowerCase().replaceAll('_', ' ');
  switch (normalized) {
    case 'no ckd':
      return 'No CKD';
    case 'with ckd':
    case 'ckd':
      return 'CKD';
    case 'at risk':
      return 'At risk';
    default:
      return _titleCase(normalized);
  }
}

String _titleCase(String value) {
  final cleaned = value.replaceAll('_', ' ').trim();
  if (cleaned.isEmpty) return 'Unknown';

  return cleaned
      .split(RegExp(r'\s+'))
      .map((part) => part.isEmpty
          ? part
          : '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}')
      .join(' ');
}

String _shortMonth(String value) {
  final parts = value.split('-');
  if (parts.length != 2) return value;
  final month = int.tryParse(parts[1]);
  if (month == null || month < 1 || month > 12) return value;

  const names = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return names[month - 1];
}

String _readableMonth(String value) {
  final parts = value.split('-');
  if (parts.length != 2) return value;
  return '${_shortMonth(value)} ${parts[0]}';
}

String _percentage(int value, int total) {
  if (total <= 0) return '0.0';
  return (value / total * 100).toStringAsFixed(1);
}
