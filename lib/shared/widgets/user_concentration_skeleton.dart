import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import 'admin_skeleton.dart';

class UserConcentrationSkeleton extends StatelessWidget {
  const UserConcentrationSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _SummarySkeleton(),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 1120;
            if (wide) {
              return const SizedBox(
                height: 610,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: _MapSkeleton()),
                    SizedBox(width: 16),
                    SizedBox(width: 340, child: _RegionListSkeleton()),
                  ],
                ),
              );
            }

            return const Column(
              children: [
                SizedBox(height: 520, child: _MapSkeleton()),
                SizedBox(height: 16),
                SizedBox(height: 500, child: _RegionListSkeleton()),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _SummarySkeleton extends StatelessWidget {
  const _SummarySkeleton();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 12.0;
        final columns = constraints.maxWidth >= 1050
            ? 4
            : constraints.maxWidth >= 650
                ? 2
                : 1;
        final width =
            (constraints.maxWidth - gap * (columns - 1)) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: List.generate(
            4,
            (_) => SizedBox(
              width: width,
              child: const _SummaryCardSkeleton(),
            ),
          ),
        );
      },
    );
  }
}

class _SummaryCardSkeleton extends StatelessWidget {
  const _SummaryCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return AdminSkeleton(
      child: Container(
        height: 96,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: const Row(
          children: [
            AdminSkeletonBox(width: 42, height: 42, radius: 12),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AdminSkeletonBox(width: 100, height: 9, radius: 5),
                  SizedBox(height: 7),
                  AdminSkeletonBox(width: 58, height: 20, radius: 6),
                  SizedBox(height: 5),
                  AdminSkeletonBox(width: 115, height: 8, radius: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapSkeleton extends StatelessWidget {
  const _MapSkeleton();

  @override
  Widget build(BuildContext context) {
    return AdminSkeleton(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.borderStrong),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  margin: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceRaised,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: AdminSkeletonBox(
                      width: 210,
                      height: 150,
                      radius: 75,
                    ),
                  ),
                ),
              ),
              const Positioned(
                top: 16,
                left: 16,
                child: AdminSkeletonBox(
                  width: 190,
                  height: 30,
                  radius: 10,
                ),
              ),
              const Positioned(
                left: 20,
                bottom: 18,
                child: AdminSkeletonBox(
                  width: 120,
                  height: 27,
                  radius: 10,
                ),
              ),
              Positioned(
                right: 16,
                bottom: 16,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceRaised,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Column(
                    children: [
                      AdminSkeletonBox(width: 38, height: 32, radius: 9),
                      SizedBox(height: 4),
                      AdminSkeletonBox(width: 38, height: 24, radius: 8),
                      SizedBox(height: 4),
                      AdminSkeletonBox(width: 38, height: 32, radius: 9),
                      SizedBox(height: 4),
                      AdminSkeletonBox(width: 38, height: 32, radius: 9),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RegionListSkeleton extends StatelessWidget {
  const _RegionListSkeleton();

  @override
  Widget build(BuildContext context) {
    return AdminSkeleton(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AdminSkeletonBox(width: 145, height: 14, radius: 7),
                      SizedBox(height: 7),
                      AdminSkeletonBox(width: 165, height: 9, radius: 5),
                    ],
                  ),
                ),
                AdminSkeletonBox(width: 75, height: 25, radius: 8),
              ],
            ),
            const SizedBox(height: 18),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 9,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  return const _RegionRowSkeleton();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RegionRowSkeleton extends StatelessWidget {
  const _RegionRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised.withValues(alpha: .45),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        children: [
          Row(
            children: [
              AdminSkeletonBox(width: 22, height: 9, radius: 4),
              SizedBox(width: 10),
              Expanded(
                child: AdminSkeletonBox(
                  width: double.infinity,
                  height: 10,
                  radius: 5,
                ),
              ),
              SizedBox(width: 10),
              AdminSkeletonBox(width: 28, height: 10, radius: 5),
              SizedBox(width: 8),
              AdminSkeletonBox(width: 38, height: 9, radius: 4),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              SizedBox(width: 32),
              Expanded(
                child: AdminSkeletonBox(
                  width: double.infinity,
                  height: 5,
                  radius: 3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
