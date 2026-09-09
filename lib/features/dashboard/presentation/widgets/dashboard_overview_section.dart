import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/dashboard_food_summary.dart';
import '../../../../shared/models/dashboard_summary.dart';
import '../../../../shared/models/system_status.dart';
import '../../../../shared/models/user_concentration.dart';
import '../../../system_status/state/system_status_provider.dart';
import '../../../user_map/state/user_concentration_provider.dart';
import '../../state/dashboard_provider.dart';

class DashboardOverviewSection
    extends ConsumerWidget {
  const DashboardOverviewSection({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final summaryAsync =
        ref.watch(
      dashboardSummaryProvider,
    );

    final foodAsync =
        ref.watch(
      dashboardFoodSummaryProvider,
    );

    final systemAsync =
        ref.watch(
      systemStatusProvider,
    );

    final concentrationAsync =
        ref.watch(
      userConcentrationProvider,
    );

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        summaryAsync.when(
          loading: () =>
              const _LoadingBox(
            height: 110,
          ),
          error: (
            error,
            stackTrace,
          ) =>
              _ErrorBox(
            message:
                'Could not load dashboard totals.',
            onRetry: () {
              ref.invalidate(
                dashboardSummaryProvider,
              );
            },
          ),
          data: (
            summary,
          ) =>
              _PrimaryMetrics(
            summary: summary,
          ),
        ),

        const SizedBox(
          height: 28,
        ),

        const _SectionTitle(
          title:
              'Platform Overview',
          subtitle:
              'Operational health, food-library coverage, and geographic reach.',
        ),

        const SizedBox(
          height: 14,
        ),

        LayoutBuilder(
          builder: (
            context,
            constraints,
          ) {
            const gap =
                16.0;

            final columns =
                constraints.maxWidth >=
                        1120
                    ? 3
                    : constraints.maxWidth >=
                            720
                        ? 2
                        : 1;

            final width =
                (constraints.maxWidth -
                        gap *
                            (columns -
                                1)) /
                    columns;

            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                SizedBox(
                  width: width,
                  child:
                      _OverviewCard(
                    title:
                        'System Health',
                    icon:
                        Icons
                            .monitor_heart_outlined,
                    actionLabel:
                        'Open System Status',
                    onAction: () {
                      context.go(
                        '/system-status',
                      );
                    },
                    child:
                        systemAsync
                            .when(
                      loading: () =>
                          const _PanelLoading(),
                      error: (
                        error,
                        stackTrace,
                      ) =>
                          _PanelError(
                        label:
                            'System health unavailable.',
                        onRetry: () {
                          ref.invalidate(
                            systemStatusProvider,
                          );
                        },
                      ),
                      data: (
                        data,
                      ) =>
                          _SystemContent(
                        data:
                            data,
                      ),
                    ),
                  ),
                ),

                SizedBox(
                  width: width,
                  child:
                      _OverviewCard(
                    title:
                        'Food Library',
                    icon:
                        Icons
                            .restaurant_menu_outlined,
                    actionLabel:
                        'Manage Foods',
                    onAction: () {
                      context.go(
                        '/foods',
                      );
                    },
                    child:
                        foodAsync
                            .when(
                      loading: () =>
                          const _PanelLoading(),
                      error: (
                        error,
                        stackTrace,
                      ) =>
                          _PanelError(
                        label:
                            'Food totals unavailable.',
                        onRetry: () {
                          ref.invalidate(
                            dashboardFoodSummaryProvider,
                          );
                        },
                      ),
                      data: (
                        data,
                      ) =>
                          _FoodContent(
                        data:
                            data,
                      ),
                    ),
                  ),
                ),

                SizedBox(
                  width: width,
                  child:
                      _OverviewCard(
                    title:
                        'Geographic Coverage',
                    icon:
                        Icons
                            .map_outlined,
                    actionLabel:
                        'Open User Map',
                    onAction: () {
                      context.go(
                        '/user-concentration',
                      );
                    },
                    child:
                        concentrationAsync
                            .when(
                      loading: () =>
                          const _PanelLoading(),
                      error: (
                        error,
                        stackTrace,
                      ) =>
                          _PanelError(
                        label:
                            'Regional data unavailable.',
                        onRetry: () {
                          ref.invalidate(
                            userConcentrationProvider,
                          );
                        },
                      ),
                      data: (
                        concentration,
                      ) =>
                          _CoverageContent(
                        concentration:
                            concentration,
                        summary:
                            summaryAsync
                                .valueOrNull,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),

        const SizedBox(
          height: 28,
        ),

        const _SectionTitle(
          title:
              'Quick Access',
          subtitle:
              'Jump directly to the main admin workspaces.',
        ),

        const SizedBox(
          height: 14,
        ),

        const _QuickActions(),
      ],
    );
  }
}

// ============================================================
// PRIMARY METRICS
// ============================================================

class _PrimaryMetrics
    extends StatelessWidget {
  const _PrimaryMetrics({
    required this.summary,
  });

  final DashboardSummary summary;

  @override
  Widget build(
    BuildContext context,
  ) {
    final activeRate =
        summary.totalUsers <=
                0
            ? 0.0
            : summary
                        .activeUsers /
                    summary
                        .totalUsers *
                100;

    final items = [
      _MetricData(
        label:
            'Total Users',
        value:
            '${summary.totalUsers}',
        helper:
            'Registered accounts',
        icon:
            Icons.people_outline,
        color:
            AppColors.primary,
      ),

      _MetricData(
        label:
            'Active Users',
        value:
            '${summary.activeUsers}',
        helper:
            '${activeRate.toStringAsFixed(1)}% of users',
        icon:
            Icons
                .check_circle_outline,
        color:
            AppColors.success,
      ),

      _MetricData(
        label:
            'New This Month',
        value:
            '${summary.newUsersThisMonth}',
        helper:
            'New registrations',
        icon:
            Icons.trending_up,
        color:
            AppColors.success,
      ),

      _MetricData(
        label:
            'Checkups This Month',
        value:
            '${summary.checkupsThisMonth}',
        helper:
            'Recorded checkups',
        icon:
            Icons
                .medical_information_outlined,
        color:
            AppColors.warning,
      ),

      _MetricData(
        label:
            'Facilities',
        value:
            '${summary.totalFacilities}',
        helper:
            '${summary.mappedFacilities} map-ready',
        icon:
            Icons
                .local_hospital_outlined,
        color:
            AppColors.primary,
      ),

      _MetricData(
        label:
            'Facility Map Coverage',
        value:
            '${summary.facilityMapCoverage.toStringAsFixed(1)}%',
        helper:
            '${summary.mappedFacilities}/${summary.totalFacilities} facilities',
        icon:
            Icons
                .location_on_outlined,
        color:
            AppColors.primaryDark,
      ),
    ];

    return LayoutBuilder(
      builder: (
        context,
        constraints,
      ) {
        const gap =
            14.0;

        final columns =
            constraints.maxWidth >=
                    1320
                ? 6
                : constraints
                            .maxWidth >=
                        900
                    ? 3
                    : constraints
                                .maxWidth >=
                            560
                        ? 2
                        : 1;

        final width =
            (constraints.maxWidth -
                    gap *
                        (columns -
                            1)) /
                columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final item
                in items)
              SizedBox(
                width: width,
                child:
                    _MetricCard(
                  item:
                      item,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _MetricData {
  const _MetricData({
    required this.label,
    required this.value,
    required this.helper,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final String helper;

  final IconData icon;
  final Color color;
}

class _MetricCard
    extends StatelessWidget {
  const _MetricCard({
    required this.item,
  });

  final _MetricData item;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(
          17,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment
                  .start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.label,
                    maxLines: 1,
                    overflow:
                        TextOverflow
                            .ellipsis,
                    style:
                        Theme.of(
                      context,
                    )
                            .textTheme
                            .bodySmall,
                  ),
                ),

                Container(
                  width: 34,
                  height: 34,
                  decoration:
                      BoxDecoration(
                    color:
                        item.color
                            .withValues(
                      alpha:
                          0.10,
                    ),
                    borderRadius:
                        BorderRadius
                            .circular(
                      10,
                    ),
                  ),
                  child: Icon(
                    item.icon,
                    color:
                        item.color,
                    size: 18,
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 8,
            ),

            Text(
              item.value,
              style:
                  Theme.of(
                context,
              )
                      .textTheme
                      .headlineLarge
                      ?.copyWith(
                fontWeight:
                    FontWeight
                        .w700,
              ),
            ),

            const SizedBox(
              height: 3,
            ),

            Text(
              item.helper,
              maxLines: 1,
              overflow:
                  TextOverflow
                      .ellipsis,
              style:
                  Theme.of(
                context,
              )
                      .textTheme
                      .bodySmall
                      ?.copyWith(
                fontSize:
                    11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// OVERVIEW PANELS
// ============================================================

class _OverviewCard
    extends StatelessWidget {
  const _OverviewCard({
    required this.title,
    required this.icon,
    required this.actionLabel,
    required this.onAction,
    required this.child,
  });

  final String title;
  final IconData icon;
  final String actionLabel;

  final VoidCallback onAction;

  final Widget child;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(
          18,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment
                  .start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration:
                      BoxDecoration(
                    color:
                        AppColors
                            .primary
                            .withValues(
                      alpha:
                          0.09,
                    ),
                    borderRadius:
                        BorderRadius
                            .circular(
                      11,
                    ),
                  ),
                  child:
                      Icon(
                    icon,
                    color:
                        AppColors
                            .primary,
                    size: 20,
                  ),
                ),

                const SizedBox(
                  width: 10,
                ),

                Expanded(
                  child: Text(
                    title,
                    style:
                        Theme.of(
                      context,
                    )
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                      fontWeight:
                          FontWeight
                              .w700,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 16,
            ),

            SizedBox(
              height: 176,
              child: child,
            ),

            const Divider(
              height: 24,
            ),

            Align(
              alignment:
                  Alignment
                      .centerRight,
              child:
                  TextButton.icon(
                onPressed:
                    onAction,
                icon:
                    const Icon(
                  Icons
                      .arrow_forward,
                  size: 16,
                ),
                label:
                    Text(
                  actionLabel,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// SYSTEM HEALTH
// ============================================================

class _SystemContent
    extends StatelessWidget {
  const _SystemContent({
    required this.data,
  });

  final SystemStatusData data;

  @override
  Widget build(
    BuildContext context,
  ) {
    final issues =
        data.summary.issues;

    final color =
        issues == 0
            ? AppColors.success
            : AppColors.warning;

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.circle,
              size: 10,
              color: color,
            ),

            const SizedBox(
              width: 7,
            ),

            Expanded(
              child: Text(
                issues == 0
                    ? 'All systems operational'
                    : '$issues issue(s)',
                style:
                    TextStyle(
                  color: color,
                  fontWeight:
                      FontWeight
                          .w700,
                ),
              ),
            ),

            Text(
              '${data.summary.online}/${data.summary.total} online',
              style:
                  Theme.of(
                context,
              )
                      .textTheme
                      .bodySmall,
            ),
          ],
        ),

        const SizedBox(
          height: 13,
        ),

        for (final service
            in data.services.take(
              3,
            ))
          Padding(
            padding:
                const EdgeInsets.only(
              bottom: 9,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.circle,
                  size: 8,
                  color:
                      _serviceColor(
                    service.status,
                  ),
                ),

                const SizedBox(
                  width: 8,
                ),

                Expanded(
                  child: Text(
                    service.name,
                    overflow:
                        TextOverflow
                            .ellipsis,
                    style:
                        const TextStyle(
                      fontSize: 12,
                      fontWeight:
                          FontWeight
                              .w500,
                    ),
                  ),
                ),

                Text(
                  service.responseTimeMs ==
                          null
                      ? _titleCase(
                          service
                              .status,
                        )
                      : '${service.responseTimeMs} ms',
                  style:
                      Theme.of(
                    context,
                  )
                          .textTheme
                          .bodySmall
                          ?.copyWith(
                    fontSize:
                        11,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ============================================================
// FOOD LIBRARY
// ============================================================

class _FoodContent
    extends StatelessWidget {
  const _FoodContent({
    required this.data,
  });

  final DashboardFoodSummary data;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment:
              CrossAxisAlignment.end,
          children: [
            Text(
              '${data.totalFoods}',
              style:
                  Theme.of(
                context,
              )
                      .textTheme
                      .headlineLarge
                      ?.copyWith(
                fontWeight:
                    FontWeight
                        .w700,
              ),
            ),

            const SizedBox(
              width: 7,
            ),

            Padding(
              padding:
                  const EdgeInsets.only(
                bottom: 4,
              ),
              child: Text(
                'active foods',
                style:
                    Theme.of(
                  context,
                )
                        .textTheme
                        .bodySmall,
              ),
            ),
          ],
        ),

        const SizedBox(
          height: 12,
        ),

        _KeyValueLine(
          label:
              'USDA Foundation',
          value:
              '${data.foundationFoods}',
        ),

        _KeyValueLine(
          label:
              'Filipino foods',
          value:
              '${data.filipinoFoods}',
        ),

        _KeyValueLine(
          label:
              'User custom',
          value:
              '${data.customFoods}',
        ),

        _KeyValueLine(
          label:
              'Admin foods',
          value:
              '${data.adminFoods}',
        ),
      ],
    );
  }
}

// ============================================================
// GEOGRAPHIC COVERAGE
// ============================================================

class _CoverageContent
    extends StatelessWidget {
  const _CoverageContent({
    required this.concentration,
    required this.summary,
  });

  final UserConcentrationData
      concentration;

  final DashboardSummary?
      summary;

  @override
  Widget build(
    BuildContext context,
  ) {
    final top =
        concentration.regions
                .isEmpty
            ? null
            : concentration
                .regions.first;

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child:
                  _MiniMetric(
                label:
                    'Users with region',
                value:
                    '${concentration.totalUsers}',
              ),
            ),

            Expanded(
              child:
                  _MiniMetric(
                label:
                    'Regions represented',
                value:
                    '${concentration.regions.length}',
              ),
            ),
          ],
        ),

        const SizedBox(
          height: 12,
        ),

        Text(
          'Highest concentration',
          style:
              Theme.of(
            context,
          )
                  .textTheme
                  .bodySmall,
        ),

        const SizedBox(
          height: 3,
        ),

        Text(
          top?.region ??
              'No regional data',
          maxLines: 1,
          overflow:
              TextOverflow.ellipsis,
          style:
              const TextStyle(
            fontSize: 13,
            fontWeight:
                FontWeight.w700,
          ),
        ),

        if (top != null)
          Text(
            '${top.count} users • '
            '${_percentage(top.count, concentration.totalUsers)}%',
            style:
                Theme.of(
              context,
            )
                    .textTheme
                    .bodySmall
                    ?.copyWith(
              fontSize: 11,
            ),
          ),

        const SizedBox(
          height: 11,
        ),

        _KeyValueLine(
          label:
              'Facility map coverage',
          value:
              summary == null
                  ? '—'
                  : '${summary!.facilityMapCoverage.toStringAsFixed(1)}%',
        ),

        _KeyValueLine(
          label:
              'Map-ready facilities',
          value:
              summary == null
                  ? '—'
                  : '${summary!.mappedFacilities}/${summary!.totalFacilities}',
        ),
      ],
    );
  }
}

// ============================================================
// QUICK ACCESS
// ============================================================

class _QuickActions
    extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(
    BuildContext context,
  ) {
    const actions = [
      _QuickAction(
        'Users',
        'Manage accounts',
        Icons.people_outline,
        '/users',
      ),

      _QuickAction(
        'Food Library',
        'Manage food data',
        Icons
            .restaurant_menu_outlined,
        '/foods',
      ),

      _QuickAction(
        'Facilities',
        'Manage facilities',
        Icons
            .local_hospital_outlined,
        '/facilities',
      ),

      _QuickAction(
        'User Map',
        'View concentration',
        Icons.map_outlined,
        '/user-concentration',
      ),

      _QuickAction(
        'System Status',
        'Monitor services',
        Icons
            .monitor_heart_outlined,
        '/system-status',
      ),
    ];

    return LayoutBuilder(
      builder: (
        context,
        constraints,
      ) {
        const gap =
            12.0;

        final columns =
            constraints.maxWidth >=
                    1200
                ? 5
                : constraints
                            .maxWidth >=
                        850
                    ? 3
                    : constraints
                                .maxWidth >=
                            560
                        ? 2
                        : 1;

        final width =
            (constraints.maxWidth -
                    gap *
                        (columns -
                            1)) /
                columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final action
                in actions)
              SizedBox(
                width: width,
                child:
                    _QuickActionCard(
                  action:
                      action,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _QuickAction {
  const _QuickAction(
    this.title,
    this.subtitle,
    this.icon,
    this.path,
  );

  final String title;
  final String subtitle;

  final IconData icon;

  final String path;
}

class _QuickActionCard
    extends StatelessWidget {
  const _QuickActionCard({
    required this.action,
  });

  final _QuickAction action;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Card(
      child: InkWell(
        borderRadius:
            BorderRadius.circular(
          12,
        ),
        onTap: () {
          context.go(
            action.path,
          );
        },
        child: Padding(
          padding:
              const EdgeInsets.all(
            15,
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration:
                    BoxDecoration(
                  color:
                      AppColors
                          .primary
                          .withValues(
                    alpha:
                        0.09,
                  ),
                  borderRadius:
                      BorderRadius
                          .circular(
                    10,
                  ),
                ),
                child: Icon(
                  action.icon,
                  color:
                      AppColors
                          .primary,
                  size: 19,
                ),
              ),

              const SizedBox(
                width: 10,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      action.title,
                      style:
                          const TextStyle(
                        fontSize: 13,
                        fontWeight:
                            FontWeight
                                .w700,
                      ),
                    ),

                    Text(
                      action.subtitle,
                      maxLines: 1,
                      overflow:
                          TextOverflow
                              .ellipsis,
                      style:
                          Theme.of(
                        context,
                      )
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                        fontSize:
                            10,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.chevron_right,
                size: 18,
                color:
                    AppColors
                        .textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// SMALL SHARED COMPONENTS
// ============================================================

class _SectionTitle
    extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style:
              Theme.of(
            context,
          )
                  .textTheme
                  .headlineMedium,
        ),

        const SizedBox(
          height: 3,
        ),

        Text(
          subtitle,
          style:
              Theme.of(
            context,
          )
                  .textTheme
                  .bodySmall,
        ),
      ],
    );
  }
}

class _MiniMetric
    extends StatelessWidget {
  const _MiniMetric({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style:
              Theme.of(
            context,
          )
                  .textTheme
                  .bodySmall
                  ?.copyWith(
            fontSize: 10,
          ),
        ),

        Text(
          value,
          style:
              const TextStyle(
            fontSize: 19,
            fontWeight:
                FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _KeyValueLine
    extends StatelessWidget {
  const _KeyValueLine({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Padding(
      padding:
          const EdgeInsets
              .symmetric(
        vertical: 3,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style:
                  Theme.of(
                context,
              )
                      .textTheme
                      .bodySmall,
            ),
          ),

          Text(
            value,
            style:
                const TextStyle(
              fontSize: 12,
              fontWeight:
                  FontWeight
                      .w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PanelLoading
    extends StatelessWidget {
  const _PanelLoading();

  @override
  Widget build(
    BuildContext context,
  ) {
    return const Center(
      child:
          CircularProgressIndicator(),
    );
  }
}

class _PanelError
    extends StatelessWidget {
  const _PanelError({
    required this.label,
    required this.onRetry,
  });

  final String label;
  final VoidCallback onRetry;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Center(
      child: Column(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline,
            color:
                AppColors.danger,
          ),

          const SizedBox(
            height: 6,
          ),

          Text(
            label,
            textAlign:
                TextAlign.center,
            style:
                Theme.of(
              context,
            )
                    .textTheme
                    .bodySmall,
          ),

          TextButton(
            onPressed:
                onRetry,
            child:
                const Text(
              'Retry',
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingBox
    extends StatelessWidget {
  const _LoadingBox({
    required this.height,
  });

  final double height;

  @override
  Widget build(
    BuildContext context,
  ) {
    return SizedBox(
      height: height,
      child:
          const Center(
        child:
            CircularProgressIndicator(),
      ),
    );
  }
}

class _ErrorBox
    extends StatelessWidget {
  const _ErrorBox({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      width:
          double.infinity,
      padding:
          const EdgeInsets.all(
        16,
      ),
      decoration:
          BoxDecoration(
        color:
            AppColors.danger
                .withValues(
          alpha: 0.06,
        ),
        borderRadius:
            BorderRadius.circular(
          12,
        ),
        border:
            Border.all(
          color:
              AppColors.danger
                  .withValues(
            alpha: 0.18,
          ),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color:
                AppColors.danger,
          ),

          const SizedBox(
            width: 10,
          ),

          Expanded(
            child:
                Text(
              message,
            ),
          ),

          TextButton(
            onPressed:
                onRetry,
            child:
                const Text(
              'Retry',
            ),
          ),
        ],
      ),
    );
  }
}

Color _serviceColor(
  String status,
) {
  switch (status) {
    case 'online':
      return AppColors.success;

    case 'degraded':
      return AppColors.warning;

    case 'offline':
      return AppColors.danger;

    default:
      return AppColors.textSecondary;
  }
}

String _titleCase(
  String value,
) {
  final cleaned =
      value
          .replaceAll(
            '_',
            ' ',
          )
          .trim();

  if (cleaned.isEmpty) {
    return 'Unknown';
  }

  return cleaned
      .split(
        RegExp(
          r'\s+',
        ),
      )
      .map(
        (part) =>
            part.isEmpty
                ? part
                : '${part[0].toUpperCase()}'
                    '${part.substring(1).toLowerCase()}',
      )
      .join(
        ' ',
      );
}

String _percentage(
  int value,
  int total,
) {
  if (total <= 0) {
    return '0.0';
  }

  return (value /
          total *
          100)
      .toStringAsFixed(
    1,
  );
}