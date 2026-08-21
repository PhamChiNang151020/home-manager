import "package:flutter/material.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/models/home.dart";
import "package:home_manager/core/navigation/app_page_route.dart";
import "package:home_manager/core/services/app_services.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:home_manager/features/bank_credit/bank_credit_page.dart";
import "package:home_manager/features/personal_debts/personal_debts_page.dart";
import "package:home_manager/features/savings/savings_page.dart";
import "package:home_manager/features/shared/animated_entrance.dart";
import "package:home_manager/features/shared/app_card.dart";
import "package:home_manager/features/shared/feature_page_scaffold.dart";

/// Hub listing three finance miniapps — same push pattern as Điện / Nước / Thu nhập.
class FinanceHubPage extends StatelessWidget {
  const FinanceHubPage({
    super.key,
    required this.home,
    required this.services,
    required this.currentUserId,
  });

  final Home home;
  final AppServices services;
  final String currentUserId;

  @override
  Widget build(BuildContext context) {
    return FeaturePageScaffold(
      title: S.finance,
      body: ListView(
        padding: AppSpacing.shellListPadding,
        children: [
          AnimatedEntrance(
            index: 0,
            child: _FinanceTile(
              icon: Icons.credit_card,
              title: S.bankCredit,
              subtitle: S.bankCreditDesc,
              onTap:
                  () => Navigator.push(
                    context,
                    AppPageRoute<void>(
                      page: BankCreditRoutePage(
                        home: home,
                        bank: services.bankAccounts,
                      ),
                    ),
                  ),
            ),
          ),
          AnimatedEntrance(
            index: 1,
            child: _FinanceTile(
              icon: Icons.handshake_outlined,
              title: S.personalDebts,
              subtitle: S.personalDebtsDesc,
              onTap:
                  () => Navigator.push(
                    context,
                    AppPageRoute<void>(
                      page: PersonalDebtsRoutePage(
                        home: home,
                        debts: services.personalDebts,
                        currentUserId: currentUserId,
                      ),
                    ),
                  ),
            ),
          ),
          AnimatedEntrance(
            index: 2,
            child: _FinanceTile(
              icon: Icons.savings_outlined,
              title: S.savings,
              subtitle: S.savingsDesc,
              onTap:
                  () => Navigator.push(
                    context,
                    AppPageRoute<void>(
                      page: SavingsRoutePage(
                        home: home,
                        savings: services.savings,
                      ),
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FinanceTile extends StatelessWidget {
  const _FinanceTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        onTap: onTap,
        padding: EdgeInsets.zero,
        child: ListTile(
          leading: Icon(icon, color: colors.accent),
          title: Text(title),
          subtitle: Text(subtitle),
          trailing: Icon(Icons.chevron_right, color: colors.textMuted),
        ),
      ),
    );
  }
}
