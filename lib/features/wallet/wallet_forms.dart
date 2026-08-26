import "package:flutter/material.dart";
import "package:home_manager/core/domain/bank_brand.dart";
import "package:home_manager/core/format/vnd_format.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/models/wallet.dart";
import "package:home_manager/core/services/wallet_service.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:home_manager/features/shared/app_sheet.dart";
import "package:home_manager/features/shared/app_toast.dart";
import "package:home_manager/features/shared/form_title.dart";
import "package:home_manager/features/shared/labeled_money_field.dart";
import "package:home_manager/features/shared/labeled_text_field.dart";

Future<void> showWalletForm({
  required BuildContext context,
  required String homeId,
  required WalletService wallets,
  Wallet? existing,
  required VoidCallback onSaved,
}) {
  return showAppSheet<void>(
    context: context,
    builder:
        (context) => _WalletFormSheet(
          homeId: homeId,
          wallets: wallets,
          existing: existing,
          onSaved: onSaved,
        ),
  );
}

Future<void> showWalletAdjustSheet({
  required BuildContext context,
  required Wallet wallet,
  required WalletService wallets,
  required VoidCallback onSaved,
}) {
  return showAppSheet<void>(
    context: context,
    builder:
        (context) => _WalletAdjustSheet(
          wallet: wallet,
          wallets: wallets,
          onSaved: onSaved,
        ),
  );
}

Future<void> showWalletTransferSheet({
  required BuildContext context,
  required List<Wallet> allWallets,
  required Wallet from,
  required WalletService wallets,
  required VoidCallback onSaved,
}) {
  return showAppSheet<void>(
    context: context,
    builder:
        (context) => _WalletTransferSheet(
          allWallets: allWallets,
          from: from,
          wallets: wallets,
          onSaved: onSaved,
        ),
  );
}

class _WalletFormSheet extends StatefulWidget {
  const _WalletFormSheet({
    required this.homeId,
    required this.wallets,
    required this.onSaved,
    this.existing,
  });

  final String homeId;
  final WalletService wallets;
  final Wallet? existing;
  final VoidCallback onSaved;

  @override
  State<_WalletFormSheet> createState() => _WalletFormSheetState();
}

class _WalletFormSheetState extends State<_WalletFormSheet> {
  late final TextEditingController _name;
  late final TextEditingController _bankName;
  late final TextEditingController _note;
  late final TextEditingController _initial;
  late WalletKind _kind;
  String? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _name = TextEditingController(text: e?.name ?? "");
    _bankName = TextEditingController(text: e?.bankName ?? "");
    _note = TextEditingController(text: e?.note ?? "");
    _initial = TextEditingController();
    _kind = e?.kind ?? WalletKind.cash;
  }

  @override
  void dispose() {
    _name.dispose();
    _bankName.dispose();
    _note.dispose();
    _initial.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _error = S.emptyHomeName);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final existing = widget.existing;
      if (existing == null) {
        final initial = VndFormat.parse(_initial.text) ?? 0;
        await widget.wallets.create(
          homeId: widget.homeId,
          kind: _kind,
          name: name,
          bankName: _kind == WalletKind.bank ? _bankName.text.trim() : null,
          note: _note.text.trim().isEmpty ? null : _note.text.trim(),
          initialBalance: initial < 0 ? 0 : initial,
        );
      } else {
        await widget.wallets.updateMeta(
          id: existing.id,
          name: name,
          kind: _kind,
          bankName: _kind == WalletKind.bank ? _bankName.text.trim() : null,
          note: _note.text.trim().isEmpty ? null : _note.text.trim(),
        );
      }
      if (!mounted) return;
      popWithAppToast(
        context,
        existing == null ? S.toastWalletAdded : S.toastWalletSaved,
        then: widget.onSaved,
      );
    } catch (e) {
      setState(() => _error = "$e");
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.md,
        bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.lg,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FormTitle(
              title: widget.existing == null ? S.addWallet : S.editWallet,
            ),
            const SizedBox(height: AppSpacing.md),
            LabeledDropdownField<WalletKind>(
              label: S.wallet,
              value: _kind,
              items: [
                SelectOption(
                  value: WalletKind.cash,
                  builder: (_) => const Text(S.walletCash),
                ),
                SelectOption(
                  value: WalletKind.bank,
                  builder: (_) => const Text(S.walletBank),
                ),
                SelectOption(
                  value: WalletKind.ewallet,
                  builder: (_) => const Text(S.walletEwallet),
                ),
              ],
              onChanged: (v) {
                if (v != null) setState(() => _kind = v);
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            LabeledTextField(label: S.savingsName, controller: _name),
            if (_kind == WalletKind.bank) ...[
              const SizedBox(height: AppSpacing.sm),
              LabeledTextField(
                label: S.bankName,
                controller: _bankName,
                hint: BankBrand.popular.first.name,
              ),
            ],
            if (widget.existing == null) ...[
              const SizedBox(height: AppSpacing.sm),
              LabeledMoneyField(
                label: S.walletInitialBalance,
                controller: _initial,
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            LabeledTextField(label: S.note, controller: _note),
            if (_error != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(_saving ? S.sending : S.save),
            ),
          ],
        ),
      ),
    );
  }
}

