import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class AdminLoginHero extends StatefulWidget {
  const AdminLoginHero({super.key});

  @override
  State<AdminLoginHero> createState() => _AdminLoginHeroState();
}

class _AdminLoginHeroState extends State<AdminLoginHero>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Offset _pointer = Offset.zero;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (event) {
        final box = context.findRenderObject() as RenderBox?;
        if (box == null || box.size.isEmpty) return;

        final local = box.globalToLocal(event.position);
        final dx = (local.dx / box.size.width - .5).clamp(-.5, .5).toDouble();
        final dy = (local.dy / box.size.height - .5).clamp(-.5, .5).toDouble();

        setState(() => _pointer = Offset(dx, dy));
      },
      onExit: (_) => setState(() => _pointer = Offset.zero),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const _HeroBackdrop(),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final t = _controller.value * math.pi * 2;
                final float = math.sin(t) * 7;
                final pulse = 1 + math.sin(t * .7) * .012;

                return Stack(
                  children: [
                    Positioned(
                      left: 34 + _pointer.dx * 18,
                      top: 38 + _pointer.dy * 14,
                      child: const _SmallLabel(
                        icon: Icons.favorite_outline_rounded,
                        text: 'PREVENTION / AWARENESS',
                      ),
                    ),
                    Positioned(
                      right: 34 - _pointer.dx * 18,
                      top: 36 - _pointer.dy * 12,
                      child: const _StatusPill(),
                    ),
                    Positioned.fill(
                      child: Transform.translate(
                        offset: Offset(
                          _pointer.dx * 22,
                          float + _pointer.dy * 12,
                        ),
                        child: Transform.scale(
                          scale: pulse,
                          child: const Center(
                            child: _ClinicComposition(),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 56 - _pointer.dx * 28,
                      bottom: 92 - _pointer.dy * 18,
                      child: Transform.translate(
                        offset: Offset(0, -float * .35),
                        child: const _LifestyleOrb(),
                      ),
                    ),
                  ],
                );
              },
            ),
            Positioned(
              left: 38,
              right: 38,
              bottom: 34,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Care infrastructure,\nseen as a system.',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontSize: 42,
                          height: 1.02,
                          letterSpacing: -1.7,
                        ),
                  ),
                  const SizedBox(height: 12),
                  ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 500,
                  ),
                  child: Text(
                    'Administrative visibility for user health signals, facilities, food data, regional reach, and service reliability.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12.5,
                      height: 1.55,
                    ),
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

class _HeroBackdrop extends StatelessWidget {
  const _HeroBackdrop();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF0A0E10),
        border: Border.all(color: AppColors.borderStrong),
        borderRadius: BorderRadius.circular(28),
      ),
      child: CustomPaint(
        painter: _HeroGridPainter(),
      ),
    );
  }
}

