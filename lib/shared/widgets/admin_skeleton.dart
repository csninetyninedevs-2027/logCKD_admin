import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class AdminSkeleton extends StatefulWidget {
  const AdminSkeleton({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<AdminSkeleton> createState() => _AdminSkeletonState();
}

class _AdminSkeletonState extends State<AdminSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(-1 + (_controller.value * 2), 0),
              end: Alignment(1 + (_controller.value * 2), 0),
              colors: [
                AppColors.surfaceRaised,
                AppColors.surfaceSoft,
                AppColors.primary.withValues(alpha: 0.35),
                AppColors.surfaceSoft,
                AppColors.surfaceRaised,
              ],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: widget.child,
        );
      },
    );
  }
}


/// Basic skeleton block
class AdminSkeletonBox extends StatelessWidget {
  const AdminSkeletonBox({
    super.key,
    this.width,
    this.height,
    this.radius = 14,
  });

  final double? width;
  final double? height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.12),
        ),
      ),
    );
  }
}


/// Text placeholder skeleton
class AdminSkeletonText extends StatelessWidget {
  const AdminSkeletonText({
    super.key,
    this.width = 120,
    this.height = 14,
  });

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return AdminSkeleton(
      child: AdminSkeletonBox(
        width: width,
        height: height,
        radius: 8,
      ),
    );
  }
}


/// Card placeholder
class AdminSkeletonCard extends StatelessWidget {
  const AdminSkeletonCard({
    super.key,
    this.height = 160,
  });

  final double height;

  @override
  Widget build(BuildContext context) {
    return AdminSkeleton(
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.12),
          ),
        ),
      ),
    );
  }
}


/// Stat card placeholder
class AdminSkeletonStatCard extends StatelessWidget {
  const AdminSkeletonStatCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AdminSkeleton(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.12),
          ),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AdminSkeletonBox(
              width: 80,
              height: 12,
              radius: 6,
            ),
            SizedBox(height: 18),
            AdminSkeletonBox(
              width: 120,
              height: 32,
              radius: 8,
            ),
          ],
        ),
      ),
    );
  }
}


/// Table row placeholder
class AdminSkeletonTableRow extends StatelessWidget {
  const AdminSkeletonTableRow({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AdminSkeleton(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 12,
        ),
        child: Row(
          children: const [
            AdminSkeletonBox(
              width: 36,
              height: 36,
              radius: 18,
            ),
            SizedBox(width: 14),
            Expanded(
              child: AdminSkeletonBox(
                height: 14,
                radius: 7,
              ),
            ),
            SizedBox(width: 20),
            AdminSkeletonBox(
              width: 80,
              height: 14,
              radius: 7,
            ),
          ],
        ),
      ),
    );
  }
}