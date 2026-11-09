import "package:flutter/material.dart";
import "package:home_manager/core/format/vnd_format.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/models/wallet.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:home_manager/core/theme/app_theme.dart";
import "package:home_manager/features/shared/app_sheet.dart";
import "package:home_manager/features/shared/list_group.dart";

/// Sentinel: user chose "Không trừ ví".
const walletPickerNone = Object();

IconData walletKindIcon(WalletKind kind) {
  return switch (kind) {
    WalletKind.cash => Icons.payments,
    WalletKind.bank => Icons.account_balance,
    WalletKind.ewallet => Icons.phone_iphone,
  };
}

/// Returns a [Wallet] id [String], or [walletPickerNone], or null if dismissed.
Future<Object?> showWalletPickerSheet({
  required BuildContext context,
  required List<Wallet> wallets,
  required String? selectedWalletId,
  double? amountVnd,
}) {
  return showAppSheet<Object?>(
    context: context,
    showDragHandle: false,
    builder:
        (context) => _WalletPickerSheet(
          wallets: wallets,
          selectedWalletId: selectedWalletId,
          amountVnd: amountVnd,
        ),
  );
}

class _WalletPickerSheet extends StatelessWidget {
  const _WalletPickerSheet({
    required this.wallets,
    required this.selectedWalletId,
    required this.amountVnd,
  });

  final List<Wallet> wallets;
  final String? selectedWalletId;
  final double? amountVnd;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    final maxSheetTop = 115.0;
    final screenH = MediaQuery.sizeOf(context).height;
    final maxHeight = screenH - maxSheetTop;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.md,
          0,
          AppSpacing.md,
          AppSpacing.md + bottomInset,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 36,
              child: Center(
                child: Container(
                  width: 32,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            Text(
              S.walletPickTitle,
              style: const TextStyle(
                fontFamily: AppFonts.nunito,
                fontSize: 18,
                height: 24 / 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Flexible(
              child: ListGroup(
                children: [
                  for (var i = 0; i < wallets.length; i++)
                    _WalletPickRow(
                      wallet: wallets[i],
                      selected: selectedWalletId == wallets[i].id,
                      amountLow:
                          amountVnd != null &&
                          wallets[i].balanceVnd < amountVnd!,
                      showDivider: true,
                      onTap:
                          () => Navigator.pop(context, wallets[i].id),
                    ),
                  _NonePayRow(
                    selected: selectedWalletId == null,
                    showDivider: false,
                    onTap: () => Navigator.pop(context, walletPickerNone),
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

class _WalletPickRow extends StatelessWidget {
  const _WalletPickRow({
    required this.wallet,
    required this.selected,
    required this.amountLow,
    required this.showDivider,
    required this.onTap,
  });

  final Wallet wallet;
  final bool selected;
  final bool amountLow;
  final bool showDivider;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final balanceColor = amountLow ? colors.error : colors.textSecondary;
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 64,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Row(
                children: [
                  ListGroupIcon(
                    icon: walletKindIcon(wallet.kind),
                    color: colors.accent,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          wallet.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: AppFonts.nunito,
                            fontSize: 14,
                            height: 20 / 14,
                            fontWeight: FontWeight.w600,
                            color: colors.textPrimary,
                          ),
                        ),
                        Text(
                          S.walletBalanceOf(VndFormat.format(wallet.balanceVnd)),
                          style: TextStyle(
                            fontFamily: AppFonts.nunito,
                            fontSize: 12,
                            height: 16 / 12,
                            color: balanceColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (selected)
                    Icon(Icons.check, size: 24, color: colors.accent),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          Divider(height: 1, thickness: 1, indent: 64, color: colors.border),
      ],
    );
  }
}

class _NonePayRow extends StatelessWidget {
  const _NonePayRow({
    required this.selected,
    required this.showDivider,
    required this.onTap,
  });

  final bool selected;
  final bool showDivider;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 64,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Row(
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          S.walletPayFromNone,
                          style: TextStyle(
                            fontFamily: AppFonts.nunito,
                            fontSize: 14,
                            height: 20 / 14,
                            fontWeight: FontWeight.w600,
                            color: colors.textPrimary,
                          ),
                        ),
                        Text(
                          S.walletPayFromNoneHint,
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
                  if (selected)
                    Icon(Icons.check, size: 24, color: colors.accent),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          Divider(height: 1, thickness: 1, indent: 64, color: colors.border),
      ],
    );
  }
}
