import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import 'admin_skeleton.dart';

class FacilityListSkeleton extends StatelessWidget {
  const FacilityListSkeleton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AdminSkeleton(
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: constraints.maxWidth < 980
                      ? 980
                      : constraints.maxWidth,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const _FacilityHeaderSkeleton(),

                      for (int i = 0; i < 10; i++)
                        const _FacilitySkeletonRow(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FacilityHeaderSkeleton extends StatelessWidget {
  const _FacilityHeaderSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surfaceRaised,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
          ),
        ),
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 60,
            child: AdminSkeletonBox(
              width: 20,
              height: 11,
              radius: 5,
            ),
          ),
          SizedBox(
            width: 210,
            child: AdminSkeletonBox(
              width: 55,
              height: 11,
              radius: 5,
            ),
          ),
          SizedBox(
            width: 150,
            child: AdminSkeletonBox(
              width: 75,
              height: 11,
              radius: 5,
            ),
          ),
          SizedBox(
            width: 190,
            child: AdminSkeletonBox(
              width: 125,
              height: 11,
              radius: 5,
            ),
          ),
          SizedBox(
            width: 110,
            child: AdminSkeletonBox(
              width: 55,
              height: 11,
              radius: 5,
            ),
          ),
          SizedBox(
            width: 120,
            child: AdminSkeletonBox(
              width: 70,
              height: 11,
              radius: 5,
            ),
          ),
        ],
      ),
    );
  }
}

class _FacilitySkeletonRow extends StatelessWidget {
  const _FacilitySkeletonRow();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
          ),
        ),
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 60,
            child: AdminSkeletonBox(
              width: 20,
              height: 11,
              radius: 5,
            ),
          ),
          SizedBox(
            width: 210,
            child: AdminSkeletonBox(
              width: 155,
              height: 13,
              radius: 6,
            ),
          ),
          SizedBox(
            width: 150,
            child: AdminSkeletonBox(
              width: 105,
              height: 13,
              radius: 6,
            ),
          ),
          SizedBox(
            width: 190,
            child: AdminSkeletonBox(
              width: 135,
              height: 13,
              radius: 6,
            ),
          ),
          SizedBox(
            width: 110,
            child: AdminSkeletonBox(
              width: 22,
              height: 22,
              radius: 11,
            ),
          ),
          SizedBox(
            width: 120,
            child: Row(
              children: [
                AdminSkeletonBox(
                  width: 32,
                  height: 32,
                  radius: 9,
                ),
                SizedBox(width: 8),
                AdminSkeletonBox(
                  width: 32,
                  height: 32,
                  radius: 9,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}