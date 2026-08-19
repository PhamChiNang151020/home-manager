import "package:flutter/material.dart";
import "package:home_manager/core/domain/meter_math.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/models/home.dart";

class ReminderBanner extends StatelessWidget {
  const ReminderBanner({super.key, required this.home});

  final Home home;

  @override
  Widget build(BuildContext context) {
    final messages = <String>[
      if (DayOfMonth.isToday(home.photoDueDay)) S.bannerPhoto,
      if (DayOfMonth.isToday(home.paydayDay)) S.bannerPayday,
      if (DayOfMonth.isToday(home.remindDay)) S.bannerRemind,
    ];
    if (messages.isEmpty) {
      return const SizedBox.shrink();
    }
    return Card(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final line in messages) Text(line),
          ],
        ),
      ),
    );
  }
}
