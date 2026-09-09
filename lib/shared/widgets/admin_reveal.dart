import 'package:flutter/material.dart';

import '../../core/theme/admin_motion.dart';

class AdminReveal extends StatefulWidget {
  const AdminReveal({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.offset = const Offset(0, 14),
  });

  final Widget child;
  final Duration delay;
  final Offset offset;

  @override
  State<AdminReveal> createState() => _AdminRevealState();
}

class _AdminRevealState extends State<AdminReveal> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(widget.delay, () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _visible ? 1 : 0,
      duration: AdminMotion.slow,
      curve: AdminMotion.emphasized,
      child: AnimatedSlide(
        offset: _visible ? Offset.zero : widget.offset,
        duration: AdminMotion.slow,
        curve: AdminMotion.emphasized,
        child: widget.child,
      ),
    );
  }
}
