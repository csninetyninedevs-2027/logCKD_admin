import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'admin_responsive.dart';

class AdminPageHeader extends StatelessWidget {
  const AdminPageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.eyebrow,
    this.actions = const [],
  });

  final String title;
  final String subtitle;
  final String? eyebrow;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final heading = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (eyebrow != null) ...[
              Text(
                eyebrow!.toUpperCase(),
                style: const TextStyle(
                  color: AppColors.primaryBright,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 8),
            ],
            Text(title, style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            ),
          ],
        );

        return AdminResponsiveHeader(
          breakpoint: AdminBreakpoints.compact,
          heading: heading,
          actions: actions,
        );
      },
    );
  }
}
