import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../state/auth_provider.dart';
import 'widgets/admin_login_form.dart';
import 'widgets/admin_login_hero.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    ref
        .read(authStateProvider.notifier)
        .login(_emailController.text.trim(), _passwordController.text);
  }

  Widget _buildForm(dynamic authState) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 390),
      child: AdminLoginForm(
        formKey: _formKey,
        emailController: _emailController,
        passwordController: _passwordController,
        obscurePassword: _obscurePassword,
        isLoading: authState.isLoading,
        errorMessage: authState.errorMessage,
        onTogglePassword: () =>
            setState(() => _obscurePassword = !_obscurePassword),
        onSubmit: _submit,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final size = MediaQuery.sizeOf(context);
    final compact = size.width < 980;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const Positioned.fill(child: _LoginBackdrop()),
          SafeArea(
            child: compact
                ? SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _LogCkdWordmark(),
                        const SizedBox(height: 18),
                        const SizedBox(
                          height: 360,
                          width: double.infinity,
                          child: AdminLoginHero(),
                        ),
                        const SizedBox(height: 22),
                        const _LoginStatement(compact: true),
                        const SizedBox(height: 38),
                        Center(child: _buildForm(authState)),
                        const SizedBox(height: 30),
                      ],
                    ),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) => SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 54,
                              vertical: 36,
                            ),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 1580),
                              child: SizedBox(
                                height: (size.height - 72)
                                    .clamp(650.0, 860.0)
                                    .toDouble(),
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      flex: 7,
                                      child: Stack(
                                        children: const [
                                          Positioned(
                                            left: 0,
                                            top: 0,
                                            child: _LogCkdWordmark(),
                                          ),
                                          Positioned(
                                            left: 8,
                                            right: 0,
                                            top: 42,
                                            bottom: 124,
                                            child: AdminLoginHero(),
                                          ),
                                          Positioned(
                                            left: 0,
                                            right: 36,
                                            bottom: 48,
                                            child: _LoginStatement(),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 42),
                                    Expanded(
                                      flex: 4,
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Transform.translate(
                                          offset: const Offset(0, 210),
                                          child: _buildForm(authState),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _LogCkdWordmark extends StatelessWidget {
  const _LogCkdWordmark();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'log.CKD',
      header: true,
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38,
              height: 38,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(11),
                color: AppColors.primary.withValues(alpha: .07),
                border: Border.all(
                  color: AppColors.primaryBright.withValues(alpha: .16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: .12),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: Image.asset(
                'assets/images/log_ckd_mark.png',
                filterQuality: FilterQuality.high,
              ),
            ),
            const SizedBox(width: 10),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'log.',
                    style: GoogleFonts.simonetta(
                      color: AppColors.textPrimary,
                      fontSize: 21,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -.7,
                    ),
                  ),
                  TextSpan(
                    text: 'CKD',
                    style: GoogleFonts.montserrat(
                      color: AppColors.primaryBright,
                      fontSize: 21,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -.7,
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

class _LoginStatement extends StatelessWidget {
  const _LoginStatement({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: compact ? 520 : 560),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Care infrastructure,\nseen as a system.',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontSize: compact ? 28 : 42,
              height: 1.04,
              letterSpacing: -1.15,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Administrative visibility for user health signals, facilities, '
            'food data, regional reach, and service reliability.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: compact ? 11.5 : 13.5,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginBackdrop extends StatelessWidget {
  const _LoginBackdrop();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(painter: _LoginBackdropPainter()),
      ),
    );
  }
}

class _LoginBackdropPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final bounds = Offset.zero & size;
    final compact = size.width < 980;
    canvas.save();
    canvas.clipRect(bounds);
    canvas.drawColor(AppColors.background, BlendMode.srcOver);

    final waveWidth = size.width * (compact ? .95 : .71);
    final waveHeight = compact
        ? size.height.clamp(480.0, 800.0).toDouble()
        : size.height;
    final waveBounds = Rect.fromLTWH(0, 0, waveWidth, waveHeight);

    canvas.save();
    canvas.translate(0, -waveHeight * .05);
    canvas.scale(1, 1.25);
    for (var layer = 0; layer < 4; layer++) {
      final inset = layer * .105;
      const topShift = .30;
      const centerHollowShift = .13;
      final bottomShift = layer == 3 ? 0.0 : .30;
      final lowerBumpControl = layer == 3 ? .78 : 1.0;
      final lowerBumpEdge = layer == 3 ? .72 : .87;

      final edge = Path()
        ..moveTo(waveWidth * (1.04 - inset - topShift), -40)
        ..cubicTo(
          waveWidth * (1.06 - inset - topShift),
          waveHeight * .17,
          waveWidth * (.57 - inset - centerHollowShift),
          waveHeight * .29,
          waveWidth * (.61 - inset - centerHollowShift),
          waveHeight * .43,
        )
        ..cubicTo(
          waveWidth * (.64 - inset - centerHollowShift),
          waveHeight * .56,
          waveWidth * (lowerBumpControl - inset),
          waveHeight * .67,
          waveWidth * (lowerBumpEdge - inset),
          waveHeight * .84,
        )
        ..cubicTo(
          waveWidth * (.79 - inset),
          waveHeight * .96,
          waveWidth * (.76 - inset - bottomShift),
          waveHeight * 1.03,
          waveWidth * (1.09 - inset - bottomShift),
          waveHeight + 40,
        );
      final surface = Path.from(edge)
        ..lineTo(-40, waveHeight + 40)
        ..lineTo(-40, -40)
        ..close();

      canvas.drawPath(
        surface.shift(Offset(16 - layer * 2.0, 9)),
        Paint()
          ..color = Colors.black.withValues(alpha: .48)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22),
      );
      canvas.drawPath(
        surface,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.lerp(
                AppColors.background,
                AppColors.primaryDeep,
                .27 + layer * .055,
              )!,
              Color.lerp(
                AppColors.background,
                AppColors.primaryDark,
                .19 + layer * .045,
              )!,
              Color.lerp(
                AppColors.background,
                AppColors.primaryDeep,
                .12 + layer * .025,
              )!,
              AppColors.backgroundRaised,
            ],
            stops: const [0, .38, .7, 1],
          ).createShader(waveBounds),
      );
      canvas.drawPath(
        edge,
        Paint()
          ..color = AppColors.primary.withValues(alpha: .065)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 7
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
      );
      canvas.drawPath(
        edge,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primaryBright.withValues(alpha: .04),
              AppColors.primaryBright.withValues(alpha: .19),
              AppColors.primary.withValues(alpha: .025),
              AppColors.primaryBright.withValues(alpha: .09),
            ],
            stops: const [0, .28, .65, 1],
          ).createShader(waveBounds)
          ..style = PaintingStyle.stroke
          ..strokeWidth = .8,
      );
    }
    canvas.restore();

    canvas.drawRect(
      bounds,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.transparent,
            AppColors.background.withValues(alpha: .18),
            AppColors.background.withValues(alpha: .94),
            AppColors.background,
          ],
          stops: const [0, .43, .74, 1],
        ).createShader(bounds),
    );
    canvas.drawRect(
      bounds,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.transparent,
            AppColors.background.withValues(alpha: .78),
          ],
          stops: [0, compact ? .35 : .65, 1],
        ).createShader(bounds),
    );

    final teal = Paint()
      ..shader =
          RadialGradient(
            colors: [
              AppColors.primary.withValues(alpha: .10),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * .15, size.height * .06),
              radius: 420,
            ),
          );
    canvas.drawCircle(Offset(size.width * .15, size.height * .06), 420, teal);

    final warm = Paint()
      ..shader =
          RadialGradient(
            colors: [
              AppColors.primaryDeep.withValues(alpha: .08),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * .94, size.height * .91),
              radius: 360,
            ),
          );
    canvas.drawCircle(Offset(size.width * .94, size.height * .91), 360, warm);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
