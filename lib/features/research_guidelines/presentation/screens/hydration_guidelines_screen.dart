import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/hydration_guideline_model.dart';
import '../../../../shared/widgets/admin_skeleton.dart';
import '../../state/hydration_guideline_admin_provider.dart';

class HydrationGuidelinesScreen extends ConsumerStatefulWidget {
  const HydrationGuidelinesScreen({
    super.key,
    this.onBack,
  });

  final VoidCallback? onBack;

  @override
  ConsumerState<HydrationGuidelinesScreen> createState() =>
      _HydrationGuidelinesScreenState();
}

class _HydrationGuidelinesScreenState
    extends ConsumerState<HydrationGuidelinesScreen> {
  bool _busy = false;

  String _errorMessage(Object error) {
    if (error is DioException) {
      final data = error.response?.data;

      if (data is Map) {
        final message = data['error'] ?? data['message'];

        if (message != null &&
            message.toString().trim().isNotEmpty) {
          return message.toString();
        }
      }

      if (data is String && data.trim().isNotEmpty) {
        return data;
      }

      return error.message ??
          'Unable to complete the request.';
    }

    return error.toString();
  }

  void _message(
    String message, {
    bool error = false,
  }) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor:
              error ? AppColors.coral : AppColors.surface,
          content: Text(message),
        ),
      );
  }

  Future<void> _refresh() async {
    ref.invalidate(
      hydrationGuidelineListProvider,
    );
    ref.invalidate(
      publishedHydrationGuidelineProvider,
    );
    ref.invalidate(
      hydrationGuidelineHistoryProvider,
    );

    try {
      await Future.wait([
        ref.read(
          hydrationGuidelineListProvider.future,
        ),
        ref.read(
          publishedHydrationGuidelineProvider.future,
        ),
      ]);
    } catch (_) {
      // Provider error states are rendered by the screen.
    }
  }

  Future<bool> _confirm({
    required String title,
    required String message,
    required String action,
    bool destructive = false,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              title: Text(title),
              content: Text(
                message,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  height: 1.45,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(
                      dialogContext,
                    ).pop(false);
                  },
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: destructive
                        ? AppColors.coral
                        : AppColors.primary,
                  ),
                  onPressed: () {
                    Navigator.of(
                      dialogContext,
                    ).pop(true);
                  },
                  child: Text(action),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Future<void> _perform(
    Future<void> Function() action, {
    required String success,
  }) async {
    if (_busy) {
      return;
    }

    setState(() {
      _busy = true;
    });

    try {
      await action();

      if (!mounted) {
        return;
      }

      _message(success);
      await _refresh();
    } catch (error) {
      if (mounted) {
        _message(
          _errorMessage(error),
          error: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  Future<void> _createNewVersion(
    int sourceVersion,
  ) async {
    final confirmed = await _confirm(
      title: 'Create hydration draft?',
      message:
          'A new DRAFT version will be copied from hydration guideline version $sourceVersion. The currently published version will remain active until the draft is explicitly published.',
      action: 'Create draft',
    );

    if (!confirmed) {
      return;
    }

    await _perform(
      () async {
        await ref
            .read(
              hydrationGuidelineAdminActionsProvider,
            )
            .createNewVersion(
              sourceVersion,
            );
      },
      success:
          'New hydration guideline draft created.',
    );
  }

  Future<void> _publish(
    HydrationGuidelineVersionSummary version,
  ) async {
    final confirmed = await _confirm(
      title: 'Publish hydration guideline?',
      message:
          'Version ${version.version} will become the published hydration guideline. The current published version will be archived automatically.',
      action: 'Publish',
    );

    if (!confirmed) {
      return;
    }

    await _perform(
      () async {
        await ref
            .read(
              hydrationGuidelineAdminActionsProvider,
            )
            .publish(
              version.version,
            );
      },
      success:
          'Hydration guideline version ${version.version} published.',
    );
  }

  Future<void> _archive(
    HydrationGuidelineVersionSummary version,
  ) async {
    final confirmed = await _confirm(
      title: 'Archive hydration draft?',
      message:
          'Draft version ${version.version} will be archived. This does not change the currently published hydration guideline.',
      action: 'Archive',
      destructive: true,
    );

    if (!confirmed) {
      return;
    }

    await _perform(
      () async {
        await ref
            .read(
              hydrationGuidelineAdminActionsProvider,
            )
            .archive(
              version.version,
            );
      },
      success:
          'Hydration guideline version ${version.version} archived.',
    );
  }

  Future<void> _rollback(
    HydrationGuidelineVersionSummary version,
  ) async {
    final confirmed = await _confirm(
      title: 'Restore hydration version?',
      message:
          'Archived version ${version.version} will become the published hydration guideline. The current published version will be archived.',
      action: 'Restore',
    );

    if (!confirmed) {
      return;
    }

    await _perform(
      () async {
        await ref
            .read(
              hydrationGuidelineAdminActionsProvider,
            )
            .rollback(
              version.version,
            );
      },
      success:
          'Hydration guideline version ${version.version} restored.',
    );
  }

  Future<HydrationGuidelineVersion?> _loadVersion(
    int version,
  ) async {
    try {
      return await ref.read(
        hydrationGuidelineVersionProvider(
          version,
        ).future,
      );
    } catch (error) {
      if (mounted) {
        _message(
          _errorMessage(error),
          error: true,
        );
      }

      return null;
    }
  }

  Future<bool> _editRule(
    HydrationGuidelineRule rule,
  ) async {
    if (!rule.isDraft) {
      _message(
        'Only DRAFT hydration guideline rules can be edited.',
        error: true,
      );
      return false;
    }

    if (rule.id.isEmpty) {
      _message(
        'Backend rule identifier unavailable.',
        error: true,
      );
      return false;
    }

    final payload =
        await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return _HydrationRuleEditDialog(
          rule: rule,
        );
      },
    );

    if (payload == null || _busy) {
      return false;
    }

    setState(() {
      _busy = true;
    });

    try {
      await ref
          .read(
            hydrationGuidelineAdminActionsProvider,
          )
          .updateRule(
            ruleId: rule.id,
            payload: payload,
          );

      if (!mounted) {
        return false;
      }

      _message(
        'Hydration rule updated.',
      );
      await _refresh();

      return true;
    } catch (error) {
      if (mounted) {
        _message(
          _errorMessage(error),
          error: true,
        );
      }

      return false;
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  Future<void> _openVersion(
    int version, {
    required bool editable,
  }) async {
    final loaded = await _loadVersion(
      version,
    );

    if (loaded == null || !mounted) {
      return;
    }

    final selectedRule =
        await showDialog<HydrationGuidelineRule>(
      context: context,
      builder: (dialogContext) {
        return _HydrationVersionDialog(
          version: loaded,
          editable:
              editable && loaded.isDraft,
        );
      },
    );

    if (selectedRule == null) {
      return;
    }

    final updated =
        await _editRule(
      selectedRule,
    );

    if (updated && mounted) {
      await _openVersion(
        version,
        editable: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final published =
        ref.watch(
      publishedHydrationGuidelineProvider,
    );

    final versions =
        ref.watch(
      hydrationGuidelineListProvider,
    );

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        _Header(
          onBack: widget.onBack,
          busy: _busy,
          onRefresh:
              _busy ? null : _refresh,
        ),
        const SizedBox(height: 18),
        published.when(
          loading: () =>
              const _LoadingCard(
            height: 180,
          ),
          error: (error, _) =>
              _ErrorCard(
            title:
                'Unable to load published hydration guideline',
            message:
                _errorMessage(error),
            onRetry: () {
              ref.invalidate(
                publishedHydrationGuidelineProvider,
              );
            },
          ),
          data: (version) {
            if (version == null) {
              return const _NoPublishedCard();
            }

            return _PublishedCard(
              version: version,
              disabled: _busy,
              onView: () {
                _openVersion(
                  version.version,
                  editable: false,
                );
              },
              onCreateVersion: () {
                _createNewVersion(
                  version.version,
                );
              },
            );
          },
        ),
        const SizedBox(height: 24),
        const _SectionTitle(
          eyebrow: 'VERSION CONTROL',
          title:
              'Hydration guideline versions',
          description:
              'Review published and archived versions, edit draft rules, and publish approved hydration guidance.',
        ),
        const SizedBox(height: 12),
        versions.when(
          loading: () =>
              const Column(
            children: [
              _LoadingCard(
                height: 94,
              ),
              SizedBox(height: 10),
              _LoadingCard(
                height: 94,
              ),
            ],
          ),
          error: (error, _) =>
              _ErrorCard(
            title:
                'Unable to load hydration guideline versions',
            message:
                _errorMessage(error),
            onRetry: () {
              ref.invalidate(
                hydrationGuidelineListProvider,
              );
            },
          ),
          data: (result) {
            if (result.items.isEmpty) {
              return const _EmptyVersions();
            }

            final items = [
              ...result.items,
            ]..sort(
                (first, second) =>
                    second.version.compareTo(
                  first.version,
                ),
              );

            return Column(
              children: [
                for (
                  var index = 0;
                  index < items.length;
                  index++
                ) ...[
                  _VersionCard(
                    version:
                        items[index],
                    disabled:
                        _busy,
                    onView: () {
                      _openVersion(
                        items[index].version,
                        editable: false,
                      );
                    },
                    onEdit:
                        items[index].isDraft
                            ? () {
                                _openVersion(
                                  items[index]
                                      .version,
                                  editable: true,
                                );
                              }
                            : null,
                    onCreateVersion:
                        items[index]
                                .isPublished
                            ? () {
                                _createNewVersion(
                                  items[index]
                                      .version,
                                );
                              }
                            : null,
                    onPublish:
                        items[index].isDraft
                            ? () {
                                _publish(
                                  items[index],
                                );
                              }
                            : null,
                    onArchive:
                        items[index].isDraft
                            ? () {
                                _archive(
                                  items[index],
                                );
                              }
                            : null,
                    onRollback:
                        items[index]
                                .canRollback
                            ? () {
                                _rollback(
                                  items[index],
                                );
                              }
                            : null,
                  ),
                  if (index !=
                      items.length - 1)
                    const SizedBox(
                      height: 10,
                    ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.onBack,
    required this.busy,
    required this.onRefresh,
  });

  final VoidCallback? onBack;
  final bool busy;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (onBack != null) ...[
          _SquareButton(
            tooltip:
                'Back to Research & Guidelines',
            icon:
                Icons.arrow_back_rounded,
            onTap:
                onBack,
          ),
          const SizedBox(width: 12),
        ],
        const Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'HYDRATION GUIDELINES',
                style: TextStyle(
                  color:
                      AppColors.primaryBright,
                  fontSize: 9,
                  fontWeight:
                      FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Hydration Guidelines',
                style: TextStyle(
                  color:
                      AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight:
                      FontWeight.w800,
                  letterSpacing: -.4,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Manage versioned hydration rules used by log.CKD to determine available daily water goals.',
                style: TextStyle(
                  color:
                      AppColors.textSecondary,
                  fontSize: 11,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _SquareButton(
          tooltip: 'Refresh',
          icon: busy
              ? Icons.hourglass_top_rounded
              : Icons.refresh_rounded,
          onTap: onRefresh == null
              ? null
              : () {
                  onRefresh!();
                },
        ),
      ],
    );
  }
}

class _PublishedCard
    extends StatelessWidget {
  const _PublishedCard({
    required this.version,
    required this.disabled,
    required this.onView,
    required this.onCreateVersion,
  });

  final HydrationGuidelineVersion version;
  final bool disabled;
  final VoidCallback onView;
  final VoidCallback onCreateVersion;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary
            .withValues(alpha: .08),
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryBright
              .withValues(alpha: .22),
        ),
      ),
      child: LayoutBuilder(
        builder: (
          context,
          constraints,
        ) {
          final compact =
              constraints.maxWidth < 720;

          final information =
              Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration:
                        BoxDecoration(
                      color: AppColors.primary
                          .withValues(
                        alpha: .12,
                      ),
                      borderRadius:
                          BorderRadius
                              .circular(12),
                    ),
                    child: const Icon(
                      Icons
                          .water_drop_outlined,
                      color: AppColors
                          .primaryBright,
                      size: 21,
                    ),
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        const Text(
                          'CURRENTLY PUBLISHED',
                          style:
                              TextStyle(
                            color: AppColors
                                .primaryBright,
                            fontSize: 8,
                            fontWeight:
                                FontWeight
                                    .w800,
                            letterSpacing:
                                1,
                          ),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Text(
                          'Hydration Guideline v${version.version}',
                          style:
                              const TextStyle(
                            color: AppColors
                                .textPrimary,
                            fontSize: 15,
                            fontWeight:
                                FontWeight
                                    .w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _MetaChip(
                    icon:
                        Icons.tag_rounded,
                    label:
                        'Version ${version.version}',
                  ),
                  _StatusBadge(
                    status:
                        version.status,
                  ),
                  _MetaChip(
                    icon:
                        Icons.rule_folder_outlined,
                    label:
                        '${version.rules.length} rules',
                  ),
                  if (version
                          .publishedAt !=
                      null)
                    _MetaChip(
                      icon:
                          Icons.schedule_rounded,
                      label:
                          'Published ${_formatDate(version.publishedAt!)}',
                    ),
                ],
              ),
              const SizedBox(height: 13),
              const Text(
                'Published rules are read-only. Create a new version to make controlled changes without modifying the active guideline.',
                style: TextStyle(
                  color:
                      AppColors.textSecondary,
                  fontSize: 10.5,
                  height: 1.5,
                ),
              ),
            ],
          );

          final actions = Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed:
                    disabled ? null : onView,
                icon: const Icon(
                  Icons.visibility_outlined,
                  size: 16,
                ),
                label:
                    const Text('View rules'),
              ),
              FilledButton.icon(
                onPressed: disabled
                    ? null
                    : onCreateVersion,
                icon: const Icon(
                  Icons
                      .add_circle_outline_rounded,
                  size: 16,
                ),
                label: const Text(
                  'Create new version',
                ),
              ),
            ],
          );

          if (compact) {
            return Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                information,
                const SizedBox(height: 18),
                actions,
              ],
            );
          }

          return Row(
            crossAxisAlignment:
                CrossAxisAlignment.end,
            children: [
              Expanded(
                child: information,
              ),
              const SizedBox(width: 20),
              actions,
            ],
          );
        },
      ),
    );
  }
}

class _VersionCard extends StatelessWidget {
  const _VersionCard({
    required this.version,
    required this.disabled,
    required this.onView,
    required this.onEdit,
    required this.onCreateVersion,
    required this.onPublish,
    required this.onArchive,
    required this.onRollback,
  });

  final HydrationGuidelineVersionSummary
      version;
  final bool disabled;
  final VoidCallback onView;
  final VoidCallback? onEdit;
  final VoidCallback? onCreateVersion;
  final VoidCallback? onPublish;
  final VoidCallback? onArchive;
  final VoidCallback? onRollback;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppColors.surface
            .withValues(alpha: .62),
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
          color: version.isPublished
              ? AppColors.primary
                  .withValues(alpha: .25)
              : AppColors.border,
        ),
      ),
      child: LayoutBuilder(
        builder: (
          context,
          constraints,
        ) {
          final compact =
              constraints.maxWidth < 760;

          final details = Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                width: 39,
                height: 39,
                decoration:
                    BoxDecoration(
                  color: _statusColor(
                    version.status,
                  ).withValues(alpha: .1),
                  borderRadius:
                      BorderRadius.circular(
                    11,
                  ),
                ),
                child: Icon(
                  _statusIcon(
                    version.status,
                  ),
                  size: 18,
                  color: _statusColor(
                    version.status,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Flexible(
                          child: Text(
                            'Hydration Guideline',
                            overflow:
                                TextOverflow
                                    .ellipsis,
                            style:
                                TextStyle(
                              color: AppColors
                                  .textPrimary,
                              fontSize: 13,
                              fontWeight:
                                  FontWeight
                                      .w700,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        _StatusBadge(
                          status:
                              version.status,
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Wrap(
                      spacing: 12,
                      runSpacing: 5,
                      children: [
                        _InlineMeta(
                          icon: Icons
                              .tag_rounded,
                          text:
                              'Version ${version.version}',
                        ),
                        _InlineMeta(
                          icon: Icons
                              .rule_folder_outlined,
                          text:
                              '${version.ruleCount} rules',
                        ),
                        if (version
                                .publishedAt !=
                            null)
                          _InlineMeta(
                            icon: Icons
                                .schedule_rounded,
                            text:
                                'Published ${_formatDate(version.publishedAt!)}',
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );

          final actions = Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _SmallButton(
                label: 'View',
                icon:
                    Icons.visibility_outlined,
                onTap:
                    disabled ? null : onView,
              ),
              if (onEdit != null)
                _SmallButton(
                  label: 'Edit rules',
                  icon:
                      Icons.edit_outlined,
                  emphasized: true,
                  onTap:
                      disabled
                          ? null
                          : onEdit,
                ),
              if (onCreateVersion != null)
                _SmallButton(
                  label: 'New version',
                  icon: Icons
                      .add_circle_outline_rounded,
                  onTap: disabled
                      ? null
                      : onCreateVersion,
                ),
              if (onPublish != null)
                _SmallButton(
                  label: 'Publish',
                  icon:
                      Icons.publish_rounded,
                  emphasized: true,
                  onTap:
                      disabled
                          ? null
                          : onPublish,
                ),
              if (onRollback != null)
                _SmallButton(
                  label: 'Restore',
                  icon:
                      Icons.history_rounded,
                  emphasized: true,
                  onTap:
                      disabled
                          ? null
                          : onRollback,
                ),
              if (onArchive != null)
                _SmallButton(
                  label: 'Archive',
                  icon:
                      Icons.archive_outlined,
                  destructive: true,
                  onTap:
                      disabled
                          ? null
                          : onArchive,
                ),
            ],
          );

          if (compact) {
            return Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                details,
                const SizedBox(height: 14),
                actions,
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: details),
              const SizedBox(width: 16),
              actions,
            ],
          );
        },
      ),
    );
  }
}

class _HydrationVersionDialog
    extends StatelessWidget {
  const _HydrationVersionDialog({
    required this.version,
    required this.editable,
  });

  final HydrationGuidelineVersion version;
  final bool editable;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor:
          Colors.transparent,
      insetPadding:
          const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 24,
      ),
      child: Container(
        width: 960,
        constraints:
            const BoxConstraints(
          maxHeight: 760,
        ),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius:
              BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.border,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(
                20,
                18,
                14,
                15,
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration:
                        BoxDecoration(
                      color: AppColors.primary
                          .withValues(
                        alpha: .1,
                      ),
                      borderRadius:
                          BorderRadius
                              .circular(11),
                    ),
                    child: const Icon(
                      Icons
                          .water_drop_outlined,
                      color: AppColors
                          .primaryBright,
                      size: 19,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        Text(
                          'Hydration Guideline v${version.version}',
                          style:
                              const TextStyle(
                            color: AppColors
                                .textPrimary,
                            fontSize: 15,
                            fontWeight:
                                FontWeight
                                    .w700,
                          ),
                        ),
                        const SizedBox(
                          height: 3,
                        ),
                        Text(
                          editable
                              ? 'Select a rule to edit this draft.'
                              : 'Review the rules stored for this version.',
                          style:
                              const TextStyle(
                            color: AppColors
                                .textMuted,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _StatusBadge(
                    status: version.status,
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () {
                      Navigator.of(
                        context,
                      ).pop();
                    },
                    icon: const Icon(
                      Icons.close_rounded,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(
              height: 1,
              color: AppColors.border,
            ),
            Expanded(
              child: version.rules.isEmpty
                  ? const Center(
                      child: Text(
                        'No hydration rules found in this version.',
                        style: TextStyle(
                          color: AppColors
                              .textMuted,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding:
                          const EdgeInsets.all(
                        18,
                      ),
                      itemCount:
                          version.rules.length,
                      separatorBuilder:
                          (_, __) =>
                              const SizedBox(
                        height: 10,
                      ),
                      itemBuilder: (
                        context,
                        index,
                      ) {
                        final rule =
                            version.rules[index];

                        return _RuleCard(
                          rule: rule,
                          editable: editable,
                          onEdit: editable
                              ? () {
                                  Navigator.of(
                                    context,
                                  ).pop(rule);
                                }
                              : null,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RuleCard extends StatelessWidget {
  const _RuleCard({
    required this.rule,
    required this.editable,
    required this.onEdit,
  });

  final HydrationGuidelineRule rule;
  final bool editable;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final sex =
        rule.sex?.trim().isNotEmpty == true
            ? rule.sex!
            : 'Any sex';

    final age =
        rule.minAge != null &&
                rule.maxAge != null
            ? '${rule.minAge}–${rule.maxAge}'
            : 'Any age';

    return Container(
      padding:
          const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.surface
            .withValues(alpha: .55),
        borderRadius:
            BorderRadius.circular(13),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: LayoutBuilder(
        builder: (
          context,
          constraints,
        ) {
          final compact =
              constraints.maxWidth < 650;

          final info = Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                rule.title.isEmpty
                    ? 'Hydration rule'
                    : rule.title,
                style: const TextStyle(
                  color:
                      AppColors.textPrimary,
                  fontSize: 12.5,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
              const SizedBox(height: 7),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _MetaChip(
                    icon: Icons
                        .person_outline_rounded,
                    label: sex,
                  ),
                  _MetaChip(
                    icon: Icons
                        .calendar_today_outlined,
                    label: 'Age $age',
                  ),
                  _MetaChip(
                    icon: Icons
                        .health_and_safety_outlined,
                    label:
                        rule.healthStatus,
                  ),
                  _MetaChip(
                    icon: Icons
                        .calculate_outlined,
                    label: rule
                        .calculationMethod,
                  ),
                  if (rule.beverageAiMl !=
                      null)
                    _MetaChip(
                      icon: Icons
                          .water_drop_outlined,
                      label:
                          '${_number(rule.beverageAiMl!)} mL beverage AI',
                    ),
                  if (rule
                          .plainWaterPercentage !=
                      null)
                    _MetaChip(
                      icon: Icons
                          .percent_rounded,
                      label:
                          '${_number(rule.plainWaterPercentage!)}% plain water',
                    ),
                  if (rule
                          .foodWaterPercentage !=
                      null)
                    _MetaChip(
                      icon: Icons
                          .restaurant_outlined,
                      label:
                          '${_number(rule.foodWaterPercentage!)}% food water',
                    ),
                ],
              ),
              if (rule.sources.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  '${rule.sources.length} source${rule.sources.length == 1 ? '' : 's'} attached',
                  style: const TextStyle(
                    color:
                        AppColors.textMuted,
                    fontSize: 9.5,
                  ),
                ),
              ],
            ],
          );

          if (compact || !editable) {
            return Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                info,
                if (editable) ...[
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(
                      Icons.edit_outlined,
                      size: 15,
                    ),
                    label:
                        const Text('Edit rule'),
                  ),
                ],
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: info),
              const SizedBox(width: 14),
              OutlinedButton.icon(
                onPressed: onEdit,
                icon: const Icon(
                  Icons.edit_outlined,
                  size: 15,
                ),
                label:
                    const Text('Edit rule'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HydrationRuleEditDialog
    extends StatefulWidget {
  const _HydrationRuleEditDialog({
    required this.rule,
  });

  final HydrationGuidelineRule rule;

  @override
  State<_HydrationRuleEditDialog>
      createState() =>
          _HydrationRuleEditDialogState();
}

class _HydrationRuleEditDialogState
    extends State<_HydrationRuleEditDialog> {
  final _formKey =
      GlobalKey<FormState>();

  late final TextEditingController _title;
  late final TextEditingController
      _healthStatus;
  late final TextEditingController _sex;
  late final TextEditingController _minAge;
  late final TextEditingController _maxAge;
  late final TextEditingController
      _beverageAiMl;
  late final TextEditingController
      _plainWaterPercentage;
  late final TextEditingController
      _foodWaterPercentage;

  late String _calculationMethod;

  final List<_SourceDraft> _sources = [];

  @override
  void initState() {
    super.initState();

    final rule = widget.rule;

    _title = TextEditingController(
      text: rule.title,
    );
    _healthStatus = TextEditingController(
      text: rule.healthStatus,
    );
    _sex = TextEditingController(
      text: rule.sex ?? '',
    );
    _minAge = TextEditingController(
      text: rule.minAge?.toString() ?? '',
    );
    _maxAge = TextEditingController(
      text: rule.maxAge?.toString() ?? '',
    );
    _beverageAiMl =
        TextEditingController(
      text: rule.beverageAiMl == null
          ? ''
          : _number(
              rule.beverageAiMl!,
            ),
    );
    _plainWaterPercentage =
        TextEditingController(
      text:
          rule.plainWaterPercentage == null
              ? ''
              : _number(
                  rule
                      .plainWaterPercentage!,
                ),
    );
    _foodWaterPercentage =
        TextEditingController(
      text:
          rule.foodWaterPercentage == null
              ? ''
              : _number(
                  rule
                      .foodWaterPercentage!,
                ),
    );

    _calculationMethod =
        rule.calculationMethod.trim().isEmpty
            ? 'BEVERAGE_AI'
            : rule.calculationMethod;

    for (final source in rule.sources) {
      _sources.add(
        _SourceDraft.fromSource(
          source,
        ),
      );
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _healthStatus.dispose();
    _sex.dispose();
    _minAge.dispose();
    _maxAge.dispose();
    _beverageAiMl.dispose();
    _plainWaterPercentage.dispose();
    _foodWaterPercentage.dispose();

    for (final source in _sources) {
      source.dispose();
    }

    super.dispose();
  }

  int? _parseInt(
    TextEditingController controller,
  ) {
    final text =
        controller.text.trim();

    if (text.isEmpty) {
      return null;
    }

    return int.tryParse(text);
  }

  double? _parseDouble(
    TextEditingController controller,
  ) {
    final text =
        controller.text.trim();

    if (text.isEmpty) {
      return null;
    }

    return double.tryParse(text);
  }

  String? _requiredText(
    String? value,
    String label,
  ) {
    if (value == null ||
        value.trim().isEmpty) {
      return '$label is required.';
    }

    return null;
  }

  String? _wholeNumber(
    String? value,
    String label,
  ) {
    if (value == null ||
        value.trim().isEmpty) {
      return '$label is required.';
    }

    final parsed =
        int.tryParse(
      value.trim(),
    );

    if (parsed == null || parsed < 0) {
      return 'Enter a valid $label.';
    }

    return null;
  }

  String? _nonNegativeNumber(
    String? value,
    String label, {
    double? maximum,
  }) {
    if (value == null ||
        value.trim().isEmpty) {
      return null;
    }

    final parsed =
        double.tryParse(
      value.trim(),
    );

    if (parsed == null || parsed < 0) {
      return 'Enter a valid $label.';
    }

    if (maximum != null &&
        parsed > maximum) {
      return '$label cannot exceed ${_number(maximum)}.';
    }

    return null;
  }

  void _addSource() {
    setState(() {
      _sources.add(
        _SourceDraft.empty(),
      );
    });
  }

  void _removeSource(
    int index,
  ) {
    final removed =
        _sources.removeAt(index);

    removed.dispose();

    setState(() {});
  }

  void _submit() {
    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    final minAge =
        _parseInt(_minAge);
    final maxAge =
        _parseInt(_maxAge);

    if (minAge != null &&
        maxAge != null &&
        minAge > maxAge) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Minimum age cannot be greater than maximum age.',
            ),
          ),
        );

      return;
    }

    final sourcePayload =
        <Map<String, dynamic>>[];

    for (final source in _sources) {
      final yearText =
          source.publicationYear.text
              .trim();

      final year = yearText.isEmpty
          ? null
          : int.tryParse(yearText);

      if (yearText.isNotEmpty &&
          year == null) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text(
                'Publication year must be a whole number.',
              ),
            ),
          );

        return;
      }

      sourcePayload.add({
        'organization':
            source.organization.text
                    .trim()
                    .isEmpty
                ? null
                : source.organization.text
                    .trim(),
        'publicationTitle':
            source.publicationTitle.text
                    .trim()
                    .isEmpty
                ? null
                : source
                    .publicationTitle.text
                    .trim(),
        'publicationYear': year,
        'doi':
            source.doi.text
                    .trim()
                    .isEmpty
                ? null
                : source.doi.text
                    .trim(),
        'url':
            source.url.text
                    .trim()
                    .isEmpty
                ? null
                : source.url.text
                    .trim(),
        'notes':
            source.notes.text
                    .trim()
                    .isEmpty
                ? null
                : source.notes.text
                    .trim(),
      });
    }

    Navigator.of(context).pop(
      <String, dynamic>{
        'title':
            _title.text.trim(),
        'healthStatus':
            _healthStatus.text
                .trim()
                .toLowerCase(),
        'sex':
            _sex.text
                .trim()
                .toLowerCase(),
        'minAge':
            minAge,
        'maxAge':
            maxAge,
        'calculationMethod':
            _calculationMethod
                .trim()
                .toUpperCase(),
        'beverageAiMl':
            _parseDouble(
          _beverageAiMl,
        ),
        'plainWaterPercentage':
            _parseDouble(
          _plainWaterPercentage,
        ),
        'foodWaterPercentage':
            _parseDouble(
          _foodWaterPercentage,
        ),
        'sources':
            sourcePayload,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor:
          Colors.transparent,
      insetPadding:
          const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 24,
      ),
      child: Container(
        width: 900,
        constraints:
            const BoxConstraints(
          maxHeight: 800,
        ),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius:
              BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.border,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(
                20,
                18,
                14,
                15,
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration:
                        BoxDecoration(
                      color: Colors.amber
                          .withValues(
                        alpha: .1,
                      ),
                      borderRadius:
                          BorderRadius
                              .circular(11),
                    ),
                    child: const Icon(
                      Icons.edit_note_rounded,
                      color: Colors.amber,
                      size: 19,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        const Text(
                          'Edit hydration rule',
                          style:
                              TextStyle(
                            color: AppColors
                                .textPrimary,
                            fontSize: 15,
                            fontWeight:
                                FontWeight
                                    .w700,
                          ),
                        ),
                        const SizedBox(
                          height: 3,
                        ),
                        Text(
                          'Version ${widget.rule.version} · DRAFT',
                          style:
                              const TextStyle(
                            color: AppColors
                                .textMuted,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () {
                      Navigator.of(
                        context,
                      ).pop();
                    },
                    icon: const Icon(
                      Icons.close_rounded,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(
              height: 1,
              color: AppColors.border,
            ),
            Expanded(
              child: Form(
                key: _formKey,
                child:
                    SingleChildScrollView(
                  padding:
                      const EdgeInsets.all(
                    20,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const _EditSectionTitle(
                        title: 'Rule identity',
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      _twoColumns(
                        TextFormField(
                          controller: _title,
                          decoration:
                              const InputDecoration(
                            labelText:
                                'Title',
                          ),
                          validator: (value) =>
                              _requiredText(
                            value,
                            'Title',
                          ),
                        ),
                        TextFormField(
                          controller:
                              _healthStatus,
                          decoration:
                              const InputDecoration(
                            labelText:
                                'Health status',
                            helperText:
                                'Example: not_diagnosed',
                          ),
                          validator: (value) =>
                              _requiredText(
                            value,
                            'Health status',
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      _twoColumns(
                        TextFormField(
                          controller: _sex,
                          decoration:
                              const InputDecoration(
                            labelText: 'Sex',
                            helperText:
                                'Example: male or female',
                          ),
                          validator: (value) =>
                              _requiredText(
                            value,
                            'Sex',
                          ),
                        ),
                        DropdownButtonFormField<
                            String>(
                          initialValue:
                              _calculationMethod,
                          decoration:
                              const InputDecoration(
                            labelText:
                                'Calculation method',
                          ),
                          items: const [
                            DropdownMenuItem(
                              value:
                                  'BEVERAGE_AI',
                              child: Text(
                                'BEVERAGE_AI',
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            if (value == null) {
                              return;
                            }

                            setState(() {
                              _calculationMethod =
                                  value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 18,
                      ),
                      const _EditSectionTitle(
                        title: 'Age range',
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      _twoColumns(
                        TextFormField(
                          controller:
                              _minAge,
                          keyboardType:
                              TextInputType
                                  .number,
                          decoration:
                              const InputDecoration(
                            labelText:
                                'Minimum age',
                          ),
                          validator: (value) =>
                              _wholeNumber(
                            value,
                            'minimum age',
                          ),
                        ),
                        TextFormField(
                          controller:
                              _maxAge,
                          keyboardType:
                              TextInputType
                                  .number,
                          decoration:
                              const InputDecoration(
                            labelText:
                                'Maximum age',
                          ),
                          validator: (value) =>
                              _wholeNumber(
                            value,
                            'maximum age',
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 18,
                      ),
                      const _EditSectionTitle(
                        title:
                            'Hydration calculation',
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      _twoColumns(
                        TextFormField(
                          controller:
                              _beverageAiMl,
                          keyboardType:
                              const TextInputType
                                  .numberWithOptions(
                            decimal: true,
                          ),
                          decoration:
                              const InputDecoration(
                            labelText:
                                'Beverage AI (mL)',
                          ),
                          validator: (value) =>
                              _nonNegativeNumber(
                            value,
                            'beverage AI',
                          ),
                        ),
                        TextFormField(
                          controller:
                              _plainWaterPercentage,
                          keyboardType:
                              const TextInputType
                                  .numberWithOptions(
                            decimal: true,
                          ),
                          decoration:
                              const InputDecoration(
                            labelText:
                                'Plain water percentage',
                            suffixText: '%',
                          ),
                          validator: (value) =>
                              _nonNegativeNumber(
                            value,
                            'plain water percentage',
                            maximum: 100,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      TextFormField(
                        controller:
                            _foodWaterPercentage,
                        keyboardType:
                            const TextInputType
                                .numberWithOptions(
                          decimal: true,
                        ),
                        decoration:
                            const InputDecoration(
                          labelText:
                              'Food water percentage',
                          suffixText: '%',
                        ),
                        validator: (value) =>
                            _nonNegativeNumber(
                          value,
                          'food water percentage',
                          maximum: 100,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          const Expanded(
                            child:
                                _EditSectionTitle(
                              title:
                                  'Source metadata',
                            ),
                          ),
                          TextButton.icon(
                            onPressed:
                                _addSource,
                            icon: const Icon(
                              Icons.add_rounded,
                              size: 16,
                            ),
                            label: const Text(
                              'Add source',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      if (_sources.isEmpty)
                        Container(
                          width:
                              double.infinity,
                          padding:
                              const EdgeInsets.all(
                            14,
                          ),
                          decoration:
                              BoxDecoration(
                            color: AppColors
                                .surface
                                .withValues(
                              alpha: .45,
                            ),
                            borderRadius:
                                BorderRadius
                                    .circular(11),
                            border: Border.all(
                              color: AppColors
                                  .border,
                            ),
                          ),
                          child: const Text(
                            'No sources attached. Add source metadata if this rule is based on a publication or guideline.',
                            style: TextStyle(
                              color: AppColors
                                  .textMuted,
                              fontSize: 10,
                              height: 1.4,
                            ),
                          ),
                        ),
                      for (
                        var index = 0;
                        index < _sources.length;
                        index++
                      ) ...[
                        _SourceEditor(
                          index: index,
                          source:
                              _sources[index],
                          onRemove: () {
                            _removeSource(
                              index,
                            );
                          },
                        ),
                        if (index !=
                            _sources.length - 1)
                          const SizedBox(
                            height: 10,
                          ),
                      ],
                      if (widget.rule
                              .ckdStage !=
                          null) ...[
                        const SizedBox(
                          height: 18,
                        ),
                        Container(
                          width:
                              double.infinity,
                          padding:
                              const EdgeInsets.all(
                            13,
                          ),
                          decoration:
                              BoxDecoration(
                            color: AppColors
                                .surface
                                .withValues(
                              alpha: .45,
                            ),
                            borderRadius:
                                BorderRadius
                                    .circular(11),
                            border: Border.all(
                              color: AppColors
                                  .border,
                            ),
                          ),
                          child: Text(
                            'CKD stage: ${widget.rule.ckdStage} (read-only in the current admin API)',
                            style:
                                const TextStyle(
                              color: AppColors
                                  .textMuted,
                              fontSize: 9.5,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            const Divider(
              height: 1,
              color: AppColors.border,
            ),
            Padding(
              padding:
                  const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(
                        context,
                      ).pop();
                    },
                    child:
                        const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: _submit,
                    icon: const Icon(
                      Icons.save_outlined,
                      size: 17,
                    ),
                    label:
                        const Text('Save rule'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _twoColumns(
    Widget first,
    Widget second,
  ) {
    return LayoutBuilder(
      builder: (
        context,
        constraints,
      ) {
        if (constraints.maxWidth < 620) {
          return Column(
            children: [
              first,
              const SizedBox(height: 12),
              second,
            ],
          );
        }

        return Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Expanded(child: first),
            const SizedBox(width: 12),
            Expanded(child: second),
          ],
        );
      },
    );
  }
}

class _SourceDraft {
  _SourceDraft({
    required this.organization,
    required this.publicationTitle,
    required this.publicationYear,
    required this.doi,
    required this.url,
    required this.notes,
  });

  factory _SourceDraft.empty() {
    return _SourceDraft(
      organization:
          TextEditingController(),
      publicationTitle:
          TextEditingController(),
      publicationYear:
          TextEditingController(),
      doi:
          TextEditingController(),
      url:
          TextEditingController(),
      notes:
          TextEditingController(),
    );
  }

  factory _SourceDraft.fromSource(
    HydrationGuidelineSource source,
  ) {
    return _SourceDraft(
      organization:
          TextEditingController(
        text: source.organization,
      ),
      publicationTitle:
          TextEditingController(
        text: source.publicationTitle,
      ),
      publicationYear:
          TextEditingController(
        text: source.publicationYear
                ?.toString() ??
            '',
      ),
      doi:
          TextEditingController(
        text: source.doi,
      ),
      url:
          TextEditingController(
        text: source.url,
      ),
      notes:
          TextEditingController(
        text: source.notes,
      ),
    );
  }

  final TextEditingController
      organization;
  final TextEditingController
      publicationTitle;
  final TextEditingController
      publicationYear;
  final TextEditingController doi;
  final TextEditingController url;
  final TextEditingController notes;

  void dispose() {
    organization.dispose();
    publicationTitle.dispose();
    publicationYear.dispose();
    doi.dispose();
    url.dispose();
    notes.dispose();
  }
}

class _SourceEditor
    extends StatelessWidget {
  const _SourceEditor({
    required this.index,
    required this.source,
    required this.onRemove,
  });

  final int index;
  final _SourceDraft source;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface
            .withValues(alpha: .48),
        borderRadius:
            BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Source ${index + 1}',
                  style:
                      const TextStyle(
                    color:
                        AppColors.textPrimary,
                    fontSize: 10.5,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Remove source',
                onPressed: onRemove,
                icon: const Icon(
                  Icons
                      .delete_outline_rounded,
                  size: 18,
                  color: AppColors.coral,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (
              context,
              constraints,
            ) {
              final compact =
                  constraints.maxWidth < 600;

              final organization =
                  TextField(
                controller:
                    source.organization,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Organization',
                ),
              );

              final title =
                  TextField(
                controller:
                    source.publicationTitle,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Publication title',
                ),
              );

              if (compact) {
                return Column(
                  children: [
                    organization,
                    const SizedBox(
                      height: 10,
                    ),
                    title,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(
                    child: organization,
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: title),
                ],
              );
            },
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (
              context,
              constraints,
            ) {
              final compact =
                  constraints.maxWidth < 600;

              final year =
                  TextField(
                controller:
                    source.publicationYear,
                keyboardType:
                    TextInputType.number,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Publication year',
                ),
              );

              final doi =
                  TextField(
                controller: source.doi,
                decoration:
                    const InputDecoration(
                  labelText: 'DOI',
                ),
              );

              if (compact) {
                return Column(
                  children: [
                    year,
                    const SizedBox(
                      height: 10,
                    ),
                    doi,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: year),
                  const SizedBox(width: 10),
                  Expanded(child: doi),
                ],
              );
            },
          ),
          const SizedBox(height: 10),
          TextField(
            controller: source.url,
            decoration:
                const InputDecoration(
              labelText: 'URL',
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: source.notes,
            minLines: 2,
            maxLines: 4,
            decoration:
                const InputDecoration(
              labelText: 'Notes',
              alignLabelWithHint: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle
    extends StatelessWidget {
  const _SectionTitle({
    required this.eyebrow,
    required this.title,
    required this.description,
  });

  final String eyebrow;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow,
          style:
              const TextStyle(
            color:
                AppColors.primaryBright,
            fontSize: 8,
            fontWeight:
                FontWeight.w800,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          title,
          style:
              const TextStyle(
            color:
                AppColors.textPrimary,
            fontSize: 17,
            fontWeight:
                FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style:
              const TextStyle(
            color:
                AppColors.textMuted,
            fontSize: 10,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

class _EditSectionTitle
    extends StatelessWidget {
  const _EditSectionTitle({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        color: AppColors.primaryBright,
        fontSize: 8,
        fontWeight: FontWeight.w800,
        letterSpacing: 1,
      ),
    );
  }
}

class _StatusBadge
    extends StatelessWidget {
  const _StatusBadge({
    required this.status,
  });

  final String status;

  @override
  Widget build(BuildContext context) {
    final color =
        _statusColor(status);

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color:
            color.withValues(alpha: .1),
        borderRadius:
            BorderRadius.circular(99),
        border: Border.all(
          color:
              color.withValues(alpha: .22),
        ),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 7.5,
          fontWeight:
              FontWeight.w800,
          letterSpacing: .7,
        ),
      ),
    );
  }
}

class _MetaChip
    extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface
            .withValues(alpha: .7),
        borderRadius:
            BorderRadius.circular(9),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color:
                AppColors.textMuted,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color:
                  AppColors.textSecondary,
              fontSize: 9,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineMeta
    extends StatelessWidget {
  const _InlineMeta({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize:
          MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 12,
          color: AppColors.textMuted,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            color:
                AppColors.textMuted,
            fontSize: 9,
          ),
        ),
      ],
    );
  }
}

class _SmallButton
    extends StatelessWidget {
  const _SmallButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.emphasized = false,
    this.destructive = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool emphasized;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final foreground = destructive
        ? AppColors.coral
        : emphasized
            ? AppColors.primaryBright
            : AppColors.textSecondary;

    return TextButton.icon(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: foreground,
        backgroundColor: emphasized
            ? AppColors.primary
                .withValues(alpha: .09)
            : destructive
                ? AppColors.coral
                    .withValues(alpha: .06)
                : AppColors.surface
                    .withValues(alpha: .5),
        padding:
            const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 9,
        ),
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(9),
          side: BorderSide(
            color: emphasized
                ? AppColors.primary
                    .withValues(alpha: .2)
                : destructive
                    ? AppColors.coral
                        .withValues(
                          alpha: .16,
                        )
                    : AppColors.border,
          ),
        ),
      ),
      icon: Icon(
        icon,
        size: 14,
      ),
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 9,
          fontWeight:
              FontWeight.w700,
        ),
      ),
    );
  }
}

class _SquareButton
    extends StatelessWidget {
  const _SquareButton({
    required this.tooltip,
    required this.icon,
    required this.onTap,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: SizedBox(
        width: 40,
        height: 40,
        child: Material(
          color: AppColors.surface
              .withValues(alpha: .65),
          borderRadius:
              BorderRadius.circular(11),
          child: InkWell(
            onTap: onTap,
            borderRadius:
                BorderRadius.circular(11),
            child: Icon(
              icon,
              size: 18,
              color: onTap == null
                  ? AppColors.textMuted
                      .withValues(alpha: .4)
                  : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingCard
    extends StatelessWidget {
  const _LoadingCard({
    required this.height,
  });

  final double height;

  @override
  Widget build(BuildContext context) {
    final isPublishedCard = height >= 150;

    return AdminSkeleton(
      child: Container(
        width: double.infinity,
        height: height,
        padding: EdgeInsets.all(
          isPublishedCard ? 20 : 17,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface
              .withValues(alpha: .45),
          borderRadius: BorderRadius.circular(
            isPublishedCard ? 16 : 14,
          ),
          border: Border.all(
            color: isPublishedCard
                ? AppColors.primaryBright
                    .withValues(alpha: .14)
                : AppColors.border,
          ),
        ),
        child: isPublishedCard
            ? const _PublishedLoadingContent()
            : const _VersionLoadingContent(),
      ),
    );
  }
}

class _PublishedLoadingContent
    extends StatelessWidget {
  const _PublishedLoadingContent();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact =
            constraints.maxWidth < 720;

        const information = Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AdminSkeletonBox(
                  width: 42,
                  height: 42,
                  radius: 12,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      AdminSkeletonBox(
                        width: 112,
                        height: 8,
                        radius: 4,
                      ),
                      SizedBox(height: 7),
                      AdminSkeletonBox(
                        width: 190,
                        height: 15,
                        radius: 7,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                AdminSkeletonBox(
                  width: 92,
                  height: 27,
                  radius: 9,
                ),
                AdminSkeletonBox(
                  width: 76,
                  height: 27,
                  radius: 14,
                ),
                AdminSkeletonBox(
                  width: 86,
                  height: 27,
                  radius: 9,
                ),
                AdminSkeletonBox(
                  width: 132,
                  height: 27,
                  radius: 9,
                ),
              ],
            ),
            SizedBox(height: 13),
            AdminSkeletonBox(
              width: 360,
              height: 10,
              radius: 5,
            ),
          ],
        );

        const actions = Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            AdminSkeletonBox(
              width: 102,
              height: 36,
              radius: 9,
            ),
            AdminSkeletonBox(
              width: 148,
              height: 36,
              radius: 9,
            ),
          ],
        );

        if (compact) {
          return const Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              information,
              SizedBox(height: 18),
              actions,
            ],
          );
        }

        return const Row(
          crossAxisAlignment:
              CrossAxisAlignment.end,
          children: [
            Expanded(child: information),
            SizedBox(width: 20),
            actions,
          ],
        );
      },
    );
  }
}

class _VersionLoadingContent
    extends StatelessWidget {
  const _VersionLoadingContent();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact =
            constraints.maxWidth < 760;

        const details = Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            AdminSkeletonBox(
              width: 39,
              height: 39,
              radius: 11,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      AdminSkeletonBox(
                        width: 150,
                        height: 13,
                        radius: 6,
                      ),
                      SizedBox(width: 8),
                      AdminSkeletonBox(
                        width: 68,
                        height: 20,
                        radius: 10,
                      ),
                    ],
                  ),
                  SizedBox(height: 9),
                  Wrap(
                    spacing: 12,
                    runSpacing: 5,
                    children: [
                      AdminSkeletonBox(
                        width: 72,
                        height: 9,
                        radius: 4,
                      ),
                      AdminSkeletonBox(
                        width: 62,
                        height: 9,
                        radius: 4,
                      ),
                      AdminSkeletonBox(
                        width: 118,
                        height: 9,
                        radius: 4,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );

        const actions = Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            AdminSkeletonBox(
              width: 66,
              height: 34,
              radius: 9,
            ),
            AdminSkeletonBox(
              width: 86,
              height: 34,
              radius: 9,
            ),
          ],
        );

        if (compact) {
          return const Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              details,
              SizedBox(height: 12),
              actions,
            ],
          );
        }

        return const Row(
          children: [
            Expanded(child: details),
            SizedBox(width: 16),
            actions,
          ],
        );
      },
    );
  }
}

class _NoPublishedCard
    extends StatelessWidget {
  const _NoPublishedCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface
            .withValues(alpha: .55),
        borderRadius:
            BorderRadius.circular(15),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: AppColors.textMuted,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'No published hydration guideline',
                  style: TextStyle(
                    color: AppColors
                        .textPrimary,
                    fontSize: 13,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'No hydration guideline version is currently published.',
                  style: TextStyle(
                    color:
                        AppColors.textMuted,
                    fontSize: 10,
                    height: 1.4,
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

class _EmptyVersions
    extends StatelessWidget {
  const _EmptyVersions();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 40,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface
            .withValues(alpha: .45),
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.water_drop_outlined,
            color: AppColors.textMuted,
            size: 28,
          ),
          SizedBox(height: 10),
          Text(
            'No hydration guideline versions found',
            style: TextStyle(
              color:
                  AppColors.textPrimary,
              fontSize: 12,
              fontWeight:
                  FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorCard
    extends StatelessWidget {
  const _ErrorCard({
    required this.title,
    required this.message,
    required this.onRetry,
  });

  final String title;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.coral
            .withValues(alpha: .05),
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.coral
              .withValues(alpha: .18),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: AppColors.coral,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors
                        .textPrimary,
                    fontSize: 11,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  message,
                  style: const TextStyle(
                    color:
                        AppColors.textMuted,
                    fontSize: 9.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          TextButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

Color _statusColor(
  String status,
) {
  switch (status.toUpperCase()) {
    case 'PUBLISHED':
      return AppColors.primaryBright;
    case 'DRAFT':
      return Colors.amber;
    case 'ARCHIVED':
      return AppColors.textMuted;
    default:
      return AppColors.textSecondary;
  }
}

IconData _statusIcon(
  String status,
) {
  switch (status.toUpperCase()) {
    case 'PUBLISHED':
      return Icons.verified_outlined;
    case 'DRAFT':
      return Icons.edit_note_rounded;
    case 'ARCHIVED':
      return Icons.archive_outlined;
    default:
      return Icons.description_outlined;
  }
}

String _formatDate(
  DateTime value,
) {
  final local = value.toLocal();

  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  return '${months[local.month - 1]} '
      '${local.day}, '
      '${local.year}';
}

String _number(
  double value,
) {
  if (value ==
      value.roundToDouble()) {
    return value.toInt().toString();
  }

  return value
      .toStringAsFixed(2)
      .replaceFirst(
        RegExp(r'0+$'),
        '',
      )
      .replaceFirst(
        RegExp(r'\.$'),
        '',
      );
}
