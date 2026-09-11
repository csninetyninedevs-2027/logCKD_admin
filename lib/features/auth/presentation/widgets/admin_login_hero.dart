import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/admin_motion.dart';
import '../../../../core/theme/app_theme.dart';

/// Animated, interactive visual for the left side of the admin login screen.
class AdminLoginHero extends StatefulWidget {
  const AdminLoginHero({super.key});

  @override
  State<AdminLoginHero> createState() => _AdminLoginHeroState();
}

class _AdminLoginHeroState extends State<AdminLoginHero>
    with SingleTickerProviderStateMixin {
  late final AnimationController _loop;
  Offset _pointer = Offset.zero;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _loop = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();
  }

  @override
  void dispose() {
    _loop.dispose();
    super.dispose();
  }

  void _trackPointer(PointerHoverEvent event) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || box.size.isEmpty) return;
    final position = box.globalToLocal(event.position);
    setState(() {
      _pointer = Offset(
        (position.dx / box.size.width - .5).clamp(-.5, .5),
        (position.dy / box.size.height - .5).clamp(-.5, .5),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onHover: _trackPointer,
      onExit: (_) => setState(() {
        _hovered = false;
        _pointer = Offset.zero;
      }),
      child: AnimatedScale(
        scale: _hovered ? 1.008 : 1,
        duration: AdminMotion.normal,
        curve: AdminMotion.emphasized,
        child: FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            width: 780,
            height: 610,
            child: AnimatedBuilder(
              animation: _loop,
              builder: (context, _) {
                final angle = _loop.value * math.pi * 2;
                return Transform.translate(
                  offset: Offset(_pointer.dx * 12, _pointer.dy * 8),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _AtmospherePainter(progress: _loop.value),
                        ),
                      ),
                      Positioned(
                        left: 157 - _pointer.dx * 17,
                        top: 111 + math.sin(angle) * 5 - _pointer.dy * 12,
                        child: Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, .0012)
                            ..rotateY(.38)
                            ..rotateZ(-.025),
                          child: const _Dashboard(),
                        ),
                      ),
                      Positioned(
                        left: 68 + _pointer.dx * 23,
                        top: 178 + math.sin(angle + .7) * 10,
                        child: const _FloatingTile(
                          icon: Icons.groups_2_rounded,
                          label: 'Users',
                          size: 76,
                          tilt: -.12,
                          roll: -.018,
                        ),
                      ),
                      Positioned(
                        left: 77 + _pointer.dx * 30,
                        top: 385 + math.sin(angle + 2.1) * 11,
                        child: const _FloatingTile(
                          icon: Icons.monitor_heart_outlined,
                          label: 'Health',
                          size: 82,
                          tilt: -.12,
                          roll: -.018,
                        ),
                      ),
                      Positioned(
                        left: 650 + _pointer.dx * 12,
                        top: 156 + math.sin(angle + 3.2) * 9,
                        child: const _FloatingTile(
                          icon: Icons.shield_outlined,
                          label: 'Secure',
                          size: 72,
                          tilt: .12,
                          roll: .018,
                        ),
                      ),
                      Positioned(
                        left: 650 + _pointer.dx * 12,
                        top: 421 + math.sin(angle + 4.4) * 12,
                        child: const _FloatingTile(
                          icon: Icons.analytics_outlined,
                          label: 'Insights',
                          size: 80,
                          tilt: .12,
                          roll: .018,
                        ),
                      ),
                      Positioned(
                        left: 111,
                        top: 119 + math.cos(angle) * 7,
                        child: const _PulseOrb(size: 18),
                      ),
                      Positioned(
                        left: 690,
                        top: 353 + math.cos(angle + 1.8) * 9,
                        child: const _PulseOrb(size: 12),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _Dashboard extends StatefulWidget {
  const _Dashboard();

  @override
  State<_Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<_Dashboard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        scale: _hovered ? 1.025 : 1,
        duration: AdminMotion.normal,
        curve: AdminMotion.emphasized,
        child: AnimatedContainer(
          duration: AdminMotion.normal,
          width: 470,
          height: 330,
          padding: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryBright.withValues(alpha: .72),
                AppColors.primary.withValues(alpha: .10),
                AppColors.border.withValues(alpha: .4),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(
                  alpha: _hovered ? .24 : .14,
                ),
                blurRadius: _hovered ? 56 : 38,
                spreadRadius: _hovered ? 3 : 0,
                offset: const Offset(0, 24),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: .58),
                blurRadius: 38,
                offset: const Offset(0, 26),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(23),
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFA142126),
                    Color(0xFC0E171B),
                    Color(0xFF0A1013),
                  ],
                ),
              ),
              child: Column(
                children: [
                  const _DashboardHeader(),
                  Divider(
                    height: 1,
                    color: AppColors.border.withValues(alpha: .72),
                  ),
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(15),
                      child: Column(
                        children: [
                          Expanded(
                            flex: 11,
                            child: Row(
                              children: [
                                Expanded(flex: 7, child: _TrendCard()),
                                SizedBox(width: 11),
                                Expanded(flex: 4, child: _RiskCard()),
                              ],
                            ),
                          ),
                          SizedBox(height: 11),
                          Expanded(
                            flex: 10,
                            child: Row(
                              children: [
                                Expanded(flex: 4, child: _MetricCard()),
                                SizedBox(width: 11),
                                Expanded(flex: 5, child: _KidneyCard()),
                                SizedBox(width: 11),
                                Expanded(flex: 4, child: _ActivityCard()),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 43,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            for (final opacity in [.95, .62, .35]) ...[
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryBright.withValues(alpha: opacity),
                  boxShadow: opacity > .9
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: .45),
                            blurRadius: 9,
                          ),
                        ]
                      : null,
                ),
              ),
              const SizedBox(width: 6),
            ],
            const SizedBox(width: 9),
            Container(
              width: 62,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const Spacer(),
            Container(
              width: 64,
              height: 22,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: .08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: .15),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _StatusDot(),
                  SizedBox(width: 6),
                  Text(
                    'LIVE',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      letterSpacing: .8,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 5,
      height: 5,
      decoration: const BoxDecoration(
        color: AppColors.success,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: AppColors.success, blurRadius: 6)],
      ),
    );
  }
}

