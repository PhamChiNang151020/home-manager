import "package:fl_chart/fl_chart.dart";
import "package:flutter/material.dart";
import "package:home_manager/core/format/vnd_format.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/services/overview_service.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/app_motion.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:home_manager/features/shared/app_card.dart";
import "package:intl/intl.dart";

/// Dual-bar income vs spend for the last 6 months (fl_chart, electricity style).
class OverviewIncomeSpendChart extends StatefulWidget {
  const OverviewIncomeSpendChart({super.key, required this.points});

  final List<IncomeSpendPoint> points;

  @override
  State<OverviewIncomeSpendChart> createState() =>
      _OverviewIncomeSpendChartState();
}

class _OverviewIncomeSpendChartState extends State<OverviewIncomeSpendChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: AppMotion.normal)
      ..forward();
  }

  @override
  void didUpdateWidget(covariant OverviewIncomeSpendChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.points != widget.points) {
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final recent = widget.points;
    if (recent.length < 2) {
      return const SizedBox.shrink();
    }

    var maxAmount = 0.0;
    for (final p in recent) {
      if (p.income > maxAmount) maxAmount = p.income;
      if (p.spend > maxAmount) maxAmount = p.spend;
    }
    if (maxAmount <= 0) {
      return const SizedBox.shrink();
    }
    final chartMax = maxAmount * 1.2;
    final midY = (chartMax / 2).roundToDouble();

    return AppCard(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            S.incomeSpendTrend,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              _LegendDot(color: colors.success, label: S.monthIncome),
              const SizedBox(width: AppSpacing.md),
              _LegendDot(color: colors.error, label: S.monthSpend),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 160,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final t = Curves.easeOutCubic.transform(_controller.value);
                return BarChart(
                  duration: AppMotion.normal,
                  BarChartData(
                    minY: 0,
                    maxY: chartMax,
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      checkToShowHorizontalLine:
                          (value) =>
                              value == 0 || value == midY || value == chartMax,
                      getDrawingHorizontalLine:
                          (_) => FlLine(color: colors.border, strokeWidth: 1),
                    ),
                    borderData: FlBorderData(show: false),
                    barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (_) => colors.bgElevated,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          return BarTooltipItem(
                            VndFormat.format(rod.toY),
                            TextStyle(
                              color: colors.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          );
                        },
                      ),
                    ),
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
                          reservedSize: 36,
                          interval: chartMax / 2,
                          getTitlesWidget: (value, _) {
                            if (value != 0 &&
                                value != midY &&
                                (value - chartMax).abs() > 1) {
                              return const SizedBox.shrink();
                            }
                            return Text(
                              VndFormat.compact(value),
                              style: TextStyle(
                                color: colors.textMuted,
                                fontSize: 10,
                              ),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, _) {
                            final i = value.toInt();
                            if (i < 0 || i >= recent.length) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                DateFormat("MM").format(recent[i].month),
                                style: TextStyle(
                                  color: colors.textMuted,
                                  fontSize: 10,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    barGroups: [
                      for (var i = 0; i < recent.length; i++)
                        BarChartGroupData(
                          x: i,
                          barsSpace: 2,
                          barRods: [
                            BarChartRodData(
                              toY: recent[i].income * t,
                              width: 8,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                              color: colors.success,
                            ),
                            BarChartRodData(
                              toY: recent[i].spend * t,
                              width: 8,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                              color: colors.error,
                            ),
                          ],
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: context.appColors.textMuted,
          ),
        ),
      ],
    );
  }
}
