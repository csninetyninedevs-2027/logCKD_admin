import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/admin_page_header.dart';
import '../../../shared/widgets/admin_reveal.dart';
import '../../../shared/widgets/admin_responsive.dart';
import '../../../shared/widgets/admin_status_badge.dart';
import '../../../shared/widgets/admin_surface.dart';
import '../../../shared/widgets/user_detail_skeleton.dart';
import '../state/users_provider.dart';

class UserDetailScreen extends ConsumerWidget {
  const UserDetailScreen({super.key, required this.userId});

  final String userId;

  Future<void> _confirmToggleActive(
    BuildContext context,
    WidgetRef ref,
    bool currentlyActive,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(currentlyActive ? 'Deactivate user?' : 'Reactivate user?'),
        content: Text(
          currentlyActive
              ? 'This immediately ends active sessions and blocks new logins. User data is preserved and the action can be reversed.'
              : 'This restores normal access for this user.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: currentlyActive ? AppColors.danger : AppColors.success,
              foregroundColor: const Color(0xFF071013),
            ),
            child: Text(currentlyActive ? 'Deactivate' : 'Reactivate'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final success = await ref
        .read(userActionsProvider.notifier)
        .setActiveStatus(userId, !currentlyActive);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? (currentlyActive ? 'User deactivated' : 'User reactivated')
              : 'Action failed. Please try again.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(userDetailProvider(userId));

    return Padding(
        padding: AdminResponsive.pageInsets(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AdminReveal(
              child: AdminPageHeader(
                eyebrow: 'Users / profile',
                title: 'User Detail',
                subtitle: 'Review account context, recent health records, risk output, and activity signals.',
                actions: [
                  OutlinedButton.icon(
                    onPressed: () => context.go('/users'),
                    icon: const Icon(Icons.arrow_back_rounded, size: 17),
                    label: const Text('Back to users'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Expanded(
              child: detailAsync.when(
                loading: () => const UserDetailSkeleton(),
                error: (error, _) => Center(
                  child: AdminSurface(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline_rounded, color: AppColors.danger),
                        const SizedBox(height: 10),
                        Text('Failed to load user: $error'),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: () => ref.invalidate(userDetailProvider(userId)),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
                data: (detail) {
                  final user = detail.user;
                  final riskCategory = detail.latestRiskAssessment?['riskCategory']?.toString();
                  final riskColor = AppTheme.riskColor(riskCategory);

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AdminReveal(
                          delay: const Duration(milliseconds: 70),
                          child: _IdentityPanel(
                            name: user.fullName,
                            email: user.email,
                            isActive: user.isActive,
                            accessMode: user.accessMode,
                            sex: _displayValue(user.sex),
                            region: _displayValue(user.region),
                            location: _locationLabel(
                              user.cityMunicipality,
                              user.province,
                            ),
                            healthStatus: user.healthStatus.trim().isEmpty
                                ? 'Not provided'
                                : _titleCase(user.healthStatus),
                            ckdStage: user.ckdStage == null ||
                                    user.ckdStage!.trim().isEmpty
                                ? 'Not provided'
                                : _titleCase(user.ckdStage!),
                            joined: _date(user.createdAt),
                            lastLogin: user.lastLoginAt == null ? 'Never' : _date(user.lastLoginAt!),
                            onToggleStatus: () => _confirmToggleActive(context, ref, user.isActive),
                          ),
                        ),
                        const SizedBox(height: 16),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final columns = constraints.maxWidth >= 1120 ? 3 : constraints.maxWidth >= 720 ? 2 : 1;
                            const gap = 16.0;
                            final width = (constraints.maxWidth - gap * (columns - 1)) / columns;

                            return Wrap(
                              spacing: gap,
                              runSpacing: gap,
                              children: [
                                SizedBox(
                                  width: width,
                                  child: AdminReveal(
                                    delay: const Duration(milliseconds: 120),
                                    child: _SignalCard(
                                      label: 'LATEST RISK',
                                      icon: Icons.analytics_outlined,
                                      accent: riskColor,
                                      title: riskCategory == null ? 'No assessment yet' : _titleCase(riskCategory),
                                      metric: detail.latestRiskAssessment == null
                                          ? null
                                          : 'Score ${detail.latestRiskAssessment!['riskScore'] ?? '—'}',
                                      lines: [
                                        if (detail.latestRiskAssessment != null)
                                          'Assessment month  ${detail.latestRiskAssessment!['assessmentMonth'] ?? '—'}',
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: width,
                                  child: AdminReveal(
                                    delay: const Duration(milliseconds: 170),
                                    child: _SignalCard(
                                      label: 'LATEST CHECKUP',
                                      icon: Icons.medical_information_outlined,
                                      accent: AppColors.primaryBright,
                                      title: detail.latestCheckup == null ? 'No checkup yet' : 'Kidney measurements',
                                      lines: detail.latestCheckup == null
                                          ? const []
                                          : [
                                              'eGFR  ${detail.latestCheckup!['egfr'] ?? '—'}',
                                              'Creatinine  ${detail.latestCheckup!['serumCreatinine'] ?? '—'}',
                                              'UACR  ${detail.latestCheckup!['uacr'] ?? '—'}',
                                              'BP  ${detail.latestCheckup!['systolicBp'] ?? '—'}/${detail.latestCheckup!['diastolicBp'] ?? '—'}',
                                            ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: width,
                                  child: AdminReveal(
                                    delay: const Duration(milliseconds: 220),
                                    child: _ActivityCard(
                                      food: detail.activitySummary.foodLogCount,
                                      water: detail.activitySummary.waterLogCount,
                                      lifestyle: detail.activitySummary.activityCount,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        AdminReveal(
                          delay: const Duration(milliseconds: 260),
                          child: _RawHealthPanel(raw: detail.rawUserJson),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
  }
}

class _IdentityPanel extends StatelessWidget {
  const _IdentityPanel({
    required this.name,
    required this.email,
    required this.isActive,
    required this.accessMode,
    required this.sex,
    required this.region,
    required this.location,
    required this.healthStatus,
    required this.ckdStage,
    required this.joined,
    required this.lastLogin,
    required this.onToggleStatus,
  });

  final String name;
  final String email;
  final bool isActive;
  final String accessMode;
  final String sex;
  final String region;
  final String location;
  final String healthStatus;
  final String ckdStage;
  final String joined;
  final String lastLogin;
  final VoidCallback onToggleStatus;

  @override
  Widget build(BuildContext context) {
    return AdminSurface(
      padding: const EdgeInsets.all(22),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 760;

          final profile = Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProfileAvatar(name: name),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 24),
                          ),
                        ),
                        const SizedBox(width: 10),
                        isActive ? AdminStatusBadge.active() : AdminStatusBadge.inactive(),
                        const SizedBox(width: 8),
                        _AccessModeBadge(
                          accessMode: accessMode,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(email, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    if (accessMode == 'awareness_only') ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: .07),
                          borderRadius: BorderRadius.circular(9),
                          border: Border.all(
                            color: AppColors.warning.withValues(alpha: .18),
                          ),
                        ),
                        child: const Text(
                          'Awareness-only account. This user may legitimately have no completed profile or personalized health data.',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10.5,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 28,
                      runSpacing: 16,
                      children: [
                        _Info(
                          label: 'ACCESS MODE',
                          value: accessMode == 'awareness_only'
                              ? 'Awareness only'
                              : 'Full access',
                        ),
                        _Info(label: 'SEX', value: sex),
                        _Info(label: 'REGION', value: region),
                        _Info(label: 'LOCATION', value: location),
                        _Info(label: 'HEALTH STATUS', value: healthStatus),
                        _Info(label: 'CKD STAGE', value: ckdStage),
                        _Info(label: 'JOINED', value: joined),
                        _Info(label: 'LAST LOGIN', value: lastLogin),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );

          final action = OutlinedButton.icon(
            onPressed: onToggleStatus,
            style: OutlinedButton.styleFrom(
              foregroundColor: isActive ? AppColors.danger : AppColors.success,
              side: BorderSide(color: (isActive ? AppColors.danger : AppColors.success).withValues(alpha: .55)),
            ),
            icon: Icon(isActive ? Icons.person_off_outlined : Icons.person_add_alt_1_outlined, size: 16),
            label: Text(isActive ? 'Deactivate' : 'Reactivate'),
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [profile, const SizedBox(height: 20), action],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Expanded(child: profile), const SizedBox(width: 24), action],
          );
        },
      ),
    );
  }
}

class _AccessModeBadge extends StatelessWidget {
  const _AccessModeBadge({
    required this.accessMode,
  });

  final String accessMode;

  @override
  Widget build(BuildContext context) {
    final awarenessOnly =
        accessMode == 'awareness_only';

    final color = awarenessOnly
        ? AppColors.warning
        : AppColors.primaryBright;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(
          color: color.withValues(alpha: .18),
        ),
      ),
      child: Text(
        awarenessOnly
            ? 'AWARENESS ONLY'
            : 'FULL ACCESS',
        style: TextStyle(
          color: color,
          fontSize: 8,
          fontWeight: FontWeight.w800,
          letterSpacing: .55,
        ),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    final parts = name.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    final text = parts.isEmpty
        ? '?'
        : parts.length == 1
            ? parts.first[0].toUpperCase()
            : '${parts.first[0]}${parts.last[0]}'.toUpperCase();

    return Container(
      width: 62,
      height: 62,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(19),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryBright, AppColors.primaryDark],
        ),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withValues(alpha: .18), blurRadius: 22, offset: const Offset(0, 10)),
        ],
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(color: Color(0xFF071214), fontSize: 18, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

class _Info extends StatelessWidget {
  const _Info({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 110, maxWidth: 240),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 8.5, fontWeight: FontWeight.w800, letterSpacing: .8)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _SignalCard extends StatelessWidget {
  const _SignalCard({
    required this.label,
    required this.icon,
    required this.accent,
    required this.title,
    this.metric,
    this.lines = const [],
  });

  final String label;
  final IconData icon;
  final Color accent;
  final String title;
  final String? metric;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return AdminSurface(
      hoverable: true,
      child: SizedBox(
        height: 190,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: .09),
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(color: accent.withValues(alpha: .18)),
                  ),
                  child: Icon(icon, size: 17, color: accent),
                ),
                const SizedBox(width: 10),
                Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: .9)),
              ],
            ),
            const SizedBox(height: 17),
            Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -.3)),
            if (metric != null) ...[
              const SizedBox(height: 3),
              Text(metric!, style: TextStyle(color: accent, fontSize: 12, fontWeight: FontWeight.w700)),
            ],
            const Spacer(),
            for (final line in lines.take(4))
              Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Text(line, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10.5)),
              ),
          ],
        ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.food, required this.water, required this.lifestyle});
  final int food;
  final int water;
  final int lifestyle;

  @override
  Widget build(BuildContext context) {
    final total = food + water + lifestyle;
    return AdminSurface(
      hoverable: true,
      child: SizedBox(
        height: 190,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.bolt_rounded, size: 18, color: AppColors.primaryBright),
                SizedBox(width: 8),
                Text('ACTIVITY SUMMARY', style: TextStyle(color: AppColors.textMuted, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: .9)),
              ],
            ),
            const SizedBox(height: 16),
            Text('$total', style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: -1)),
            const Text('recorded entries', style: TextStyle(color: AppColors.textSecondary, fontSize: 10.5)),
            const Spacer(),
            Row(
              children: [
                Expanded(child: _ActivityValue(label: 'FOOD', value: food, color: AppColors.coral)),
                Expanded(child: _ActivityValue(label: 'WATER', value: water, color: AppColors.softBlue)),
                Expanded(child: _ActivityValue(label: 'LIFESTYLE', value: lifestyle, color: AppColors.success)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityValue extends StatelessWidget {
  const _ActivityValue({required this.label, required this.value, required this.color});
  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$value', style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w800)),
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 8, fontWeight: FontWeight.w800, letterSpacing: .55)),
      ],
    );
  }
}

class _RawHealthPanel extends StatelessWidget {
  const _RawHealthPanel({required this.raw});
  final Map<String, dynamic> raw;

  @override
  Widget build(BuildContext context) {
    final entries = <MapEntry<String, dynamic>>[
      for (final key in const [
        'heightCm',
        'weightKg',
        'bmi',
        'existingFactorsResponse',
        'familyHistoryResponse',
      ])
        if (raw.containsKey(key) && raw[key] != null) MapEntry(key, raw[key]),
    ];

    return AdminSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.health_and_safety_outlined, size: 18, color: AppColors.primaryBright),
              SizedBox(width: 9),
              Text('Additional health context', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 14),
          if (entries.isEmpty)
            const Text('No additional profile health fields available.', style: TextStyle(color: AppColors.textSecondary, fontSize: 11))
          else
            Wrap(
              spacing: 28,
              runSpacing: 14,
              children: [
                for (final entry in entries)
                  _Info(label: _fieldLabel(entry.key), value: entry.value.toString()),
              ],
            ),
        ],
      ),
    );
  }
}

String _displayValue(
  String? value,
) {
  final trimmed =
      value?.trim() ?? '';

  return trimmed.isEmpty
      ? 'Not provided'
      : trimmed;
}

String _locationLabel(
  String cityMunicipality,
  String province,
) {
  final parts = [
    cityMunicipality.trim(),
    province.trim(),
  ].where((part) => part.isNotEmpty).toList();

  if (parts.isEmpty) {
    return 'Not provided';
  }

  return parts.join(', ');
}

String _date(DateTime value) {
  final d = value.toLocal();
  return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

String _titleCase(String value) {
  return value
      .replaceAll('_', ' ')
      .split(RegExp(r'\s+'))
      .where((e) => e.isNotEmpty)
      .map((e) => '${e[0].toUpperCase()}${e.substring(1).toLowerCase()}')
      .join(' ');
}

String _fieldLabel(String key) {
  switch (key) {
    case 'heightCm':
      return 'HEIGHT CM';
    case 'weightKg':
      return 'WEIGHT KG';
    case 'bmi':
      return 'BMI';
    case 'existingFactorsResponse':
      return 'EXISTING FACTORS';
    case 'familyHistoryResponse':
      return 'FAMILY HISTORY';
    default:
      return key.toUpperCase();
  }
}