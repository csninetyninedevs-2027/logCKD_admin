import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/admin_motion.dart';
import '../../core/theme/app_theme.dart';
import '../../features/auth/state/auth_provider.dart';
import 'admin_responsive.dart';

final adminSidebarCollapsedProvider =
    StateProvider<bool>((ref) => false);

class AdminShell extends ConsumerWidget {
  const AdminShell({
    super.key,
    required this.selectedIndex,
    required this.child,
  });

  final int selectedIndex;
  final Widget child;

  static const _destinations = [
    (
      icon: Icons.grid_view_rounded,
      label: 'Dashboard',
      path: '/dashboard',
    ),
    (
      icon: Icons.people_alt_outlined,
      label: 'Users',
      path: '/users',
    ),
    (
      icon: Icons.local_hospital_outlined,
      label: 'Facilities',
      path: '/facilities',
    ),
    (
      icon: Icons.restaurant_menu_rounded,
      label: 'Food Library',
      path: '/foods',
    ),
    (
      icon: Icons.public_rounded,
      label: 'User Map',
      path: '/user-concentration',
    ),
    (
      icon: Icons.monitor_heart_outlined,
      label: 'System',
      path: '/system-status',
    ),
    (
      icon: Icons.science_outlined,
      label: 'Research & Guidelines',
      path: '/research-guidelines',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final admin = ref.watch(authStateProvider).admin;
    final requestedCollapsed =
        ref.watch(adminSidebarCollapsedProvider);

    final width = MediaQuery.sizeOf(context).width;
    final compact = width < AdminBreakpoints.compact;
    final forcedCollapsed =
        width < AdminBreakpoints.navigation;
    final collapsed =
        forcedCollapsed || requestedCollapsed;

    void navigate(int index) {
      context.go(_destinations[index].path);
    }

    final sidebar = _AdminSidebar(
      collapsed: collapsed,
      selectedIndex: selectedIndex,
      adminName: admin?.name ?? 'Administrator',
      adminEmail: admin?.email ?? '',
      adminRole: admin?.role ?? 'admin',
      destinations: _destinations,
      onDestinationSelected: navigate,
      onToggleCollapsed: forcedCollapsed
          ? null
          : () {
              ref
                      .read(
                        adminSidebarCollapsedProvider.notifier,
                      )
                      .state =
                  !requestedCollapsed;
            },
      onLogout: () =>
          ref.read(authStateProvider.notifier).logout(),
    );

    final content = Stack(
      children: [
        const Positioned.fill(
          child: _AdminBackdrop(),
        ),
        Positioned.fill(
          child: SafeArea(
            left: false,
            top: !compact,
            child: child,
          ),
        ),
      ],
    );

    if (compact) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          toolbarHeight: 56,
          titleSpacing: 0,
          title: RichText(
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
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Divider(height: 1),
          ),
        ),
        drawer: Drawer(
          width: 260,
          backgroundColor: AppColors.sidebar,
          child: Builder(
            builder: (drawerContext) => SizedBox.expand(
              child: _AdminSidebar(
                collapsed: false,
                selectedIndex: selectedIndex,
                adminName:
                    admin?.name ?? 'Administrator',
                adminEmail: admin?.email ?? '',
                adminRole: admin?.role ?? 'admin',
                destinations: _destinations,
                onDestinationSelected: (index) {
                  Navigator.of(drawerContext).pop();
                  navigate(index);
                },
                onToggleCollapsed: null,
                onLogout: () => ref
                    .read(authStateProvider.notifier)
                    .logout(),
              ),
            ),
          ),
        ),
        body: content,
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          sidebar,
          Expanded(child: content),
        ],
      ),
    );
  }
}

class _AdminSidebar extends StatelessWidget {
  const _AdminSidebar({
    required this.collapsed,
    required this.selectedIndex,
    required this.adminName,
    required this.adminEmail,
    required this.adminRole,
    required this.destinations,
    required this.onDestinationSelected,
    required this.onToggleCollapsed,
    required this.onLogout,
  });

  final bool collapsed;
  final int selectedIndex;
  final String adminName;
  final String adminEmail;
  final String adminRole;

  final List<
      ({
        IconData icon,
        String label,
        String path,
      })> destinations;

