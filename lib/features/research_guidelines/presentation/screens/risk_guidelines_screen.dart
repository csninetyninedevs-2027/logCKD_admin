import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/risk_guideline_model.dart';
import '../../state/risk_guideline_admin_provider.dart';

class RiskGuidelinesScreen extends ConsumerStatefulWidget {
  const RiskGuidelinesScreen({
    super.key,
    this.onBack,
  });

  final VoidCallback? onBack;

  @override
  ConsumerState<RiskGuidelinesScreen> createState() =>
      _RiskGuidelinesScreenState();
}

class _RiskGuidelinesScreenState
    extends ConsumerState<RiskGuidelinesScreen> {
  bool _actionInProgress = false;

  Future<void> _refresh() async {
    ref.invalidate(
      riskGuidelineListProvider,
    );

    ref.invalidate(
      publishedRiskGuidelineProvider,
    );

    ref.invalidate(
      riskGuidelineHistoryProvider,
    );

    await Future.wait([
      ref.read(
        riskGuidelineListProvider.future,
      ),
      ref.read(
        publishedRiskGuidelineProvider.future,
      ),
    ]);
  }

  String _errorMessage(
    Object error,
  ) {
    if (error is DioException) {
      final data = error.response?.data;

      if (data is Map) {
        final message =
            data['message'] ??
            data['error'];

        if (message != null &&
            message.toString().trim().isNotEmpty) {
          return message.toString();
        }
      }

      if (data is String &&
          data.trim().isNotEmpty) {
        return data;
      }

      return error.message ??
          'The request could not be completed.';
    }

    return error.toString();
  }

  void _showMessage(
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
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: error
              ? AppColors.coral
              : AppColors.surface,
        ),
      );
  }

  Future<bool> _confirm({
    required String title,
    required String message,
    required String actionLabel,
    bool destructive = false,
  }) async {
    final result = await showDialog<bool>(
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
              child: Text(actionLabel),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  Future<void> _publish(
    RiskGuidelineModel guideline,
  ) async {
    final confirmed = await _confirm(
      title: 'Publish guideline?',
      message:
          'Version ${guideline.version} will become the published risk guideline used by the system. The previously published version will no longer remain active.',
      actionLabel: 'Publish',
    );

    if (!confirmed) {
      return;
    }

    await _performAction(
      () async {
        await ref
            .read(
              riskGuidelineAdminActionsProvider,
            )
            .publish(guideline.id);
      },
      success:
          'Risk guideline version ${guideline.version} published.',
    );
  }

  Future<void> _archive(
    RiskGuidelineModel guideline,
  ) async {
    final confirmed = await _confirm(
      title: 'Archive guideline?',
      message:
          'Version ${guideline.version} will be archived. Archived versions remain available in guideline history.',
      actionLabel: 'Archive',
      destructive: true,
    );

    if (!confirmed) {
      return;
    }

    await _performAction(
      () async {
        await ref
            .read(
              riskGuidelineAdminActionsProvider,
            )
            .archive(guideline.id);
      },
      success:
          'Risk guideline version ${guideline.version} archived.',
    );
  }

  Future<void> _rollback(
    RiskGuidelineModel guideline,
  ) async {
    final confirmed = await _confirm(
      title: 'Restore this version?',
      message:
          'Version ${guideline.version} will be restored as the published risk guideline. The currently published version will be moved out of the active published state.',
      actionLabel: 'Restore version',
    );

    if (!confirmed) {
      return;
    }

    await _performAction(
      () async {
        await ref
            .read(
              riskGuidelineAdminActionsProvider,
            )
            .rollback(guideline.id);
      },
      success:
          'Risk guideline version ${guideline.version} restored.',
    );
  }

  Future<void> _createNewVersion(
    RiskGuidelineModel guideline,
  ) async {
    final confirmed = await _confirm(
      title: 'Create new draft?',
      message:
          'A new draft version will be created from version ${guideline.version}. The currently published guideline will not change until the new version is explicitly published.',
      actionLabel: 'Create draft',
    );

    if (!confirmed) {
      return;
    }

    await _performAction(
      () async {
        await ref
            .read(
              riskGuidelineAdminActionsProvider,
            )
            .createNewVersion(
              id: guideline.id,
              payload: const {},
            );
      },
      success:
          'A new risk guideline draft was created.',
    );
  }

  Future<void> _performAction(
    Future<void> Function() action, {
    required String success,
  }) async {
    if (_actionInProgress) {
      return;
    }

    setState(() {
      _actionInProgress = true;
    });

    try {
      await action();

      if (!mounted) {
        return;
      }

      _showMessage(success);

      await _refresh();
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage(
        _errorMessage(error),
        error: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _actionInProgress = false;
        });
      }
    }
  }

  Future<void> _editDraft(
    RiskGuidelineModel guideline,
  ) async {
    if (!guideline.isDraft) {
      _showMessage(
        'Only DRAFT risk guideline versions can be edited.',
        error: true,
      );

      return;
    }

    RiskGuidelineModel selected = guideline;

    try {
      selected = await ref.read(
        riskGuidelineDetailProvider(
          guideline.id,
        ).future,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage(
        _errorMessage(error),
        error: true,
      );

      return;
    }

    if (!mounted) {
      return;
    }

    final payload =
        await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return _RiskGuidelineEditDialog(
          guideline: selected,
        );
      },
    );

    if (payload == null) {
      return;
    }

    await _performAction(
      () async {
        await ref
            .read(
              riskGuidelineAdminActionsProvider,
            )
            .update(
              id: guideline.id,
              payload: payload,
            );
      },
      success:
          'Risk guideline version ${guideline.version} updated.',
    );
  }

  Future<void> _showDetails(
    RiskGuidelineModel guideline,
  ) async {
    RiskGuidelineModel selected = guideline;

    try {
      selected = await ref.read(
        riskGuidelineDetailProvider(
          guideline.id,
        ).future,
      );
    } catch (_) {
      // The list representation is still enough to
      // display useful information if detail retrieval
      // temporarily fails.
    }

    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return _RiskGuidelineDetailsDialog(
          guideline: selected,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final published = ref.watch(
      publishedRiskGuidelineProvider,
    );

    final guidelines = ref.watch(
      riskGuidelineListProvider,
    );

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        _TopBar(
          onBack: widget.onBack,
          refreshing: _actionInProgress,
          onRefresh: _actionInProgress
              ? null
              : _refresh,
        ),
        const SizedBox(height: 18),
        published.when(
          loading: () =>
              const _PublishedLoadingCard(),
          error: (error, _) =>
              _InlineErrorCard(
            title:
                'Unable to load published guideline',
            message: _errorMessage(error),
            onRetry: () {
              ref.invalidate(
                publishedRiskGuidelineProvider,
              );
            },
          ),
          data: (guideline) {
            if (guideline == null) {
              return const _NoPublishedCard();
            }

            return _PublishedGuidelineCard(
              guideline: guideline,
              disabled: _actionInProgress,
              onView: () =>
                  _showDetails(guideline),
              onCreateVersion: () =>
                  _createNewVersion(guideline),
            );
          },
        ),
        const SizedBox(height: 22),
        const _SectionHeading(
          eyebrow: 'VERSION CONTROL',
          title: 'Guideline versions',
          description:
              'Review and edit draft versions, publish approved changes, or restore archived versions.',
        ),
        const SizedBox(height: 12),
        guidelines.when(
          loading: () =>
              const _VersionListLoading(),
          error: (error, _) =>
              _InlineErrorCard(
            title:
                'Unable to load guideline versions',
            message: _errorMessage(error),
            onRetry: () {
              ref.invalidate(
                riskGuidelineListProvider,
              );
            },
          ),
          data: (result) {
            if (result.items.isEmpty) {
              return const _EmptyVersions();
            }

            final items = [
              ...result.items,
            ];

            items.sort(
              (a, b) =>
                  b.version.compareTo(a.version),
            );

            return Column(
              children: [
                for (
                  var index = 0;
                  index < items.length;
                  index++
                ) ...[
                  _GuidelineVersionCard(
                    guideline: items[index],
                    disabled:
                        _actionInProgress,
                    onView: () =>
                        _showDetails(
                      items[index],
                    ),
                    onEdit:
                        items[index].isDraft
                            ? () => _editDraft(
                                  items[index],
                                )
                            : null,
                    onPublish:
                        items[index].isDraft
                            ? () => _publish(
                                  items[index],
                                )
                            : null,
                    onArchive:
                        items[index].isDraft
                            ? () => _archive(
                                  items[index],
                                )
                            : null,
                    onRollback:
                        items[index].isArchived
                            ? () => _rollback(
                                  items[index],
                                )
                            : null,
                    onCreateVersion:
                        items[index].isPublished
                            ? () =>
                                _createNewVersion(
                                  items[index],
                                )
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

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.onBack,
    required this.refreshing,
    required this.onRefresh,
  });

  final VoidCallback? onBack;
  final bool refreshing;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (onBack != null) ...[
          _SquareButton(
            tooltip:
                'Back to Research & Guidelines',
            icon: Icons.arrow_back_rounded,
            onTap: onBack!,
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Text(
                'RISK ASSESSMENT GUIDELINES',
                style: TextStyle(
                  color:
                      AppColors.primaryBright,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Risk Guidelines',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Manage the versioned clinical and risk-rule configuration consumed by the assessment system.',
                style: TextStyle(
                  color: AppColors.textSecondary
                      .withValues(alpha: .9),
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
          icon: refreshing
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

class _PublishedGuidelineCard
    extends StatelessWidget {
  const _PublishedGuidelineCard({
    required this.guideline,
    required this.disabled,
    required this.onView,
    required this.onCreateVersion,
  });

  final RiskGuidelineModel guideline;
  final bool disabled;
  final VoidCallback onView;
  final VoidCallback onCreateVersion;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color:
            AppColors.primary.withValues(
          alpha: .08,
        ),
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryBright
              .withValues(alpha: .22),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary
                .withValues(alpha: .06),
            blurRadius: 24,
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact =
              constraints.maxWidth < 700;

          final information = Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.primary
                          .withValues(
                        alpha: .12,
                      ),
                      borderRadius:
                          BorderRadius.circular(
                        12,
                      ),
                    ),
                    child: const Icon(
                      Icons
                          .verified_outlined,
                      color: AppColors
                          .primaryBright,
                      size: 20,
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
                          'CURRENTLY PUBLISHED',
                          style: TextStyle(
                            color: AppColors
                                .primaryBright,
                            fontSize: 8,
                            fontWeight:
                                FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Text(
                          _guidelineName(
                            guideline,
                          ),
                          style:
                              const TextStyle(
                            color: AppColors
                                .textPrimary,
                            fontSize: 15,
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 17),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _MetadataChip(
                    label:
                        'Version ${guideline.version}',
                    icon:
                        Icons.tag_rounded,
                  ),
                  _StatusBadge(
                    status:
                        guideline.status,
                  ),
                  if (guideline
                      .guidelineKey.isNotEmpty)
                    _MetadataChip(
                      label: guideline
                          .guidelineKey,
                      icon: Icons
                          .key_outlined,
                    ),
                ],
              ),
              if (guideline
                  .description.isNotEmpty) ...[
                const SizedBox(height: 14),
                Text(
                  guideline.description,
                  style: const TextStyle(
                    color: AppColors
                        .textSecondary,
                    fontSize: 10.5,
                    height: 1.5,
                  ),
                ),
              ],
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
                    const Text('View details'),
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
              Expanded(child: information),
              const SizedBox(width: 20),
              actions,
            ],
          );
        },
      ),
    );
  }
}

class _GuidelineVersionCard
    extends StatelessWidget {
  const _GuidelineVersionCard({
    required this.guideline,
    required this.disabled,
    required this.onView,
    required this.onEdit,
    required this.onPublish,
    required this.onArchive,
    required this.onRollback,
    required this.onCreateVersion,
  });

  final RiskGuidelineModel guideline;
  final bool disabled;

  final VoidCallback onView;
  final VoidCallback? onEdit;
  final VoidCallback? onPublish;
  final VoidCallback? onArchive;
  final VoidCallback? onRollback;
  final VoidCallback? onCreateVersion;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppColors.surface
            .withValues(alpha: .62),
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
          color: guideline.isPublished
              ? AppColors.primary
                  .withValues(alpha: .25)
              : AppColors.border,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact =
              constraints.maxWidth < 760;

          final details = Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                width: 39,
                height: 39,
                decoration: BoxDecoration(
                  color: _statusColor(
                    guideline.status,
                  ).withValues(alpha: .1),
                  borderRadius:
                      BorderRadius.circular(
                    11,
                  ),
                ),
                child: Icon(
                  _statusIcon(
                    guideline.status,
                  ),
                  size: 18,
                  color: _statusColor(
                    guideline.status,
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
                        Flexible(
                          child: Text(
                            _guidelineName(
                              guideline,
                            ),
                            overflow:
                                TextOverflow
                                    .ellipsis,
                            style:
                                const TextStyle(
                              color: AppColors
                                  .textPrimary,
                              fontSize: 13,
                              fontWeight:
                                  FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _StatusBadge(
                          status:
                              guideline.status,
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Wrap(
                      spacing: 12,
                      runSpacing: 5,
                      children: [
                        _InlineMetadata(
                          icon: Icons
                              .tag_rounded,
                          text:
                              'Version ${guideline.version}',
                        ),
                        if (guideline
                            .guidelineKey
                            .isNotEmpty)
                          _InlineMetadata(
                            icon: Icons
                                .key_outlined,
                            text: guideline
                                .guidelineKey,
                          ),
                        if (guideline
                                .updatedAt !=
                            null)
                          _InlineMetadata(
                            icon: Icons
                                .schedule_rounded,
                            text:
                                'Updated ${_formatDate(guideline.updatedAt!)}',
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
              _SmallActionButton(
                label: 'View',
                icon:
                    Icons.visibility_outlined,
                onTap:
                    disabled ? null : onView,
              ),
              if (onEdit != null)
                _SmallActionButton(
                  label: 'Edit',
                  icon:
                      Icons.edit_outlined,
                  emphasized: true,
                  onTap: disabled
                      ? null
                      : onEdit,
                ),
              if (onCreateVersion != null)
                _SmallActionButton(
                  label: 'New version',
                  icon: Icons
                      .add_circle_outline_rounded,
                  onTap: disabled
                      ? null
                      : onCreateVersion,
                ),
              if (onPublish != null)
                _SmallActionButton(
                  label: 'Publish',
                  icon:
                      Icons.publish_rounded,
                  emphasized: true,
                  onTap: disabled
                      ? null
                      : onPublish,
                ),
              if (onRollback != null)
                _SmallActionButton(
                  label: 'Restore',
                  icon: Icons
                      .history_rounded,
                  emphasized: true,
                  onTap: disabled
                      ? null
                      : onRollback,
                ),
              if (onArchive != null)
                _SmallActionButton(
                  label: 'Archive',
                  icon: Icons
                      .archive_outlined,
                  destructive: true,
                  onTap: disabled
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

class _RiskGuidelineEditDialog
    extends StatefulWidget {
  const _RiskGuidelineEditDialog({
    required this.guideline,
  });

  final RiskGuidelineModel guideline;

  @override
  State<_RiskGuidelineEditDialog>
      createState() =>
          _RiskGuidelineEditDialogState();
}

class _RiskGuidelineEditDialogState
    extends State<_RiskGuidelineEditDialog> {
  static const _systemFields = <String>{
    '_id',
    'id',
    '__v',
    'version',
    'status',
    'publishedAt',
    'archivedAt',
    'createdAt',
    'updatedAt',
    'createdBy',
    'publishedBy',
  };

  final _formKey =
      GlobalKey<FormState>();

  late final Map<String, dynamic>
      _originalValues;

  late final Map<String, TextEditingController>
      _controllers;

  late final Map<String, bool>
      _booleanValues;

  @override
  void initState() {
    super.initState();

    _originalValues =
        <String, dynamic>{};

    _controllers =
        <String, TextEditingController>{};

    _booleanValues =
        <String, bool>{};

    for (final entry
        in widget.guideline.raw.entries) {
      if (_systemFields.contains(
        entry.key,
      )) {
        continue;
      }

      final value = entry.value;

      _originalValues[entry.key] =
          value;

      if (value is bool) {
        _booleanValues[entry.key] =
            value;
      } else {
        _controllers[entry.key] =
            TextEditingController(
          text: _displayValue(
            value,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    for (final controller
        in _controllers.values) {
      controller.dispose();
    }

    super.dispose();
  }

  String _displayValue(
    dynamic value,
  ) {
    if (value == null) {
      return '';
    }

    if (value is Map ||
        value is List) {
      return const JsonEncoder.withIndent(
        '  ',
      ).convert(
        value,
      );
    }

    return value.toString();
  }

  String _labelForField(
    String field,
  ) {
    const special =
        <String, String>{
      'gfr_g1':
          'eGFR G1 threshold',
      'gfr_g2':
          'eGFR G2 threshold',
      'gfr_g3a':
          'eGFR G3a threshold',
      'gfr_g3b':
          'eGFR G3b threshold',
      'gfr_g4':
          'eGFR G4 threshold',
      'acr_a1_max':
          'ACR A1 maximum',
      'acr_a2_max':
          'ACR A2 maximum',
      'kdigo_risk_matrix':
          'KDIGO risk matrix',
      'abnormal_egfr_threshold':
          'Abnormal eGFR threshold',
      'abnormal_acr_threshold':
          'Abnormal ACR threshold',
      'low_max':
          'Low risk maximum',
      'moderate_max':
          'Moderate risk maximum',
      'source_doi':
          'Source DOI',
      'source_url':
          'Source URL',
    };

    final known = special[field];

    if (known != null) {
      return known;
    }

    final words = field
        .split('_')
        .where(
          (part) =>
              part.isNotEmpty,
        )
        .map(
          (part) {
            final upper =
                part.toUpperCase();

            if (const {
              'CKD',
              'KDIGO',
              'ACR',
              'GFR',
              'EGFR',
              'BP',
              'HR',
              'FSM',
              'DOI',
              'URL',
              'MG',
              'KCAL',
              'BPM',
            }.contains(
              upper,
            )) {
              return upper;
            }

            return '${part[0].toUpperCase()}${part.substring(1)}';
          },
        )
        .toList();

    return words.join(' ');
  }

  String _groupForField(
    String field,
  ) {
    if (field == 'title' ||
        field == 'description') {
      return 'Basic information';
    }

    if (field.startsWith('gfr_') ||
        field.startsWith('acr_') ||
        field == 'kdigo_risk_matrix') {
      return 'KDIGO classification';
    }

    if (field.startsWith('abnormal_')) {
      return 'Kidney-marker thresholds';
    }

    if (field.startsWith('safety_') ||
        field ==
            'very_high_acr_followup_threshold' ||
        field.startsWith('severe_')) {
      return 'Safety thresholds';
    }

    if (field == 'low_max' ||
        field == 'moderate_max' ||
        field == 'moderate_floor' ||
        field == 'high_floor' ||
        field == 'very_high_floor') {
      return 'Risk bands and score floors';
    }

    if (field.startsWith('history_') ||
        field == 'max_history_modifier' ||
        field == 'max_monthly_modifier') {
      return 'History and monthly modifiers';
    }

    if (field == 'minimum_usable_coverage' ||
        field == 'sufficient_coverage') {
      return 'General tracker coverage';
    }

    if (field.startsWith('sodium_') ||
        field == 'high_sodium_mg') {
      return 'Sodium risk modifier';
    }

    if (field == 'active_minutes_target' ||
        field == 'very_low_active_minutes' ||
        field == 'low_activity_points' ||
        field == 'very_low_activity_points' ||
        field == 'high_sedentary_hours' ||
        field == 'high_sedentary_points') {
      return 'Activity risk modifier';
    }

    if (field.startsWith('food_')) {
      return 'Food recommendations';
    }

    if (field.startsWith('activity_rec_')) {
      return 'Activity recommendations';
    }

    if (field.startsWith('sleep_rec_')) {
      return 'Sleep recommendations';
    }

    if (field.startsWith('hydration_rec_')) {
      return 'Hydration recommendations';
    }

    if (field.startsWith('fsm_') ||
        field.startsWith(
          'immediate_escalation_',
        )) {
      return 'FSM and safety bypass';
    }

    if (field.startsWith('source_')) {
      return 'Source metadata';
    }

    return 'Other configuration';
  }

  bool _isNumericField(
    String field,
    dynamic original,
  ) {
    if (original is num) {
      return true;
    }

    return field ==
        'source_publication_year';
  }

  bool _isStructuredField(
    dynamic original,
  ) {
    return original is Map ||
        original is List;
  }

  dynamic _parseFieldValue(
    String field,
    String text,
    dynamic original,
  ) {
    final trimmed =
        text.trim();

    if (_isStructuredField(
      original,
    )) {
      if (trimmed.isEmpty) {
        throw const FormatException(
          'Structured values cannot be empty.',
        );
      }

      final decoded =
          jsonDecode(
        trimmed,
      );

      if (original is Map &&
          decoded is! Map) {
        throw const FormatException(
          'Expected a JSON object.',
        );
      }

      if (original is List &&
          decoded is! List) {
        throw const FormatException(
          'Expected a JSON array.',
        );
      }

      return decoded;
    }

    if (_isNumericField(
      field,
      original,
    )) {
      if (trimmed.isEmpty) {
        if (original == null) {
          return null;
        }

        throw const FormatException(
          'A numeric value is required.',
        );
      }

      final parsed =
          num.tryParse(
        trimmed,
      );

      if (parsed == null) {
        throw const FormatException(
          'Enter a valid number.',
        );
      }

      if (original is int) {
        if (parsed % 1 != 0) {
          throw const FormatException(
            'Enter a whole number.',
          );
        }

        return parsed.toInt();
      }

      if (field ==
          'source_publication_year') {
        if (parsed % 1 != 0) {
          throw const FormatException(
            'Enter a whole year.',
          );
        }

        return parsed.toInt();
      }

      return parsed.toDouble();
    }

    if (original == null) {
      return trimmed.isEmpty
          ? null
          : trimmed;
    }

    return text.trim();
  }

  void _submit() {
    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    final payload =
        <String, dynamic>{};

    try {
      for (final entry
          in _originalValues.entries) {
        final field = entry.key;
        final original = entry.value;

        if (original is bool) {
          payload[field] =
              _booleanValues[field] ??
                  original;

          continue;
        }

        final controller =
            _controllers[field];

        if (controller == null) {
          continue;
        }

        payload[field] =
            _parseFieldValue(
          field,
          controller.text,
          original,
        );
      }
    } on FormatException catch (error) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              error.message,
            ),
          ),
        );

      return;
    }

    Navigator.of(context).pop(
      payload,
    );
  }

  @override
  Widget build(BuildContext context) {
    final grouped =
        <String, List<String>>{};

    for (final field
        in _originalValues.keys) {
      final group =
          _groupForField(
        field,
      );

      grouped
          .putIfAbsent(
            group,
            () => <String>[],
          )
          .add(
            field,
          );
    }

    return Dialog(
      backgroundColor:
          Colors.transparent,
      insetPadding:
          const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 24,
      ),
      child: Container(
        width: 920,
        constraints:
            const BoxConstraints(
          maxHeight: 780,
        ),
        decoration: BoxDecoration(
          color:
              AppColors.background,
          borderRadius:
              BorderRadius.circular(
            18,
          ),
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
                          BorderRadius.circular(
                        11,
                      ),
                    ),
                    child: const Icon(
                      Icons.edit_note_rounded,
                      size: 19,
                      color: Colors.amber,
                    ),
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Edit ${_guidelineName(widget.guideline)}',
                          style:
                              const TextStyle(
                            color: AppColors
                                .textPrimary,
                            fontSize: 15,
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),
                        const SizedBox(
                          height: 3,
                        ),
                        Text(
                          'Version ${widget.guideline.version} · DRAFT',
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
                              .primary
                              .withValues(
                            alpha: .06,
                          ),
                          borderRadius:
                              BorderRadius.circular(
                            12,
                          ),
                          border: Border.all(
                            color: AppColors
                                .primary
                                .withValues(
                              alpha: .14,
                            ),
                          ),
                        ),
                        child: const Text(
                          'Only this DRAFT version will be changed. Published and archived versions remain immutable until an explicit publish or restore action is performed.',
                          style:
                              TextStyle(
                            color: AppColors
                                .textSecondary,
                            fontSize: 10,
                            height: 1.45,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 18,
                      ),
                      for (final group
                          in grouped.entries) ...[
                        _EditSectionTitle(
                          title:
                              group.key,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        for (final field
                            in group.value) ...[
                          _buildEditor(
                            field,
                            _originalValues[
                                field],
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                        ],
                        const SizedBox(
                          height: 6,
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
                  const EdgeInsets.all(
                16,
              ),
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
                        const Text(
                      'Cancel',
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  FilledButton.icon(
                    onPressed:
                        _submit,
                    icon: const Icon(
                      Icons.save_outlined,
                      size: 17,
                    ),
                    label: const Text(
                      'Save draft',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditor(
    String field,
    dynamic original,
  ) {
    if (original is bool) {
      return Container(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface
              .withValues(
            alpha: .5,
          ),
          borderRadius:
              BorderRadius.circular(
            10,
          ),
          border: Border.all(
            color:
                AppColors.border,
          ),
        ),
        child: SwitchListTile(
          contentPadding:
              EdgeInsets.zero,
          title: Text(
            _labelForField(
              field,
            ),
            style:
                const TextStyle(
              color: AppColors
                  .textPrimary,
              fontSize: 11,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
          value:
              _booleanValues[field] ??
                  original,
          onChanged: (value) {
            setState(() {
              _booleanValues[field] =
                  value;
            });
          },
        ),
      );
    }

    final structured =
        _isStructuredField(
      original,
    );

    final numeric =
        _isNumericField(
      field,
      original,
    );

    return TextFormField(
      controller:
          _controllers[field],
      minLines:
          structured ? 5 : 1,
      maxLines:
          structured
              ? 14
              : field ==
                          'description' ||
                      field ==
                          'source_notes'
                  ? 4
                  : 1,
      keyboardType: numeric
          ? const TextInputType
              .numberWithOptions(
              decimal: true,
              signed: false,
            )
          : TextInputType.text,
      style: TextStyle(
        color:
            AppColors.textPrimary,
        fontSize:
            structured ? 10 : 11,
        fontFamily:
            structured
                ? 'monospace'
                : null,
      ),
      decoration: InputDecoration(
        labelText:
            _labelForField(
          field,
        ),
        helperText: structured
            ? field ==
                    'kdigo_risk_matrix'
                ? 'Structured JSON object. Keep all G1–G5 rows and A1–A3 risk levels.'
                : 'Structured JSON value.'
            : null,
        alignLabelWithHint:
            structured,
      ),
      validator: (value) {
        final text =
            value ?? '';

        if (const {
          'title',
          'description',
          'source_organization',
        }.contains(field) &&
            text.trim().isEmpty) {
          return '${_labelForField(field)} is required.';
        }

        try {
          _parseFieldValue(
            field,
            text,
            original,
          );
        } on FormatException catch (error) {
          return error.message;
        }

        return null;
      },
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
        color:
            AppColors.primaryBright,
        fontSize: 8,
        fontWeight:
            FontWeight.w800,
        letterSpacing: 1.0,
      ),
    );
  }
}

class _RiskGuidelineDetailsDialog
    extends StatelessWidget {
  const _RiskGuidelineDetailsDialog({
    required this.guideline,
  });

  final RiskGuidelineModel guideline;

  @override
  Widget build(BuildContext context) {
    final prettyJson =
        const JsonEncoder.withIndent(
      '  ',
    ).convert(
      guideline.raw,
    );

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding:
          const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 24,
      ),
      child: Container(
        width: 820,
        constraints: const BoxConstraints(
          maxHeight: 720,
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
                    decoration: BoxDecoration(
                      color: AppColors.primary
                          .withValues(
                        alpha: .1,
                      ),
                      borderRadius:
                          BorderRadius.circular(
                        11,
                      ),
                    ),
                    child: const Icon(
                      Icons
                          .policy_outlined,
                      size: 18,
                      color: AppColors
                          .primaryBright,
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
                          _guidelineName(
                            guideline,
                          ),
                          style:
                              const TextStyle(
                            color: AppColors
                                .textPrimary,
                            fontSize: 15,
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),
                        const SizedBox(
                          height: 3,
                        ),
                        Text(
                          'Version ${guideline.version}',
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
                    status: guideline.status,
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
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Persisted guideline configuration',
                      style: TextStyle(
                        color: AppColors
                            .textPrimary,
                        fontSize: 12,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'This is the configuration returned by the backend. Values are displayed as stored so the admin console does not duplicate clinical thresholds.',
                      style: TextStyle(
                        color:
                            AppColors.textMuted,
                        fontSize: 10,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding:
                          const EdgeInsets.all(
                        16,
                      ),
                      decoration:
                          BoxDecoration(
                        color: AppColors.surface
                            .withValues(
                          alpha: .65,
                        ),
                        borderRadius:
                            BorderRadius.circular(
                          12,
                        ),
                        border: Border.all(
                          color:
                              AppColors.border,
                        ),
                      ),
                      child: SelectableText(
                        prettyJson,
                        style: const TextStyle(
                          color: AppColors
                              .textSecondary,
                          fontSize: 10,
                          height: 1.55,
                          fontFamily:
                              'monospace',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.status,
  });

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(
      status,
    );

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(
          alpha: .1,
        ),
        borderRadius:
            BorderRadius.circular(99),
        border: Border.all(
          color: color.withValues(
            alpha: .22,
          ),
        ),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 7.5,
          fontWeight: FontWeight.w800,
          letterSpacing: .7,
        ),
      ),
    );
  }
}

class _MetadataChip extends StatelessWidget {
  const _MetadataChip({
    required this.label,
    required this.icon,
  });

  final String label;
  final IconData icon;

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
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: AppColors.textMuted,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color:
                  AppColors.textSecondary,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineMetadata extends StatelessWidget {
  const _InlineMetadata({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
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
            color: AppColors.textMuted,
            fontSize: 9,
          ),
        ),
      ],
    );
  }
}

class _SmallActionButton
    extends StatelessWidget {
  const _SmallActionButton({
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
                        .withValues(alpha: .16)
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
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SquareButton extends StatelessWidget {
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

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
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
          style: const TextStyle(
            color: AppColors.primaryBright,
            fontSize: 8,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 10,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

class _PublishedLoadingCard
    extends StatelessWidget {
  const _PublishedLoadingCard();

  @override
  Widget build(BuildContext context) {
    return const _LoadingCard(
      height: 180,
    );
  }
}

class _VersionListLoading
    extends StatelessWidget {
  const _VersionListLoading();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _LoadingCard(height: 90),
        SizedBox(height: 10),
        _LoadingCard(height: 90),
        SizedBox(height: 10),
        _LoadingCard(height: 90),
      ],
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard({
    required this.height,
  });

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surface
            .withValues(alpha: .45),
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: const Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        ),
      ),
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
      padding: const EdgeInsets.all(22),
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
                  'No published guideline',
                  style: TextStyle(
                    color:
                        AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'No risk guideline is currently published. Review the available draft versions below.',
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

class _EmptyVersions extends StatelessWidget {
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
            Icons
                .description_outlined,
            color: AppColors.textMuted,
            size: 28,
          ),
          SizedBox(height: 10),
          Text(
            'No guideline versions found',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Risk guideline versions will appear here once they have been registered in the backend.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineErrorCard
    extends StatelessWidget {
  const _InlineErrorCard({
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
      padding: const EdgeInsets.all(18),
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
                    color:
                        AppColors.textPrimary,
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

String _guidelineName(
  RiskGuidelineModel guideline,
) {
  if (guideline.title.trim().isNotEmpty) {
    return guideline.title.trim();
  }

  if (guideline.guidelineKey
      .trim()
      .isNotEmpty) {
    return guideline.guidelineKey.trim();
  }

  return 'Risk Guideline';
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