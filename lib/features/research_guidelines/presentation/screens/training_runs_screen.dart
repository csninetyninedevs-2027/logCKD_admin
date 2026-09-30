import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/model_specification_model.dart';
import '../../../../shared/models/training_config_model.dart';
import '../../../../shared/models/training_run_model.dart';
import '../../../../shared/widgets/admin_surface.dart';

import '../../state/model_specification_admin_provider.dart';
import '../../state/training_config_admin_provider.dart';
import '../../state/training_run_admin_provider.dart';

class TrainingRunsScreen
    extends ConsumerStatefulWidget {
  const TrainingRunsScreen({
    super.key,
    this.onBack,
  });

  final VoidCallback? onBack;

  @override
  ConsumerState<TrainingRunsScreen>
      createState() =>
          _TrainingRunsScreenState();
}

class _TrainingRunsScreenState
    extends ConsumerState<
        TrainingRunsScreen> {
  String? _busyRunId;

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
          'Unable to complete request.';
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

  Future<void> _refresh() async {
    ref.invalidate(
      trainingRunListProvider,
    );

    ref.invalidate(
      activeTrainingDatasetsProvider,
    );

    ref.invalidate(
      modelSpecificationListProvider,
    );

    ref.invalidate(
      trainingConfigListProvider,
    );
  }

  Future<void> _createRun() async {
    final datasets =
        ref
            .read(
              activeTrainingDatasetsProvider,
            )
            .valueOrNull;

    final specifications =
        ref
            .read(
              modelSpecificationListProvider,
            )
            .valueOrNull
            ?.items;

    final configs =
        ref
            .read(
              trainingConfigListProvider,
            )
            .valueOrNull
            ?.items;

    if (datasets == null ||
        specifications == null ||
        configs == null) {
      _message(
        'Required training resources are still loading.',
      );

      return;
    }

    final publishedSpecifications =
        specifications
            .where(
              (item) =>
                  item.isPublished,
            )
            .toList();

    final publishedConfigs =
        configs
            .where(
              (item) =>
                  item.isPublished,
            )
            .toList();

    if (datasets.isEmpty) {
      _message(
        'No ACTIVE TRAINING dataset is available.',
      );

      return;
    }

    if (publishedSpecifications.isEmpty) {
      _message(
        'No PUBLISHED Model Specification is available.',
      );

      return;
    }

    if (publishedConfigs.isEmpty) {
      _message(
        'No PUBLISHED Training Configuration is available.',
      );

      return;
    }

    final payload =
        await showDialog<
            _CreateRunPayload>(
      context: context,
      builder: (context) {
        return _CreateTrainingRunDialog(
          datasets: datasets,
          specifications:
              publishedSpecifications,
          configs:
              publishedConfigs,
        );
      },
    );

    if (payload == null) {
      return;
    }

    try {
      final run =
          await ref
              .read(
                trainingRunAdminActionsProvider,
              )
              .createRun(
                algorithm:
                    payload.algorithm,
                datasetKey:
                    payload.datasetKey,
                datasetVersion:
                    payload.datasetVersion,
                modelSpecificationVersion:
                    payload
                        .modelSpecificationVersion,
                trainingConfigVersion:
                    payload
                        .trainingConfigVersion,
                notes: payload.notes,
              );

      _message(
        'Training run ${run.runId} created as PENDING.',
      );
    } catch (error) {
      _message(
        _errorMessage(error),
      );
    }
  }

  Future<void> _startRun(
    TrainingRunModel run,
  ) async {
    if (!run.canStart) {
      return;
    }

    final confirmed =
        await showDialog<bool>(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title:
                      const Text(
                    'Start training?',
                  ),
                  content: Text(
                    'Start candidate training for ${run.runId}?\n\n'
                    'The Node backend will submit this run to the configured '
                    'training orchestration service.',
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
                            .play_arrow_rounded,
                      ),
                      label:
                          const Text(
                        'Start training',
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
      _busyRunId =
          run.runId;
    });

    try {
      final updated =
          await ref
              .read(
                trainingRunAdminActionsProvider,
              )
              .startRun(
                run.runId,
              );

      _message(
        'Training request accepted. ${updated.runId} is ${updated.status}.',
      );
    } on DioException catch (error) {
      final data =
          error.response?.data;

      if (error.response?.statusCode ==
              503 &&
          data is Map &&
          data['code'] ==
              'TRAINING_ORCHESTRATION_UNAVAILABLE') {
        _message(
          'The run is ready, but candidate-training orchestration is not configured yet. '
          'The run remains PENDING.',
        );
      } else {
        _message(
          _errorMessage(error),
        );
      }
    } catch (error) {
      _message(
        _errorMessage(error),
      );
    } finally {
      if (mounted) {
        setState(() {
          _busyRunId = null;
        });
      }
    }
  }

  Future<void> _showDetails(
    TrainingRunModel run,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title:
              Text(run.runId),
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
                  run.raw,
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

  @override
  Widget build(
    BuildContext context,
  ) {
    final runs =
        ref.watch(
      trainingRunListProvider,
    );

    // Load dependencies so the create
    // dialog has current published/active
    // resources.
    ref.watch(
      activeTrainingDatasetsProvider,
    );

    ref.watch(
      modelSpecificationListProvider,
    );

    ref.watch(
      trainingConfigListProvider,
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
                    'CANDIDATE TRAINING',
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
                    'Training Runs',
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
                    'Create reproducible candidate-training runs from active datasets and published model configuration.',
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
              onPressed: _refresh,
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
        AdminSurface(
          padding:
              const EdgeInsets.all(
            16,
          ),
          child: Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      'Candidate training',
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
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      'Creation records provenance first. Training starts only after an explicit admin action.',
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
              FilledButton.icon(
                onPressed:
                    _createRun,
                icon:
                    const Icon(
                  Icons.add_rounded,
                  size: 17,
                ),
                label:
                    const Text(
                  'Create run',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 14,
        ),
        runs.when(
          loading: () =>
              const _LoadingCard(),
          error: (
            error,
            stack,
          ) {
            return _ErrorCard(
              message:
                  _errorMessage(
                error,
              ),
              onRetry: () {
                ref.invalidate(
                  trainingRunListProvider,
                );
              },
            );
          },
          data: (result) {
            if (result.items.isEmpty) {
              return const _EmptyCard();
            }

            return Column(
              children: [
                for (final run
                    in result.items) ...[
                  _TrainingRunCard(
                    run: run,
                    busy:
                        _busyRunId ==
                            run.runId,
                    onDetails: () {
                      _showDetails(
                        run,
                      );
                    },
                    onStart:
                        run.canStart
                            ? () {
                                _startRun(
                                  run,
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

class _CreateRunPayload {
  const _CreateRunPayload({
    required this.algorithm,
    required this.datasetKey,
    required this.datasetVersion,
    required this.modelSpecificationVersion,
    required this.trainingConfigVersion,
    this.notes,
  });

  final String algorithm;

  final String datasetKey;
  final String datasetVersion;

  final int modelSpecificationVersion;
  final int trainingConfigVersion;

  final String? notes;
}

class _CreateTrainingRunDialog
    extends StatefulWidget {
  const _CreateTrainingRunDialog({
    required this.datasets,
    required this.specifications,
    required this.configs,
  });

  final List<TrainingDatasetChoice>
      datasets;

  final List<ModelSpecificationModel>
      specifications;

  final List<TrainingConfigModel>
      configs;

  @override
  State<_CreateTrainingRunDialog>
      createState() =>
          _CreateTrainingRunDialogState();
}

class _CreateTrainingRunDialogState
    extends State<
        _CreateTrainingRunDialog> {
  final _notes =
      TextEditingController();

  ModelSpecificationModel?
      _specification;

  TrainingConfigModel? _config;

  TrainingDatasetChoice?
      _dataset;

  @override
  void initState() {
    super.initState();

    if (widget.specifications
        .isNotEmpty) {
      _specification =
          widget.specifications.first;

      _synchronizeSelection();
    }
  }

  List<TrainingConfigModel>
      get _compatibleConfigs {
    final specification =
        _specification;

    if (specification == null) {
      return const [];
    }

    return widget.configs
        .where(
          (config) =>
              config.isPublished &&
              config.algorithm ==
                  specification
                      .algorithm &&
              config
                      .modelSpecificationVersion ==
                  specification.version &&
              config.preprocessingVersion ==
                  specification
                      .preprocessingVersion,
        )
        .toList();
  }

  List<TrainingDatasetChoice>
      get _compatibleDatasets {
    final specification =
        _specification;

    if (specification == null) {
      return const [];
    }

    return widget.datasets
        .where(
          (dataset) =>
              dataset.isEligible &&
              dataset.datasetKey ==
                  specification
                      .trainingDatasetKey &&
              dataset.preprocessingVersion ==
                  specification
                      .preprocessingVersion,
        )
        .toList();
  }

  void _synchronizeSelection() {
    final configs =
        _compatibleConfigs;

    final datasets =
        _compatibleDatasets;

    _config =
        configs.isNotEmpty
            ? configs.first
            : null;

    _dataset =
        datasets.isNotEmpty
            ? datasets.first
            : null;
  }

  void _submit() {
    final specification =
        _specification;

    final config =
        _config;

    final dataset =
        _dataset;

    if (specification == null ||
        config == null ||
        dataset == null) {
      return;
    }

    Navigator.pop(
      context,
      _CreateRunPayload(
        algorithm:
            specification.algorithm,
        datasetKey:
            dataset.datasetKey,
        datasetVersion:
            dataset.version,
        modelSpecificationVersion:
            specification.version,
        trainingConfigVersion:
            config.version,
        notes:
            _notes.text
                    .trim()
                    .isEmpty
                ? null
                : _notes.text
                    .trim(),
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final configs =
        _compatibleConfigs;

    final datasets =
        _compatibleDatasets;

    final ready =
        _specification != null &&
        _config != null &&
        _dataset != null;

    return AlertDialog(
      title:
          const Text(
        'Create Training Run',
      ),
      content: SizedBox(
        width: 680,
        child:
            SingleChildScrollView(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,
            children: [
              const Text(
                'Select a published Model Specification. Compatible published Training Configurations and ACTIVE training datasets are then restricted automatically.',
                style: TextStyle(
                  color:
                      AppColors
                          .textSecondary,
                  fontSize: 11,
                  height: 1.5,
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              DropdownButtonFormField<
                  ModelSpecificationModel>(
                initialValue:
                    _specification,
                isExpanded: true,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Published Model Specification',
                ),
                items: [
                  for (final item
                      in widget
                          .specifications)
                    DropdownMenuItem(
                      value: item,
                      child: Text(
                        '${item.specificationKey} v${item.version} · ${item.algorithm}',
                        overflow:
                            TextOverflow
                                .ellipsis,
                      ),
                    ),
                ],
                onChanged: (value) {
                  setState(() {
                    _specification =
                        value;

                    _synchronizeSelection();
                  });
                },
              ),
              const SizedBox(
                height: 12,
              ),
              DropdownButtonFormField<
                  TrainingConfigModel>(
                key: ValueKey(
                  'config-${_specification?.specificationKey}-${_specification?.version}',
                ),
                initialValue:
                    _config,
                isExpanded: true,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Published Training Configuration',
                ),
                items: [
                  for (final item
                      in configs)
                    DropdownMenuItem(
                      value: item,
                      child: Text(
                        '${item.configKey} v${item.version}',
                        overflow:
                            TextOverflow
                                .ellipsis,
                      ),
                    ),
                ],
                onChanged: (value) {
                  setState(() {
                    _config =
                        value;
                  });
                },
              ),
              if (configs.isEmpty) ...[
                const SizedBox(
                  height: 7,
                ),
                const Text(
                  'No compatible published Training Configuration exists for this specification.',
                  style: TextStyle(
                    color:
                        AppColors
                            .textMuted,
                    fontSize: 10,
                  ),
                ),
              ],
              const SizedBox(
                height: 12,
              ),
              DropdownButtonFormField<
                  TrainingDatasetChoice>(
                key: ValueKey(
                  'dataset-${_specification?.specificationKey}-${_specification?.version}',
                ),
                initialValue:
                    _dataset,
                isExpanded: true,
                decoration:
                    const InputDecoration(
                  labelText:
                      'ACTIVE Training Dataset',
                ),
                items: [
                  for (final item
                      in datasets)
                    DropdownMenuItem(
                      value: item,
                      child: Text(
                        '${item.datasetKey} · ${item.version} · ${item.recordCount} records',
                        overflow:
                            TextOverflow
                                .ellipsis,
                      ),
                    ),
                ],
                onChanged: (value) {
                  setState(() {
                    _dataset =
                        value;
                  });
                },
              ),
              if (datasets.isEmpty) ...[
                const SizedBox(
                  height: 7,
                ),
                const Text(
                  'No compatible ACTIVE TRAINING dataset exists for this specification.',
                  style: TextStyle(
                    color:
                        AppColors
                            .textMuted,
                    fontSize: 10,
                  ),
                ),
              ],
              const SizedBox(
                height: 12,
              ),
              TextField(
                controller:
                    _notes,
                maxLines: 3,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Notes (optional)',
                ),
              ),
              const SizedBox(
                height: 14,
              ),
              Container(
                width:
                    double.infinity,
                padding:
                    const EdgeInsets.all(
                  12,
                ),
                decoration:
                    BoxDecoration(
                  color:
                      AppColors.primary
                          .withValues(
                    alpha: .06,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    10,
                  ),
                  border:
                      Border.all(
                    color:
                        AppColors
                            .primaryBright
                            .withValues(
                      alpha: .12,
                    ),
                  ),
                ),
                child:
                    const Text(
                  'Creating the run does not train the model. It creates a PENDING provenance record. Use Start Training afterward.',
                  style: TextStyle(
                    color:
                        AppColors
                            .textSecondary,
                    fontSize: 10,
                    height: 1.45,
                  ),
                ),
              ),
            ],
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
            'Cancel',
          ),
        ),
        FilledButton(
          onPressed:
              ready
                  ? _submit
                  : null,
          child:
              const Text(
            'Create pending run',
          ),
        ),
      ],
    );
  }
}

class _TrainingRunCard
    extends StatelessWidget {
  const _TrainingRunCard({
    required this.run,
    required this.busy,
    required this.onDetails,
    this.onStart,
  });

  final TrainingRunModel run;

  final bool busy;

  final VoidCallback onDetails;
  final VoidCallback? onStart;

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
                      .model_training_outlined,
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
                      run.runId,
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
                      '${run.algorithm} · ${run.datasetKey} ${run.datasetVersion}',
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
              _RunStatusBadge(
                status:
                    run.status,
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
                    'Spec v${run.modelSpecificationVersion}',
              ),
              _InfoChip(
                label:
                    'Config v${run.trainingConfigVersion}',
              ),
              _InfoChip(
                label:
                    run.preprocessingVersion,
              ),
              _InfoChip(
                label:
                    'Seed ${run.randomState}',
              ),
              if (run.decisionThreshold !=
                  null)
                _InfoChip(
                  label:
                      'Threshold ${run.decisionThreshold!.toStringAsFixed(3)}',
                ),
            ],
          ),
          if (run.isSucceeded &&
              run.finalTestMetrics
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
                    in run
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
          if (run.errorMessage !=
                  null &&
              run.errorMessage!
                  .trim()
                  .isNotEmpty) ...[
            const SizedBox(
              height: 14,
            ),
            Container(
              width:
                  double.infinity,
              padding:
                  const EdgeInsets.all(
                11,
              ),
              decoration:
                  BoxDecoration(
                color:
                    AppColors.surface,
                borderRadius:
                    BorderRadius.circular(
                  9,
                ),
                border:
                    Border.all(
                  color:
                      AppColors.border,
                ),
              ),
              child: Text(
                run.errorMessage!,
                style:
                    const TextStyle(
                  color:
                      AppColors
                          .textSecondary,
                  fontSize: 9.5,
                ),
              ),
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
              else if (onStart !=
                  null)
                FilledButton.icon(
                  onPressed:
                      onStart,
                  icon:
                      const Icon(
                    Icons
                        .play_arrow_rounded,
                    size: 17,
                  ),
                  label:
                      const Text(
                    'Start training',
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RunStatusBadge
    extends StatelessWidget {
  const _RunStatusBadge({
    required this.status,
  });

  final String status;

  IconData get _icon {
    switch (status) {
      case 'RUNNING':
        return Icons
            .sync_rounded;

      case 'SUCCEEDED':
        return Icons
            .check_circle_outline_rounded;

      case 'FAILED':
        return Icons
            .error_outline_rounded;

      default:
        return Icons
            .schedule_rounded;
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

  String get _value {
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
        '$name: $_value',
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

class _LoadingCard
    extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(
    BuildContext context,
  ) {
    return const AdminSurface(
      padding:
          EdgeInsets.all(30),
      child: Center(
        child:
            CircularProgressIndicator(),
      ),
    );
  }
}

class _ErrorCard
    extends StatelessWidget {
  const _ErrorCard({
    required this.message,
    required this.onRetry,
  });

  final String message;

  final VoidCallback onRetry;

  @override
  Widget build(
    BuildContext context,
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
                AppColors.textMuted,
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            message,
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
                onRetry,
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
  }
}

class _EmptyCard
    extends StatelessWidget {
  const _EmptyCard();

  @override
  Widget build(
    BuildContext context,
  ) {
    return const AdminSurface(
      padding:
          EdgeInsets.all(30),
      child: Column(
        children: [
          Icon(
            Icons
                .model_training_outlined,
            color:
                AppColors.textMuted,
            size: 28,
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            'No training runs',
            style:
                TextStyle(
              color:
                  AppColors
                      .textPrimary,
              fontWeight:
                  FontWeight.w700,
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            'Create the first controlled candidate-training run.',
            textAlign:
                TextAlign.center,
            style:
                TextStyle(
              color:
                  AppColors.textMuted,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}