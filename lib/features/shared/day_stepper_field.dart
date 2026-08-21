import "package:flutter/material.dart";
import "package:home_manager/core/domain/month_clamp.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:home_manager/features/shared/datetime_picker.dart";
import "package:intl/intl.dart";

class DayStepperField extends StatelessWidget {
  const DayStepperField({
    super.key,
    required this.day,
    required this.onChanged,
  });

  final DateTime day;
  final ValueChanged<DateTime> onChanged;

  Future<void> _pick(BuildContext context) async {
    final picked = await showAppDatePicker(
      context: context,
      initialDate: day,
      helpText: S.selectDay,
    );
    if (picked != null) {
      onChanged(today(picked));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final canNext = canGoNextDay(day);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          S.day,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: colors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            IconButton(
              tooltip: S.previousDay,
              onPressed: () {
                final previous = shiftDay(day, -1);
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
                    DateFormat("dd/MM/yyyy").format(day),
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
              tooltip: S.nextDay,
              onPressed:
                  canNext
                      ? () {
                        final next = shiftDay(day, 1);
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
