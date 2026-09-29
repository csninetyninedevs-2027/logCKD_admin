import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import 'admin_skeleton.dart';

class SystemStatusSkeleton extends StatelessWidget {
  const SystemStatusSkeleton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _StatusSummarySkeleton(),
          SizedBox(height: 14),
          _RequestFlowSkeleton(),
          SizedBox(height: 14),
          _InspectorSkeleton(),
          SizedBox(height: 10),
          _FooterSkeleton(),
        ],
      ),
    );
  }
}

class _StatusSummarySkeleton extends StatelessWidget {
  const _StatusSummarySkeleton();

  @override
  Widget build(BuildContext context) {
    return AdminSkeleton(
      child: Wrap(
        spacing: 22,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Container(
            height: 30,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AdminSkeletonBox(width: 7, height: 7, radius: 4),
                SizedBox(width: 8),
                AdminSkeletonBox(width: 125, height: 10, radius: 5),
              ],
            ),
          ),
          const _SummarySkeleton(width: 70),
          const _SummarySkeleton(width: 55),
          const _SummarySkeleton(width: 50),
          const _SummarySkeleton(width: 75),
        ],
      ),
    );
  }
}

class _SummarySkeleton extends StatelessWidget {
  const _SummarySkeleton({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AdminSkeletonBox(width: width, height: 8, radius: 4),
        const SizedBox(width: 7),
        const AdminSkeletonBox(width: 24, height: 11, radius: 5),
      ],
    );
  }
}

class _RequestFlowSkeleton extends StatelessWidget {
  const _RequestFlowSkeleton();

  @override
  Widget build(BuildContext context) {
    return AdminSkeleton(
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 860) {
            return const _CompactFlowSkeleton();
          }

          return Container(
            height: 540,
            decoration: BoxDecoration(
              color: const Color(0xFF0B0F12),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.borderStrong),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                const Positioned.fill(
                  child: CustomPaint(
                    painter: _GridSkeletonPainter(),
                  ),
                ),
                Positioned(
                  left: 44,
                  top: 224,
                  width: 260,
                  height: 92,
                  child: const _MonitorSkeleton(),
                ),
                Positioned(
                  right: 44,
                  top: 72,
                  width: 360,
                  height: 96,
                  child: const _ServiceNodeSkeleton(),
                ),
                Positioned(
                  right: 44,
                  top: 222,
                  width: 360,
                  height: 96,
                  child: const _ServiceNodeSkeleton(),
                ),
                Positioned(
                  right: 44,
                  top: 372,
                  width: 360,
                  height: 96,
                  child: const _ServiceNodeSkeleton(),
                ),
                const Positioned(
                  left: 22,
                  top: 18,
                  child: Row(
                    children: [
                      AdminSkeletonBox(width: 13, height: 13, radius: 4),
                      SizedBox(width: 6),
                      AdminSkeletonBox(width: 110, height: 8, radius: 4),
                    ],
                  ),
                ),
                const Positioned(
                  right: 22,
                  top: 18,
                  child: AdminSkeletonBox(
                    width: 82,
                    height: 25,
                    radius: 99,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MonitorSkeleton extends StatelessWidget {
  const _MonitorSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xF213181B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.borderStrong,
        ),
      ),
      child: const Row(
        children: [
          AdminSkeletonBox(width: 46, height: 46, radius: 13),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AdminSkeletonBox(width: 105, height: 12, radius: 6),
                SizedBox(height: 7),
                AdminSkeletonBox(width: 165, height: 8, radius: 4),
                SizedBox(height: 5),
                AdminSkeletonBox(width: 125, height: 8, radius: 4),
              ],
            ),
          ),
          SizedBox(width: 8),
          AdminSkeletonBox(width: 30, height: 20, radius: 5),
        ],
      ),
    );
  }
}

