import "package:flutter/material.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/app_spacing.dart";

class SelectOption<T> {
  const SelectOption({required this.value, required this.builder});

  final T value;
  final WidgetBuilder builder;
}

class SelectSheetChoice<T> {
  const SelectSheetChoice(this.value);

  final T value;
}

Future<SelectSheetChoice<T>?> showSelectSheet<T>({
  required BuildContext context,
  required String title,
  required T value,
  required List<SelectOption<T>> items,
}) {
  return showModalBottomSheet<SelectSheetChoice<T>>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: context.appColors.bgSurface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppSpacing.cardRadius),
      ),
    ),
    builder: (context) {
      final colors = context.appColors;
      final maxHeight = MediaQuery.sizeOf(context).height * 0.5;
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  decoration: BoxDecoration(
                    color: colors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppSpacing.md),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: maxHeight),
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final item in items)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          item.value == value
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          color:
                              item.value == value
                                  ? colors.accent
                                  : colors.textMuted,
                        ),
                        title: DefaultTextStyle.merge(
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: colors.textPrimary),
                          child: item.builder(context),
                        ),
                        onTap: () {
                          Navigator.pop(context, SelectSheetChoice(item.value));
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
