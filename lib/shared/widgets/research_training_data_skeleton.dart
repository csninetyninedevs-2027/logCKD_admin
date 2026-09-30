import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'admin_skeleton.dart';

class ResearchTrainingDataSkeleton extends StatelessWidget {
  const ResearchTrainingDataSkeleton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _DatasetSkeletonCard(),
        SizedBox(height: 10),
        _DatasetSkeletonCard(),
        SizedBox(height: 10),
        _DatasetSkeletonCard(),
      ],
    );
  }
}

class _DatasetSkeletonCard extends StatelessWidget {
  const _DatasetSkeletonCard();

  @override
  Widget build(BuildContext context) {
    return AdminSkeleton(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(
            alpha: .62,
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.border,
          ),
        ),
        child: LayoutBuilder(
          builder: (
            context,
            constraints,
          ) {
            final compact =
                constraints.maxWidth < 760;

            final info = Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const AdminSkeletonBox(
                  width: 42,
                  height: 42,
                  radius: 11,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Flexible(
                            child: AdminSkeletonBox(
                              height: 14,
                              radius: 7,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const AdminSkeletonBox(
                            width: 58,
                            height: 20,
                            radius: 10,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Wrap(
                        spacing: 12,
                        runSpacing: 7,
                        children: [
                          AdminSkeletonBox(
                            width: 110,
                            height: 10,
                            radius: 5,
                          ),
                          AdminSkeletonBox(
                            width: 70,
                            height: 10,
                            radius: 5,
                          ),
                          AdminSkeletonBox(
                            width: 55,
                            height: 10,
                            radius: 5,
                          ),
                          AdminSkeletonBox(
                            width: 90,
                            height: 10,
                            radius: 5,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );

            final actions = const Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                AdminSkeletonBox(
                  width: 58,
                  height: 34,
                  radius: 10,
                ),
                AdminSkeletonBox(
                  width: 82,
                  height: 34,
                  radius: 10,
                ),
                AdminSkeletonBox(
                  width: 76,
                  height: 34,
                  radius: 10,
                ),
              ],
            );

            if (compact) {
              return Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  info,
                  const SizedBox(height: 14),
                  actions,
                ],
              );
            }

            return Row(
              children: [
                Expanded(
                  child: info,
                ),
                const SizedBox(width: 15),
                actions,
              ],
            );
          },
        ),
      ),
    );
  }
}