import "package:fl_chart/fl_chart.dart";
import "package:flutter/material.dart";
import "package:home_manager/core/format/vnd_format.dart";
import "package:intl/intl.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/models/electricity_period.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:home_manager/features/shared/app_card.dart";
class ElectricityTrendChart extends StatelessWidget {
  const ElectricityTrendChart({super.key, required this.periods});

  final List<ElectricityPeriod> periods;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final recent = periods.take(6).toList().reversed.toList();
    if (recent.length < 2) {
      return const SizedBox.shrink();
    }

    final maxAmount = recent
        .map((p) => p.amountVnd)
        .reduce((a, b) => a > b ? a : b);
    final chartMax = maxAmount * 1.2;
    // index of the most recent bar (last in the reversed list)
    final latestIndex = recent.length - 1;
    // Y axis ticks: 0, midpoint, max
    final midY = (chartMax / 2).roundToDouble();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.trendSixMonths,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 160,
            child: BarChart(
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
                      reservedSize: 44,
                      getTitlesWidget: (value, meta) {
                        if (value != 0 && value != midY && value != chartMax) {
                          return const SizedBox.shrink();
                        }
                        return Text(
                          value == 0 ? "0" : VndFormat.compact(value),
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
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= recent.length) {
                          return const SizedBox.shrink();
                        }
                        final isLatest = index == latestIndex;
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            DateFormat("MM").format(recent[index].periodMonth),
                            style: TextStyle(
                              color:
                                  isLatest ? colors.accent : colors.textMuted,
                              fontSize: 11,
                              fontWeight:
                                  isLatest
                                      ? FontWeight.w700
                                      : FontWeight.normal,
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
                      barRods: [
                        BarChartRodData(
                          toY: recent[i].amountVnd,
                          color:
                              i == latestIndex
                                  ? colors.accent
                                  : colors.accent.withValues(alpha: 0.45),
                          width: 20,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
