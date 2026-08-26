import "package:flutter_test/flutter_test.dart";
import "package:home_manager/core/services/wallet_service.dart";
import "package:mocktail/mocktail.dart";

import "../support/mock_supabase.dart";

void main() {
  late MockSupabaseClient client;
  late WalletService service;

  setUpAll(registerSupabaseFallbacks);

  setUp(() {
    resetMocktailState();
    client = MockSupabaseClient();
    service = WalletService(client);
  });

  test("transfer calls wallet_transfer RPC", () async {
    when(() => client.rpc(any(), params: any(named: "params"))).thenAnswer(
      (_) => ImmediateRpcResult(null),
    );

    await service.transfer(
      fromWalletId: "a",
      toWalletId: "b",
      amount: 10000,
      note: "test",
    );

    verify(
      () => client.rpc(
        "wallet_transfer",
        params: {
          "p_from_wallet_id": "a",
          "p_to_wallet_id": "b",
          "p_amount": 10000,
          "p_note": "test",
        },
      ),
    ).called(1);
  });

  test("applyExpense calls wallet_apply_expense RPC", () async {
    when(() => client.rpc(any(), params: any(named: "params"))).thenAnswer(
      (_) => ImmediateRpcResult(null),
    );

    await service.applyExpense(
      expenseId: "e1",
      walletId: "w1",
      amount: 5000,
    );

    verify(
      () => client.rpc(
        "wallet_apply_expense",
        params: {
          "p_expense_id": "e1",
          "p_wallet_id": "w1",
          "p_amount": 5000,
        },
      ),
    ).called(1);
  });
}
