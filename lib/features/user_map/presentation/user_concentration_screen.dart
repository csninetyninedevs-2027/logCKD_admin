import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:maplibre_gl/maplibre_gl.dart' as ml;

import '../../../core/theme/app_theme.dart';
import '../../../shared/models/user_concentration.dart';
import '../../../shared/widgets/admin_responsive.dart';
import '../../../shared/widgets/user_concentration_skeleton.dart';
import '../data/philippine_region_centroids.dart';
import '../state/user_concentration_provider.dart';

class UserConcentrationScreen extends ConsumerStatefulWidget {
  const UserConcentrationScreen({super.key});

  @override
  ConsumerState<UserConcentrationScreen> createState() =>
      _UserConcentrationScreenState();
}

class _UserConcentrationScreenState
    extends ConsumerState<UserConcentrationScreen> {
  String? _selectedRegion;
  int _resetEpoch = 0;

  void _resetMap() {
    setState(() {
      _selectedRegion = null;
      _resetEpoch++;
    });
  }

  void _selectRegion(_MappedRegion region) {
    setState(() => _selectedRegion = region.data.region);
  }

  @override
  Widget build(BuildContext context) {
    final dataAsync = ref.watch(userConcentrationProvider);

    return SingleChildScrollView(
      padding: AdminResponsive.pageInsets(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(
            onReset: _resetMap,
            onRefresh: () => ref.invalidate(userConcentrationProvider),
          ),
          const SizedBox(height: 20),
          dataAsync.when(
            loading: () => const UserConcentrationSkeleton(),
            error: (error, _) => _ErrorView(
              message: error.toString(),
              onRetry: () => ref.invalidate(userConcentrationProvider),
            ),
            data: (data) {
              if (data.regions.isEmpty) {
                return const SizedBox(
                  height: 420,
                  child: Center(
                    child: Text('No regional user data is available yet.'),
                  ),
                );
              }

              final mapped = <_MappedRegion>[];
              final unmapped = <UserConcentration>[];

              for (final region in data.regions) {
                final point = resolvePhilippineRegion(region.region);
                if (point == null) {
                  unmapped.add(region);
                } else {
                  mapped.add(_MappedRegion(data: region, point: point));
                }
              }

              final mappedUsers = mapped.fold<int>(
                0,
                (total, item) => total + item.data.count,
              );
              final topRegion = data.regions.isEmpty
                  ? null
                  : data.regions.first;

              return Column(
                children: [
                  _SummaryGrid(
                    totalUsers: data.totalUsers,
                    mappedRegions: mapped.length,
                    mappedUsers: mappedUsers,
                    topRegion: topRegion,
                  ),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final wide = constraints.maxWidth >= 1120;
                      final panelHeight = wide ? 610.0 : 520.0;

                      if (wide) {
                        return SizedBox(
                          height: panelHeight,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: _MapPanel(
                                  regions: mapped,
                                  selectedRegion: _selectedRegion,
                                  totalUsers: data.totalUsers,
                                  onSelected: _selectRegion,
                                  resetEpoch: _resetEpoch,
                                ),
                              ),
                              const SizedBox(width: 16),
                              SizedBox(
                                width: 340,
                                child: _RegionListPanel(
                                  regions: data.regions,
                                  mappedRegions: mapped,
                                  unmappedRegions: unmapped,
                                  totalUsers: data.totalUsers,
                                  selectedRegion: _selectedRegion,
                                  onSelected: _selectRegion,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return Column(
                        children: [
                          SizedBox(
                            height: panelHeight,
                            child: _MapPanel(
                              regions: mapped,
                              selectedRegion: _selectedRegion,
                              totalUsers: data.totalUsers,
                              onSelected: _selectRegion,
                              resetEpoch: _resetEpoch,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 500,
                            child: _RegionListPanel(
                              regions: data.regions,
                              mappedRegions: mapped,
                              unmappedRegions: unmapped,
                              totalUsers: data.totalUsers,
                              selectedRegion: _selectedRegion,
                              onSelected: _selectRegion,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onReset, required this.onRefresh});

  final VoidCallback onReset;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return AdminResponsiveHeader(
      heading: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'MAP / REGIONAL SIGNALS',
            style: TextStyle(
              color: AppColors.primaryBright,
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.15,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            'User Concentration',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 4),
          Text(
            'Aggregated user distribution by Philippine region.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      actions: [
        OutlinedButton.icon(
          onPressed: onReset,
          icon: const Icon(Icons.center_focus_strong_outlined, size: 17),
          label: const Text('Reset view'),
        ),
        IconButton(
          tooltip: 'Refresh',
          onPressed: onRefresh,
          icon: const Icon(Icons.refresh_rounded),
        ),
      ],
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({
    required this.totalUsers,
    required this.mappedRegions,
    required this.mappedUsers,
    required this.topRegion,
  });

  final int totalUsers;
  final int mappedRegions;
  final int mappedUsers;
  final UserConcentration? topRegion;

  @override
  Widget build(BuildContext context) {
    final coverage = totalUsers == 0 ? 0.0 : mappedUsers / totalUsers * 100;
    final items = [
      _SummaryData(
        title: 'Users With Region',
        value: '$totalUsers',
        subtitle: 'Regional profiles',
        icon: Icons.people_outline_rounded,
      ),
      _SummaryData(
        title: 'Mapped Regions',
        value: '$mappedRegions',
        subtitle: 'Resolved centroids',
        icon: Icons.map_outlined,
      ),
      _SummaryData(
        title: 'Map Coverage',
        value: '${coverage.toStringAsFixed(1)}%',
        subtitle: '$mappedUsers mapped users',
        icon: Icons.location_on_outlined,
      ),
      _SummaryData(
        title: 'Highest Concentration',
        value: topRegion == null ? '—' : '${topRegion!.count}',
        subtitle: topRegion?.region ?? 'No data',
        icon: Icons.trending_up_rounded,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 12.0;
        final columns = constraints.maxWidth >= 1050
            ? 4
            : constraints.maxWidth >= 650
            ? 2
            : 1;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final item in items)
              SizedBox(
                width: width,
                child: _SummaryCard(data: item),
              ),
          ],
        );
      },
    );
  }
}

class _SummaryData {
  const _SummaryData({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.data});

  final _SummaryData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: .92),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: .11),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: .13),
              ),
            ),
            child: Icon(data.icon, color: AppColors.primaryBright, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  data.value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -.6,
                  ),
                ),
                Text(
                  data.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MapPanel extends StatefulWidget {
  const _MapPanel({
    required this.regions,
    required this.selectedRegion,
    required this.totalUsers,
    required this.onSelected,
    required this.resetEpoch,
  });

  final List<_MappedRegion> regions;
  final String? selectedRegion;
  final int totalUsers;
  final ValueChanged<_MappedRegion> onSelected;
  final int resetEpoch;

  @override
  State<_MapPanel> createState() => _MapPanelState();
}

class _MapPanelState extends State<_MapPanel> {
  static const LatLng _defaultCenter = LatLng(12.65, 122.15);
  static const double _defaultZoom = 6.2;
  static const double _minZoom = 4.9;
  static const double _maxZoom = 13.5;
  static const double _baseMapZoomOffset = 1;

  static final LatLngBounds _panBounds = LatLngBounds(
    const LatLng(2.6, 114.0),
    const LatLng(23.8, 130.4),
  );

  final MapController _mapController = MapController();
  ml.MapLibreMapController? _baseMapController;
  double _zoom = _defaultZoom;
  bool _mapReady = false;

  @override
  void didUpdateWidget(covariant _MapPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.resetEpoch != widget.resetEpoch) {
      _resetMapView();
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    _baseMapController?.dispose();
    super.dispose();
  }

  void _onBaseMapCreated(ml.MapLibreMapController controller) {
    _baseMapController = controller;
    if (_mapReady) {
      _syncBaseMap(_mapController.camera);
    }
  }

  Future<void> _hideMaritimeBoundaries() async {
    final controller = _baseMapController;
    if (controller == null) {
      return;
    }

    const landBordersOnly = <dynamic>[
      'all',
      <dynamic>[
        '==',
        <dynamic>['get', 'admin_level'],
        2,
      ],
      <dynamic>[
        '!=',
        <dynamic>['get', 'maritime'],
        1,
      ],
    ];
    const lowZoomLandBordersOnly = <dynamic>[
      'all',
      <dynamic>[
        '==',
        <dynamic>['get', 'admin_level'],
        2,
      ],
      <dynamic>[
        '!=',
        <dynamic>['get', 'maritime'],
        1,
      ],
      <dynamic>[
        '!',
        <dynamic>['has', 'claimed_by'],
      ],
    ];

    await controller.setFilter('boundary_country_z0-4', lowZoomLandBordersOnly);
    await controller.setFilter('boundary_country_z5-', landBordersOnly);
  }

  Future<void> _highlightRoads() async {
    final controller = _baseMapController;
    if (controller == null) {
      return;
    }

    await Future.wait([
      controller.setLayerProperties(
        'highway_motorway_subtle',
        const ml.LineLayerProperties(lineColor: '#2C7884', lineOpacity: .78),
      ),
      controller.setLayerProperties(
        'highway_motorway_inner',
        const ml.LineLayerProperties(lineColor: '#3A8995', lineOpacity: .88),
      ),
      controller.setLayerProperties(
        'highway_major_subtle',
        const ml.LineLayerProperties(lineColor: '#326974', lineOpacity: .68),
      ),
      controller.setLayerProperties(
        'highway_major_inner',
        const ml.LineLayerProperties(lineColor: '#39727C', lineOpacity: .76),
      ),
      controller.setLayerProperties(
        'highway_minor',
        const ml.LineLayerProperties(lineColor: '#28545C', lineOpacity: .58),
      ),
    ]);
  }

  Future<void> _configureBaseMapStyle() async {
    await Future.wait([_hideMaritimeBoundaries(), _highlightRoads()]);
  }

  void _syncBaseMap(MapCamera camera) {
    final controller = _baseMapController;
    if (controller == null) {
      return;
    }

    unawaited(
      controller.moveCamera(
        ml.CameraUpdate.newLatLngZoom(
          ml.LatLng(camera.center.latitude, camera.center.longitude),
          camera.zoom - _baseMapZoomOffset,
        ),
      ),
    );
  }

  void _resetMapView() {
    if (!_mapReady) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _mapReady) {
          _resetMapView();
        }
      });
      return;
    }

    _mapController.move(_defaultCenter, _defaultZoom);
    if ((_zoom - _defaultZoom).abs() > .01 && mounted) {
      setState(() => _zoom = _defaultZoom);
    }
  }

  void _zoomBy(double delta) {
    if (!_mapReady) {
      return;
    }

    final camera = _mapController.camera;
    final target = (camera.zoom + delta).clamp(_minZoom, _maxZoom).toDouble();
    if ((target - camera.zoom).abs() < .001) {
      return;
    }

    _mapController.move(camera.center, target);
  }

  @override
  Widget build(BuildContext context) {
    var maxCount = 1;
    for (final region in widget.regions) {
      maxCount = math.max(maxCount, region.data.count);
    }

    _MappedRegion? selected;
    if (widget.selectedRegion != null) {
      for (final region in widget.regions) {
        if (region.data.region == widget.selectedRegion) {
          selected = region;
          break;
        }
      }
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFF061014),
          border: Border.all(color: AppColors.borderStrong),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: ml.MapLibreMap(
                  initialCameraPosition: const ml.CameraPosition(
                    target: ml.LatLng(12.65, 122.15),
                    zoom: _defaultZoom - _baseMapZoomOffset,
                  ),
                  styleString: 'https://tiles.openfreemap.org/styles/dark',
                  onMapCreated: _onBaseMapCreated,
                  onStyleLoadedCallback: () {
                    unawaited(_configureBaseMapStyle());
                  },
                  compassEnabled: false,
                  rotateGesturesEnabled: false,
                  scrollGesturesEnabled: false,
                  zoomGesturesEnabled: false,
                  tiltGesturesEnabled: false,
                  doubleClickZoomEnabled: false,
                  dragEnabled: false,
                  minMaxZoomPreference: const ml.MinMaxZoomPreference(
                    _minZoom - _baseMapZoomOffset,
                    _maxZoom - _baseMapZoomOffset,
                  ),
                ),
              ),
            ),
            const Positioned.fill(
              child: IgnorePointer(child: ColoredBox(color: Color(0x2600A9B8))),
            ),
            Positioned.fill(
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _defaultCenter,
                  initialZoom: _defaultZoom,
                  minZoom: _minZoom,
                  maxZoom: _maxZoom,
                  backgroundColor: Colors.transparent,
                  cameraConstraint: CameraConstraint.containCenter(
                    bounds: _panBounds,
                  ),
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                  ),
                  onMapReady: () {
                    _mapReady = true;
                    _syncBaseMap(_mapController.camera);
                    if (mounted) {
                      setState(() {
                        _zoom = _mapController.camera.zoom;
                      });
                    }
                  },
                  onPositionChanged: (camera, hasGesture) {
                    _syncBaseMap(camera);
                    if (!mounted || (camera.zoom - _zoom).abs() < .01) {
                      return;
                    }
                    setState(() => _zoom = camera.zoom);
                  },
                ),
                children: [
                  MarkerLayer(
                    markers: [
                      for (final region in widget.regions)
                        Marker(
                          point: region.point.position,
                          width: 98,
                          height: 98,
                          alignment: Alignment.center,
                          child: _MapRegionMarker(
                            key: ValueKey(region.data.region),
                            region: region,
                            maxCount: maxCount,
                            selected:
                                widget.selectedRegion == region.data.region,
                            onTap: () => widget.onSelected(region),
                          ),
                        ),
                    ],
                  ),
                  SimpleAttributionWidget(
                    source: const Text(
                      'OpenStreetMap contributors',
                      style: TextStyle(
                        color: Color(0xFF819298),
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    backgroundColor: const Color(0xC2071116),
                    alignment: Alignment.bottomCenter,
                  ),
                ],
              ),
            ),

            // A restrained vignette keeps the Philippines as the visual focus
            // while preserving a genuine interactive basemap underneath.
            const Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Color(0xA8050D11),
                        Color(0x32050D11),
                        Color(0x00050D11),
                        Color(0x00050D11),
                        Color(0x32050D11),
                        Color(0xA8050D11),
                      ],
                      stops: [0, .10, .23, .77, .90, 1],
                    ),
                  ),
                ),
              ),
            ),
            const Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x4D050D11),
                        Color(0x00050D11),
                        Color(0x00050D11),
                        Color(0x59050D11),
                      ],
                      stops: [0, .15, .82, 1],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 16,
              left: 16,
              child: _MapChip(
                icon: _zoom < 7 ? Icons.public_rounded : Icons.route_outlined,
                text: _zoom < 7
                    ? 'PHILIPPINES / MAP OVERVIEW'
                    : 'PHILIPPINES / LOCAL MAP DETAIL',
              ),
            ),
            if (selected != null)
              Positioned(
                top: 16,
                right: 16,
                child: _MapSelectionCard(
                  region: selected,
                  totalUsers: widget.totalUsers,
                ),
              ),
            const Positioned(left: 20, bottom: 18, child: _MapLegend()),
            Positioned(
              right: 16,
              bottom: 16,
              child: _MapZoomControls(
                zoom: _zoom,
                onZoomIn: () => _zoomBy(.75),
                onZoomOut: () => _zoomBy(-.75),
                onReset: _resetMapView,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapRegionMarker extends StatefulWidget {
  const _MapRegionMarker({
    super.key,
    required this.region,
    required this.maxCount,
    required this.selected,
    required this.onTap,
  });

  final _MappedRegion region;
  final int maxCount;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_MapRegionMarker> createState() => _MapRegionMarkerState();
}

class _MapRegionMarkerState extends State<_MapRegionMarker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1180),
    )..addStatusListener(_handlePulseStatus);

    if (widget.selected) {
      _pulseController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant _MapRegionMarker oldWidget) {
    super.didUpdateWidget(oldWidget);

    final gainedUsers = widget.region.data.count > oldWidget.region.data.count;

    if (widget.selected && !oldWidget.selected) {
      _pulseController.repeat();
    } else if (!widget.selected && oldWidget.selected) {
      _pulseController
        ..stop()
        ..value = 0;
    }

    if (gainedUsers && !widget.selected) {
      _pulseController
        ..stop()
        ..forward(from: 0);
    }
  }

  void _handlePulseStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && !widget.selected) {
      _pulseController.value = 0;
    }
  }

  @override
  void dispose() {
    _pulseController
      ..removeStatusListener(_handlePulseStatus)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ratio = widget.region.data.count / math.max(1, widget.maxCount);
    final haloSize = 44.0 + ratio * 24.0;
    final coreSize = widget.selected ? 29.0 : 23.0;

    return Tooltip(
      message:
          '${widget.region.data.region}\n${widget.region.data.count} users',
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, _) {
            final pulse = _pulseController.value;
            final ringScale = .78 + pulse * .82;
            final ringOpacity = (1 - pulse) * (widget.selected ? .68 : .46);

            return Stack(
              alignment: Alignment.center,
              children: [
                if (_pulseController.isAnimating)
                  Transform.scale(
                    scale: ringScale,
                    child: Container(
                      width: haloSize + 20,
                      height: haloSize + 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primaryBright.withValues(
                            alpha: ringOpacity,
                          ),
                          width: 1.3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryBright.withValues(
                              alpha: ringOpacity * .50,
                            ),
                            blurRadius: 22,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  width: haloSize,
                  height: haloSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(
                      0xFF081A20,
                    ).withValues(alpha: widget.selected ? .94 : .78),
                    border: Border.all(
                      color: AppColors.primaryBright.withValues(
                        alpha: widget.selected ? .88 : .42,
                      ),
                      width: widget.selected ? 1.7 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryBright.withValues(
                          alpha: widget.selected ? .34 : .15,
                        ),
                        blurRadius: widget.selected ? 24 : 14,
                        spreadRadius: widget.selected ? 2 : 0,
                      ),
                    ],
                  ),
                  child: Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      width: coreSize,
                      height: coreSize,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.selected
                            ? AppColors.primaryBright
                            : AppColors.primary,
                        border: Border.all(
                          color: const Color(0xFF031012),
                          width: 2,
                        ),
                      ),
                      child: Text(
                        '${widget.region.data.count}',
                        style: TextStyle(
                          color: const Color(0xFF031012),
                          fontSize: widget.region.data.count >= 10 ? 8.5 : 9.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _MapZoomControls extends StatelessWidget {
  const _MapZoomControls({
    required this.zoom,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onReset,
  });

  final double zoom;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xE710171A),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.borderStrong),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .28),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _MapControlButton(
            icon: Icons.add_rounded,
            tooltip: 'Zoom in',
            onTap: onZoomIn,
          ),
          const SizedBox(height: 4),
          Container(
            width: 38,
            padding: const EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.surfaceRaised.withValues(alpha: .78),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'z${zoom.toStringAsFixed(1)}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 8.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 4),
          _MapControlButton(
            icon: Icons.remove_rounded,
            tooltip: 'Zoom out',
            onTap: onZoomOut,
          ),
          const SizedBox(height: 4),
          _MapControlButton(
            icon: Icons.center_focus_strong_rounded,
            tooltip: 'Reset map',
            onTap: onReset,
          ),
        ],
      ),
    );
  }
}

