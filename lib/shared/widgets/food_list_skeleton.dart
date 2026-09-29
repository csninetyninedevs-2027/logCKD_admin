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
                    child: const Row(
                      children: [
                        AdminSkeletonBox(
                          width: 220,
                          height: 12,
                          radius: 6,
                        ),
                        SizedBox(width: 24),
                        AdminSkeletonBox(
                          width: 110,
                          height: 12,
                          radius: 6,
                        ),
                        Spacer(),
                        AdminSkeletonBox(
                          width: 70,
                          height: 12,
                          radius: 6,
                        ),
                        SizedBox(width: 24),
                        AdminSkeletonBox(
                          width: 70,
                          height: 12,
                          radius: 6,
                        ),
                        SizedBox(width: 24),
                        AdminSkeletonBox(
                          width: 80,
                          height: 12,
                          radius: 6,
                        ),
                        SizedBox(width: 24),
                        AdminSkeletonBox(
                          width: 65,
                          height: 12,
                          radius: 6,
                        ),
                        SizedBox(width: 24),
                        AdminSkeletonBox(
                          width: 70,
                          height: 12,
                          radius: 6,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 8,
                      ),
                      itemCount: 9,
                      separatorBuilder: (_, index) => Divider(
                        height: 1,
                        color: AppColors.border,
                      ),
                      itemBuilder: (context, index) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 15,
                          ),
                          child: _FoodSkeletonRow(),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const _FoodPaginationSkeleton(),
      ],
    );
  }
}

class _FoodSkeletonRow extends StatelessWidget {
  const _FoodSkeletonRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const AdminSkeletonBox(
          width: 280,
          height: 14,
          radius: 7,
        ),
        const SizedBox(width: 20),
        const AdminSkeletonBox(
          width: 150,
          height: 14,
          radius: 7,
        ),
        const Spacer(),
        const AdminSkeletonBox(
          width: 82,
          height: 14,
          radius: 7,
        ),
        const SizedBox(width: 28),
        const AdminSkeletonBox(
          width: 82,
          height: 14,
          radius: 7,
        ),
        const SizedBox(width: 28),
        const AdminSkeletonBox(
          width: 78,
          height: 24,
          radius: 12,
        ),
        const SizedBox(width: 28),
        const AdminSkeletonBox(
          width: 70,
          height: 24,
          radius: 12,
        ),
        const SizedBox(width: 28),
        const AdminSkeletonBox(
          width: 92,
          height: 28,
          radius: 8,
        ),
      ],
    );
  }
}

class _FoodPaginationSkeleton extends StatelessWidget {
  const _FoodPaginationSkeleton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Row(
        children: const [
          AdminSkeletonBox(
            width: 135,
            height: 11,
            radius: 6,
          ),
          Spacer(),
          AdminSkeletonBox(
            width: 78,
            height: 11,
            radius: 6,
          ),
          SizedBox(width: 16),
          AdminSkeletonBox(
            width: 32,
            height: 32,
            radius: 8,
          ),
          SizedBox(width: 8),
          AdminSkeletonBox(
            width: 70,
            height: 11,
            radius: 6,
          ),
          SizedBox(width: 8),
          AdminSkeletonBox(
            width: 32,
            height: 32,
            radius: 8,
          ),
        ],
      ),
    );
  }
}