class _ServiceNodeSkeleton extends StatelessWidget {
  const _ServiceNodeSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      decoration: BoxDecoration(
        color: const Color(0xF5181D20),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.borderStrong,
        ),
      ),
      child: const Row(
        children: [
          AdminSkeletonBox(width: 48, height: 48, radius: 14),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AdminSkeletonBox(width: 115, height: 12, radius: 6),
                    Spacer(),
                    AdminSkeletonBox(width: 30, height: 20, radius: 5),
                  ],
                ),
                SizedBox(height: 9),
                Row(
                  children: [
                    AdminSkeletonBox(width: 65, height: 8, radius: 4),
                    SizedBox(width: 8),
                    Expanded(
                      child: AdminSkeletonBox(
                        width: double.infinity,
                        height: 8,
                        radius: 4,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
          AdminSkeletonBox(width: 18, height: 18, radius: 5),
        ],
      ),
    );
  }
}

class _CompactFlowSkeleton extends StatelessWidget {
  const _CompactFlowSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0B0F12),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.borderStrong),
      ),
      child: Column(
        children: [
          const SizedBox(
            height: 86,
            child: _MonitorSkeleton(),
          ),
          const SizedBox(height: 22),
          const SizedBox(
            height: 92,
            child: _ServiceNodeSkeleton(),
          ),
          const SizedBox(height: 22),
          const SizedBox(
            height: 92,
            child: _ServiceNodeSkeleton(),
          ),
          const SizedBox(height: 22),
          const SizedBox(
            height: 92,
            child: _ServiceNodeSkeleton(),
          ),
        ],
      ),
    );
  }
}

class _InspectorSkeleton extends StatelessWidget {
  const _InspectorSkeleton();

  @override
  Widget build(BuildContext context) {
    return AdminSkeleton(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderStrong),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AdminSkeletonBox(
                        width: 150,
                        height: 16,
                        radius: 7,
                      ),
                      SizedBox(height: 7),
                      AdminSkeletonBox(
                        width: 290,
                        height: 9,
                        radius: 5,
                      ),
                    ],
                  ),
                ),
                AdminSkeletonBox(
                  width: 70,
                  height: 25,
                  radius: 99,
                ),
              ],
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final stacked = constraints.maxWidth < 760;

                final left = const Column(
                  children: [
                    _DarkFieldSkeleton(),
                    SizedBox(height: 10),
                    _DarkFieldSkeleton(),
                  ],
                );

                final right = Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(
                    6,
                    (_) => const _MetricSkeleton(),
                  ),
                );

                if (stacked) {
                  return Column(
                    children: [
                      left,
                      const SizedBox(height: 12),
                      right,
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: left),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: right,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            const Row(
              children: [
                AdminSkeletonBox(width: 13, height: 13, radius: 4),
                SizedBox(width: 6),
                AdminSkeletonBox(width: 185, height: 8, radius: 4),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DarkFieldSkeleton extends StatelessWidget {
  const _DarkFieldSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 11),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        children: [
          AdminSkeletonBox(width: 14, height: 14, radius: 4),
          SizedBox(width: 8),
          Expanded(
            child: AdminSkeletonBox(
              width: double.infinity,
              height: 9,
              radius: 5,
            ),
          ),
          SizedBox(width: 8),
          AdminSkeletonBox(width: 13, height: 13, radius: 4),
        ],
      ),
    );
  }
}

class _MetricSkeleton extends StatelessWidget {
  const _MetricSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 122,
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.backgroundRaised,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdminSkeletonBox(width: 55, height: 7, radius: 4),
          SizedBox(height: 6),
          AdminSkeletonBox(width: 72, height: 10, radius: 5),
        ],
      ),
    );
  }
}

class _FooterSkeleton extends StatelessWidget {
  const _FooterSkeleton();

  @override
  Widget build(BuildContext context) {
    return AdminSkeleton(
      child: const Row(
        children: [
          AdminSkeletonBox(width: 13, height: 13, radius: 4),
          SizedBox(width: 7),
          AdminSkeletonBox(width: 260, height: 8, radius: 4),
        ],
      ),
    );
  }
}

class _GridSkeletonPainter extends CustomPainter {
  const _GridSkeletonPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.textMuted.withValues(alpha: .10);

    const spacing = 24.0;

    for (double x = 12; x < size.width; x += spacing) {
      for (double y = 12; y < size.height; y += spacing) {
        canvas.drawCircle(
          Offset(x, y),
          .75,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GridSkeletonPainter oldDelegate) {
    return false;
  }
}
