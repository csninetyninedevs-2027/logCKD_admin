import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/admin_motion.dart';
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
    ref.read(authStateProvider.notifier).login(
          _emailController.text.trim(),
          _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final size = MediaQuery.sizeOf(context);
    final compact = size.width < 980;
    final desktopPanelHeight =
        (size.height - 56).clamp(720.0, 920.0).toDouble();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const Positioned.fill(child: _LoginBackdrop()),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(compact ? 18 : 28),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1320),
                  child: AnimatedContainer(
                    duration: AdminMotion.slow,
                    curve: AdminMotion.emphasized,
                    height: compact ? null : desktopPanelHeight,
                    constraints: BoxConstraints(minHeight: compact ? 0 : 720),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundRaised,
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: .38),
                          blurRadius: 70,
                          offset: const Offset(0, 32),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(compact ? 16 : 18),
                      child: compact
                          ? Column(
                              children: [
                                SizedBox(height: 390, child: const AdminLoginHero()),
                                const SizedBox(height: 18),
                                _FormPanel(
                                  child: AdminLoginForm(
                                    formKey: _formKey,
                                    emailController: _emailController,
                                    passwordController: _passwordController,
                                    obscurePassword: _obscurePassword,
                                    isLoading: authState.isLoading,
                                    errorMessage: authState.errorMessage,
                                    onTogglePassword: () => setState(
                                      () => _obscurePassword = !_obscurePassword,
                                    ),
                                    onSubmit: _submit,
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Expanded(flex: 7, child: AdminLoginHero()),
                                const SizedBox(width: 18),
                                Expanded(
                                  flex: 4,
                                  child: _FormPanel(
                                    child: AdminLoginForm(
                                      formKey: _formKey,
                                      emailController: _emailController,
                                      passwordController: _passwordController,
                                      obscurePassword: _obscurePassword,
                                      isLoading: authState.isLoading,
                                      errorMessage: authState.errorMessage,
                                      onTogglePassword: () => setState(
                                        () => _obscurePassword = !_obscurePassword,
                                      ),
                                      onSubmit: _submit,
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
        ],
      ),
    );
  }
}

class _FormPanel extends StatelessWidget {
  const _FormPanel({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 470),
      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 38),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: .76),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 390),
          child: child,
        ),
      ),
    );
  }
}

class _LoginBackdrop extends StatelessWidget {
  const _LoginBackdrop();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _LoginBackdropPainter());
  }
}

class _LoginBackdropPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawColor(AppColors.background, BlendMode.srcOver);
    final teal = Paint()
      ..shader = RadialGradient(
        colors: [AppColors.primary.withValues(alpha: .10), Colors.transparent],
      ).createShader(Rect.fromCircle(center: Offset(size.width * .15, size.height * .06), radius: 420));
    canvas.drawCircle(Offset(size.width * .15, size.height * .06), 420, teal);

    final warm = Paint()
      ..shader = RadialGradient(
        colors: [AppColors.coral.withValues(alpha: .055), Colors.transparent],
      ).createShader(Rect.fromCircle(center: Offset(size.width * .94, size.height * .91), radius: 360));
    canvas.drawCircle(Offset(size.width * .94, size.height * .91), 360, warm);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