class _MapControlButton extends StatelessWidget {
  const _MapControlButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: SizedBox(
          width: 38,
          height: 32,
          child: Icon(icon, size: 17, color: AppColors.textSecondary),
        ),
      ),
    );
  }
}

class _MapLegend extends StatelessWidget {
  const _MapLegend();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xD910171A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryBright,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryBright.withValues(alpha: .45),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
          const SizedBox(width: 7),
          const Text(
            'User concentration',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MapChip extends StatelessWidget {
  const _MapChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xD910171A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderStrong),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primaryBright),
          const SizedBox(width: 7),
          Text(
            text,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 8.5,
              fontWeight: FontWeight.w800,
              letterSpacing: .9,
            ),
          ),
        ],
      ),
    );
  }
}

class _MapSelectionCard extends StatelessWidget {
  const _MapSelectionCard({required this.region, required this.totalUsers});

  final _MappedRegion region;
  final int totalUsers;

  @override
  Widget build(BuildContext context) {
    final share = totalUsers <= 0 ? 0.0 : region.data.count / totalUsers * 100;

    return Container(
      width: 238,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xED11191C),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderStrong),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .32),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SELECTED REGION',
            style: TextStyle(
              color: AppColors.primaryBright,
              fontSize: 8,
              fontWeight: FontWeight.w800,
              letterSpacing: .9,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            region.data.region,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _MiniMetric(
                  label: 'Users',
                  value: '${region.data.count}',
                ),
              ),
              Expanded(
                child: _MiniMetric(
                  label: 'Share',
                  value: '${share.toStringAsFixed(1)}%',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RegionListPanel extends StatelessWidget {
  const _RegionListPanel({
    required this.regions,
    required this.mappedRegions,
    required this.unmappedRegions,
    required this.totalUsers,
    required this.selectedRegion,
    required this.onSelected,
  });

  final List<UserConcentration> regions;
  final List<_MappedRegion> mappedRegions;
  final List<UserConcentration> unmappedRegions;
  final int totalUsers;
  final String? selectedRegion;
  final ValueChanged<_MappedRegion> onSelected;

  _MappedRegion? _findMapped(String regionName) {
    for (final region in mappedRegions) {
      if (region.data.region == regionName) return region;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    _MappedRegion? selected;
    if (selectedRegion != null) selected = _findMapped(selectedRegion!);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: .94),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 15, 16, 13),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selected == null
                            ? 'Regional Distribution'
                            : 'Selected Region',
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        selected == null
                            ? 'Ranked by registered users'
                            : 'Selection synced with map',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 9.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: .08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: .14),
                    ),
                  ),
                  child: Text(
                    '${regions.length} REGIONS',
                    style: const TextStyle(
                      color: AppColors.primaryBright,
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      letterSpacing: .7,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (selected != null) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(14),
              child: _SelectedRegionCard(
                region: selected,
                totalUsers: totalUsers,
              ),
            ),
          ],
          const Divider(height: 1),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
              itemCount: regions.length,
              separatorBuilder: (_, _) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final region = regions[index];
                final mapped = _findMapped(region.region);
                final percent = totalUsers == 0
                    ? 0.0
                    : region.count / totalUsers;
                final isSelected = region.region == selectedRegion;

                return Material(
                  color: isSelected
                      ? AppColors.sidebarActive
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: mapped == null ? null : () => onSelected(mapped),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 9,
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                width: 24,
                                child: Text(
                                  '${index + 1}'.padLeft(2, '0'),
                                  style: TextStyle(
                                    color: isSelected
                                        ? AppColors.primaryBright
                                        : AppColors.textMuted,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  region.region,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${region.count}',
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(width: 7),
                              SizedBox(
                                width: 40,
                                child: Text(
                                  '${(percent * 100).toStringAsFixed(1)}%',
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 9,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 7),
                          Row(
                            children: [
                              const SizedBox(width: 24),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(99),
                                  child: LinearProgressIndicator(
                                    value: percent,
                                    minHeight: 4,
                                    backgroundColor: AppColors.surfaceSoft,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      isSelected
                                          ? AppColors.primaryBright
                                          : AppColors.primary,
                                    ),
                                  ),
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
            ),
          ),
          if (unmappedRegions.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Text(
                '${unmappedRegions.length} region(s) could not be mapped.',
                style: const TextStyle(color: AppColors.warning, fontSize: 9.5),
              ),
            ),
        ],
      ),
    );
  }
}

class _SelectedRegionCard extends StatelessWidget {
  const _SelectedRegionCard({required this.region, required this.totalUsers});

  final _MappedRegion region;
  final int totalUsers;

  @override
  Widget build(BuildContext context) {
    final share = totalUsers == 0 ? 0.0 : region.data.count / totalUsers * 100;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: .12),
            AppColors.primaryDeep.withValues(alpha: .05),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: .20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            region.data.region,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _MiniMetric(
                  label: 'Users',
                  value: '${region.data.count}',
                ),
              ),
              Expanded(
                child: _MiniMetric(
                  label: 'Share',
                  value: '${share.toStringAsFixed(1)}%',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  const _MiniMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 8.5),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w900,
            letterSpacing: -.4,
          ),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 360,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, color: AppColors.danger),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 10),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

class _MappedRegion {
  const _MappedRegion({required this.data, required this.point});

  final UserConcentration data;
  final PhilippineRegionPoint point;
}
