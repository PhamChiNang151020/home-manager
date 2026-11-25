import "package:flutter/material.dart";
import "package:home_manager/core/domain/month_clamp.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:intl/intl.dart";

/// 48-tall month stepper. Next is disabled at a single 38% opacity past current
/// month (do not wrap a disabled IconButton in Opacity — that compounds to ~14%).
class MonthStepper extends StatelessWidget {
  const MonthStepper({
    super.key,
    required this.month,
    required this.onChanged,
  });

  final DateTime month;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final canNext = canGoNextMonth(month);
    final disabledFg = colors.textPrimary.withValues(alpha: 0.38);
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: IconButton(
              tooltip: S.previousMonth,
              onPressed: () {
                final previous = shiftMonth(month, -1);
                if (previous != null) onChanged(previous);
              },
              icon: const Icon(Icons.chevron_left),
            ),
          ),
          Expanded(
            child: Text(
              S.monthTitle(DateFormat("MM/yyyy").format(month)),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                height: 24 / 16,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
                fontFamily: "Nunito",
              ),
            ),
          ),
          SizedBox(
            width: 48,
            height: 48,
            child: IconButton(
              tooltip: S.nextMonth,
              onPressed:
                  canNext
                      ? () {
                        final next = shiftMonth(month, 1);
                        if (next != null) onChanged(next);
                      }
                      : null,
              style: IconButton.styleFrom(disabledForegroundColor: disabledFg),
              icon: const Icon(Icons.chevron_right),
            ),
          ),
        ],
      ),
    );
  }
}
