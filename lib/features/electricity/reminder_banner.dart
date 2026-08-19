import "package:flutter/material.dart";
import "package:home_manager/core/domain/meter_math.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/models/home.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:home_manager/features/shared/app_card.dart";

class ReminderBanner extends StatelessWidget {
  const ReminderBanner({super.key, required this.home});

  final Home home;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final messages = <String>[
      if (DayOfMonth.isToday(home.photoDueDay)) S.bannerPhoto,
      if (DayOfMonth.isToday(home.paydayDay)) S.bannerPayday,
      if (DayOfMonth.isToday(home.remindDay)) S.bannerRemind,
    ];
    if (messages.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.notifications_active_outlined, color: colors.warning),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final line in messages)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(line),
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
