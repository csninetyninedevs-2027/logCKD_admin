import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import 'admin_skeleton.dart';

class UserDetailSkeleton extends StatelessWidget {
  const UserDetailSkeleton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const UserDetailIdentitySkeleton(),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 1120
                  ? 3
                  : constraints.maxWidth >= 720
                      ? 2
                      : 1;

              const gap = 16.0;
              final width =
                  (constraints.maxWidth - gap * (columns - 1)) / columns;

              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: List.generate(
                  3,
                  (_) => SizedBox(
                    width: width,
                    child: const UserDetailSignalSkeleton(),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          const UserDetailHealthSkeleton(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class UserDetailIdentitySkeleton extends StatelessWidget {
  const UserDetailIdentitySkeleton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AdminSkeleton(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.border,
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 760;

            final profile = Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AdminSkeletonBox(
                  width: 62,
                  height: 62,
                  radius: 19,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          AdminSkeletonBox(
                            width: 180,
                            height: 24,
                            radius: 7,
                          ),
                          SizedBox(width: 10),
                          AdminSkeletonBox(
                            width: 68,
                            height: 24,
                            radius: 8,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const AdminSkeletonBox(
                        width: 220,
                        height: 11,
                        radius: 6,
                      ),
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 28,
                        runSpacing: 16,
                        children: const [
                          _UserDetailInfoSkeleton(
                            width: 90,
                            valueWidth: 70,
                          ),
                          _UserDetailInfoSkeleton(
                            width: 100,
                            valueWidth: 150,
                          ),
                          _UserDetailInfoSkeleton(
                            width: 95,
                            valueWidth: 170,
                          ),
                          _UserDetailInfoSkeleton(
                            width: 115,
                            valueWidth: 105,
                          ),
                          _UserDetailInfoSkeleton(
                            width: 85,
                            valueWidth: 70,
                          ),
                          _UserDetailInfoSkeleton(
                            width: 75,
                            valueWidth: 100,
                          ),
                          _UserDetailInfoSkeleton(
                            width: 95,
                            valueWidth: 100,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );

            const action = AdminSkeletonBox(
              width: 130,
              height: 40,
              radius: 10,
            );

            if (compact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  profile,
                  const SizedBox(height: 20),
                  action,
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: profile),
                const SizedBox(width: 24),
                action,
              ],
            );
          },
        ),
      ),
    );
  }
}

class _UserDetailInfoSkeleton extends StatelessWidget {
  const _UserDetailInfoSkeleton({
    required this.width,
    required this.valueWidth,
  });

  final double width;
  final double valueWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width + 80,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdminSkeletonBox(
            width: width,
            height: 8,
            radius: 4,
          ),
          const SizedBox(height: 6),
          AdminSkeletonBox(
            width: valueWidth,
            height: 12,
            radius: 6,
          ),
        ],
      ),
    );
  }
}

class UserDetailSignalSkeleton extends StatelessWidget {
  const UserDetailSignalSkeleton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AdminSkeleton(
      child: Container(
        height: 190,
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
                  width: 34,
                  height: 34,
                  radius: 11,
                ),
                SizedBox(width: 10),
                AdminSkeletonBox(
                  width: 105,
                  height: 9,
                  radius: 5,
                ),
              ],
            ),
            SizedBox(height: 17),
            AdminSkeletonBox(
              width: 150,
              height: 18,
              radius: 7,
            ),
            SizedBox(height: 8),
            AdminSkeletonBox(
              width: 90,
              height: 11,
              radius: 6,
            ),
            Spacer(),
            AdminSkeletonBox(
              width: 175,
              height: 10,
              radius: 5,
            ),
            SizedBox(height: 8),
            AdminSkeletonBox(
              width: 125,
              height: 10,
              radius: 5,
            ),
            SizedBox(height: 8),
            AdminSkeletonBox(
              width: 145,
              height: 10,
              radius: 5,
            ),
          ],
        ),
      ),
    );
  }
}

class UserDetailHealthSkeleton extends StatelessWidget {
  const UserDetailHealthSkeleton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AdminSkeleton(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
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
                  width: 18,
                  height: 18,
                  radius: 5,
                ),
                SizedBox(width: 9),
                AdminSkeletonBox(
                  width: 165,
                  height: 14,
                  radius: 7,
                ),
              ],
            ),
            const SizedBox(height: 14),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 760 ? 3 : 1;
                const gap = 28.0;
                final width =
                    (constraints.maxWidth - gap * (columns - 1)) / columns;

                return Wrap(
                  spacing: gap,
                  runSpacing: 14,
                  children: List.generate(
                    5,
                    (_) => SizedBox(
                      width: columns == 1 ? constraints.maxWidth : width,
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AdminSkeletonBox(
                            width: 100,
                            height: 8,
                            radius: 4,
                          ),
                          SizedBox(height: 6),
                          AdminSkeletonBox(
                            width: 150,
                            height: 12,
                            radius: 6,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