class _GlassCard extends StatefulWidget {
  const _GlassCard({required this.child});

  final Widget child;

  @override
  State<_GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<_GlassCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: AdminMotion.fast,
        transform: Matrix4.translationValues(0, _hovered ? -3 : 0, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.surfaceHover.withValues(alpha: .88),
              AppColors.surface.withValues(alpha: .78),
            ],
          ),
          border: Border.all(
            color: _hovered
                ? AppColors.primary.withValues(alpha: .52)
                : AppColors.border.withValues(alpha: .78),
          ),
          boxShadow: _hovered
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: .12),
                    blurRadius: 20,
                  ),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: widget.child,
        ),
      ),
    );
  }
}

class _TrendCard extends StatelessWidget {
  const _TrendCard();

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: Stack(
        children: [
          const Positioned.fill(child: CustomPaint(painter: _TrendPainter())),
          Positioned(
            left: 13,
            top: 11,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PATIENT TREND',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    letterSpacing: .8,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Text(
                      '2,486',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 7),
                    Text(
                      '+8.4%',
                      style: TextStyle(
                        color: AppColors.success.withValues(alpha: .9),
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RiskCard extends StatelessWidget {
  const _RiskCard();

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Positioned.fill(child: CustomPaint(painter: _RingPainter())),
          Positioned(
            bottom: 11,
            child: Text(
              'RISK PROFILE',
              style: TextStyle(
                color: AppColors.textMuted.withValues(alpha: .9),
                fontSize: 7,
                fontWeight: FontWeight.w700,
                letterSpacing: .7,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard();

  @override
  Widget build(BuildContext context) {
    return const _GlassCard(
      child: CustomPaint(
        painter: _BarsPainter(values: [.28, .43, .38, .64, .82]),
        child: SizedBox.expand(),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard();

  @override
  Widget build(BuildContext context) {
    return const _GlassCard(
      child: CustomPaint(
        painter: _BarsPainter(values: [.34, .57, .48, .76, .92]),
        child: SizedBox.expand(),
      ),
    );
  }
}

class _KidneyCard extends StatelessWidget {
  const _KidneyCard();

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Positioned.fill(child: CustomPaint(painter: _KidneyPainter())),
          Positioned(
            left: 10,
            top: 9,
            child: Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                color: AppColors.primaryBright,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: AppColors.primary, blurRadius: 8)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingTile extends StatefulWidget {
  const _FloatingTile({
    required this.icon,
    required this.label,
    required this.size,
    required this.tilt,
    required this.roll,
  });

  final IconData icon;
  final String label;
  final double size;
  final double tilt;
  final double roll;

  @override
  State<_FloatingTile> createState() => _FloatingTileState();
}

class _FloatingTileState extends State<_FloatingTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        scale: _hovered ? 1.055 : 1,
        duration: AdminMotion.normal,
        curve: AdminMotion.ease,
        child: AnimatedContainer(
          duration: AdminMotion.normal,
          curve: AdminMotion.ease,
          transformAlignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, .002)
            ..rotateX(_hovered ? -.025 : -.09)
            ..rotateY(widget.tilt * (_hovered ? .45 : 1))
            ..rotateZ(widget.roll * (_hovered ? .45 : 1)),
          width: widget.size,
          height: widget.size,
          foregroundDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.size * .25),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: const [0, .22, .48, 1],
              colors: [
                Colors.white.withValues(alpha: _hovered ? .06 : .025),
                Colors.white.withValues(alpha: .015),
                Colors.transparent,
                AppColors.primary.withValues(alpha: .035),
              ],
            ),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.size * .25),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withValues(alpha: _hovered ? .24 : .14),
                AppColors.surfaceHover.withValues(alpha: .94),
                AppColors.surface.withValues(alpha: .96),
              ],
            ),
            border: Border.all(
              color: AppColors.primaryBright.withValues(
                alpha: _hovered ? .48 : .22,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(
                  alpha: _hovered ? .16 : .06,
                ),
                blurRadius: _hovered ? 22 : 14,
                spreadRadius: _hovered ? 2 : 0,
                offset: const Offset(0, 12),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: .38),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.icon,
                size: widget.size * .35,
                color: AppColors.primaryBright,
              ),
              const SizedBox(height: 6),
              Text(
                widget.label.toUpperCase(),
                style: TextStyle(
                  color: _hovered
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                  fontSize: 7,
                  fontWeight: FontWeight.w700,
                  letterSpacing: .6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PulseOrb extends StatelessWidget {
  const _PulseOrb({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          center: Alignment(-.35, -.35),
          colors: [
            AppColors.textPrimary,
            AppColors.primaryBright,
            AppColors.primaryDark,
          ],
          stops: [0, .24, 1],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: .5),
            blurRadius: 22,
            spreadRadius: 3,
          ),
        ],
      ),
    );
  }
}

class _AtmospherePainter extends CustomPainter {
  const _AtmospherePainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final glowRect = Rect.fromCenter(
      center: Offset(size.width * .48, size.height * .45),
      width: 650,
      height: 510,
    );
    canvas.drawOval(
      glowRect,
      Paint()
        ..shader = RadialGradient(
          colors: [
            AppColors.primary.withValues(alpha: .13),
            AppColors.primaryDeep.withValues(alpha: .05),
            Colors.transparent,
          ],
          stops: const [0, .52, 1],
        ).createShader(glowRect),
    );

    final floor = Rect.fromCenter(
      center: Offset(size.width * .49, size.height * .74),
      width: 590,
      height: 105,
    );
    canvas.drawOval(
      floor,
      Paint()
        ..shader = RadialGradient(
          colors: [
            AppColors.primary.withValues(alpha: .12),
            Colors.transparent,
          ],
        ).createShader(floor),
    );

    final paths = <Path>[
      Path()
        ..moveTo(31, 420)
        ..cubicTo(145, 302, 265, 347, 355, 413)
        ..cubicTo(475, 500, 622, 424, 758, 512),
      Path()
        ..moveTo(18, 464)
        ..cubicTo(150, 348, 247, 420, 368, 468)
        ..cubicTo(520, 528, 650, 505, 775, 572),
    ];

    for (var i = 0; i < paths.length; i++) {
      final path = paths[i];
      canvas.drawPath(
        path,
        Paint()
          ..color = AppColors.primaryBright.withValues(alpha: .16)
          ..style = PaintingStyle.stroke
          ..strokeWidth = i == 0 ? 1.5 : 1
          ..strokeCap = StrokeCap.round,
      );

      final metric = path.computeMetrics().first;
      final phase = [0.0, .29, .53, .76][i];
      // Periodic travel avoids a visible jump when the loop restarts.
      final position = .5 - .5 * math.cos((progress + phase) * math.pi * 2);
      final tangent = metric.getTangentForOffset(metric.length * position);
      if (tangent == null) continue;
      canvas.drawCircle(
        tangent.position,
        10,
        Paint()
          ..color = AppColors.primary.withValues(alpha: .18)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
      canvas.drawCircle(
        tangent.position,
        i == 0 ? 4 : 3,
        Paint()..color = AppColors.primaryBright,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AtmospherePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _TrendPainter extends CustomPainter {
  const _TrendPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = AppColors.border.withValues(alpha: .42)
      ..strokeWidth = .7;
    for (var i = 1; i < 5; i++) {
      final y = size.height * i / 5;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    final line = Path()
      ..moveTo(0, size.height * .78)
      ..cubicTo(
        size.width * .13,
        size.height * .62,
        size.width * .2,
        size.height * .72,
        size.width * .29,
        size.height * .68,
      )
      ..cubicTo(
        size.width * .4,
        size.height * .63,
        size.width * .43,
        size.height * .43,
        size.width * .55,
        size.height * .53,
      )
      ..cubicTo(
        size.width * .7,
        size.height * .67,
        size.width * .75,
        size.height * .25,
        size.width * .88,
        size.height * .36,
      )
      ..cubicTo(
        size.width * .94,
        size.height * .41,
        size.width * .97,
        size.height * .2,
        size.width,
        size.height * .14,
      );
    final fill = Path.from(line)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary.withValues(alpha: .28),
            AppColors.primary.withValues(alpha: .01),
          ],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      line,
      Paint()
        ..color = AppColors.primaryBright
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RingPainter extends CustomPainter {
  const _RingPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * .43);
    final radius = math.min(size.width, size.height) * .25;
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(
      rect,
      0,
      math.pi * 2,
      false,
      Paint()
        ..color = AppColors.border
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10,
    );
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 1.46,
      false,
      Paint()
        ..shader = const SweepGradient(
          colors: [
            AppColors.primaryBright,
            AppColors.primary,
            AppColors.success,
          ],
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round,
    );
    final textPainter = TextPainter(
      text: const TextSpan(
        text: '73%',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, center - Offset(textPainter.width / 2, 7));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BarsPainter extends CustomPainter {
  const _BarsPainter({required this.values});

  final List<double> values;

  @override
  void paint(Canvas canvas, Size size) {
    final slot = size.width / (values.length + 1);
    final width = slot * .52;
    final grid = Paint()
      ..color = AppColors.primary.withValues(alpha: .10)
      ..strokeWidth = .7;
    for (var row = 0; row < 3; row++) {
      final y = size.height - 15 - row * size.height * .23;
      canvas.drawLine(Offset(10, y), Offset(size.width - 10, y), grid);
    }
    for (var i = 0; i < values.length; i++) {
      final height = size.height * .62 * values[i];
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          slot * (i + 1) - width / 2,
          size.height - height - 15,
          width,
          height,
        ),
        const Radius.circular(3),
      );
      canvas.drawRRect(
        rect,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [AppColors.primaryDark, AppColors.primaryBright],
          ).createShader(rect.outerRect),
      );
    }
    final label = TextPainter(
      text: const TextSpan(
        text: 'ACTIVITY',
        style: TextStyle(
          color: AppColors.textMuted,
          fontSize: 7,
          fontWeight: FontWeight.w700,
          letterSpacing: .7,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    label.paint(canvas, const Offset(10, 9));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _KidneyPainter extends CustomPainter {
  const _KidneyPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // A uniform scale keeps the organ silhouettes proportional in the card.
    final scale = math.min(size.width / 150, size.height / 110);
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2 - 3 * scale);
    canvas.scale(scale);

    final outline = Paint()
      ..color = AppColors.primaryBright
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.7
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (final side in [-1.0, 1.0]) {
      canvas.save();
      canvas.scale(side, 1);
      canvas.translate(0, side > 0 ? 3 : -2);

      // Rounded outer cortex with a distinct inward-facing hilar notch.
      final kidney = Path()
        ..moveTo(25, -32)
        ..cubicTo(39, -36, 51, -22, 52, -6)
        ..cubicTo(54, 12, 45, 30, 33, 31)
        ..cubicTo(23, 32, 16, 26, 17, 18)
        ..cubicTo(17, 12, 26, 10, 28, 4)
        ..cubicTo(30, -2, 22, -4, 18, -9)
        ..cubicTo(11, -18, 15, -29, 25, -32)
        ..close();

      canvas.drawPath(
        kidney,
        Paint()
          ..color = AppColors.primary.withValues(alpha: .15)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
      canvas.drawPath(
        kidney,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              AppColors.primary.withValues(alpha: .24),
              AppColors.primaryDeep.withValues(alpha: .08),
            ],
          ).createShader(const Rect.fromLTWH(12, -36, 44, 70)),
      );
      canvas.drawPath(kidney, outline);

      // Each renal pelvis drains into its own curved ureter.
      final ureter = Path()
        ..moveTo(24, -2)
        ..cubicTo(14, -1, 11, 5, 13, 13)
        ..cubicTo(16, 24, 10, 33, 11, 42);
      canvas.drawPath(
        ureter,
        Paint()
          ..color = AppColors.primaryBright.withValues(alpha: .78)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round,
      );
      canvas.restore();
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
