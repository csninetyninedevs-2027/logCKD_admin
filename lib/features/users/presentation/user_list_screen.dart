import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/admin_page_header.dart';
import '../../../shared/widgets/admin_reveal.dart';
import '../../../shared/widgets/admin_responsive.dart';
import '../../../shared/widgets/admin_status_badge.dart';
import '../../../shared/widgets/admin_surface.dart';
import '../../../shared/widgets/user_list_skeleton.dart';
import '../state/users_provider.dart';


class UserListScreen extends ConsumerStatefulWidget {
  const UserListScreen({super.key});

  @override
  ConsumerState<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends ConsumerState<UserListScreen> {
  final _searchController = TextEditingController();
  final _tableScrollController = ScrollController();

  @override
  void dispose() {
    _searchController.dispose();
    _tableScrollController.dispose();
    super.dispose();
  }

  void _search() {
    ref.read(userListParamsProvider.notifier).update(
          (state) => state.copyWith(search: _searchController.text.trim(), page: 1),
        );
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(userListParamsProvider.notifier).update(
          (state) => state.copyWith(search: '', page: 1),
        );
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(userListProvider);
    final params = ref.watch(userListParamsProvider);

    return Padding(
        padding: AdminResponsive.pageInsets(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AdminReveal(
              child: AdminPageHeader(
                eyebrow: 'People / access',
                title: 'Users',
                subtitle: 'Search, review, and manage registered log.CKD accounts without leaving the operational console.',
                actions: [
                  SizedBox(
                    width: AdminResponsive.actionWidth(context, maxWidth: 330),
                    child: TextField(
                      controller: _searchController,
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: 'Search name or email',
                        prefixIcon: const Icon(Icons.search_rounded, size: 19),
                        suffixIcon: params.search.isEmpty
                            ? IconButton(
                                tooltip: 'Search',
                                onPressed: _search,
                                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                              )
                            : IconButton(
                                tooltip: 'Clear search',
                                onPressed: _clearSearch,
                                icon: const Icon(Icons.close_rounded, size: 17),
                              ),
                      ),
                      onSubmitted: (_) => _search(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Expanded(
              child: usersAsync.when(
                loading: () => const UserListSkeleton(),
                error: (error, _) => _UsersError(
                  message: 'Failed to load users: $error',
                  onRetry: () => ref.invalidate(userListProvider),
                ),
                data: (page) {
                  final active =
                      page.users.where((user) => user.isActive).length;

                  final awarenessOnly =
                      page.users.where((user) => user.isAwarenessOnly).length;

                  final ckd = page.users
                      .where((user) => (user.ckdStage ?? '').trim().isNotEmpty)
                      .length;

                  final regions = page.users
                      .map((user) => user.region.trim())
                      .where((value) => value.isNotEmpty)
                      .toSet()
                      .length;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AdminReveal(
                        delay: const Duration(milliseconds: 80),
                        child: _UserMetricStrip(
                          total: page.total,
                          visible: page.users.length,
                          active: active,
                          awarenessOnly: awarenessOnly,
                          ckd: ckd,
                          regions: regions,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: AdminReveal(
                          delay: const Duration(milliseconds: 140),
                          child: page.users.isEmpty
                              ? _EmptyUsers(search: params.search, onClear: _clearSearch)
                              : AdminSurface(
                                  padding: EdgeInsets.zero,
                                  child: Column(
                                    children: [
                                      _TableHeader(search: params.search),
                                      const Divider(height: 1),
                                      Expanded(
                                        child: LayoutBuilder(
                                          builder: (context, constraints) =>
                                              SingleChildScrollView(
                                            child: Scrollbar(
                                              controller: _tableScrollController,
                                              thumbVisibility: true,
                                              scrollbarOrientation: ScrollbarOrientation.bottom,
                                              child: SingleChildScrollView(
                                                controller: _tableScrollController,
                                                scrollDirection: Axis.horizontal,
                                                child: ConstrainedBox(
                                                constraints: BoxConstraints(
                                                  minWidth: constraints.maxWidth > 1160
                                                      ? constraints.maxWidth
                                                      : 1160,
                                                ),
                                                child: DataTable(
                                                showCheckboxColumn: false,
                                                horizontalMargin: 18,
                                                columnSpacing: 28,
                                                dataRowMinHeight: 60,
                                                dataRowMaxHeight: 68,
                                                headingRowHeight: 42,
                                                columns: const [
                                                  DataColumn(label: Text('USER')),
                                                  DataColumn(label: Text('REGION')),
                                                  DataColumn(label: Text('HEALTH STATUS')),
                                                  DataColumn(label: Text('CKD STAGE')),
                                                  DataColumn(label: Text('ACCESS MODE')),
                                                  DataColumn(label: Text('STATUS')),
                                                  DataColumn(label: Text('LAST LOGIN')),
                                                ],
                                                rows: [
                                                  for (final user in page.users)
                                                    DataRow(
                                                      onSelectChanged: (_) => context.go('/users/${user.id}'),
                                                      cells: [
                                                        DataCell(
                                                          Row(
                                                            children: [
                                                              _InitialAvatar(name: user.fullName),
                                                              const SizedBox(width: 11),
                                                              Column(
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  Text(
                                                                    user.fullName,
                                                                    maxLines: 1,
                                                                    overflow: TextOverflow.ellipsis,
                                                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
                                                                  ),
                                                                  const SizedBox(height: 2),
                                                                  Text(
                                                                    user.email,
                                                                    maxLines: 1,
                                                                    overflow: TextOverflow.ellipsis,
                                                                    style: const TextStyle(color: AppColors.textMuted, fontSize: 10.5),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        DataCell(_MutedText(user.region)),
                                                        DataCell(_HealthPill(user.healthStatus)),
                                                        DataCell(
                                                          Text(
                                                            _displayValue(user.ckdStage),
                                                          ),
                                                        ),
                                                        DataCell(
                                                          _AccessModePill(
                                                            accessMode: user.accessMode,
                                                          ),
                                                        ),
                                                        DataCell(
                                                          user.isActive
                                                              ? AdminStatusBadge.active()
                                                              : AdminStatusBadge.inactive(),
                                                        ),
                                                        DataCell(
                                                          _MutedText(
                                                            user.lastLoginAt == null
                                                                ? 'Never'
                                                                : _shortDate(user.lastLoginAt!),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const Divider(height: 1),
                                      _PaginationFooter(page: page.page, limit: page.limit, total: page.total),
                                    ],
                                  ),
                                ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      );
  }
}

class _UserMetricStrip extends StatelessWidget {
  const _UserMetricStrip({
    required this.total,
    required this.visible,
    required this.active,
    required this.awarenessOnly,
    required this.ckd,
    required this.regions,
  });

  final int total;
  final int visible;
  final int active;
  final int awarenessOnly;
  final int ckd;
  final int regions;

  @override
  Widget build(BuildContext context) {
    return AdminSurface(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Wrap(
            spacing: 14,
            runSpacing: 12,
            children: [
              _Metric(label: 'TOTAL ACCOUNTS', value: '$total', accent: AppColors.primaryBright),
              _Metric(label: 'VISIBLE PAGE', value: '$visible', accent: AppColors.softBlue),
              _Metric(label: 'ACTIVE ON PAGE', value: '$active', accent: AppColors.success),
              _Metric(label: 'AWARENESS ONLY', value: '$awarenessOnly', accent: AppColors.warning),
              _Metric(label: 'CKD STAGE RECORDED', value: '$ckd', accent: AppColors.warning),
              _Metric(label: 'REGIONS ON PAGE', value: '$regions', accent: AppColors.coral),
            ],
          );
        },
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value, required this.accent});
  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 150),
      padding: const EdgeInsets.only(right: 22),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 3, height: 31, decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(99))),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800, letterSpacing: -.6)),
              Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 8.5, fontWeight: FontWeight.w800, letterSpacing: .7)),
            ],
          ),
        ],
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader({required this.search});
  final String search;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        children: [
          const Icon(Icons.table_rows_rounded, size: 17, color: AppColors.primaryBright),
          const SizedBox(width: 9),
          const Text('Account directory', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
          const Spacer(),
          if (search.isNotEmpty)
            Text(
              'Filtering by “$search”',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 10.5),
            ),
        ],
      ),
    );
  }
}

class _PaginationFooter extends ConsumerWidget {
  const _PaginationFooter({required this.page, required this.limit, required this.total});
  final int page;
  final int limit;
  final int total;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canPrevious = page > 1;
    final canNext = page * limit < total;
    final start = total == 0 ? 0 : (page - 1) * limit + 1;
    final end = (page * limit).clamp(0, total);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      child: Row(
        children: [
          Text('$start–$end of $total', style: Theme.of(context).textTheme.bodySmall),
          const Spacer(),
          Text('Page $page', style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Previous page',
            onPressed: canPrevious
                ? () => ref.read(userListParamsProvider.notifier).update((s) => s.copyWith(page: s.page - 1))
                : null,
            icon: const Icon(Icons.chevron_left_rounded, size: 19),
          ),
          IconButton(
            tooltip: 'Next page',
            onPressed: canNext
                ? () => ref.read(userListParamsProvider.notifier).update((s) => s.copyWith(page: s.page + 1))
                : null,
            icon: const Icon(Icons.chevron_right_rounded, size: 19),
          ),
        ],
      ),
    );
  }
}

class _InitialAvatar extends StatelessWidget {
  const _InitialAvatar({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    final parts = name.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    final initials = parts.isEmpty
        ? '?'
        : parts.length == 1
            ? parts.first.substring(0, 1).toUpperCase()
            : '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'.toUpperCase();

    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(11),
        color: AppColors.primary.withValues(alpha: .10),
        border: Border.all(color: AppColors.primary.withValues(alpha: .26)),
      ),
      child: Center(
        child: Text(initials, style: const TextStyle(color: AppColors.primaryBright, fontWeight: FontWeight.w800, fontSize: 10)),
      ),
    );
  }
}

class _HealthPill extends StatelessWidget {
  const _HealthPill(this.value);
  final String value;

  @override
  Widget build(BuildContext context) {
    final trimmed = value.trim();
    final missing = trimmed.isEmpty;
    final normalized = trimmed.toLowerCase();

    final color = missing
        ? AppColors.textMuted
        : normalized.contains('ckd')
            ? AppColors.warning
            : AppColors.primaryBright;

    final label = missing
        ? 'Not provided'
        : _titleCase(trimmed);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: .18)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _AccessModePill extends StatelessWidget {
  const _AccessModePill({
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

    final label = awarenessOnly
        ? 'Awareness only'
        : 'Full access';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: .18),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _MutedText extends StatelessWidget {
  const _MutedText(this.value);
  final String value;

  @override
  Widget build(BuildContext context) {
    return Text(
      _displayValue(value),
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 11.5,
      ),
    );
  }
}

class _EmptyUsers extends StatelessWidget {
  const _EmptyUsers({required this.search, required this.onClear});
  final String search;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return AdminSurface(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(42),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.person_search_rounded, size: 34, color: AppColors.textMuted),
              const SizedBox(height: 12),
              Text(search.isEmpty ? 'No users found' : 'No users match “$search”', style: Theme.of(context).textTheme.titleMedium),
              if (search.isNotEmpty) ...[
                const SizedBox(height: 9),
                TextButton(onPressed: onClear, child: const Text('Clear search')),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _UsersError extends StatelessWidget {
  const _UsersError({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AdminSurface(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, color: AppColors.danger),
            const SizedBox(height: 10),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 10),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
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
      ? '—'
      : trimmed;
}

String _titleCase(
  String value,
) {
  return value
      .replaceAll('_', ' ')
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .map(
        (part) =>
            '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}',
      )
      .join(' ');
}

String _shortDate(DateTime date) {
  final d = date.toLocal();
  return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}