import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/admin_page_header.dart';
import '../../../shared/widgets/admin_reveal.dart';
import '../../../shared/widgets/admin_surface.dart';
import '../../system_status/state/system_status_provider.dart';
import '../../user_map/state/user_concentration_provider.dart';
import '../state/dashboard_provider.dart';
import 'widgets/dashboard_analytics_section.dart';
import 'widgets/dashboard_overview_section.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  void _refreshAll(WidgetRef ref) {
    ref.invalidate(dashboardSummaryProvider);
    ref.invalidate(demographicsProvider);
    ref.invalidate(riskDistributionProvider);
    final signupMonths = ref.read(signupTrendMonthsProvider);
    ref.invalidate(signupTrendProvider(signupMonths));
    ref.invalidate(dashboardFoodSummaryProvider);
    ref.invalidate(systemStatusProvider);
    ref.invalidate(userConcentrationProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
        onRefresh: () async => _refreshAll(ref),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(28, 26, 28, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AdminReveal(
                child: AdminPageHeader(
                  eyebrow: 'Control room',
                  title: 'Dashboard',
                  subtitle: 'A live operational view of log.CKD users, health signals, content coverage, geography, and service reliability.',
                  actions: [
                    OutlinedButton.icon(
                      onPressed: () => _refreshAll(ref),
                      icon: const Icon(Icons.refresh_rounded, size: 17),
                      label: const Text('Refresh dashboard'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              AdminReveal(
                delay: const Duration(milliseconds: 70),
                child: const _DashboardIntroBand(),
              ),
              const SizedBox(height: 22),
              const AdminReveal(
                delay: Duration(milliseconds: 120),
                child: DashboardOverviewSection(),
              ),
              const SizedBox(height: 30),
              const AdminReveal(
                delay: Duration(milliseconds: 170),
                child: DashboardAnalyticsSection(),
              ),
            ],
          ),
        ),
      );
  }
}

class _DashboardIntroBand extends ConsumerWidget {
  const _DashboardIntroBand();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(dashboardSummaryProvider);
    final systemAsync = ref.watch(systemStatusProvider);

    return AdminSurface(
      padding: EdgeInsets.zero,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 820;
          final left = Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary.withValues(alpha: .12),
                  AppColors.primaryDeep.withValues(alpha: .05),
                  Colors.transparent,
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PLATFORM SNAPSHOT',
                  style: TextStyle(
                    color: AppColors.primaryBright,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.15,
                  ),
                ),
                const SizedBox(height: 12),
                summaryAsync.when(
                  loading: () => const SizedBox(
                    height: 44,
                    width: 44,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  error: (_, __) => const Text(
                    'Dashboard data unavailable',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  data: (summary) => Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${summary.totalUsers}',
                        style: const TextStyle(
                          fontSize: 46,
                          height: 1,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -2,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Text(
                          'registered users\n${summary.newUsersThisMonth} new this month',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'The dashboard is intentionally composed around the operational story — not a wall of identical metric cards.',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 10.5, height: 1.45),
                ),
              ],
            ),
          );

          final right = Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.monitor_heart_outlined, size: 17, color: AppColors.primaryBright),
                    SizedBox(width: 8),
                    Text(
                      'SERVICE PULSE',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                systemAsync.when(
                  loading: () => const LinearProgressIndicator(minHeight: 2),
                  error: (_, __) => const Text('Service status unavailable', style: TextStyle(color: AppColors.danger)),
                  data: (data) {
                    final healthy = data.summary.issues == 0;
                    final color = healthy ? AppColors.success : AppColors.warning;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                healthy ? 'All monitored services operational' : '${data.summary.issues} service issue(s) detected',
                                style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '${data.summary.online}/${data.summary.total} online',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -.6),
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          'Main backend · Risk engine · Backup service',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 10.5),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          );

          if (compact) {
            return Column(
              children: [left, const Divider(height: 1), right],
            );
          }

          return SizedBox(
            height: 190,
            child: Row(
              children: [
                Expanded(flex: 7, child: left),
                const VerticalDivider(width: 1),
                Expanded(flex: 4, child: right),
              ],
            ),
          );
        },
      ),
    );
  }
}