class _HeroGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: .024)
      ..strokeWidth = .7;

    const gap = 29.0;
    for (double x = 0; x < size.width; x += gap) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += gap) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    final tealGlow = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0x5538B9C7), Color(0x0010191B)],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * .18, size.height * .12),
          radius: 270,
        ),
      );
    canvas.drawCircle(
      Offset(size.width * .18, size.height * .12),
      270,
      tealGlow,
    );

    final warmGlow = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0x2CE89476), Color(0x0010191B)],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * .88, size.height * .31),
          radius: 230,
        ),
      );
    canvas.drawCircle(
      Offset(size.width * .88, size.height * .31),
      230,
      warmGlow,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ClinicComposition extends StatelessWidget {
  const _ClinicComposition();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 500,
      height: 390,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 350,
            height: 350,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.primary.withValues(alpha: .15),
                  AppColors.primary.withValues(alpha: .035),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Transform.translate(
            offset: const Offset(18, -4),
            child: Transform.rotate(
              angle: -.018,
              child: CustomPaint(
                size: const Size(350, 270),
                painter: _ClinicPainter(),
              ),
            ),
          ),
          Positioned(
            left: 48,
            bottom: 62,
            child: Container(
              width: 112,
              height: 112,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryBright.withValues(alpha: .94),
                    AppColors.primaryDark.withValues(alpha: .78),
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: .20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: .20),
                    blurRadius: 30,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: const Icon(
                Icons.directions_run_rounded,
                size: 56,
                color: Color(0xFF061012),
              ),
            ),
          ),
          Positioned(
            right: 42,
            top: 82,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surfaceSoft.withValues(alpha: .90),
                border: Border.all(color: AppColors.borderStrong),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .24),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.monitor_heart_outlined,
                color: AppColors.coral,
                size: 29,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ClinicPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final shadowRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * .10,
        size.height * .20 + 15,
        size.width * .80,
        size.height * .67,
      ),
      const Radius.circular(28),
    );

    canvas.drawRRect(
      shadowRect,
      Paint()
        ..color = Colors.black.withValues(alpha: .40)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
    );

    final side = Path()
      ..moveTo(size.width * .08, size.height * .34)
      ..lineTo(size.width * .24, size.height * .26)
      ..lineTo(size.width * .24, size.height * .80)
      ..lineTo(size.width * .08, size.height * .86)
      ..close();
    canvas.drawPath(
      side,
      Paint()..color = const Color(0xFF0E4C59),
    );

    final buildingRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * .22,
        size.height * .18,
        size.width * .68,
        size.height * .68,
      ),
      const Radius.circular(26),
    );

    final buildingGradient = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF1C7583),
        Color(0xFF0E4B58),
        Color(0xFF112B32),
      ],
      stops: [0, .48, 1],
    );
    canvas.drawRRect(
      buildingRect,
      Paint()
        ..shader = buildingGradient.createShader(buildingRect.outerRect),
    );

    canvas.drawRRect(
      buildingRect,
      Paint()
        ..color = Colors.white.withValues(alpha: .18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    final roof = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * .28,
        size.height * .10,
        size.width * .49,
        size.height * .16,
      ),
      const Radius.circular(18),
    );
    canvas.drawRRect(
      roof,
      Paint()..color = const Color(0xFF17373F),
    );
    canvas.drawRRect(
      roof,
      Paint()
        ..color = AppColors.primaryBright.withValues(alpha: .18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3,
    );

    final windowPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF7BE2E8), Color(0xFF207486)],
      ).createShader(
        Rect.fromLTWH(
          size.width * .30,
          size.height * .32,
          size.width * .52,
          size.height * .33,
        ),
      );

    for (var row = 0; row < 2; row++) {
      for (var col = 0; col < 4; col++) {
        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(
            size.width * (.30 + col * .13),
            size.height * (.33 + row * .17),
            size.width * .085,
            size.height * .085,
          ),
          const Radius.circular(6),
        );
        canvas.drawRRect(rect, windowPaint);
      }
    }

    final entrance = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * .48,
        size.height * .64,
        size.width * .18,
        size.height * .22,
      ),
      const Radius.circular(11),
    );
    canvas.drawRRect(
      entrance,
      Paint()..color = const Color(0xFF091417),
    );
    canvas.drawRRect(
      entrance,
      Paint()
        ..color = AppColors.primaryBright.withValues(alpha: .28)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );

    final crossPaint = Paint()
      ..color = AppColors.coral
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 13;
    final crossCenter = Offset(size.width * .53, size.height * .18);
    canvas.drawLine(
      Offset(crossCenter.dx - 22, crossCenter.dy),
      Offset(crossCenter.dx + 22, crossCenter.dy),
      crossPaint,
    );
    canvas.drawLine(
      Offset(crossCenter.dx, crossCenter.dy - 22),
      Offset(crossCenter.dx, crossCenter.dy + 22),
      crossPaint,
    );

    final lanePaint = Paint()
      ..color = AppColors.primaryBright.withValues(alpha: .17)
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(size.width * .18, size.height * .90),
      Offset(size.width * .80, size.height * .90),
      lanePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LifestyleOrb extends StatelessWidget {
  const _LifestyleOrb();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised.withValues(alpha: .88),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderStrong),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .3),
            blurRadius: 18,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.directions_walk_rounded,
            size: 16,
            color: AppColors.primaryBright,
          ),
          SizedBox(width: 8),
          Text(
            'LIFESTYLE SIGNALS',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: .8,
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallLabel extends StatelessWidget {
  const _SmallLabel({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: .72),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.coral),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 8.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: .72),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.lock_outline_rounded,
            size: 12,
            color: AppColors.success,
          ),
          SizedBox(width: 6),
          Text(
            'SECURE ADMIN ACCESS',
            style: TextStyle(
              fontSize: 8.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
