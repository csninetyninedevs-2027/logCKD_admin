import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import 'admin_skeleton.dart';

class FoodListSkeleton extends StatelessWidget {
  const FoodListSkeleton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: AdminSkeleton(
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  Container(
                    height: 54,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceRaised,
                      border: Border(
                        bottom: BorderSide(
                          color: AppColors.border,
                        ),
                      ),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        const baseWidth = 805.0;

                        final widthScale =
                            (constraints.maxWidth / baseWidth)
                                .clamp(0.0, 1.0);

                        double w(double value) =>
                            value * widthScale;

                        return Row(
                          children: [
                            AdminSkeletonBox(
                              width: w(220),
                              height: 12,
                              radius: 6,
                            ),
                            SizedBox(
                              width: w(24),
                            ),
                            AdminSkeletonBox(
                              width: w(110),
                              height: 12,
                              radius: 6,
                            ),
                            const Spacer(),
                            AdminSkeletonBox(
                              width: w(70),
                              height: 12,
                              radius: 6,
                            ),
                            SizedBox(
                              width: w(24),
                            ),
                            AdminSkeletonBox(
                              width: w(70),
                              height: 12,
                              radius: 6,
                            ),
                            SizedBox(
                              width: w(24),
                            ),
                            AdminSkeletonBox(
                              width: w(80),
                              height: 12,
                              radius: 6,
                            ),
                            SizedBox(
                              width: w(24),
                            ),
                            AdminSkeletonBox(
                              width: w(65),
                              height: 12,
                              radius: 6,
                            ),
                            SizedBox(
                              width: w(24),
                            ),
                            AdminSkeletonBox(
                              width: w(70),
                              height: 12,
                              radius: 6,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 8,
                      ),
                      itemCount: 9,
                      separatorBuilder: (_, index) =>
                          Divider(
                        height: 1,
                        color: AppColors.border,
                      ),
                      itemBuilder: (
                        context,
                        index,
                      ) {
                        return const Padding(
                          padding:
                              EdgeInsets.symmetric(
                            vertical: 15,
                          ),
                          child:
                              _FoodSkeletonRow(),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 12,
        ),
        const _FoodPaginationSkeleton(),
      ],
    );
  }
}

class _FoodSkeletonRow extends StatelessWidget {
  const _FoodSkeletonRow();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const baseWidth = 966.0;

        final widthScale =
            (constraints.maxWidth / baseWidth)
                .clamp(0.0, 1.0);

        double w(double value) =>
            value * widthScale;

        return Row(
          children: [
            AdminSkeletonBox(
              width: w(280),
              height: 14,
              radius: 7,
            ),
            SizedBox(
              width: w(20),
            ),
            AdminSkeletonBox(
              width: w(150),
              height: 14,
              radius: 7,
            ),
            const Spacer(),
            AdminSkeletonBox(
              width: w(82),
              height: 14,
              radius: 7,
            ),
            SizedBox(
              width: w(28),
            ),
            AdminSkeletonBox(
              width: w(82),
              height: 14,
              radius: 7,
            ),
            SizedBox(
              width: w(28),
            ),
            AdminSkeletonBox(
              width: w(78),
              height: 24,
              radius: 12,
            ),
            SizedBox(
              width: w(28),
            ),
            AdminSkeletonBox(
              width: w(70),
              height: 24,
              radius: 12,
            ),
            SizedBox(
              width: w(28),
            ),
            AdminSkeletonBox(
              width: w(92),
              height: 28,
              radius: 8,
            ),
          ],
        );
      },
    );
  }
}

class _FoodPaginationSkeleton
    extends StatelessWidget {
  const _FoodPaginationSkeleton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: LayoutBuilder(
        builder: (context, constraints) {
          const baseWidth = 379.0;

          final widthScale =
              (constraints.maxWidth / baseWidth)
                  .clamp(0.0, 1.0);

          double w(double value) =>
              value * widthScale;

          return Row(
            children: [
              AdminSkeletonBox(
                width: w(135),
                height: 11,
                radius: 6,
              ),
              const Spacer(),
              AdminSkeletonBox(
                width: w(78),
                height: 11,
                radius: 6,
              ),
              SizedBox(
                width: w(16),
              ),
              AdminSkeletonBox(
                width: w(32),
                height: 32,
                radius: 8,
              ),
              SizedBox(
                width: w(8),
              ),
              AdminSkeletonBox(
                width: w(70),
                height: 11,
                radius: 6,
              ),
              SizedBox(
                width: w(8),
              ),
              AdminSkeletonBox(
                width: w(32),
                height: 32,
                radius: 8,
              ),
            ],
          );
        },
      ),
    );
  }
}