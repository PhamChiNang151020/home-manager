import "package:flutter/material.dart";
import "package:home_manager/core/format/vnd_format.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/models/wallet.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:home_manager/core/theme/app_theme.dart";
import "package:home_manager/features/shared/list_group.dart";
import "package:home_manager/features/wallet/wallet_picker_sheet.dart";

/// Shared Ô Ví control for expense form + quick-add sheet.
///
/// Spec relative to amount field bottom B: label B+16–32, field B+36–100,
/// over-balance line B+104–120.
class ExpenseWalletField extends StatelessWidget {
  const ExpenseWalletField({
    super.key,
    required this.wallet,
    required this.enabled,
    required this.overBalance,
    required this.onTap,
  });

  final Wallet? wallet;
  final bool enabled;
  final bool overBalance;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final borderColor = overBalance ? colors.error : colors.border;
    final borderWidth = overBalance ? 1.5 : 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          S.walletPayFrom,
          style: TextStyle(
            fontFamily: AppFonts.nunito,
            fontSize: 12,
            height: 16 / 12,
            fontWeight: FontWeight.w600,
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Material(
          color: colors.bgSurface,
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          child: InkWell(
            key: const ValueKey("expense-wallet-field"),
            onTap: enabled ? onTap : null,
            borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
            child: Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
                border: Border.all(color: borderColor, width: borderWidth),
              ),
              child:
                  wallet == null
                      ? Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: colors.bgElevated,
                            ),
                            child: Icon(
                              Icons.money_off,
                              size: 20,
                              color: colors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              S.walletPayFromNone,
                              style: TextStyle(
                                fontFamily: AppFonts.nunito,
                                fontSize: 16,
                                height: 24 / 16,
                                fontWeight: FontWeight.w700,
                                color: colors.textSecondary,
                              ),
                            ),
                          ),
                          if (enabled)
                            Icon(
                              Icons.chevron_right,
                              size: 20,
                              color: colors.textMuted,
                            ),
                        ],
                      )
                      : Row(
                        children: [
                          ListGroupIcon(
                            icon: walletKindIcon(wallet!.kind),
                            color: colors.accent,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  wallet!.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: AppFonts.nunito,
                                    fontSize: 16,
                                    height: 24 / 16,
                                    fontWeight: FontWeight.w700,
                                    color: colors.textPrimary,
                                  ),
                                ),
                                Text(
                                  S.walletBalanceOf(
                                    VndFormat.format(wallet!.balanceVnd),
                                  ),
                                  style: TextStyle(
                                    fontFamily: AppFonts.nunito,
                                    fontSize: 12,
                                    height: 16 / 12,
                                    color: colors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            size: 20,
                            color: colors.textMuted,
                          ),
                        ],
                      ),
            ),
          ),
        ),
      ],
    );
  }
}