  final ValueChanged<int> onDestinationSelected;
  final VoidCallback? onToggleCollapsed;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AdminMotion.normal,
      curve: AdminMotion.emphasized,
      clipBehavior: Clip.hardEdge,
      width: collapsed ? 76 : 244,
      decoration: const BoxDecoration(
        color: AppColors.sidebar,
        border: Border(
          right: BorderSide(
            color: AppColors.border,
          ),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final contentCollapsed =
              constraints.maxWidth < 220;

          return SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal:
                    contentCollapsed ? 8 : 14,
                vertical: 14,
              ),
              child: Column(
                children: [
                  _Brand(
                    collapsed: contentCollapsed,
                  ),
                  const SizedBox(height: 26),
                  Expanded(
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: destinations.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: 5),
                      itemBuilder:
                          (context, index) {
                        final destination =
                            destinations[index];

                        return _SidebarDestination(
                          collapsed:
                              contentCollapsed,
                          selected:
                              selectedIndex ==
                                  index,
                          icon:
                              destination.icon,
                          label:
                              destination.label,
                          onTap: () =>
                              onDestinationSelected(
                                index,
                              ),
                        );
                      },
                    ),
                  ),
                  _AdminIdentity(
                    collapsed: contentCollapsed,
                    name: adminName,
                    email: adminEmail,
                    role: adminRole,
                  ),
                  const SizedBox(height: 10),
                  if (contentCollapsed)
                    _CollapsedBottomActions(
                      onLogout: onLogout,
                      onToggleCollapsed:
                          onToggleCollapsed,
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child:
                              _SidebarSmallButton(
                            icon:
                                Icons.logout_rounded,
                            label: 'Sign out',
                            onTap: onLogout,
                          ),
                        ),
                        if (onToggleCollapsed !=
                            null) ...[
                          const SizedBox(
                            width: 6,
                          ),
                          Tooltip(
                            message:
                                'Collapse navigation',
                            child:
                                _CompactIconButton(
                              onPressed:
                                  onToggleCollapsed!,
                              icon: Icons
                                  .keyboard_double_arrow_left_rounded,
                            ),
                          ),
                        ],
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CollapsedBottomActions
    extends StatelessWidget {
  const _CollapsedBottomActions({
    required this.onLogout,
    required this.onToggleCollapsed,
  });

  final VoidCallback onLogout;
  final VoidCallback? onToggleCollapsed;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Tooltip(
          message: 'Sign out',
          child: _CompactIconButton(
            onPressed: onLogout,
            icon: Icons.logout_rounded,
          ),
        ),
        if (onToggleCollapsed != null) ...[
          const SizedBox(height: 6),
          Tooltip(
            message: 'Expand navigation',
            child: _CompactIconButton(
              onPressed: onToggleCollapsed!,
              icon: Icons
                  .keyboard_double_arrow_right_rounded,
              highlighted: true,
            ),
          ),
        ],
      ],
    );
  }
}

