import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/model_version_model.dart';
import '../../../../shared/widgets/admin_surface.dart';
import '../../state/model_registry_admin_provider.dart';

class ModelRegistryScreen
    extends ConsumerStatefulWidget {
  const ModelRegistryScreen({
    super.key,
    this.onBack,
  });

  final VoidCallback? onBack;

  @override
  ConsumerState<ModelRegistryScreen>
      createState() =>
          _ModelRegistryScreenState();
}

class _ModelRegistryScreenState
    extends ConsumerState<
        ModelRegistryScreen> {
  String? _busyVersion;
  bool _rollbackBusy = false;

  String _errorMessage(
    Object error,
  ) {
    if (error is DioException) {
      final data =
          error.response?.data;

      if (data is Map) {
        final message =
            data['error'] ??
            data['message'];

        final code =
            data['code'];

        if (message != null) {
          if (code != null) {
            return '$message\nCode: $code';
          }

          return message.toString();
        }
      }

      return error.message ??
          'Unable to complete the model registry request.';
    }

    return error.toString();
  }

  void _message(
    String message,
  ) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
  }

  void _refresh() {
    ref
        .read(
          modelRegistryAdminActionsProvider,
        )
        .refresh();
  }

  Future<void> _showDetails(
    ModelVersionModel model,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            model.version,
          ),
          content: SizedBox(
            width: 760,
            child:
                SingleChildScrollView(
              child:
                  SelectableText(
                const JsonEncoder
                    .withIndent(
                  '  ',
                ).convert(
                  model.raw,
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                );
              },
              child:
                  const Text(
                'Close',
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _activate(
    ModelVersionModel model,
  ) async {
    final confirmed =
        await showDialog<bool>(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title:
                      const Text(
                    'Activate model?',
                  ),
                  content: Text(
                    'Activate ${model.version} as the runtime model?\n\n'
                    'The backend will perform runtime deployment, artifact '
                    'verification, inference refresh, MongoDB synchronization, '
                    'and deployment verification.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(
                          context,
                          false,
                        );
                      },
                      child:
                          const Text(
                        'Cancel',
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: () {
                        Navigator.pop(
                          context,
                          true,
                        );
                      },
                      icon:
                          const Icon(
                        Icons
                            .rocket_launch_outlined,
                      ),
                      label:
                          const Text(
                        'Activate',
                      ),
                    ),
                  ],
                );
              },
            ) ??
            false;

    if (!confirmed) {
      return;
    }

    setState(() {
      _busyVersion =
          model.version;
    });

    try {
      await ref
          .read(
            modelRegistryAdminActionsProvider,
          )
          .activate(
            model.version,
          );

      _message(
        'Model ${model.version} activated successfully.',
      );
    } catch (error) {
      _message(
        _errorMessage(error),
      );
    } finally {
      if (mounted) {
        setState(() {
          _busyVersion = null;
        });
      }
    }
  }

  Future<void> _rollback({
    required String algorithm,
    String? targetModelVersion,
  }) async {
    final target =
        targetModelVersion == null
            ? 'the previous eligible model'
            : targetModelVersion;

    final confirmed =
        await showDialog<bool>(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title:
                      const Text(
                    'Roll back model?',
                  ),
                  content: Text(
                    'Roll back $algorithm to $target?\n\n'
                    'This changes the runtime model and should only be '
                    'performed after reviewing the model provenance and metrics.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(
                          context,
                          false,
                        );
                      },
                      child:
                          const Text(
                        'Cancel',
                      ),
                    ),
                    FilledButton(
                      onPressed: () {
                        Navigator.pop(
                          context,
                          true,
                        );
                      },
                      child:
                          const Text(
                        'Roll back',
                      ),
                    ),
                  ],
                );
              },
            ) ??
            false;

    if (!confirmed) {
      return;
    }

    setState(() {
      _rollbackBusy = true;
    });

    try {
      await ref
          .read(
            modelRegistryAdminActionsProvider,
          )
          .rollback(
            algorithm:
                algorithm,
            targetModelVersion:
                targetModelVersion,
          );

      _message(
        targetModelVersion == null
            ? 'Rollback completed for $algorithm.'
            : 'Rolled back $algorithm to $targetModelVersion.',
      );
    } catch (error) {
      _message(
        _errorMessage(error),
      );
    } finally {
      if (mounted) {
        setState(() {
          _rollbackBusy = false;
        });
      }
    }
  }

  Future<void>
      _chooseRollbackTarget(
    String algorithm,
    List<ModelVersionModel> models,
  ) async {
    final eligible =
        models
            .where(
              (model) =>
                  model.algorithm ==
                      algorithm &&
                  !model.isActive,
            )
            .toList();

    final result =
        await showDialog<
            String?>(
      context: context,
      builder: (context) {
        String? selected;

        return StatefulBuilder(
          builder: (
            context,
            setDialogState,
          ) {
            return AlertDialog(
              title:
                  const Text(
                'Rollback target',
              ),
              content: SizedBox(
                width: 540,
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    const Text(
                      'Leave the target empty to let the backend restore the previous eligible model, or select a specific version.',
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    DropdownButtonFormField<
                        String>(
                      initialValue:
                          selected,
                      isExpanded:
                          true,
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Target model version (optional)',
                      ),
                      items: [
                        for (final model
                            in eligible)
                          DropdownMenuItem(
                            value:
                                model.version,
                            child: Text(
                              '${model.version} · ${model.status}',
                              overflow:
                                  TextOverflow
                                      .ellipsis,
                            ),
                          ),
                      ],
                      onChanged:
                          (value) {
                        setDialogState(
                          () {
                            selected =
                                value;
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                    );
                  },
                  child:
                      const Text(
                    'Cancel',
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                      '',
                    );
                  },
                  child:
                      const Text(
                    'Previous eligible',
                  ),
                ),
                if (selected !=
                    null)
                  FilledButton(
                    onPressed: () {
                      Navigator.pop(
                        context,
                        selected,
                      );
                    },
                    child:
                        const Text(
                      'Use selected',
                    ),
                  ),
              ],
            );
          },
        );
      },
    );

    if (result == null) {
      return;
    }

    await _rollback(
      algorithm:
          algorithm,
      targetModelVersion:
          result.isEmpty
              ? null
              : result,
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final registry =
        ref.watch(
      modelRegistryListProvider,
    );

    final activeRf =
        ref.watch(
      activeRandomForestModelProvider,
    );

    final activeXgb =
        ref.watch(
      activeXgboostModelProvider,
    );

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (widget.onBack !=
                null) ...[
              IconButton(
                tooltip: 'Back',
                onPressed:
                    widget.onBack,
                icon:
                    const Icon(
                  Icons
                      .arrow_back_rounded,
                ),
              ),
              const SizedBox(
                width: 8,
              ),
            ],
            const Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Text(
                    'MODEL GOVERNANCE',
                    style:
                        TextStyle(
                      color:
                          AppColors
                              .primaryBright,
                      fontSize: 9,
                      fontWeight:
                          FontWeight
                              .w800,
                      letterSpacing:
                          1.15,
                    ),
                  ),
                  SizedBox(
                    height: 6,
                  ),
                  Text(
                    'Model Registry',
                    style:
                        TextStyle(
                      color:
                          AppColors
                              .textPrimary,
                      fontSize: 22,
                      fontWeight:
                          FontWeight
                              .w800,
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    'Review candidate and deployed model versions, provenance, metrics, activation state, and rollback history.',
                    style:
                        TextStyle(
                      color:
                          AppColors
                              .textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Refresh',
              onPressed:
                  _refresh,
              icon:
                  const Icon(
                Icons
                    .refresh_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 20,
        ),

        // =====================================================
        // ACTIVE RUNTIME SUMMARY
        // =====================================================

        LayoutBuilder(
          builder: (
            context,
            constraints,
          ) {
            final compact =
                constraints.maxWidth <
                    760;

            final rf =
                _ActiveModelCard(
              title:
                  'Random Forest',
              algorithm:
                  'random_forest',
              state:
                  activeRf,
              rollbackBusy:
                  _rollbackBusy,
              onRollback:
                  registry.valueOrNull ==
                          null
                      ? null
                      : () {
                          _chooseRollbackTarget(
                            'random_forest',
                            registry
                                .valueOrNull!
                                .items,
                          );
                        },
            );

            final xgb =
                _ActiveModelCard(
              title:
                  'XGBoost',
              algorithm:
                  'xgboost',
              state:
                  activeXgb,
              rollbackBusy:
                  _rollbackBusy,
              onRollback:
                  registry.valueOrNull ==
                          null
                      ? null
                      : () {
                          _chooseRollbackTarget(
                            'xgboost',
                            registry
                                .valueOrNull!
                                .items,
                          );
                        },
            );

            if (compact) {
              return Column(
                children: [
                  rf,
                  const SizedBox(
                    height: 12,
                  ),
                  xgb,
                ],
              );
            }

            return Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: rf,
                ),
                const SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: xgb,
                ),
              ],
            );
          },
        ),

        const SizedBox(
          height: 18,
        ),

        // =====================================================
        // REGISTRY
        // =====================================================

        registry.when(
          loading: () =>
              const AdminSurface(
            padding:
                EdgeInsets.all(
              30,
            ),
            child: Center(
              child:
                  CircularProgressIndicator(),
            ),
          ),
          error: (
            error,
            stack,
          ) {
            return AdminSurface(
              padding:
                  const EdgeInsets.all(
                22,
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons
                        .error_outline_rounded,
                    color:
                        AppColors
                            .textMuted,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    _errorMessage(
                      error,
                    ),
                    textAlign:
                        TextAlign.center,
                    style:
                        const TextStyle(
                      color:
                          AppColors
                              .textSecondary,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  OutlinedButton.icon(
                    onPressed:
                        _refresh,
                    icon:
                        const Icon(
                      Icons
                          .refresh_rounded,
                    ),
                    label:
                        const Text(
                      'Retry',
                    ),
                  ),
                ],
              ),
            );
          },
          data: (result) {
            if (result.items.isEmpty) {
              return const AdminSurface(
                padding:
                    EdgeInsets.all(
                  30,
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons
                            .account_tree_outlined,
                        color:
                            AppColors
                                .textMuted,
                        size: 28,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        'No registered models',
                        style:
                            TextStyle(
                          color:
                              AppColors
                                  .textPrimary,
                          fontWeight:
                              FontWeight
                                  .w700,
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        'Successful candidate training will populate the model registry.',
                        textAlign:
                            TextAlign
                                .center,
                        style:
                            TextStyle(
                          color:
                              AppColors
                                  .textMuted,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                const Text(
                  'Registered versions',
                  style:
                      TextStyle(
                    color:
                        AppColors
                            .textPrimary,
                    fontSize: 14,
                    fontWeight:
                        FontWeight
                            .w700,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                for (final model
                    in result.items) ...[
                  _ModelVersionCard(
                    model:
                        model,
                    busy:
                        _busyVersion ==
                            model.version,
                    onDetails: () {
                      _showDetails(
                        model,
                      );
                    },
                    onActivate:
                        model.canActivate
                            ? () {
                                _activate(
                                  model,
                                );
                              }
                            : null,
                    onRollback:
                        model.isActive
                            ? () {
                                _chooseRollbackTarget(
                                  model
                                      .algorithm,
                                  result
                                      .items,
                                );
                              }
                            : null,
                  ),
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

class _ActiveModelCard
    extends StatelessWidget {
  const _ActiveModelCard({
    required this.title,
    required this.algorithm,
    required this.state,
    required this.rollbackBusy,
    this.onRollback,
  });

  final String title;
  final String algorithm;

  final AsyncValue<ModelVersionModel?>
      state;

  final bool rollbackBusy;

  final VoidCallback? onRollback;

  @override
  Widget build(
    BuildContext context,
  ) {
    return AdminSurface(
      padding:
          const EdgeInsets.all(
        17,
      ),
      child: state.when(
        loading: () =>
            const SizedBox(
          height: 100,
          child: Center(
            child:
                CircularProgressIndicator(
              strokeWidth: 2,
            ),
          ),
        ),
        error: (
          error,
          stack,
        ) {
          return Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,
            children: [
              Text(
                title,
                style:
                    const TextStyle(
                  color:
                      AppColors
                          .textPrimary,
                  fontSize: 13,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
              const SizedBox(
                height: 7,
              ),
              const Text(
                'Unable to read active runtime model.',
                style:
                    TextStyle(
                  color:
                      AppColors
                          .textMuted,
                  fontSize: 10,
                ),
              ),
            ],
          );
        },
        data: (model) {
          return Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,
            children: [
              Row(
                children: [
                  Container(
                    width: 37,
                    height: 37,
                    decoration:
                        BoxDecoration(
                      color:
                          AppColors
                              .primary
                              .withValues(
                        alpha: .09,
                      ),
                      borderRadius:
                          BorderRadius
                              .circular(
                        10,
                      ),
                    ),
                    child:
                        const Icon(
                      Icons
                          .memory_outlined,
                      color:
                          AppColors
                              .primaryBright,
                      size: 18,
                    ),
                  ),
                  const SizedBox(
                    width: 11,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        Text(
                          title,
                          style:
                              const TextStyle(
                            color:
                                AppColors
                                    .textPrimary,
                            fontSize: 13,
                            fontWeight:
                                FontWeight
                                    .w700,
                          ),
                        ),
                        Text(
                          algorithm,
                          style:
                              const TextStyle(
                            color:
                                AppColors
                                    .textMuted,
                            fontSize: 8.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const _StatusBadge(
                    status:
                        'ACTIVE',
                  ),
                ],
              ),
              const SizedBox(
                height: 14,
              ),
              if (model == null)
                const Text(
                  'No active model reported.',
                  style:
                      TextStyle(
                    color:
                        AppColors
                            .textMuted,
                    fontSize: 10,
                  ),
                )
              else ...[
                Text(
                  model.version,
                  style:
                      const TextStyle(
                    color:
                        AppColors
                            .textPrimary,
                    fontSize: 11,
                    fontWeight:
                        FontWeight
                            .w700,
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  '${model.datasetKey} ${model.datasetVersion} · Run ${model.trainingRunId}',
                  style:
                      const TextStyle(
                    color:
                        AppColors
                            .textMuted,
                    fontSize: 9,
                  ),
                ),
                const SizedBox(
                  height: 13,
                ),
                Align(
                  alignment:
                      Alignment
                          .centerRight,
                  child:
                      OutlinedButton.icon(
                    onPressed:
                        rollbackBusy
                            ? null
                            : onRollback,
                    icon:
                        const Icon(
                      Icons
                          .history_rounded,
                      size: 15,
                    ),
                    label:
                        const Text(
                      'Rollback',
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _ModelVersionCard
    extends StatelessWidget {
  const _ModelVersionCard({
    required this.model,
    required this.busy,
    required this.onDetails,
    this.onActivate,
    this.onRollback,
  });

  final ModelVersionModel model;
  final bool busy;

  final VoidCallback onDetails;
  final VoidCallback? onActivate;
  final VoidCallback? onRollback;

  @override
  Widget build(
    BuildContext context,
  ) {
    return AdminSurface(
      padding:
          const EdgeInsets.all(
        17,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration:
                    BoxDecoration(
                  color:
                      AppColors.primary
                          .withValues(
                    alpha: .09,
                  ),
                  borderRadius:
                      BorderRadius
                          .circular(
                    11,
                  ),
                ),
                child:
                    const Icon(
                  Icons
                      .account_tree_outlined,
                  color:
                      AppColors
                          .primaryBright,
                  size: 19,
                ),
              ),
              const SizedBox(
                width: 13,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      model.version,
                      overflow:
                          TextOverflow
                              .ellipsis,
                      style:
                          const TextStyle(
                        color:
                            AppColors
                                .textPrimary,
                        fontSize: 12,
                        fontWeight:
                            FontWeight
                                .w700,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      '${model.algorithm} · ${model.datasetKey} ${model.datasetVersion}',
                      style:
                          const TextStyle(
                        color:
                            AppColors
                                .textMuted,
                        fontSize: 9.5,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusBadge(
                status:
                    model.status,
              ),
            ],
          ),
          const SizedBox(
            height: 14,
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip(
                label:
                    'Spec v${model.modelSpecificationVersion}',
              ),
              _InfoChip(
                label:
                    'Config v${model.trainingConfigVersion}',
              ),
              _InfoChip(
                label:
                    model.preprocessingVersion,
              ),
              if (model.decisionThreshold !=
                  null)
                _InfoChip(
                  label:
                      'Threshold ${model.decisionThreshold!.toStringAsFixed(3)}',
                ),
              _InfoChip(
                label:
                    model.affectsRiskScore
                        ? 'Affects risk score'
                        : 'No direct risk-score effect',
              ),
            ],
          ),
          if (model.finalTestMetrics
              .isNotEmpty) ...[
            const SizedBox(
              height: 15,
            ),
            const Text(
              'Final test metrics',
              style:
                  TextStyle(
                color:
                    AppColors
                        .textPrimary,
                fontSize: 10,
                fontWeight:
                    FontWeight.w700,
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final entry
                    in model
                        .finalTestMetrics
                        .entries)
                  _MetricChip(
                    name:
                        entry.key,
                    value:
                        entry.value,
                  ),
              ],
            ),
          ],
          const SizedBox(
            height: 15,
          ),
          Row(
            children: [
              TextButton.icon(
                onPressed:
                    onDetails,
                icon:
                    const Icon(
                  Icons
                      .visibility_outlined,
                  size: 16,
                ),
                label:
                    const Text(
                  'Details',
                ),
              ),
              const Spacer(),
              if (busy)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child:
                      CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              else ...[
                if (onRollback !=
                    null)
                  OutlinedButton.icon(
                    onPressed:
                        onRollback,
                    icon:
                        const Icon(
                      Icons
                          .history_rounded,
                      size: 15,
                    ),
                    label:
                        const Text(
                      'Rollback',
                    ),
                  ),
                if (onRollback !=
                        null &&
                    onActivate !=
                        null)
                  const SizedBox(
                    width: 8,
                  ),
                if (onActivate !=
                    null)
                  FilledButton.icon(
                    onPressed:
                        onActivate,
                    icon:
                        const Icon(
                      Icons
                          .rocket_launch_outlined,
                      size: 15,
                    ),
                    label:
                        const Text(
                      'Activate',
                    ),
                  ),
              ],
            ],
          ),
        ],
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

  IconData get _icon {
    switch (status) {
      case 'ACTIVE':
        return Icons
            .check_circle_outline_rounded;

      case 'CANDIDATE':
        return Icons
            .science_outlined;

      case 'INACTIVE':
        return Icons
            .pause_circle_outline_rounded;

      case 'ARCHIVED':
        return Icons
            .inventory_2_outlined;

      default:
        return Icons
            .circle_outlined;
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      decoration:
          BoxDecoration(
        color:
            AppColors.primary
                .withValues(
          alpha: .08,
        ),
        borderRadius:
            BorderRadius.circular(
          99,
        ),
      ),
      child: Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Icon(
            _icon,
            size: 12,
            color:
                AppColors
                    .primaryBright,
          ),
          const SizedBox(
            width: 5,
          ),
          Text(
            status,
            style:
                const TextStyle(
              color:
                  AppColors
                      .primaryBright,
              fontSize: 8,
              fontWeight:
                  FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip
    extends StatelessWidget {
  const _InfoChip({
    required this.label,
  });

  final String label;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      decoration:
          BoxDecoration(
        color:
            AppColors.surface,
        borderRadius:
            BorderRadius.circular(
          8,
        ),
        border:
            Border.all(
          color:
              AppColors.border,
        ),
      ),
      child: Text(
        label,
        style:
            const TextStyle(
          color:
              AppColors
                  .textSecondary,
          fontSize: 8.5,
          fontWeight:
              FontWeight.w600,
        ),
      ),
    );
  }
}

class _MetricChip
    extends StatelessWidget {
  const _MetricChip({
    required this.name,
    required this.value,
  });

  final String name;
  final dynamic value;

  String get _displayValue {
    if (value is num) {
      return (value as num)
          .toDouble()
          .toStringAsFixed(
            4,
          );
    }

    return value.toString();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration:
          BoxDecoration(
        color:
            AppColors.primary
                .withValues(
          alpha: .055,
        ),
        borderRadius:
            BorderRadius.circular(
          8,
        ),
        border:
            Border.all(
          color:
              AppColors
                  .primaryBright
                  .withValues(
            alpha: .10,
          ),
        ),
      ),
      child: Text(
        '$name: $_displayValue',
        style:
            const TextStyle(
          color:
              AppColors
                  .textSecondary,
          fontSize: 8.5,
          fontWeight:
              FontWeight.w600,
        ),
      ),
    );
  }
}