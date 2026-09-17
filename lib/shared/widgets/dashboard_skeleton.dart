import 'package:flutter/material.dart';

import '../../../../shared/widgets/admin_skeleton.dart';
import '../../../../core/theme/app_theme.dart';

class DashboardTopSkeleton extends StatelessWidget {
  const DashboardTopSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminSkeleton(
      child: Container(
        height: 110,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  AdminSkeletonBox(
                    width: 120,
                    height: 10,
                    radius: 5,
                  ),
                  SizedBox(height: 16),
                  AdminSkeletonBox(
                    width: 180,
                    height: 38,
                    radius: 8,
                  ),
                ],
              ),
            ),
            const AdminSkeletonBox(
              width: 120,
              height: 40,
              radius: 10,
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardMetricSkeleton extends StatelessWidget {
  const DashboardMetricSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminSkeleton(
      child: Container(
        height: 125,
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.border,
          ),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AdminSkeletonBox(
              width: 90,
              height: 12,
              radius: 6,
            ),
            SizedBox(height: 18),
            AdminSkeletonBox(
              width: 75,
              height: 30,
              radius: 8,
            ),
            SizedBox(height: 10),
            AdminSkeletonBox(
              width: 110,
              height: 10,
              radius: 5,
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardPanelSkeleton extends StatelessWidget {
  const DashboardPanelSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminSkeleton(
      child: Container(
        height: 176,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.border,
          ),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AdminSkeletonBox(
                  width: 38,
                  height: 38,
                  radius: 10,
                ),
                SizedBox(width: 12),
                AdminSkeletonBox(
                  width: 120,
                  height: 14,
                  radius: 7,
                ),
              ],
            ),
            SizedBox(height: 20),
            AdminSkeletonBox(
              width: double.infinity,
              height: 14,
              radius: 7,
            ),
            SizedBox(height: 12),
            AdminSkeletonBox(
              width: 180,
              height: 14,
              radius: 7,
            ),
            SizedBox(height: 12),
            AdminSkeletonBox(
              width: 220,
              height: 14,
              radius: 7,
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardChartSkeleton extends StatelessWidget {
  const DashboardChartSkeleton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AdminSkeleton(
      child: Container(
        height: 260,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                AdminSkeletonBox(
                  width: 3,
                  height: 34,
                  radius: 4,
                ),
                SizedBox(width: 12),
                AdminSkeletonBox(
                  width: 140,
                  height: 14,
                  radius: 7,
                ),
              ],
            ),
            const SizedBox(height: 18),
            Expanded(
              child: AdminSkeletonBox(
                width: double.infinity,
                height: double.infinity,
                radius: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardMetricsSkeleton extends StatelessWidget {
  const DashboardMetricsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1200
            ? 6
            : constraints.maxWidth >= 800
                ? 3
                : 2;

        const gap = 14.0;

        final width =
            (constraints.maxWidth - (gap * (columns - 1))) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: List.generate(
            6,
            (_) => SizedBox(
              width: width,
              child: const DashboardMetricSkeleton(),
            ),
          ),
        );
      },
    );
  }
}

class DashboardChartsSkeleton extends StatelessWidget {
  const DashboardChartsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1000 ? 2 : 1;

        const gap = 16.0;

        final width =
            (constraints.maxWidth - (gap * (columns - 1))) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: List.generate(
            7,
            (_) => SizedBox(
              width: width,
              child: const DashboardChartSkeleton(),
            ),
          ),
        );
      },
    );
  }
}