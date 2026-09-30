import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/training_dataset_model.dart';
import '../../services/training_dataset_admin_service.dart';
import '../../state/training_dataset_admin_provider.dart';

class TrainingDataScreen
    extends ConsumerStatefulWidget {
  const TrainingDataScreen({
    super.key,
    this.onBack,
  });

  final VoidCallback? onBack;

  @override
  ConsumerState<TrainingDataScreen>
      createState() =>
          _TrainingDataScreenState();
}

class _TrainingDataScreenState
    extends ConsumerState<TrainingDataScreen> {
  bool _busy = false;

  String _errorMessage(
    Object error,
  ) {
    if (error is DioException) {
      final data = error.response?.data;

      if (data is Map) {
        final message =
            data['error'] ??
            data['message'];

        if (message != null) {
          return message.toString();
        }
      }

      return error.message ??
          'The request could not be completed.';
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
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: error
              ? AppColors.coral
              : AppColors.surface,
        ),
      );
  }

  Future<void> _refresh() async {
    ref.invalidate(
      trainingDatasetListProvider,
    );

    await ref.read(
      trainingDatasetListProvider.future,
    );
  }

  Future<void> _upload() async {
    if (_busy) {
      return;
    }

    final picked =
        await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const [
        'csv',
        'xlsx',
      ],
      withData: true,
      allowMultiple: false,
    );

    if (picked == null ||
        picked.files.isEmpty) {
      return;
    }

    final file = picked.files.single;
    final bytes = file.bytes;

    if (bytes == null) {
      _message(
        'The selected file could not be read.',
        error: true,
      );

      return;
    }

    setState(() {
      _busy = true;
    });

    try {
      final service = ref.read(
        trainingDatasetAdminServiceProvider,
      );

      final result =
          await service.validateUpload(
        bytes: bytes,
        fileName: file.name,
      );

      if (!mounted) {
        return;
      }

      if (!result.canConfirm) {
        await showDialog<void>(
          context: context,
          builder: (_) =>
              _ValidationDialog(
            result: result,
          ),
        );

        return;
      }

      final imported =
          await showDialog<
              TrainingDatasetModel>(
        context: context,
        barrierDismissible: false,
        builder: (_) =>
            _ConfirmImportDialog(
          service: service,
          result: result,
        ),
      );

      if (imported != null) {
        _message(
          '${imported.name} ${imported.version} imported.',
        );

        await _refresh();
      }
    } catch (error) {
      _message(
        _errorMessage(error),
        error: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
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
              backgroundColor:
                  AppColors.surface,
              title: Text(title),
              content: Text(
                message,
                style: const TextStyle(
                  color:
                      AppColors.textSecondary,
                  height: 1.45,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                      false,
                    );
                  },
                  child:
                      const Text('Cancel'),
                ),
                FilledButton(
                  style:
                      FilledButton.styleFrom(
                    backgroundColor:
                        destructive
                            ? AppColors.coral
                            : AppColors.primary,
                  ),
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                      true,
                    );
                  },
                  child: Text(action),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Future<void> _activate(
    TrainingDatasetModel dataset,
  ) async {
    final confirmed = await _confirm(
      title: 'Activate dataset?',
      message:
          '${dataset.name} ${dataset.version} will become the active version for ${dataset.datasetKey}.',
      action: 'Activate',
    );

    if (!confirmed) {
      return;
    }

    await _runAction(
      () => ref
          .read(
            trainingDatasetAdminActionsProvider,
          )
          .activate(dataset.id),
      '${dataset.name} activated.',
    );
  }

  Future<void> _deactivate(
    TrainingDatasetModel dataset,
  ) async {
    final confirmed = await _confirm(
      title: 'Deactivate dataset?',
      message:
          '${dataset.name} ${dataset.version} will no longer be active.',
      action: 'Deactivate',
    );

    if (!confirmed) {
      return;
    }

    await _runAction(
      () => ref
          .read(
            trainingDatasetAdminActionsProvider,
          )
          .deactivate(dataset.id),
      '${dataset.name} deactivated.',
    );
  }

  Future<void> _archive(
    TrainingDatasetModel dataset,
  ) async {
    final confirmed = await _confirm(
      title: 'Archive dataset?',
      message:
          '${dataset.name} ${dataset.version} will be moved to the archived lifecycle state.',
      action: 'Archive',
      destructive: true,
    );

    if (!confirmed) {
      return;
    }

    await _runAction(
      () => ref
          .read(
            trainingDatasetAdminActionsProvider,
          )
          .archive(dataset.id),
      '${dataset.name} archived.',
    );
  }

  Future<void> _runAction(
    Future<dynamic> Function() action,
    String success,
  ) async {
    if (_busy) {
      return;
    }

    setState(() {
      _busy = true;
    });

    try {
      await action();

      _message(success);

      await _refresh();
    } catch (error) {
      _message(
        _errorMessage(error),
        error: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  void _showDetails(
    TrainingDatasetModel dataset,
  ) {
    showDialog<void>(
      context: context,
      builder: (_) =>
          _DatasetDetailsDialog(
        dataset: dataset,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final datasets = ref.watch(
      trainingDatasetListProvider,
    );

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (widget.onBack != null) ...[
              IconButton(
                tooltip: 'Back',
                onPressed: widget.onBack,
                icon: const Icon(
                  Icons.arrow_back_rounded,
                ),
              ),
              const SizedBox(width: 8),
            ],
            const Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'TRAINING DATA',
                    style: TextStyle(
                      color: AppColors
                          .primaryBright,
                      fontSize: 9,
                      fontWeight:
                          FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Dataset Registry',
                    style: TextStyle(
                      color: AppColors
                          .textPrimary,
                      fontSize: 22,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Upload, validate, register, and control approved model-training datasets.',
                    style: TextStyle(
                      color: AppColors
                          .textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            OutlinedButton.icon(
              onPressed:
                  _busy ? null : _refresh,
              icon: const Icon(
                Icons.refresh_rounded,
                size: 17,
              ),
              label: const Text('Refresh'),
            ),
            const SizedBox(width: 8),
            FilledButton.icon(
              onPressed:
                  _busy ? null : _upload,
              icon: _busy
                  ? const SizedBox(
                      width: 15,
                      height: 15,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(
                      Icons
                          .upload_file_outlined,
                      size: 17,
                    ),
              label: const Text(
                'Upload dataset',
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const _WorkflowCard(),
        const SizedBox(height: 18),
        datasets.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child:
                  CircularProgressIndicator(),
            ),
          ),
          error: (error, _) =>
              _ErrorCard(
            message:
                _errorMessage(error),
            onRetry: () {
              ref.invalidate(
                trainingDatasetListProvider,
              );
            },
          ),
          data: (result) {
            if (result.items.isEmpty) {
              return _EmptyCard(
                onUpload: _busy
                    ? null
                    : _upload,
              );
            }

            return Column(
              children: [
                for (
                  var index = 0;
                  index <
                      result.items.length;
                  index++
                ) ...[
                  _DatasetCard(
                    dataset:
                        result.items[index],
                    disabled: _busy,
                    onView: () =>
                        _showDetails(
                      result.items[index],
                    ),
                    onActivate:
                        result.items[index]
                                .isInactive
                            ? () => _activate(
                                  result.items[
                                      index],
                                )
                            : null,
                    onDeactivate:
                        result.items[index]
                                .isActive
                            ? () => _deactivate(
                                  result.items[
                                      index],
                                )
                            : null,
                    onArchive:
                        !result.items[index]
                                .isArchived
                            ? () => _archive(
                                  result.items[
                                      index],
                                )
                            : null,
                  ),
                  if (index !=
                      result.items.length - 1)
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

class _WorkflowCard extends StatelessWidget {
  const _WorkflowCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary
            .withValues(alpha: .06),
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.primary
              .withValues(alpha: .15),
        ),
      ),
      child: const Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment:
            WrapCrossAlignment.center,
        children: [
          _WorkflowStep(
            number: '1',
            text: 'Upload CSV/XLSX',
          ),
          Icon(
            Icons.arrow_forward_rounded,
            size: 14,
            color: AppColors.textMuted,
          ),
          _WorkflowStep(
            number: '2',
            text: 'Validate',
          ),
          Icon(
            Icons.arrow_forward_rounded,
            size: 14,
            color: AppColors.textMuted,
          ),
          _WorkflowStep(
            number: '3',
            text: 'Review',
          ),
          Icon(
            Icons.arrow_forward_rounded,
            size: 14,
            color: AppColors.textMuted,
          ),
          _WorkflowStep(
            number: '4',
            text: 'Confirm import',
          ),
          Icon(
            Icons.arrow_forward_rounded,
            size: 14,
            color: AppColors.textMuted,
          ),
          _WorkflowStep(
            number: '5',
            text: 'Activate',
          ),
        ],
      ),
    );
  }
}

class _WorkflowStep extends StatelessWidget {
  const _WorkflowStep({
    required this.number,
    required this.text,
  });

  final String number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface
            .withValues(alpha: .7),
        borderRadius:
            BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 18,
            height: 18,
            alignment: Alignment.center,
            decoration:
                const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary,
            ),
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 8,
                fontWeight:
                    FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            text,
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

class _DatasetCard extends StatelessWidget {
  const _DatasetCard({
    required this.dataset,
    required this.disabled,
    required this.onView,
    required this.onActivate,
    required this.onDeactivate,
    required this.onArchive,
  });

  final TrainingDatasetModel dataset;
  final bool disabled;

  final VoidCallback onView;
  final VoidCallback? onActivate;
  final VoidCallback? onDeactivate;
  final VoidCallback? onArchive;

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
          color: dataset.isActive
              ? AppColors.primary
                  .withValues(alpha: .28)
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

          final info = Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primary
                      .withValues(alpha: .09),
                  borderRadius:
                      BorderRadius.circular(
                    11,
                  ),
                ),
                child: const Icon(
                  Icons.dataset_outlined,
                  color:
                      AppColors.primaryBright,
                  size: 20,
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
                            dataset.name,
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
                              dataset.status,
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Wrap(
                      spacing: 12,
                      runSpacing: 5,
                      children: [
                        _MetaText(
                          text:
                              '${dataset.datasetKey} • ${dataset.version}',
                        ),
                        _MetaText(
                          text:
                              dataset.datasetRole,
                        ),
                        _MetaText(
                          text:
                              dataset.fileFormat,
                        ),
                        if (dataset.recordCount !=
                            null)
                          _MetaText(
                            text:
                                '${dataset.recordCount} records',
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
              TextButton(
                onPressed:
                    disabled ? null : onView,
                child: const Text('View'),
              ),
              if (onActivate != null)
                FilledButton(
                  onPressed: disabled
                      ? null
                      : onActivate,
                  child:
                      const Text('Activate'),
                ),
              if (onDeactivate != null)
                OutlinedButton(
                  onPressed: disabled
                      ? null
                      : onDeactivate,
                  child: const Text(
                    'Deactivate',
                  ),
                ),
              if (onArchive != null)
                TextButton(
                  onPressed: disabled
                      ? null
                      : onArchive,
                  child: const Text(
                    'Archive',
                    style: TextStyle(
                      color: AppColors.coral,
                    ),
                  ),
                ),
            ],
          );

          if (compact) {
            return Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                info,
                const SizedBox(height: 14),
                actions,
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: info),
              const SizedBox(width: 15),
              actions,
            ],
          );
        },
      ),
    );
  }
}

class _ConfirmImportDialog
    extends StatefulWidget {
  const _ConfirmImportDialog({
    required this.service,
    required this.result,
  });

  final TrainingDatasetAdminService service;
  final TrainingDatasetUploadResult result;

  @override
  State<_ConfirmImportDialog>
      createState() =>
          _ConfirmImportDialogState();
}

class _ConfirmImportDialogState
    extends State<_ConfirmImportDialog> {
  final _formKey =
      GlobalKey<FormState>();

  final _datasetKey =
      TextEditingController();
  final _name =
      TextEditingController();
  final _version =
      TextEditingController();
  final _preprocessing =
      TextEditingController(
    text: 'v1',
  );
  final _sourceName =
      TextEditingController();
  final _sourceOrganization =
      TextEditingController();
  final _sourcePeriod =
      TextEditingController();
  final _intendedUse =
      TextEditingController(
    text: 'Model training',
  );
  final _notes =
      TextEditingController();

  String _role = 'TRAINING';
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _datasetKey.dispose();
    _name.dispose();
    _version.dispose();
    _preprocessing.dispose();
    _sourceName.dispose();
    _sourceOrganization.dispose();
    _sourcePeriod.dispose();
    _intendedUse.dispose();
    _notes.dispose();

    super.dispose();
  }

  String? _required(
    String? value,
  ) {
    if (value == null ||
        value.trim().isEmpty) {
      return 'Required';
    }

    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final source =
          <String, dynamic>{
        'name': _sourceName.text.trim(),
      };

      if (_sourceOrganization.text
          .trim()
          .isNotEmpty) {
        source['organization'] =
            _sourceOrganization.text.trim();
      }

      if (_sourcePeriod.text
          .trim()
          .isNotEmpty) {
        source['period'] =
            _sourcePeriod.text.trim();
      }

      final intendedUses = _intendedUse
          .text
          .split(',')
          .map((item) => item.trim())
          .where(
            (item) => item.isNotEmpty,
          )
          .toList();

      if (intendedUses.isEmpty) {
        setState(() {
          _saving = false;
          _error =
              'Enter at least one intended use.';
        });

        return;
      }

      final dataset =
          await widget.service.confirmImport(
        staging: widget.result.staging!,
        datasetKey:
            _datasetKey.text,
        name: _name.text,
        version: _version.text,
        datasetRole: _role,
        source: source,
        intendedUses: intendedUses,
        preprocessingVersion:
            _preprocessing.text,
        notes: _notes.text,
      );

      if (!mounted) {
        return;
      }

      Navigator.pop(
        context,
        dataset,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      var message = error.toString();

      if (error is DioException) {
        final data =
            error.response?.data;

        if (data is Map) {
          message =
              (data['error'] ??
                      data['message'] ??
                      message)
                  .toString();
        }
      }

      setState(() {
        _saving = false;
        _error = message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final validation =
        widget.result.validation;

    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: const Text(
        'Confirm dataset import',
      ),
      content: SizedBox(
        width: 680,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                _ValidationSummary(
                  validation: validation,
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: _datasetKey,
                  validator: _required,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Dataset key',
                    hintText:
                        'ckd_screening_dataset',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _name,
                  validator: _required,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Dataset name',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _version,
                  validator: _required,
                  decoration:
                      const InputDecoration(
                    labelText: 'Version',
                    hintText: 'v1.0',
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<
                    String>(
                  initialValue: _role,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Dataset role',
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'TRAINING',
                      child:
                          Text('TRAINING'),
                    ),
                    DropdownMenuItem(
                      value:
                          'EXTERNAL_VALIDATION',
                      child: Text(
                        'EXTERNAL_VALIDATION',
                      ),
                    ),
                  ],
                  onChanged: _saving
                      ? null
                      : (value) {
                          if (value !=
                              null) {
                            setState(() {
                              _role =
                                  value;
                            });
                          }
                        },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller:
                      _preprocessing,
                  validator: _required,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Preprocessing version',
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Source provenance',
                  style: TextStyle(
                    color:
                        AppColors.textPrimary,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _sourceName,
                  validator: _required,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Source name',
                    hintText:
                        'Research dataset / study',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller:
                      _sourceOrganization,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Source organization',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller:
                      _sourcePeriod,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Source period',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller:
                      _intendedUse,
                  validator: _required,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Intended uses',
                    helperText:
                        'Separate multiple uses with commas.',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notes,
                  maxLines: 3,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Notes (optional)',
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style: const TextStyle(
                      color: AppColors.coral,
                      fontSize: 10,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving
              ? null
              : () {
                  Navigator.pop(context);
                },
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed:
              _saving ? null : _submit,
          icon: _saving
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child:
                      CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : const Icon(
                  Icons.check_rounded,
                  size: 16,
                ),
          label:
              const Text('Confirm import'),
        ),
      ],
    );
  }
}

class _ValidationDialog
    extends StatelessWidget {
  const _ValidationDialog({
    required this.result,
  });

  final TrainingDatasetUploadResult result;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: const Text(
        'Dataset validation failed',
      ),
      content: SizedBox(
        width: 680,
        child: SingleChildScrollView(
          child: _ValidationSummary(
            validation:
                result.validation,
            showErrors: true,
          ),
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _ValidationSummary
    extends StatelessWidget {
  const _ValidationSummary({
    required this.validation,
    this.showErrors = false,
  });

  final TrainingDatasetValidationResult
      validation;

  final bool showErrors;

  @override
  Widget build(BuildContext context) {
    final summary =
        validation.summary;

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _SummaryChip(
              label:
                  '${summary.totalRows} total',
            ),
            _SummaryChip(
              label:
                  '${summary.validRows} valid',
            ),
            _SummaryChip(
              label:
                  '${summary.invalidRows} invalid',
              error:
                  summary.invalidRows > 0,
            ),
          ],
        ),
        if (validation
            .modelColumns.isNotEmpty) ...[
          const SizedBox(height: 14),
          const Text(
            'Validated columns',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            validation.modelColumns.join(
              ', ',
            ),
            style: const TextStyle(
              color:
                  AppColors.textSecondary,
              fontSize: 9.5,
              height: 1.4,
            ),
          ),
        ],
        if (showErrors &&
            validation
                .datasetErrors.isNotEmpty) ...[
          const SizedBox(height: 14),
          for (final error
              in validation.datasetErrors)
            Padding(
              padding:
                  const EdgeInsets.only(
                bottom: 5,
              ),
              child: Text(
                '• $error',
                style: const TextStyle(
                  color: AppColors.coral,
                  fontSize: 9.5,
                ),
              ),
            ),
        ],
        if (showErrors &&
            validation
                .rowErrors.isNotEmpty) ...[
          const SizedBox(height: 14),
          const Text(
            'Row errors',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 7),
          for (final row
              in validation.rowErrors.take(50))
            for (final error
                in row.errors)
              Padding(
                padding:
                    const EdgeInsets.only(
                  bottom: 5,
                ),
                child: Text(
                  'Row ${row.rowNumber ?? '-'} • '
                  '${error.field}: '
                  '${error.message}',
                  style: const TextStyle(
                    color: AppColors.coral,
                    fontSize: 9.5,
                    height: 1.35,
                  ),
                ),
              ),
          if (validation.rowErrors.length >
              50)
            Text(
              '${validation.rowErrors.length - 50} additional row-error groups are not shown.',
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 9,
              ),
            ),
        ],
      ],
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.label,
    this.error = false,
  });

  final String label;
  final bool error;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: (error
                ? AppColors.coral
                : AppColors.primary)
            .withValues(alpha: .08),
        borderRadius:
            BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: error
              ? AppColors.coral
              : AppColors.primaryBright,
          fontSize: 9,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _DatasetDetailsDialog
    extends StatelessWidget {
  const _DatasetDetailsDialog({
    required this.dataset,
  });

  final TrainingDatasetModel dataset;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text(
        '${dataset.name} ${dataset.version}',
      ),
      content: SizedBox(
        width: 720,
        height: 500,
        child: SingleChildScrollView(
          child: SelectableText(
            const JsonEncoder.withIndent(
              '  ',
            ).convert(
              dataset.raw,
            ),
            style: const TextStyle(
              color:
                  AppColors.textSecondary,
              fontFamily: 'monospace',
              fontSize: 10,
              height: 1.5,
            ),
          ),
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Close'),
        ),
      ],
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
    final color =
        status.toUpperCase() == 'ACTIVE'
            ? AppColors.primaryBright
            : status.toUpperCase() ==
                    'ARCHIVED'
                ? AppColors.textMuted
                : Colors.amber;

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color:
            color.withValues(alpha: .09),
        borderRadius:
            BorderRadius.circular(99),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 7.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _MetaText extends StatelessWidget {
  const _MetaText({
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textMuted,
        fontSize: 9,
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({
    required this.onUpload,
  });

  final VoidCallback? onUpload;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppColors.surface
            .withValues(alpha: .5),
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.dataset_outlined,
            color: AppColors.textMuted,
            size: 30,
          ),
          const SizedBox(height: 10),
          const Text(
            'No training datasets',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Upload a CSV or XLSX dataset to begin the validation workflow.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 15),
          FilledButton.icon(
            onPressed: onUpload,
            icon: const Icon(
              Icons.upload_file_outlined,
            ),
            label:
                const Text('Upload dataset'),
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({
    required this.message,
    required this.onRetry,
  });

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
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color:
                    AppColors.textSecondary,
                fontSize: 10,
              ),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}