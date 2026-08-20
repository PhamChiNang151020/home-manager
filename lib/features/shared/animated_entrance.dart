import "package:flutter/material.dart";
import "package:home_manager/core/theme/app_motion.dart";

class AnimatedEntrance extends StatefulWidget {
  const AnimatedEntrance({super.key, required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  State<AnimatedEntrance> createState() => _AnimatedEntranceState();
}

class _AnimatedEntranceState extends State<AnimatedEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: AppMotion.normal);
    _opacity = CurvedAnimation(parent: _controller, curve: AppCurves.enter);
    _offset = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(_opacity);
    final capped = widget.index.clamp(0, AppMotion.staggerCap);
    Future<void>.delayed(AppMotion.staggerStep * capped, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _offset, child: widget.child),
    );
  }
}
