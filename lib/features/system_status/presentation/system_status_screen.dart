import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/admin_responsive.dart';
import '../../../shared/widgets/system_status_skeleton.dart';
import '../../../shared/models/system_status.dart';
import '../state/system_status_provider.dart';

class SystemStatusScreen extends ConsumerStatefulWidget {
  const SystemStatusScreen({super.key});

  @override
  ConsumerState<SystemStatusScreen> createState() =>
      _SystemStatusScreenState();
}

class _SystemStatusScreenState extends ConsumerState<SystemStatusScreen>
    with TickerProviderStateMixin {
  Timer? _refreshTimer;

  late final AnimationController _flowController;
  late final AnimationController _requestPulseController;

  bool _autoRefresh = true;
  String? _selectedServiceId;
  int? _lastObservedStamp;

  @override
  void initState() {
    super.initState();

    // Force a fresh status request whenever this screen is entered.
    // This ensures the loading skeleton is shown even when navigating
    // directly from Dashboard.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      ref.invalidate(systemStatusProvider);
    });

    _flowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    )..repeat();

    _requestPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 980),
    );

    _configureAutoRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _flowController.dispose();
    _requestPulseController.dispose();
    super.dispose();
  }

  void _configureAutoRefresh() {
    _refreshTimer?.cancel();

    if (!_autoRefresh) {
      return;
    }

    _refreshTimer = Timer.periodic(
      const Duration(seconds: 60),
      (_) {
        if (!mounted) {
          return;
        }

        _triggerRefresh();
      },
    );
  }

  void _setAutoRefresh(bool value) {
    setState(() {
      _autoRefresh = value;
    });

    _configureAutoRefresh();
  }

  void _triggerRefresh() {
    _requestPulseController.forward(from: 0);
    ref.invalidate(systemStatusProvider);
  }

  void _syncPulseWithData(SystemStatusData data) {
    final stamp = data.checkedAt?.millisecondsSinceEpoch ??
        data.services
            .map((service) => service.checkedAt?.millisecondsSinceEpoch ?? 0)
            .fold<int>(
              0,
              (current, value) => value > current ? value : current,
            );

    if (stamp == 0 || stamp == _lastObservedStamp) {
      return;
    }

    _lastObservedStamp = stamp;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      _requestPulseController.forward(from: 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final statusAsync = ref.watch(systemStatusProvider);

    final currentData = statusAsync.valueOrNull;
    if (currentData != null) {
      _syncPulseWithData(currentData);
    }

    return Padding(
      padding: AdminResponsive.pageInsets(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(
            autoRefresh: _autoRefresh,
            onAutoRefreshChanged: _setAutoRefresh,
            onRefresh: _triggerRefresh,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: statusAsync.when(
              loading: () => const SystemStatusSkeleton(),
              error: (error, _) => _ErrorState(
                message: systemStatusErrorMessage(error),
                onRetry: _triggerRefresh,
              ),
              data: (data) {
                final services = _ResolvedServices.from(data.services);

                final selected = _selectedServiceId == null
                    ? services.main
                    : services.byId(_selectedServiceId!) ?? services.main;

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _InlineSummary(data: data),
                      const SizedBox(height: 14),
                      _RequestFlowCanvas(
                        data: data,
                        services: services,
                        selectedServiceId: selected?.id,
                        flow: _flowController,
                        requestPulse: _requestPulseController,
                        onSelected: (id) {
                          setState(() {
                            _selectedServiceId =
                                _selectedServiceId == id ? null : id;
                          });
                        },
                      ),
                      if (selected != null) ...[
                        const SizedBox(height: 14),
                        _ServiceInspector(
                          service: selected,
                          requestPulse: _requestPulseController,
                        ),
                      ],
                      const SizedBox(height: 10),
                      _Footer(data: data),
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

class _Header extends StatelessWidget {
  const _Header({
    required this.autoRefresh,
    required this.onAutoRefreshChanged,
    required this.onRefresh,
  });

  final bool autoRefresh;
  final ValueChanged<bool> onAutoRefreshChanged;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return AdminResponsiveHeader(
      heading: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'OPERATIONS / REQUEST FLOW',
            style: TextStyle(
              color: AppColors.primaryBright,
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            'System Status',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 4),
          Text(
            'Live request health across the log.CKD platform.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      actions: [
        _MiniAutoRefresh(
          enabled: autoRefresh,
          onTap: () => onAutoRefreshChanged(!autoRefresh),
        ),
        Tooltip(
          message: 'Refresh now',
          child: IconButton(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh_rounded),
            color: AppColors.textSecondary,
            hoverColor: AppColors.surfaceHover,
            splashRadius: 20,
          ),
        ),
      ],
    );
  }
}

class _MiniAutoRefresh extends StatelessWidget {
  const _MiniAutoRefresh({
    required this.enabled,
    required this.onTap,
  });

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: enabled
          ? 'Auto refresh every 60 seconds'
          : 'Auto refresh is off',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.sync_rounded,
                size: 16,
                color: enabled
                    ? AppColors.primaryBright
                    : AppColors.textMuted,
              ),
              const SizedBox(width: 6),
              Text(
                enabled ? '60s' : 'Off',
                style: TextStyle(
                  color: enabled
                      ? AppColors.primaryBright
                      : AppColors.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: .25,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InlineSummary extends StatelessWidget {
  const _InlineSummary({required this.data});

  final SystemStatusData data;

  @override
  Widget build(BuildContext context) {
    final ok = data.summary.issues == 0;
    final color = ok ? AppColors.success : AppColors.warning;

    return Wrap(
      spacing: 22,
      runSpacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: .42),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              ok ? 'All systems operational' : 'Service issue detected',
              style: TextStyle(
                color: color,
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        _SummaryPair(label: 'SERVICES', value: '${data.summary.total}'),
        _SummaryPair(label: 'ONLINE', value: '${data.summary.online}'),
        _SummaryPair(label: 'ISSUES', value: '${data.summary.issues}'),
        _SummaryPair(
          label: 'CHECKED',
          value: _formatTime(data.checkedAt),
        ),
      ],
    );
  }
}

class _SummaryPair extends StatelessWidget {
  const _SummaryPair({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 8.5,
            fontWeight: FontWeight.w800,
            letterSpacing: .6,
          ),
        ),
        const SizedBox(width: 7),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _RequestFlowCanvas extends StatelessWidget {
  const _RequestFlowCanvas({
    required this.data,
    required this.services,
    required this.selectedServiceId,
    required this.flow,
    required this.requestPulse,
    required this.onSelected,
  });

  final SystemStatusData data;
  final _ResolvedServices services;
  final String? selectedServiceId;
  final Animation<double> flow;
  final Animation<double> requestPulse;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 860) {
          return _CompactRequestFlow(
            services: services,
            selectedServiceId: selectedServiceId,
            requestPulse: requestPulse,
            onSelected: onSelected,
          );
        }

        final size = Size(constraints.maxWidth, 540);
        final geometry = _RequestFlowGeometry.fromSize(size);

        return Container(
          height: size.height,
          decoration: BoxDecoration(
            color: const Color(0xFF0B0F12),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.borderStrong),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              const Positioned.fill(
                child: CustomPaint(
                  painter: _DottedGridPainter(),
                ),
              ),
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: Listenable.merge([
                    flow,
                    requestPulse,
                  ]),
                  builder: (context, _) {
                    return CustomPaint(
                      painter: _RequestFlowPainter(
                        geometry: geometry,
                        flow: flow.value,
                        pulse: requestPulse.value,
                        services: services,
                      ),
                    );
                  },
                ),
              ),
              Positioned.fromRect(
                rect: geometry.monitorRect,
                child: AnimatedBuilder(
                  animation: requestPulse,
                  builder: (context, child) {
                    final pulse =
                        math.sin(math.pi * requestPulse.value).clamp(0.0, 1.0).toDouble();

                    return _HealthMonitorNode(
                      pulse: pulse,
                      child: child!,
                    );
                  },
                  child: const _HealthMonitorNodeBody(),
                ),
              ),
              if (services.risk != null)
                Positioned.fromRect(
                  rect: geometry.riskRect,
                  child: _AnimatedRequestNode(
                    service: services.risk!,
                    icon: Icons.psychology_alt_outlined,
                    selected: selectedServiceId == services.risk!.id,
                    requestPulse: requestPulse,
                    onTap: () => onSelected(services.risk!.id),
                  ),
                ),
              if (services.main != null)
                Positioned.fromRect(
                  rect: geometry.mainRect,
                  child: _AnimatedRequestNode(
                    service: services.main!,
                    icon: Icons.dns_outlined,
                    selected: selectedServiceId == services.main!.id,
                    requestPulse: requestPulse,
                    onTap: () => onSelected(services.main!.id),
                  ),
                ),
              if (services.backup != null)
                Positioned.fromRect(
                  rect: geometry.backupRect,
                  child: _AnimatedRequestNode(
                    service: services.backup!,
                    icon: Icons.cloud_upload_outlined,
                    selected: selectedServiceId == services.backup!.id,
                    requestPulse: requestPulse,
                    onTap: () => onSelected(services.backup!.id),
                  ),
                ),
              const Positioned(
                left: 22,
                top: 18,
                child: _CanvasLabel(),
              ),
              Positioned(
                right: 22,
                top: 18,
                child: _PlatformHealthBadge(data: data),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CanvasLabel extends StatelessWidget {
  const _CanvasLabel();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.hub_outlined,
          size: 13,
          color: AppColors.primaryBright,
        ),
        SizedBox(width: 6),
        Text(
          'LIVE REQUEST GRAPH',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 8.5,
            fontWeight: FontWeight.w800,
            letterSpacing: .8,
          ),
        ),
      ],
    );
  }
}

class _PlatformHealthBadge extends StatelessWidget {
  const _PlatformHealthBadge({
    required this.data,
  });

  final SystemStatusData data;

  @override
  Widget build(BuildContext context) {
    final ok = data.summary.issues == 0;
    final color = ok ? AppColors.success : AppColors.warning;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(
          color: color.withValues(alpha: .22),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            ok
                ? '${data.summary.online}/${data.summary.total} healthy'
                : '${data.summary.issues} issue(s)',
            style: TextStyle(
              color: color,
              fontSize: 8.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _HealthMonitorNode extends StatelessWidget {
  const _HealthMonitorNode({
    required this.pulse,
    required this.child,
  });

  final double pulse;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xF213181B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.primaryBright.withValues(
            alpha: .32 + (.34 * pulse),
          ),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(
              alpha: .08 + (.24 * pulse),
            ),
            blurRadius: 18 + (24 * pulse),
            spreadRadius: 1 + (3 * pulse),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: .32),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _HealthMonitorNodeBody extends StatelessWidget {
  const _HealthMonitorNodeBody();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: AppColors.primaryBright.withValues(alpha: .26),
              ),
            ),
            child: const Icon(
              Icons.route_outlined,
              color: AppColors.primaryBright,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Health Monitor',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Dispatches GET checks to each platform service.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 9.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
          _MethodChip(label: 'GET'),
        ],
      ),
    );
  }
}

class _AnimatedRequestNode extends StatelessWidget {
  const _AnimatedRequestNode({
    required this.service,
    required this.icon,
    required this.selected,
    required this.requestPulse,
    required this.onTap,
  });

  final SystemServiceStatus service;
  final IconData icon;
  final bool selected;
  final Animation<double> requestPulse;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(service.status);

    return AnimatedBuilder(
      animation: requestPulse,
      builder: (context, _) {
        final pulse =
            math.sin(math.pi * requestPulse.value).clamp(0.0, 1.0).toDouble();

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFF1B2024)
                    : const Color(0xF5181D20),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected
                      ? AppColors.primaryBright.withValues(alpha: .72)
                      : statusColor.withValues(
                          alpha: .22 + (.26 * pulse),
                        ),
                  width: selected ? 1.35 : 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: statusColor.withValues(
                      alpha: .07 + (.24 * pulse),
                    ),
                    blurRadius: 16 + (30 * pulse),
                    spreadRadius: .5 + (3.4 * pulse),
                  ),
                  if (selected)
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: .16),
                      blurRadius: 26,
                    ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .34),
                    blurRadius: 18,
                    offset: const Offset(0, 9),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: statusColor.withValues(alpha: .24),
                      ),
                    ),
                    child: Icon(
                      icon,
                      color: statusColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                service.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            const _MethodChip(label: 'GET'),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            _ResponseBadge(
                              status: service.status,
                              httpStatus: service.httpStatus,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                service.url ?? 'Not configured',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 9.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (service.responseTimeMs != null)
                        Text(
                          '${service.responseTimeMs} ms',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      const SizedBox(height: 5),
                      AnimatedRotation(
                        duration: const Duration(milliseconds: 180),
                        turns: selected ? .25 : 0,
                        child: const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.textMuted,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MethodChip extends StatelessWidget {
  const _MethodChip({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: AppColors.success.withValues(alpha: .22),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.success,
          fontSize: 7.5,
          fontWeight: FontWeight.w900,
          letterSpacing: .4,
        ),
      ),
    );
  }
}

class _ResponseBadge extends StatelessWidget {
  const _ResponseBadge({
    required this.status,
    required this.httpStatus,
  });

  final String status;
  final int? httpStatus;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);
    final text = status == 'online'
        ? 'SUCCESS'
        : status == 'degraded'
            ? 'DEGRADED'
            : status == 'offline'
                ? 'FAILED'
                : _statusLabel(status);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 7.7,
            fontWeight: FontWeight.w900,
            letterSpacing: .35,
          ),
        ),
        if (httpStatus != null) ...[
          const SizedBox(width: 5),
          Text(
            '$httpStatus',
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 7.7,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
        const SizedBox(width: 5),
        Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: .45),
                blurRadius: 7,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CompactRequestFlow extends StatelessWidget {
  const _CompactRequestFlow({
    required this.services,
    required this.selectedServiceId,
    required this.requestPulse,
    required this.onSelected,
  });

  final _ResolvedServices services;
  final String? selectedServiceId;
  final Animation<double> requestPulse;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final items = <({SystemServiceStatus service, IconData icon})>[
      if (services.main != null)
        (service: services.main!, icon: Icons.dns_outlined),
      if (services.risk != null)
        (service: services.risk!, icon: Icons.psychology_alt_outlined),
      if (services.backup != null)
        (service: services.backup!, icon: Icons.cloud_upload_outlined),
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0B0F12),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.borderStrong),
      ),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: requestPulse,
            builder: (context, child) {
              final pulse =
                  math.sin(math.pi * requestPulse.value).clamp(0.0, 1.0).toDouble();

              return _HealthMonitorNode(
                pulse: pulse,
                child: child!,
              );
            },
            child: const SizedBox(
              height: 86,
              child: _HealthMonitorNodeBody(),
            ),
          ),
          for (var i = 0; i < items.length; i++) ...[
            const _VerticalFlowConnector(),
            SizedBox(
              height: 92,
              child: _AnimatedRequestNode(
                service: items[i].service,
                icon: items[i].icon,
                selected: selectedServiceId == items[i].service.id,
                requestPulse: requestPulse,
                onTap: () => onSelected(items[i].service.id),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _VerticalFlowConnector extends StatelessWidget {
  const _VerticalFlowConnector();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 22,
      child: Center(
        child: Container(
          width: 1,
          color: AppColors.primary.withValues(alpha: .26),
        ),
      ),
    );
  }
}

class _ServiceInspector extends StatelessWidget {
  const _ServiceInspector({
    required this.service,
    required this.requestPulse,
  });

  final SystemServiceStatus service;
  final Animation<double> requestPulse;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(service.status);

    return AnimatedBuilder(
      animation: requestPulse,
      builder: (context, child) {
        final pulse =
            math.sin(math.pi * requestPulse.value).clamp(0.0, 1.0).toDouble();

        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: color.withValues(
                alpha: .22 + (.15 * pulse),
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(
                  alpha: .04 + (.08 * pulse),
                ),
                blurRadius: 20 + (12 * pulse),
              ),
            ],
          ),
          child: child,
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.name,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      service.message ?? 'Service health request details.',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10.5,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              _TinyStatus(status: service.status),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final stacked = constraints.maxWidth < 760;

              final left = Column(
                children: [
                  _DarkField(
                    label: 'SERVICE ENDPOINT',
                    icon: Icons.link_rounded,
                    value: service.url ?? 'Not configured',
                    onCopy: service.url == null
                        ? null
                        : () => Clipboard.setData(
                              ClipboardData(text: service.url!),
                            ),
                  ),
                  const SizedBox(height: 10),
                  _DarkField(
                    label: 'HEALTH PATH',
                    icon: Icons.monitor_heart_outlined,
                    value: service.healthPath ?? '/',
                  ),
                ],
              );

              final right = Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _MetricField(
                    label: 'HTTP',
                    value: service.httpStatus?.toString() ?? '—',
                  ),
                  _MetricField(
                    label: 'LATENCY',
                    value: service.responseTimeMs == null
                        ? '—'
                        : '${service.responseTimeMs} ms',
                  ),
                  _MetricField(
                    label: 'UPTIME',
                    value: _formatUptime(service.uptimeSeconds),
                  ),
                  _MetricField(
                    label: 'ENVIRONMENT',
                    value: service.environment ?? '—',
                  ),
                  _MetricField(
                    label: 'RUNTIME',
                    value: service.nodeVersion ?? '—',
                  ),
                  if (service.errorCode != null)
                    _MetricField(
                      label: 'ERROR',
                      value: service.errorCode!,
                    ),
                ],
              );

              if (stacked) {
                return Column(
                  children: [
                    left,
                    const SizedBox(height: 12),
                    right,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: left),
                  const SizedBox(width: 12),
                  Expanded(flex: 2, child: right),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.schedule_rounded,
                size: 13,
                color: color,
              ),
              const SizedBox(width: 6),
              Text(
                service.checkedAt == null
                    ? 'No check time'
                    : 'Last request completed ${_formatTime(service.checkedAt)}',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DarkField extends StatelessWidget {
  const _DarkField({
    required this.label,
    required this.icon,
    required this.value,
    this.onCopy,
  });

  final String label;
  final IconData icon;
  final String value;
  final VoidCallback? onCopy;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: _fieldLabelStyle,
        ),
        const SizedBox(height: 6),
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 11),
          decoration: BoxDecoration(
            color: AppColors.surfaceRaised,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 14,
                color: AppColors.primaryBright,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 9.5,
                  ),
                ),
              ),
              if (onCopy != null)
                IconButton(
                  onPressed: onCopy,
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(
                    width: 26,
                    height: 26,
                  ),
                  icon: const Icon(
                    Icons.copy_rounded,
                    size: 13,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetricField extends StatelessWidget {
  const _MetricField({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 122,
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.backgroundRaised,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: _fieldLabelStyle,
          ),
          const SizedBox(height: 5),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _TinyStatus extends StatelessWidget {
  const _TinyStatus({
    required this.status,
  });

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .09),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(
          color: color.withValues(alpha: .24),
        ),
      ),
      child: Text(
        _statusLabel(status),
        style: TextStyle(
          color: color,
          fontSize: 8,
          fontWeight: FontWeight.w800,
          letterSpacing: .45,
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({
    required this.data,
  });

  final SystemStatusData data;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.info_outline_rounded,
          size: 13,
          color: AppColors.textMuted,
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            'Reachability monitor · service health only · last checked '
            '${_formatDateTime(data.checkedAt)}',
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 8.5,
            ),
          ),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 460,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderStrong),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color: AppColors.danger,
              size: 30,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _RequestFlowGeometry {
  const _RequestFlowGeometry({
    required this.monitorRect,
    required this.riskRect,
    required this.mainRect,
    required this.backupRect,
  });

  final Rect monitorRect;
  final Rect riskRect;
  final Rect mainRect;
  final Rect backupRect;

  factory _RequestFlowGeometry.fromSize(Size size) {
    const sideMargin = 44.0;
    const monitorWidth = 260.0;
    const monitorHeight = 92.0;
    const nodeHeight = 96.0;

    final nodeWidth = math.min(
      380.0,
      math.max(300.0, size.width * .34),
    );

    final rightX = size.width - sideMargin - nodeWidth;

    final monitorRect = Rect.fromLTWH(
      sideMargin,
      (size.height - monitorHeight) / 2,
      monitorWidth,
      monitorHeight,
    );

    return _RequestFlowGeometry(
      monitorRect: monitorRect,
      riskRect: Rect.fromLTWH(
        rightX,
        72,
        nodeWidth,
        nodeHeight,
      ),
      mainRect: Rect.fromLTWH(
        rightX,
        222,
        nodeWidth,
        nodeHeight,
      ),
      backupRect: Rect.fromLTWH(
        rightX,
        372,
        nodeWidth,
        nodeHeight,
      ),
    );
  }

  Path pathTo(Rect target) {
    final start = Offset(
      monitorRect.right,
      monitorRect.center.dy,
    );

    final end = Offset(
      target.left,
      target.center.dy,
    );

    final horizontal = math.max(80.0, (end.dx - start.dx) * .58);

    return Path()
      ..moveTo(start.dx, start.dy)
      ..cubicTo(
        start.dx + horizontal,
        start.dy,
        end.dx - horizontal,
        end.dy,
        end.dx,
        end.dy,
      );
  }
}

class _RequestFlowPainter extends CustomPainter {
  const _RequestFlowPainter({
    required this.geometry,
    required this.flow,
    required this.pulse,
    required this.services,
  });

  final _RequestFlowGeometry geometry;
  final double flow;
  final double pulse;
  final _ResolvedServices services;

  @override
  void paint(Canvas canvas, Size size) {
    final pulseStrength =
        math.sin(math.pi * pulse).clamp(0.0, 1.0).toDouble();

    final paths = <({Path path, SystemServiceStatus? service, double offset})>[
      (
        path: geometry.pathTo(geometry.riskRect),
        service: services.risk,
        offset: 0.0,
      ),
      (
        path: geometry.pathTo(geometry.mainRect),
        service: services.main,
        offset: .28,
      ),
      (
        path: geometry.pathTo(geometry.backupRect),
        service: services.backup,
        offset: .56,
      ),
    ];

    for (final item in paths) {
      if (item.service == null) {
        continue;
      }

      final color = _statusColor(item.service!.status);

      canvas.drawPath(
        item.path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.3
          ..color = AppColors.borderStrong.withValues(alpha: .82),
      );

      canvas.drawPath(
        item.path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.1
          ..color = AppColors.primary.withValues(
            alpha: .18 + (.16 * pulseStrength),
          ),
      );

      if (pulseStrength > .02) {
        canvas.drawPath(
          item.path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 5.4
            ..maskFilter = const MaskFilter.blur(
              BlurStyle.normal,
              8,
            )
            ..color = color.withValues(
              alpha: .08 * pulseStrength,
            ),
        );
      }

      _drawTravelingParticle(
        canvas,
        item.path,
        (flow + item.offset) % 1,
        color,
        pulseStrength,
      );
    }
  }

  void _drawTravelingParticle(
    Canvas canvas,
    Path path,
    double progress,
    Color color,
    double pulseStrength,
  ) {
    final metrics = path.computeMetrics().toList();

    if (metrics.isEmpty) {
      return;
    }

    final metric = metrics.first;
    final tangent = metric.getTangentForOffset(
      metric.length * progress,
    );

    if (tangent == null) {
      return;
    }

    final point = tangent.position;

    canvas.drawCircle(
      point,
      10 + (4 * pulseStrength),
      Paint()
        ..color = color.withValues(
          alpha: .06 + (.08 * pulseStrength),
        )
        ..maskFilter = const MaskFilter.blur(
          BlurStyle.normal,
          8,
        ),
    );

    canvas.drawCircle(
      point,
      3.2 + (1.2 * pulseStrength),
      Paint()
        ..color = color.withValues(
          alpha: .74 + (.18 * pulseStrength),
        ),
    );

    canvas.drawCircle(
      point,
      1.2,
      Paint()..color = Colors.white.withValues(alpha: .85),
    );
  }

  @override
  bool shouldRepaint(covariant _RequestFlowPainter oldDelegate) {
    return oldDelegate.flow != flow ||
        oldDelegate.pulse != pulse ||
        oldDelegate.services != services ||
        oldDelegate.geometry != geometry;
  }
}

class _DottedGridPainter extends CustomPainter {
  const _DottedGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.textMuted.withValues(alpha: .11);

    const spacing = 24.0;

    for (double x = 12; x < size.width; x += spacing) {
      for (double y = 12; y < size.height; y += spacing) {
        canvas.drawCircle(
          Offset(x, y),
          .75,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DottedGridPainter oldDelegate) => false;
}

class _ResolvedServices {
  const _ResolvedServices({
    required this.main,
    required this.risk,
    required this.backup,
  });

  final SystemServiceStatus? main;
  final SystemServiceStatus? risk;
  final SystemServiceStatus? backup;

  factory _ResolvedServices.from(List<SystemServiceStatus> services) {
    SystemServiceStatus? byMatch(List<String> terms) {
      for (final service in services) {
        final haystack = '${service.id} ${service.name}'.toLowerCase();

        if (terms.any(haystack.contains)) {
          return service;
        }
      }

      return null;
    }

    return _ResolvedServices(
      main: byMatch([
            'main',
            'backend',
            'api',
          ]) ??
          (services.isNotEmpty ? services.first : null),
      risk: byMatch([
            'risk',
            'engine',
          ]) ??
          (services.length > 1 ? services[1] : null),
      backup: byMatch([
            'backup',
          ]) ??
          (services.length > 2 ? services[2] : null),
    );
  }

  SystemServiceStatus? byId(String id) {
    for (final service in [
      main,
      risk,
      backup,
    ]) {
      if (service?.id == id) {
        return service;
      }
    }

    return null;
  }
}

const _fieldLabelStyle = TextStyle(
  color: AppColors.textMuted,
  fontSize: 7.8,
  fontWeight: FontWeight.w800,
  letterSpacing: .65,
);

Color _statusColor(String status) {
  switch (status) {
    case 'online':
      return AppColors.success;
    case 'degraded':
      return AppColors.warning;
    case 'offline':
      return AppColors.danger;
    case 'not_configured':
      return AppColors.warning;
    default:
      return AppColors.textMuted;
  }
}

String _statusLabel(String status) {
  return status
      .replaceAll('_', ' ')
      .trim()
      .split(RegExp(r'\s+'))
      .map(
        (part) => part.isEmpty
            ? part
            : '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}',
      )
      .join(' ')
      .toUpperCase();
}

String _formatTime(DateTime? value) {
  if (value == null) {
    return '—';
  }

  final local = value.toLocal();

  return '${local.hour.toString().padLeft(2, '0')}:'
      '${local.minute.toString().padLeft(2, '0')}';
}

String _formatDateTime(DateTime? value) {
  if (value == null) {
    return '—';
  }

  final local = value.toLocal();

  return '${local.year.toString().padLeft(4, '0')}-'
      '${local.month.toString().padLeft(2, '0')}-'
      '${local.day.toString().padLeft(2, '0')} '
      '${local.hour.toString().padLeft(2, '0')}:'
      '${local.minute.toString().padLeft(2, '0')}:'
      '${local.second.toString().padLeft(2, '0')}';
}

String _formatUptime(int? seconds) {
  if (seconds == null) {
    return '—';
  }

  if (seconds < 60) {
    return '${seconds}s';
  }

  final minutes = seconds ~/ 60;

  if (minutes < 60) {
    return '${minutes}m';
  }

  final hours = minutes ~/ 60;
  final remainingMinutes = minutes % 60;

  if (hours < 24) {
    return remainingMinutes == 0
        ? '${hours}h'
        : '${hours}h ${remainingMinutes}m';
  }

  final days = hours ~/ 24;
  final remainingHours = hours % 24;

  return remainingHours == 0
      ? '${days}d'
      : '${days}d ${remainingHours}h';
}
