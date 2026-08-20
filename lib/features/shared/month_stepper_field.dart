import "package:flutter/material.dart";
import "package:home_manager/core/domain/month_clamp.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:home_manager/features/shared/month_picker.dart";
import "package:intl/intl.dart";

class MonthStepperField extends StatelessWidget {
  const MonthStepperField({
    super.key,
    required this.month,
    required this.onChanged,
  });

  final DateTime month;
  final ValueChanged<DateTime> onChanged;

  Future<void> _pick(BuildContext context) async {
    final picked = await showMonthPicker(context: context, initialDate: month);
    if (picked != null) {
      onChanged(monthStart(picked));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final canNext = canGoNextMonth(month);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          S.month,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: colors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            IconButton(
              tooltip: S.previousMonth,
              onPressed: () {
                final previous = shiftMonth(month, -1);
                if (previous != null) onChanged(previous);
              },
              icon: const Icon(Icons.chevron_left),
            ),
            Expanded(
              child: InkWell(
                onTap: () => _pick(context),
                borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
                child: InputDecorator(
                  decoration: const InputDecoration(),
                  child: Text(
                    DateFormat("MM/yyyy").format(month),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            IconButton(
              tooltip: S.nextMonth,
              onPressed:
                  canNext
                      ? () {
                        final next = shiftMonth(month, 1);
                        if (next != null) onChanged(next);
                      }
                      : null,
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
      ],
    );
  }
}
