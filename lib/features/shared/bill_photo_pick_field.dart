import "dart:typed_data";

import "package:flutter/material.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:image_picker/image_picker.dart";

/// Pick a bill photo from the library, preview it, and drop it before saving.
class BillPhotoPickField extends StatelessWidget {
  const BillPhotoPickField({
    super.key,
    required this.bytes,
    required this.onChanged,
    this.enabled = true,
  });

  final Uint8List? bytes;
  final ValueChanged<Uint8List?> onChanged;
  final bool enabled;

  Future<void> _pick() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 1600,
    );
    if (file == null) return;
    onChanged(await file.readAsBytes());
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final picked = bytes;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton.icon(
          onPressed: enabled ? _pick : null,
          icon: const Icon(Icons.photo_library_outlined),
          label: Text(picked == null ? S.pickPhoto : S.pickPhotoReplace),
        ),
        const SizedBox(height: AppSpacing.xs),
        if (picked == null)
          Text(
            S.photoConstraintHint,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: colors.textMuted),
          )
        else
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
                  child: Image.memory(
                    picked,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 18,
                        color: colors.success,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Flexible(
                        child: Text(
                          S.photoSelected,
                          style: TextStyle(color: colors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: enabled ? () => onChanged(null) : null,
                  style: TextButton.styleFrom(foregroundColor: colors.error),
                  child: const Text(S.removePhoto),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
