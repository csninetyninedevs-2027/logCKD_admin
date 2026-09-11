import 'package:flutter/material.dart';

abstract final class AdminBreakpoints {
  static const double compact = 720;
  static const double navigation = 980;
  static const double medium = 1100;

  static bool isCompact(BuildContext context) =>
      MediaQuery.sizeOf(context).width < compact;

  static bool isMedium(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= compact && width < medium;
  }

  static bool isExpanded(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= medium;
}

abstract final class AdminResponsive {
  static EdgeInsets pageInsets(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < AdminBreakpoints.compact) {
      return const EdgeInsets.fromLTRB(16, 18, 16, 20);
    }
    if (width < AdminBreakpoints.medium) {
      return const EdgeInsets.fromLTRB(22, 22, 22, 24);
    }
    return const EdgeInsets.fromLTRB(28, 26, 28, 28);
  }

  static double actionWidth(
    BuildContext context, {
    required double maxWidth,
    double additionalInsets = 0,
  }) {
    final horizontalInsets = pageInsets(context).horizontal;
    return (MediaQuery.sizeOf(context).width -
            horizontalInsets -
            additionalInsets)
        .clamp(0, maxWidth)
        .toDouble();
  }
}

class AdminResponsiveHeader extends StatelessWidget {
  const AdminResponsiveHeader({
    super.key,
    required this.heading,
    this.actions = const [],
    this.breakpoint = AdminBreakpoints.compact,
  });

  final Widget heading;
  final List<Widget> actions;
  final double breakpoint;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < breakpoint) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              heading,
              if (actions.isNotEmpty) ...[
                const SizedBox(height: 16),
                Wrap(spacing: 10, runSpacing: 10, children: actions),
              ],
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: heading),
            if (actions.isNotEmpty) ...[
              const SizedBox(width: 24),
              Wrap(spacing: 10, runSpacing: 10, children: actions),
            ],
          ],
        );
      },
    );
  }
}
