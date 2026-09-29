import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/admin_skeleton.dart';

class UserListSkeleton extends StatelessWidget {
  const UserListSkeleton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdminSkeleton(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 15,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.border,
              ),
            ),
            child: Wrap(
              spacing: 18,
              runSpacing: 14,
              children: List.generate(
                5,
                (_) => const _MetricSkeleton(),
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        Expanded(
          child: AdminSkeleton(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppColors.border,
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    child: Row(
                      children: const [
                        AdminSkeletonBox(
                          width: 150,
                          height: 14,
                          radius: 7,
                        ),
                        Spacer(),
                        AdminSkeletonBox(
                          width: 90,
                          height: 14,
                          radius: 7,
                        ),
                      ],
                    ),
                  ),

                  Divider(
                    height: 1,
                    color: AppColors.border,
                  ),

                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: 8,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return const AdminSkeletonTableRow();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MetricSkeleton extends StatelessWidget {
  const _MetricSkeleton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: Row(
        children: const [
          AdminSkeletonBox(
            width: 3,
            height: 32,
            radius: 99,
          ),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AdminSkeletonBox(
                width: 70,
                height: 22,
                radius: 6,
              ),
              SizedBox(height: 6),
              AdminSkeletonBox(
                width: 100,
                height: 9,
                radius: 5,
              ),
            ],
          ),
        ],
      ),
    );
  }
}