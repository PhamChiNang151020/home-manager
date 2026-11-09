import "package:flutter/material.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/app_theme.dart";

/// Invite notice above the sign-in card when a pending `?join=` token is stored.
class JoinInviteBanner extends StatelessWidget {
  const JoinInviteBanner({super.key});

  static const Key bannerKey = ValueKey<String>("join_invite_banner");

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return SizedBox(
      key: bannerKey,
      width: double.infinity,
      height: 64,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.accent.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.group_add, size: 20, color: colors.accent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  S.joinInviteBanner,
                  style: TextStyle(
                    fontFamily: AppFonts.nunito,
                    fontSize: 14,
                    height: 20 / 14,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
