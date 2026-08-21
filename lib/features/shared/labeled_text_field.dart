import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:home_manager/features/shared/select_sheet.dart";

export "package:home_manager/features/shared/select_sheet.dart"
    show SelectOption;

class LabeledTextField extends StatelessWidget {
  const LabeledTextField({
    super.key,
    required this.label,
    required this.controller,
    this.keyboardType,
    this.inputFormatters,
    this.maxLength,
    this.readOnly = false,
    this.enabled = true,
    this.onChanged,
    this.hint,
    this.helperText,
    this.prefix,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final bool readOnly;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final String? hint;
  final String? helperText;
  final Widget? prefix;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: colors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLength: maxLength,
          readOnly: readOnly,
          enabled: enabled,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            helperText: helperText,
            counterText: maxLength == null ? null : "",
            prefixIcon:
                prefix == null
                    ? null
                    : Padding(padding: const EdgeInsets.all(10), child: prefix),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 40,
              minHeight: 40,
            ),
          ),
        ),
      ],
    );
  }
}

class LabeledDropdownField<T> extends StatelessWidget {
  const LabeledDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.enabled = true,
    this.helperText,
    this.compact = false,
  });

  final String label;
  final T value;
  final List<SelectOption<T>> items;
  final ValueChanged<T?>? onChanged;
  final bool enabled;
  final String? helperText;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final labelStyle =
        compact
            ? Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: colors.textSecondary)
            : Theme.of(context).textTheme.labelLarge?.copyWith(
              color: colors.textSecondary,
              fontWeight: FontWeight.w500,
            );
    SelectOption<T>? selected;
    for (final item in items) {
      if (item.value == value) {
        selected = item;
        break;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: labelStyle),
        const SizedBox(height: AppSpacing.xs),
        InkWell(
          onTap:
              enabled
                  ? () async {
                    final choice = await showSelectSheet<T>(
                      context: context,
                      title: label,
                      value: value,
                      items: items,
                    );
                    if (choice != null) onChanged?.call(choice.value);
                  }
                  : null,
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          child: InputDecorator(
            decoration: InputDecoration(
              enabled: enabled,
              helperText: helperText,
              helperMaxLines: 3,
              isDense: compact,
              contentPadding:
                  compact
                      ? const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.sm,
                      )
                      : null,
            ),
            child: Row(
              children: [
                Expanded(
                  child: DefaultTextStyle.merge(
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: colors.textPrimary),
                    child:
                        selected?.builder(context) ?? const SizedBox.shrink(),
                  ),
                ),
                Icon(
                  Icons.expand_more,
                  color: colors.textSecondary,
                  size: compact ? 18 : 22,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class LabeledPickerField extends StatelessWidget {
  const LabeledPickerField({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
    this.enabled = true,
    this.trailing = const Icon(Icons.calendar_today_outlined),
  });

  final String label;
  final String value;
  final VoidCallback onTap;
  final bool enabled;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: colors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          child: InputDecorator(
            decoration: InputDecoration(enabled: enabled),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: colors.textPrimary),
                  ),
                ),
                IconTheme(
                  data: IconThemeData(color: colors.textSecondary, size: 20),
                  child: trailing,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
