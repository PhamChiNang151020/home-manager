import "package:flutter/material.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/state/lock_controller.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:home_manager/core/theme/mobile_viewport.dart";
import "package:home_manager/features/lock/lock_screen.dart";

class SetupPinPage extends StatefulWidget {
  const SetupPinPage({
    super.key,
    required this.lock,
    this.changeExisting = false,
  });

  final LockController lock;
  final bool changeExisting;

  @override
  State<SetupPinPage> createState() => _SetupPinPageState();
}

class _SetupPinPageState extends State<SetupPinPage> {
  String _first = "";
  String _confirm = "";
  bool _confirming = false;
  String? _error;

  String get _current => _confirming ? _confirm : _first;

  void _onDigit(String digit) {
    if (_current.length >= kPinLength) return;
    setState(() {
      _error = null;
      if (_confirming) {
        _confirm += digit;
      } else {
        _first += digit;
      }
    });
    final value = _confirming ? _confirm : _first;
    if (value.length < kPinLength) return;

    if (!_confirming) {
      setState(() => _confirming = true);
      return;
    }

    if (_first != _confirm) {
      setState(() {
        _error = S.setupPinMismatch;
        _first = "";
        _confirm = "";
        _confirming = false;
      });
      return;
    }

    _save(_first);
  }

  Future<void> _save(String pin) async {
    if (widget.changeExisting) {
      await widget.lock.changePin(pin);
    } else {
      await widget.lock.enableWithPin(pin);
    }
    if (mounted) Navigator.pop(context, true);
  }

  void _onBackspace() {
    setState(() {
      _error = null;
      if (_confirming) {
        if (_confirm.isEmpty) {
          _confirming = false;
        } else {
          _confirm = _confirm.substring(0, _confirm.length - 1);
        }
      } else if (_first.isNotEmpty) {
        _first = _first.substring(0, _first.length - 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final title = _confirming ? S.setupPinConfirmTitle : S.setupPinTitle;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.changeExisting ? S.changePin : S.setupPinTitle),
      ),
      body: MobileViewport(
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(kPinLength, (i) {
                  final filled = i < _current.length;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: filled ? colors.accent : colors.border,
                    ),
                  );
                }),
              ),
              if (_error != null) ...[
                const SizedBox(height: AppSpacing.md),
                Text(_error!, style: TextStyle(color: colors.error)),
              ],
              const Spacer(),
              PinPad(onDigit: _onDigit, onBackspace: _onBackspace),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