class _WalletAdjustSheet extends StatefulWidget {
  const _WalletAdjustSheet({
    required this.wallet,
    required this.wallets,
    required this.onSaved,
  });

  final Wallet wallet;
  final WalletService wallets;
  final VoidCallback onSaved;

  @override
  State<_WalletAdjustSheet> createState() => _WalletAdjustSheetState();
}

class _WalletAdjustSheetState extends State<_WalletAdjustSheet> {
  late final TextEditingController _amount;
  late final TextEditingController _note;
  bool _deposit = true;
  String? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _amount = TextEditingController();
    _note = TextEditingController();
  }

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final money = VndFormat.parse(_amount.text);
    if (money == null || money <= 0) {
      setState(() => _error = S.invalidAmount);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.wallets.adjust(
        walletId: widget.wallet.id,
        signedAmount: _deposit ? money : -money,
        note: _note.text.trim().isEmpty ? null : _note.text.trim(),
      );
      if (!mounted) return;
      popWithAppToast(context, S.toastWalletAdjusted, then: widget.onSaved);
    } catch (e) {
      setState(() => _error = "$e");
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.md,
        bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const FormTitle(title: S.walletAdjust),
          const SizedBox(height: AppSpacing.md),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: true, label: Text("+")),
              ButtonSegment(value: false, label: Text("−")),
            ],
            selected: {_deposit},
            onSelectionChanged: (s) => setState(() => _deposit = s.first),
          ),
          const SizedBox(height: AppSpacing.sm),
          LabeledMoneyField(label: S.amount, controller: _amount),
          const SizedBox(height: AppSpacing.sm),
          LabeledTextField(label: S.note, controller: _note),
          if (_error != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: const Text(S.save),
          ),
        ],
      ),
    );
  }
}

class _WalletTransferSheet extends StatefulWidget {
  const _WalletTransferSheet({
    required this.allWallets,
    required this.from,
    required this.wallets,
    required this.onSaved,
  });

  final List<Wallet> allWallets;
  final Wallet from;
  final WalletService wallets;
  final VoidCallback onSaved;

  @override
  State<_WalletTransferSheet> createState() => _WalletTransferSheetState();
}

class _WalletTransferSheetState extends State<_WalletTransferSheet> {
  late final TextEditingController _amount;
  late final TextEditingController _note;
  late String _toId;
  String? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _amount = TextEditingController();
    _note = TextEditingController();
    final others =
        widget.allWallets.where((w) => w.id != widget.from.id).toList();
    _toId = others.isEmpty ? widget.from.id : others.first.id;
  }

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final money = VndFormat.parse(_amount.text);
    if (money == null || money <= 0) {
      setState(() => _error = S.invalidAmount);
      return;
    }
    if (_toId == widget.from.id) {
      setState(() => _error = S.walletTransferTo);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.wallets.transfer(
        fromWalletId: widget.from.id,
        toWalletId: _toId,
        amount: money,
        note: _note.text.trim().isEmpty ? null : _note.text.trim(),
      );
      if (!mounted) return;
      popWithAppToast(context, S.toastWalletTransferred, then: widget.onSaved);
    } catch (e) {
      setState(() => _error = "$e");
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final others =
        widget.allWallets.where((w) => w.id != widget.from.id).toList();
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.md,
        bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const FormTitle(title: S.walletTransfer),
          const SizedBox(height: AppSpacing.sm),
          Text("${S.walletTransferFrom}: ${widget.from.name}"),
          const SizedBox(height: AppSpacing.sm),
          LabeledDropdownField<String>(
            label: S.walletTransferTo,
            value: _toId,
            items:
                others
                    .map(
                      (w) => SelectOption(
                        value: w.id,
                        builder: (_) => Text(w.name),
                      ),
                    )
                    .toList(),
            onChanged: (v) {
              if (v != null) setState(() => _toId = v);
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          LabeledMoneyField(label: S.amount, controller: _amount),
          const SizedBox(height: AppSpacing.sm),
          LabeledTextField(label: S.note, controller: _note),
          if (_error != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          FilledButton(
            onPressed: _saving || others.isEmpty ? null : _save,
            child: const Text(S.save),
          ),
        ],
      ),
    );
  }
}