class _CompactIconButton
    extends StatelessWidget {
  const _CompactIconButton({
    required this.onPressed,
    required this.icon,
    this.highlighted = false,
  });

  final VoidCallback onPressed;
  final IconData icon;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 42,
      height: 42,
      child: Material(
        color: highlighted
            ? AppColors.sidebarActive
            : AppColors.surface.withValues(
                alpha: .52,
              ),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onPressed,
          borderRadius:
              BorderRadius.circular(12),
          child: Icon(
            icon,
            size: 18,
            color: highlighted
                ? AppColors.primaryBright
                : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand({
    required this.collapsed,
  });

  final bool collapsed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: Row(
        mainAxisAlignment: collapsed
            ? MainAxisAlignment.center
            : MainAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(11),
              color: AppColors.primary
                  .withValues(alpha: .07),
              border: Border.all(
                color: AppColors.primaryBright
                    .withValues(alpha: .16),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary
                      .withValues(alpha: .12),
                  blurRadius: 16,
                ),
              ],
            ),
            child: Image.asset(
              'assets/images/log_ckd_mark.png',
              filterQuality: FilterQuality.high,
            ),
          ),
          if (!collapsed) ...[
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'log.',
                          style:
                              GoogleFonts.simonetta(
                            color: AppColors
                                .textPrimary,
                            fontSize: 21,
                            fontWeight:
                                FontWeight.w500,
                            letterSpacing: -.7,
                          ),
                        ),
                        TextSpan(
                          text: 'CKD',
                          style:
                              GoogleFonts.montserrat(
                            color: AppColors
                                .primaryBright,
                            fontSize: 21,
                            fontWeight:
                                FontWeight.w500,
                            letterSpacing: -.7,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Text(
                    'ADMIN CONSOLE',
                    style: TextStyle(
                      color:
                          AppColors.primaryBright,
                      fontSize: 8,
                      fontWeight:
                          FontWeight.w800,
                      letterSpacing: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SidebarDestination
    extends StatefulWidget {
  const _SidebarDestination({
    required this.collapsed,
    required this.selected,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final bool collapsed;
  final bool selected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  State<_SidebarDestination>
      createState() =>
          _SidebarDestinationState();
}

class _SidebarDestinationState
    extends State<_SidebarDestination> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.selected;

    final color = active
        ? AppColors.textPrimary
        : AppColors.textSecondary;

    final item = MouseRegion(
      onEnter: (_) =>
          setState(() => _hovered = true),
      onExit: (_) =>
          setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: AdminMotion.fast,
        curve: AdminMotion.ease,
        height: 45,
        decoration: BoxDecoration(
          color: active
              ? AppColors.sidebarActive
              : _hovered
                  ? AppColors.surface
                      .withValues(alpha: .7)
                  : Colors.transparent,
          borderRadius:
              BorderRadius.circular(12),
          border: Border.all(
            color: active
                ? AppColors.primary
                    .withValues(alpha: .28)
                : Colors.transparent,
          ),
        ),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius:
              BorderRadius.circular(12),
          child: Row(
            mainAxisAlignment:
                widget.collapsed
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.start,
            children: [
              if (!widget.collapsed)
                AnimatedContainer(
                  duration: AdminMotion.fast,
                  width: 3,
                  height: active ? 21 : 0,
                  margin:
                      const EdgeInsets.only(
                    left: 5,
                    right: 10,
                  ),
                  decoration: BoxDecoration(
                    color:
                        AppColors.primaryBright,
                    borderRadius:
                        BorderRadius.circular(
                      99,
                    ),
                  ),
                ),
              Icon(
                widget.icon,
                size: 19,
                color: active
                    ? AppColors.primaryBright
                    : color,
              ),
              if (!widget.collapsed) ...[
                const SizedBox(width: 11),
                Expanded(
                  child: Text(
                    widget.label,
                    overflow:
                        TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      color: color,
                      fontSize: 12.5,
                      fontWeight: active
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );

    if (widget.collapsed) {
      return Tooltip(
        message: widget.label,
        child: item,
      );
    }

    return item;
  }
}

class _AdminIdentity extends StatelessWidget {
  const _AdminIdentity({
    required this.collapsed,
    required this.name,
    required this.email,
    required this.role,
  });

  final bool collapsed;
  final String name;
  final String email;
  final String role;

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isEmpty
        ? 'A'
        : name.trim()[0].toUpperCase();

    final avatar = Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary
            .withValues(alpha: .13),
        border: Border.all(
          color: AppColors.primary
              .withValues(alpha: .36),
        ),
      ),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            color: AppColors.primaryBright,
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
      ),
    );

    if (collapsed) {
      return Tooltip(
        message: name,
        child: Center(child: avatar),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface
            .withValues(alpha: .74),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        children: [
          avatar,
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  email.isNotEmpty
                      ? email
                      : role.toUpperCase(),
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 9.5,
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

class _SidebarSmallButton
    extends StatelessWidget {
  const _SidebarSmallButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(
        icon,
        size: 17,
      ),
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
        ),
      ),
    );
  }
}

class _AdminBackdrop extends StatelessWidget {
  const _AdminBackdrop();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _AdminBackdropPainter(),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _AdminBackdropPainter
    extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color =
          Colors.white.withValues(alpha: .018)
      ..strokeWidth = .7;

    const step = 34.0;

    for (
      double x = 0;
      x < size.width;
      x += step
    ) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        gridPaint,
      );
    }

    for (
      double y = 0;
      y < size.height;
      y += step
    ) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    final tealGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.primary
              .withValues(alpha: .11),
          AppColors.primary
              .withValues(alpha: 0),
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(
            size.width * .88,
            size.height * .08,
          ),
          radius: 330,
        ),
      );

    canvas.drawCircle(
      Offset(
        size.width * .88,
        size.height * .08,
      ),
      330,
      tealGlow,
    );

    final coralGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.coral
              .withValues(alpha: .045),
          AppColors.coral
              .withValues(alpha: 0),
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(
            size.width * .18,
            size.height * .96,
          ),
          radius: 280,
        ),
      );

    canvas.drawCircle(
      Offset(
        size.width * .18,
        size.height * .96,
      ),
      280,
      coralGlow,
    );
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) =>
      false;
}