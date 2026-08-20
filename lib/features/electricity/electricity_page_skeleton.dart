import "package:flutter/material.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:home_manager/features/shared/app_card.dart";
import "package:home_manager/features/shared/skeleton.dart";

class ElectricityPageSkeleton extends StatelessWidget {
  const ElectricityPageSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      children: [
        _SummarySkeleton(),
        const SizedBox(height: AppSpacing.sm),
        _ChartSkeleton(),
        const SizedBox(height: AppSpacing.md),
        const SkeletonLine(width: 80, height: 18),
        const SizedBox(height: AppSpacing.sm),
        const SkeletonBox(
          width: double.infinity,
          height: 44,
          borderRadius: AppSpacing.inputRadius,
        ),
        const SizedBox(height: AppSpacing.sm),
        for (var i = 0; i < 3; i++) ...[
          _ListTileSkeleton(),
          const SizedBox(height: AppSpacing.xs),
        ],
      ],
    );
  }
}

class _SummarySkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonLine(width: 72, height: 12),
          const SizedBox(height: AppSpacing.xs),
          const SkeletonLine(width: 140, height: 18),
          const SizedBox(height: AppSpacing.sm),
          const SkeletonLine(width: 180, height: 28),
          const SizedBox(height: AppSpacing.sm),
          const SkeletonLine(width: 120, height: 12),
        ],
      ),
    );
  }
}

class _ChartSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonLine(width: 100, height: 14),
          const SizedBox(height: AppSpacing.sm),
          const SkeletonBox(
            width: double.infinity,
            height: 130,
            borderRadius: AppSpacing.inputRadius,
          ),
        ],
      ),
    );
  }
}

class _ListTileSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(child: SkeletonLine(width: 80, height: 20)),
              SkeletonBox(width: 24, height: 24, borderRadius: 12),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          const SkeletonLine(width: 120, height: 22),
          const SizedBox(height: AppSpacing.xs),
          const SkeletonLine(width: 160, height: 12),
        ],
      ),
    );
  }
}
