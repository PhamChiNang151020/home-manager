import "package:custom_refresh_indicator/custom_refresh_indicator.dart";
import "package:flutter/material.dart";
import "package:home_manager/features/shared/app_loading.dart";

/// Pull-to-refresh that shows the same branded overlay as [LoadingOverlay].
///
/// The gesture comes from [CustomRefreshIndicator]; the overlay is owned by
/// this widget and follows the [onRefresh] future, not the package's
/// settle/finalize animation. Tying the scrim to that animation left the
/// loader spinning after the data had already arrived.
class AppRefreshIndicator extends StatefulWidget {
  const AppRefreshIndicator({
    super.key,
    required this.onRefresh,
    required this.child,
  });

  final Future<void> Function() onRefresh;
  final Widget child;

  @override
  State<AppRefreshIndicator> createState() => _AppRefreshIndicatorState();
}

class _AppRefreshIndicatorState extends State<AppRefreshIndicator> {
  var _showOverlay = false;

  Future<void> _onRefresh() async {
    setState(() => _showOverlay = true);
    try {
      await widget.onRefresh();
    } finally {
      if (mounted) setState(() => _showOverlay = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomRefreshIndicator(
          onRefresh: _onRefresh,
          builder: (context, child, _) => child,
          child: widget.child,
        ),
        if (_showOverlay) const Positioned.fill(child: AppLoadingScrim()),
      ],
    );
  }
}
