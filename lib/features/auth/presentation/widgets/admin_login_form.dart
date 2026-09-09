import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/utils/admin_input_validation.dart';

class AdminLoginForm extends StatelessWidget {
  const AdminLoginForm({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.isLoading,
    required this.errorMessage,
    required this.onTogglePassword,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onTogglePassword;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'ADMIN PORTAL',
            style: TextStyle(
              color: AppColors.primaryBright,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Welcome back.',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 36),
          ),
          const SizedBox(height: 9),
          const Text(
            'Sign in to manage the log.CKD platform and operational health data.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5, height: 1.5),
          ),
          const SizedBox(height: 32),
          const _FieldLabel('EMAIL ADDRESS'),
          const SizedBox(height: 8),
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            inputFormatters: [
              ...AdminInputValidation.safeTextFormatters,
              LengthLimitingTextInputFormatter(254),
            ],
            decoration: const InputDecoration(
              hintText: 'admin@logckd.com',
              prefixIcon: Icon(Icons.alternate_email_rounded, size: 18),
            ),
            validator: AdminInputValidation.email,
          ),
          const SizedBox(height: 18),
          const _FieldLabel('PASSWORD'),
          const SizedBox(height: 8),
          TextFormField(
            controller: passwordController,
            obscureText: obscurePassword,
            autofillHints: const [AutofillHints.password],
            inputFormatters: [LengthLimitingTextInputFormatter(128)],
            decoration: InputDecoration(
              hintText: 'Enter your password',
              prefixIcon: const Icon(Icons.lock_outline_rounded, size: 18),
              suffixIcon: IconButton(
                onPressed: onTogglePassword,
                icon: Icon(
                  obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  size: 18,
                ),
              ),
            ),
            onFieldSubmitted: (_) => onSubmit(),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Password is required';
              if (value.length > 128) return 'Password is too long';
              return null;
            },
          ),
          if (errorMessage != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: .08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.danger.withValues(alpha: .22)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.error_outline_rounded, color: AppColors.danger, size: 17),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      errorMessage!,
                      style: const TextStyle(color: AppColors.danger, fontSize: 11.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            height: 49,
            child: FilledButton(
              onPressed: isLoading ? null : onSubmit,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: isLoading
                    ? const SizedBox(
                        key: ValueKey('loading'),
                        width: 19,
                        height: 19,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF031114),
                        ),
                      )
                    : const Row(
                        key: ValueKey('label'),
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Sign in'),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded, size: 17),
                        ],
                      ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.shield_outlined, size: 14, color: AppColors.textMuted),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  'Restricted to authorized log.CKD administrators.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 9.5,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.05,
      ),
    );
  }
}
