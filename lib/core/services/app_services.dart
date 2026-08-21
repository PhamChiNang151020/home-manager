import "package:home_manager/core/services/bank_account_service.dart";
import "package:home_manager/core/services/electricity_service.dart";
import "package:home_manager/core/services/expense_service.dart";
import "package:home_manager/core/services/home_service.dart";
import "package:home_manager/core/services/income_service.dart";
import "package:home_manager/core/services/invite_service.dart";
import "package:home_manager/core/services/personal_debt_service.dart";
import "package:home_manager/core/services/savings_service.dart";
import "package:home_manager/core/services/water_service.dart";
import "package:supabase_flutter/supabase_flutter.dart";

/// App-wide service locator created once in [main], never in widget [build].
class AppServices {
  AppServices(SupabaseClient client)
    : homes = HomeService(client),
      electricity = ElectricityService(client),
      water = WaterService(client),
      expenses = ExpenseService(client),
      incomes = IncomeService(client),
      photos = BillPhotoService(client),
      invites = InviteService(client),
      bankAccounts = BankAccountService(client),
      personalDebts = PersonalDebtService(client),
      savings = SavingsService(client);

  final HomeService homes;
  final ElectricityService electricity;
  final WaterService water;
  final ExpenseService expenses;
  final IncomeService incomes;
  final BillPhotoService photos;
  final InviteService invites;
  final BankAccountService bankAccounts;
  final PersonalDebtService personalDebts;
  final SavingsService savings;
}
