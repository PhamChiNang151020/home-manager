import "package:flutter/material.dart";
import "package:home_manager/core/format/vnd_input_formatter.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/app_spacing.dart";

class LabeledMoneyField extends StatelessWidget {
  const LabeledMoneyField({
    super.key,
    required this.label,
    required this.controller,
    this.readOnly = false,
    this.enabled = true,
    this.onChanged,
    this.suffix = "đ",
  });

  final String label;
  final TextEditingController controller;
  final bool readOnly;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final String suffix;

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
          readOnly: readOnly,
          enabled: enabled,
          onChanged: onChanged,
          keyboardType: TextInputType.number,
          inputFormatters: readOnly ? null : [VndInputFormatter()],
          decoration: InputDecoration(
            suffixText: suffix,
          ),
        ),
      ],
    );
  }
}
