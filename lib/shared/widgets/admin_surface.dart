import 'package:flutter/material.dart';

import '../../core/theme/admin_motion.dart';
import '../../core/theme/app_theme.dart';

class AdminSurface extends StatefulWidget {
  const AdminSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.onTap,
    this.hoverable = false,
    this.radius = 18,
    this.borderColor,
    this.backgroundColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final bool hoverable;
  final double radius;
  final Color? borderColor;
  final Color? backgroundColor;

  @override
  State<AdminSurface> createState() => _AdminSurfaceState();
}

class _AdminSurfaceState extends State<AdminSurface> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final elevated = widget.hoverable && _hovered;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: widget.onTap == null ? MouseCursor.defer : SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: AdminMotion.normal,
        curve: AdminMotion.ease,
        transform: Matrix4.translationValues(0, elevated ? -3 : 0, 0),
        decoration: BoxDecoration(
          color: widget.backgroundColor ??
              (elevated ? AppColors.surfaceRaised : AppColors.surface),
          borderRadius: BorderRadius.circular(widget.radius),
          border: Border.all(
            color: widget.borderColor ??
                (elevated ? AppColors.borderStrong : AppColors.border),
          ),
          boxShadow: elevated
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.28),
                    blurRadius: 24,
                    offset: const Offset(0, 14),
                  ),
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.035),
                    blurRadius: 28,
                  ),
                ]
              : const [],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(widget.radius),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(widget.radius),
            child: Padding(padding: widget.padding, child: widget.child),
          ),
        ),
      ),
    );
  }
}
