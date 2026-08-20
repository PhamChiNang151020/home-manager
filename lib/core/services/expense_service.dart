import "package:home_manager/core/logging/app_log.dart";
import "package:home_manager/core/models/expense.dart";
import "package:intl/intl.dart";
import "package:supabase_flutter/supabase_flutter.dart";

class ExpenseService {
  ExpenseService(this._client);

  final SupabaseClient _client;

  Future<List<ExpenseCategory>> listCategories(String homeId) async {
    final rows = await _client
        .from("expense_categories")
        .select()
        .eq("home_id", homeId)
        .order("name");
    return (rows as List)
        .map(
          (row) =>
              ExpenseCategory.fromJson(Map<String, dynamic>.from(row as Map)),
        )
        .toList();
  }

  Future<List<Expense>> list(
    String homeId, {
    DateTime? month,
    String? categoryId,
    String? paidBy,
  }) async {
    AppLog.d("list expenses for $homeId");
    var query = _client
        .from("expenses")
        .select(
          "*, expense_categories(*), profiles!paid_by(display_name, email)",
        )
        .eq("home_id", homeId);
    if (month != null) {
      final start = DateFormat("yyyy-MM-01").format(month);
      final end = DateFormat(
        "yyyy-MM-01",
      ).format(DateTime(month.year, month.month + 1));
      query = query.gte("expense_date", start).lt("expense_date", end);
    }
    if (categoryId != null) {
      query = query.eq("category_id", categoryId);
    }
    if (paidBy != null) {
      query = query.eq("paid_by", paidBy);
    }
    final rows = await query.order("expense_date", ascending: false);
    return (rows as List)
        .map((row) => Expense.fromJson(Map<String, dynamic>.from(row as Map)))
        .toList();
  }

  Future<Expense> insert({
    required String homeId,
    required String categoryId,
    required String paidBy,
    required double amountVnd,
    required DateTime expenseDate,
    String? note,
    String? receiptPhotoPath,
  }) async {
    final row =
        await _client
            .from("expenses")
            .insert({
              "home_id": homeId,
              "category_id": categoryId,
              "paid_by": paidBy,
              "amount_vnd": amountVnd,
              "expense_date": DateFormat("yyyy-MM-dd").format(expenseDate),
              "note": note,
              "receipt_photo_path": receiptPhotoPath,
            })
            .select(
              "*, expense_categories(*), profiles!paid_by(display_name, email)",
            )
            .single();
    return Expense.fromJson(row);
  }

  Future<Expense> update({
    required String id,
    required String categoryId,
    required String paidBy,
    required double amountVnd,
    required DateTime expenseDate,
    String? note,
    String? receiptPhotoPath,
  }) async {
    final row =
        await _client
            .from("expenses")
            .update({
              "category_id": categoryId,
              "paid_by": paidBy,
              "amount_vnd": amountVnd,
              "expense_date": DateFormat("yyyy-MM-dd").format(expenseDate),
              "note": note,
              "receipt_photo_path": receiptPhotoPath,
            })
            .eq("id", id)
            .select(
              "*, expense_categories(*), profiles!paid_by(display_name, email)",
            )
            .single();
    return Expense.fromJson(row);
  }

  Future<void> delete(String id) async {
    AppLog.d("delete expense $id");
    await _client.from("expenses").delete().eq("id", id);
  }
}
