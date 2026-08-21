import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:home_manager/core/domain/month_clamp.dart";
import "package:home_manager/core/l10n/app_locale.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/app_spacing.dart";

Future<DateTime?> showCupertinoDateSheet({
  required BuildContext context,
  required DateTime initialDateTime,
  required CupertinoDatePickerMode mode,
  DateTime? minimumDate,
  DateTime? maximumDate,
  String? title,
}) {
  final colors = context.appColors;
  return showModalBottomSheet<DateTime>(
    context: context,
    backgroundColor: colors.bgSurface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppSpacing.cardRadius),
      ),
    ),
    builder: (context) {
      return _CupertinoDateSheetBody(
        initialDateTime: initialDateTime,
        mode: mode,
        minimumDate: minimumDate,
        maximumDate: maximumDate,
        title: title,
      );
    },
  );
}

class _CupertinoDateSheetBody extends StatefulWidget {
  const _CupertinoDateSheetBody({
    required this.initialDateTime,
    required this.mode,
    this.minimumDate,
    this.maximumDate,
    this.title,
  });

  final DateTime initialDateTime;
  final CupertinoDatePickerMode mode;
  final DateTime? minimumDate;
  final DateTime? maximumDate;
  final String? title;

  @override
  State<_CupertinoDateSheetBody> createState() =>
      _CupertinoDateSheetBodyState();
}

class _CupertinoDateSheetBodyState extends State<_CupertinoDateSheetBody> {
  late DateTime _selected;

  @override
  void initState() {
    super.initState();
    _selected = _clampInitial(widget.initialDateTime);
  }

  DateTime _clampInitial(DateTime value) {
    final first = widget.minimumDate;
    final last = widget.maximumDate;
    if (first != null && last != null) {
      return clampDate(value, first: first, last: last);
    }
    if (first != null && value.isBefore(first)) return first;
    if (last != null && value.isAfter(last)) return last;
    return value;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      top: false,
      child: SizedBox(
        width: MediaQuery.sizeOf(context).width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.sm,
                AppSpacing.sm,
                AppSpacing.sm,
                0,
              ),
              child: Row(
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      minimumSize: const Size(0, AppSpacing.touchMin),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(S.cancel),
                  ),
                  Expanded(
                    child: Text(
                      widget.title ?? "",
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      minimumSize: const Size(0, AppSpacing.touchMin),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () => Navigator.pop(context, _selected),
                    child: const Text(S.done),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 216,
              child: Localizations.override(
                context: context,
                locale: AppLocale.locale,
                child: CupertinoTheme(
                  data: CupertinoThemeData(
                    brightness: Theme.of(context).brightness,
                    primaryColor: colors.accent,
                    textTheme: CupertinoTextThemeData(
                      dateTimePickerTextStyle: textTheme.bodyLarge?.copyWith(
                        color: colors.textPrimary,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  child: CupertinoDatePicker(
                    mode: widget.mode,
                    initialDateTime: _selected,
                    minimumDate: widget.minimumDate,
                    maximumDate: widget.maximumDate,
                    use24hFormat: true,
                    onDateTimeChanged: (value) {
                      setState(() => _selected = value);
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
