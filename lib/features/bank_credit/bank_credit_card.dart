import "dart:ui";

import "package:flutter/material.dart";
import "package:home_manager/core/domain/bank_brand.dart";
import "package:home_manager/core/format/vnd_format.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/models/bank_account.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/app_motion.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:home_manager/features/shared/bank_logo.dart";
import "package:home_manager/features/shared/money_text.dart";
import "package:home_manager/features/shared/status_badge.dart";

/// Credit-card style tile: gradient face + faded bank logo watermark.
class BankCreditCard extends StatefulWidget {
  const BankCreditCard({
    super.key,
    required this.account,
    required this.period,
    required this.onTap,
    required this.onEditPeriod,
  });

  final BankAccount account;
  final BankAccountPeriod? period;
  final VoidCallback onTap;
  final VoidCallback onEditPeriod;

  @override
  State<BankCreditCard> createState() => _BankCreditCardState();
}

class _BankCreditCardState extends State<BankCreditCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
      vsync: this,
      duration: AppMotion.fast,
      reverseDuration: AppMotion.fast,
    );
    _scale = Tween<double>(
      begin: 1,
      end: 0.985,
    ).animate(CurvedAnimation(parent: _press, curve: AppCurves.press));
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final theme = Theme.of(context);
    final account = widget.account;
    final period = widget.period;
    final used = period?.balanceUsed ?? 0;
    final remaining = (account.creditLimit - used).clamp(
      0,
      account.creditLimit,
    );
    final progress =
        account.creditLimit <= 0
            ? 0.0
            : (used / account.creditLimit).clamp(0.0, 1.0);
    final logoUrl = BankBrand.logoUrlForName(account.bankName);
    final radius = BorderRadius.circular(AppSpacing.cardRadius + 4);

    return ScaleTransition(
      scale: _scale,
      child: Material(
        color: Colors.transparent,
        elevation: 6,
        shadowColor: colors.accent.withValues(alpha: 0.35),
        borderRadius: radius,
        child: InkWell(
          onTap: widget.onTap,
          onTapDown: (_) => _press.forward(),
          onTapUp: (_) => _press.reverse(),
          onTapCancel: () => _press.reverse(),
          borderRadius: radius,
          child: ClipRRect(
            borderRadius: radius,
            child: Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color.lerp(colors.bgSurface, colors.accent, 0.24)!,
                          Color.lerp(colors.bgElevated, colors.accent, 0.1)!,
                          colors.bgSurface,
                        ],
                        stops: const [0, 0.5, 1],
                      ),
                      border: Border.all(
                        color: colors.accent.withValues(alpha: 0.28),
                      ),
                    ),
                  ),
                ),
                if (logoUrl != null)
                  Positioned(
                    right: -36,
                    top: -20,
                    bottom: -20,
                    width: 220,
                    child: IgnorePointer(
                      child: Opacity(
                        opacity: 0.2,
                        child: ImageFiltered(
                          imageFilter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: Image.network(
                            logoUrl,
                            fit: BoxFit.contain,
                            errorBuilder:
                                (_, __, ___) => const SizedBox.shrink(),
                          ),
                        ),
                      ),
                    ),
                  ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          colors.bgSurface.withValues(alpha: 0.5),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.md + 4,
                    AppSpacing.md + 6,
                    AppSpacing.md,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          BankLogo(bankName: account.bankName, size: 40),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              account.bankName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Container(
                              width: 38,
                              height: 28,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFFE8C872),
                                    Color.lerp(
                                      const Color(0xFFE8C872),
                                      colors.accent,
                                      0.35,
                                    )!,
                                  ],
                                ),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.35),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        S.remainingCredit,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                      MoneyText(
                        amount: remaining.toDouble(),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: colors.textPrimary,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "${S.creditLimit}: ${VndFormat.format(account.creditLimit)}",
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.textMuted,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          backgroundColor: colors.bgElevated.withValues(
                            alpha: 0.7,
                          ),
                          color: colors.accent,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          StatusBadge(
                            label:
                                period == null
                                    ? S.unpaid
                                    : (period.isPaid ? S.paid : S.unpaid),
                            variant:
                                period?.isPaid == true
                                    ? StatusBadgeVariant.success
                                    : StatusBadgeVariant.warning,
                          ),
                          const Spacer(),
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: Color.lerp(
                                colors.accent,
                                theme.brightness == Brightness.dark
                                    ? const Color(0xFFFFFFFF)
                                    : const Color(0xFF000000),
                                theme.brightness == Brightness.dark
                                    ? 0.08
                                    : 0.28,
                              ),
                              backgroundColor: colors.accent.withValues(
                                alpha:
                                    theme.brightness == Brightness.dark
                                        ? 0.28
                                        : 0.2,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: AppSpacing.xs,
                              ),
                            ),
                            onPressed: widget.onEditPeriod,
                            child: Text(
                              period == null
                                  ? S.addBankPeriod
                                  : S.editBankPeriod,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
