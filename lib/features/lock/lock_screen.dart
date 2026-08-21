import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/state/lock_controller.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:home_manager/core/theme/mobile_viewport.dart";
import "package:home_manager/features/shared/app_brand_logo.dart";

const kPinLength = 6;

class LockScreen extends StatefulWidget {
  const LockScreen({super.key, required this.lock});

  final LockController lock;

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  String _pin = "";
  String? _error;

  int get _expectedLength => widget.lock.pinLength;

  void _onDigit(String digit) {
    if (_pin.length >= _expectedLength) return;
    final next = _pin + digit;
    setState(() {
      _pin = next;
      _error = null;
    });
    if (next.length == _expectedLength) {
      final ok = widget.lock.unlock(next);
      if (!ok) {
        HapticFeedback.heavyImpact();
        setState(() {
          _error = S.lockWrongPin;
          _pin = "";
        });
      }
    }
  }

  void _onBackspace() {
    if (_pin.isEmpty) return;
    setState(() {
      _pin = _pin.substring(0, _pin.length - 1);
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      backgroundColor: colors.bgBase,
      body: MobileViewport(
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(),
              const AppBrandLogo(size: 56),
              const SizedBox(height: AppSpacing.lg),
              Text(
                S.lockTitle,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_expectedLength, (i) {
                  final filled = i < _pin.length;
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

class PinPad extends StatelessWidget {
  const PinPad({super.key, required this.onDigit, required this.onBackspace});

  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
    final keys = [
      ["1", "2", "3"],
      ["4", "5", "6"],
      ["7", "8", "9"],
      ["", "0", "⌫"],
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: [
          for (final row in keys)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: [
                  for (final key in row)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child:
                            key.isEmpty
                                ? const SizedBox(height: 56)
                                : _PadKey(
                                  label: key,
                                  onTap:
                                      key == "⌫"
                                          ? onBackspace
                                          : () => onDigit(key),
                                ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _PadKey extends StatelessWidget {
  const _PadKey({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return SizedBox(
      height: 56,
      child: Material(
        color: colors.bgSurface,
        borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          child: Center(
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}
