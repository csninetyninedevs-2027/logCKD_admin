import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/model_specification_model.dart';
import '../../../../shared/models/training_config_model.dart';
import '../../../../shared/widgets/admin_surface.dart';
import '../../../../shared/widgets/admin_skeleton.dart';
import '../../state/model_specification_admin_provider.dart';
import '../../state/training_config_admin_provider.dart';

enum ModelsView {
  specifications,
  trainingConfigs,
}

class ModelsScreen extends ConsumerStatefulWidget {
  const ModelsScreen({
    super.key,
    required this.initialView,
    this.onBack,
  });

  final ModelsView initialView;
  final VoidCallback? onBack;

  @override
  ConsumerState<ModelsScreen> createState() =>
      _ModelsScreenState();
}

class _ModelsScreenState
    extends ConsumerState<ModelsScreen> {
  late ModelsView _view;

  String? _busyId;

  @override
  void initState() {
    super.initState();

    _view = widget.initialView;
  }

  Future<void> _refresh() async {
    ref.invalidate(
      modelSpecificationListProvider,
    );

    ref.invalidate(
      trainingConfigListProvider,
    );
  }

  String _errorMessage(Object error) {
    if (error is DioException) {
      final data = error.response?.data;

      if (data is Map) {
        final message =
            data['error'] ?? data['message'];

        if (message != null) {
          final details = data['details'];

          if (details is List &&
              details.isNotEmpty) {
            return '$message\n${details.join('\n')}';
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
        ),
      );
  }

  Future<bool> _confirm({
    required String title,
    required String message,
    required String action,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(title),
              content: Text(message),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                      false,
                    );
                  },
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
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

  Future<void> _publishSpecification(
    ModelSpecificationModel specification,
  ) async {
    if (specification.id.isEmpty) {
      _message(
        'Backend record identifier unavailable.',
        error: true,
      );

      return;
    }

    final confirmed = await _confirm(
      title: 'Publish specification?',
      message:
          'Publishing this version can archive the currently published version of the same specification key. The referenced training dataset must also be ACTIVE.',
      action: 'Publish',
    );

    if (!confirmed) {
      return;
    }

    setState(() {
      _busyId = specification.id;
    });

    try {
      await ref
          .read(
            modelSpecificationAdminActionsProvider,
          )
          .publish(
            specification.id,
          );

      _message(
        'Model specification published.',
      );
    } catch (error) {
      _message(
        _errorMessage(error),
        error: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _busyId = null;
        });
      }
    }
  }

  Future<void> _archiveSpecification(
    ModelSpecificationModel specification,
  ) async {
    if (specification.id.isEmpty) {
      _message(
        'Backend record identifier unavailable.',
        error: true,
      );

      return;
    }

    final confirmed = await _confirm(
      title: 'Archive specification?',
      message:
          'This model specification version will no longer be available for normal lifecycle use.',
      action: 'Archive',
    );

    if (!confirmed) {
      return;
    }

    setState(() {
      _busyId = specification.id;
    });

    try {
      await ref
          .read(
            modelSpecificationAdminActionsProvider,
          )
          .archive(
            specification.id,
          );

      _message(
        'Model specification archived.',
      );
    } catch (error) {
      _message(
        _errorMessage(error),
        error: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _busyId = null;
        });
      }
    }
  }

  Future<void> _publishConfig(
    TrainingConfigModel config,
  ) async {
    if (config.id.isEmpty) {
      _message(
        'Backend record identifier unavailable.',
        error: true,
      );

      return;
    }

    final confirmed = await _confirm(
      title: 'Publish training configuration?',
      message:
          'The referenced Model Specification must already be PUBLISHED. Publishing can archive the previous published configuration with the same key.',
      action: 'Publish',
    );

    if (!confirmed) {
      return;
    }

    setState(() {
      _busyId = config.id;
    });

    try {
      await ref
          .read(
            trainingConfigAdminActionsProvider,
          )
          .publish(
            config.id,
          );

      _message(
        'Training configuration published.',
      );
    } catch (error) {
      _message(
        _errorMessage(error),
        error: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _busyId = null;
        });
      }
    }
  }

  Future<void> _archiveConfig(
    TrainingConfigModel config,
  ) async {
    if (config.id.isEmpty) {
      _message(
        'Backend record identifier unavailable.',
        error: true,
      );

      return;
    }

    final confirmed = await _confirm(
      title: 'Archive training configuration?',
      message:
          'This configuration version will be archived.',
      action: 'Archive',
    );

    if (!confirmed) {
      return;
    }

    setState(() {
      _busyId = config.id;
    });

    try {
      await ref
          .read(
            trainingConfigAdminActionsProvider,
          )
          .archive(
            config.id,
          );

      _message(
        'Training configuration archived.',
      );
    } catch (error) {
      _message(
        _errorMessage(error),
        error: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _busyId = null;
        });
      }
    }
  }

  Future<void> _showSpecificationDetail(
    ModelSpecificationModel specification,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            '${specification.specificationKey} v${specification.version}',
          ),
          content: SizedBox(
            width: 680,
            child: SingleChildScrollView(
              child: SelectableText(
                const JsonEncoder.withIndent(
                  '  ',
                ).convert(
                  specification.raw,
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showConfigDetail(
    TrainingConfigModel config,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            '${config.configKey} v${config.version}',
          ),
          content: SizedBox(
            width: 680,
            child: SingleChildScrollView(
              child: SelectableText(
                const JsonEncoder.withIndent(
                  '  ',
                ).convert(
                  config.raw,
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    'MODEL GOVERNANCE',
                    style: TextStyle(
                      color:
                          AppColors.primaryBright,
                      fontSize: 9,
                      fontWeight:
                          FontWeight.w800,
                      letterSpacing: 1.15,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Models',
                    style: TextStyle(
                      color:
                          AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Manage versioned model specifications and reproducible training configurations.',
                    style: TextStyle(
                      color:
                          AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Refresh',
              onPressed: _refresh,
              icon: const Icon(
                Icons.refresh_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        AdminSurface(
          padding:
              const EdgeInsets.all(6),
          child: Row(
            children: [
              Expanded(
                child: _TabButton(
                  label:
                      'Model Specifications',
                  icon:
                      Icons.tune_rounded,
                  selected:
                      _view ==
                      ModelsView.specifications,
                  onTap: () {
                    setState(() {
                      _view =
                          ModelsView.specifications;
                    });
                  },
                ),
              ),
              Expanded(
                child: _TabButton(
                  label:
                      'Training Configurations',
                  icon: Icons
                      .settings_suggest_outlined,
                  selected:
                      _view ==
                      ModelsView.trainingConfigs,
                  onTap: () {
                    setState(() {
                      _view =
                          ModelsView.trainingConfigs;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (_view ==
            ModelsView.specifications)
          _buildSpecifications()
        else
          _buildTrainingConfigs(),
      ],
    );
  }

  Widget _buildSpecifications() {
    final state = ref.watch(
      modelSpecificationListProvider,
    );

    return state.when(
      loading: () => const _LoadingCard(),
      error: (error, stack) {
        return _ErrorCard(
          message:
              _errorMessage(error),
          onRetry: () {
            ref.invalidate(
              modelSpecificationListProvider,
            );
          },
        );
      },
      data: (result) {
        return Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            _SummaryBar(
              title:
                  'Model Specifications',
              subtitle:
                  '${result.total} registered version${result.total == 1 ? '' : 's'}',
              buttonLabel:
                  'Create specification',
              onPressed:
                  _createSpecification,
            ),
            const SizedBox(height: 12),
            if (result.items.isEmpty)
              const _EmptyCard(
                title:
                    'No model specifications',
                message:
                    'Create the first controlled model specification.',
              )
            else
              for (final item
                  in result.items) ...[
                _SpecificationCard(
                  specification: item,
                  busy:
                      _busyId == item.id,
                  onDetails: () {
                    _showSpecificationDetail(
                      item,
                    );
                  },
                  onPublish:
                      item.isDraft
                          ? () {
                              _publishSpecification(
                                item,
                              );
                            }
                          : null,
                  onArchive:
                      !item.isArchived
                          ? () {
                              _archiveSpecification(
                                item,
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
    );
  }

  Widget _buildTrainingConfigs() {
    final state = ref.watch(
      trainingConfigListProvider,
    );

    return state.when(
      loading: () => const _LoadingCard(),
      error: (error, stack) {
        return _ErrorCard(
          message:
              _errorMessage(error),
          onRetry: () {
            ref.invalidate(
              trainingConfigListProvider,
            );
          },
        );
      },
      data: (result) {
        return Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            _SummaryBar(
              title:
                  'Training Configurations',
              subtitle:
                  '${result.total} registered version${result.total == 1 ? '' : 's'}',
              buttonLabel:
                  'Create configuration',
              onPressed:
                  _createTrainingConfig,
            ),
            const SizedBox(height: 12),
            if (result.items.isEmpty)
              const _EmptyCard(
                title:
                    'No training configurations',
                message:
                    'Create a configuration after a matching Model Specification exists.',
              )
            else
              for (final item
                  in result.items) ...[
                _TrainingConfigCard(
                  config: item,
                  busy:
                      _busyId == item.id,
                  onDetails: () {
                    _showConfigDetail(
                      item,
                    );
                  },
                  onPublish:
                      item.isDraft
                          ? () {
                              _publishConfig(
                                item,
                              );
                            }
                          : null,
                  onArchive:
                      !item.isArchived
                          ? () {
                              _archiveConfig(
                                item,
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
    );
  }

  Future<void> _createSpecification() async {
    final result =
        await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) =>
          const _SpecificationDialog(),
    );

    if (result == null) {
      return;
    }

    try {
      await ref
          .read(
            modelSpecificationAdminActionsProvider,
          )
          .create(result);

      _message(
        'Model specification draft created.',
      );
    } catch (error) {
      _message(
        _errorMessage(error),
        error: true,
      );
    }
  }

Future<void> _createTrainingConfig() async {
  late final List<ModelSpecificationModel>
      specifications;

  try {
    final specificationResult =
        await ref.read(
      modelSpecificationListProvider.future,
    );

    specifications =
        specificationResult.items;
  } catch (error) {
    _message(
      _errorMessage(error),
      error: true,
    );

    return;
  }

  if (!mounted) {
    return;
  }

  if (specifications.isEmpty) {
    _message(
      'Create a Model Specification first.',
      error: true,
    );

    return;
  }

  final result =
      await showDialog<Map<String, dynamic>>(
    context: context,
    builder: (context) {
      return _TrainingConfigDialog(
        specifications:
            specifications,
      );
    },
  );

  if (result == null) {
    return;
  }

  try {
    await ref
        .read(
          trainingConfigAdminActionsProvider,
        )
        .create(result);

    _message(
      'Training configuration draft created.',
    );
  } catch (error) {
    _message(
      _errorMessage(error),
      error: true,
    );
  }
}
}

class _SpecificationDialog
    extends StatefulWidget {
  const _SpecificationDialog();

  @override
  State<_SpecificationDialog>
      createState() =>
          _SpecificationDialogState();
}

class _SpecificationDialogState
    extends State<_SpecificationDialog> {
  final _formKey =
      GlobalKey<FormState>();

  final _key =
      TextEditingController();

  final _title =
      TextEditingController();

  final _description =
      TextEditingController();

  final _dataset =
      TextEditingController();

  final _target =
      TextEditingController(
    text: 'screeningRiskPositive',
  );

  final _features =
      TextEditingController(
    text:
        'ageYears, bmi, systolicBp, diastolicBp, hasDiabetes, sexAtBirth',
  );

  final _numeric =
      TextEditingController(
    text:
        'ageYears, bmi, systolicBp, diastolicBp',
  );

  final _categorical =
      TextEditingController(
    text:
        'hasDiabetes, sexAtBirth',
  );

  final _preprocessingVersion =
      TextEditingController(
    text: 'v1',
  );

  final _hyperparameters =
      TextEditingController(
    text: '{}',
  );

  final _notes =
      TextEditingController();

  String _algorithm =
      'random_forest';

  double _training = .70;
  double _validation = .15;
  double _test = .15;

  bool _stratify = true;

  int _randomState = 42;

  double _minimumThreshold = .10;
  double _maximumThreshold = .90;
  double _thresholdStep = .01;
  double _minimumSensitivity = .80;

  String _primaryMetric =
      'balanced_accuracy';

  final _secondaryMetrics =
      TextEditingController(
    text:
        'sensitivity, specificity, f1',
  );

  List<String> _list(
    String value,
  ) {
    return value
        .split(RegExp(r'[,\n]'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toSet()
        .toList();
  }

  String get _role =>
      _algorithm == 'random_forest'
          ? 'primary_risk_scorer'
          : 'secondary_model_consistency_check';

  void _submit() {
    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    final splitTotal =
        _training +
        _validation +
        _test;

    if ((splitTotal - 1).abs() >
        .000000001) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Training, validation, and test fractions must total 1.0.',
          ),
        ),
      );

      return;
    }

    Map<String, dynamic> hyperparameters;

    try {
      final decoded =
          jsonDecode(
        _hyperparameters.text.trim(),
      );

      if (decoded is! Map ||
          decoded.isEmpty) {
        throw const FormatException();
      }

      hyperparameters =
          Map<String, dynamic>.from(
        decoded,
      );
    } catch (_) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Hyperparameters must be a non-empty JSON object.',
          ),
        ),
      );

      return;
    }

    final features =
        _list(_features.text);

    final numeric =
        _list(_numeric.text);

    final categorical =
        _list(_categorical.text);

    final combined = {
      ...numeric,
      ...categorical,
    };

    if (features.toSet().length !=
            combined.length ||
        !features.every(
          combined.contains,
        )) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Numeric and categorical features must exactly cover all model features.',
          ),
        ),
      );

      return;
    }

    Navigator.pop(
      context,
      {
        'specificationKey':
            _key.text.trim(),
        'title':
            _title.text.trim(),
        'description':
            _description.text.trim(),
        'algorithm':
            _algorithm,
        'modelRole':
            _role,
        'target':
            _target.text.trim(),
        'features':
            features,
        'numericFeatures':
            numeric,
        'categoricalFeatures':
            categorical,
        'split': {
          'training': _training,
          'validation':
              _validation,
          'test': _test,
          'stratify':
              _stratify,
          'randomState':
              _randomState,
        },
        'preprocessing': {
          'numericImputation':
              'median',
          'categoricalImputation':
              'most_frequent',
          'categoricalEncoding':
              'one_hot',
          'handleUnknown':
              'ignore',
        },
        'preprocessingVersion':
            _preprocessingVersion
                .text
                .trim(),
        'hyperparameters':
            hyperparameters,
        'thresholdTuning': {
          'enabled': true,
          'minimumThreshold':
              _minimumThreshold,
          'maximumThreshold':
              _maximumThreshold,
          'step':
              _thresholdStep,
          'minimumSensitivity':
              _minimumSensitivity,
          'primaryMetric':
              _primaryMetric,
          'secondaryMetrics':
              _list(
            _secondaryMetrics.text,
          ),
        },
        'trainingDatasetKey':
            _dataset.text.trim(),
        'notes':
            _notes.text.trim().isEmpty
                ? null
                : _notes.text.trim(),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Create Model Specification',
      ),
      content: SizedBox(
        width: 720,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _field(
                  _key,
                  'Specification key',
                ),
                _field(
                  _title,
                  'Title',
                ),
                _field(
                  _description,
                  'Description',
                  lines: 3,
                ),
                DropdownButtonFormField<String>(
                  initialValue:
                      _algorithm,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Algorithm',
                  ),
                  items: const [
                    DropdownMenuItem(
                      value:
                          'random_forest',
                      child: Text(
                        'Random Forest',
                      ),
                    ),
                    DropdownMenuItem(
                      value:
                          'xgboost',
                      child: Text(
                        'XGBoost',
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _algorithm =
                            value;
                      });
                    }
                  },
                ),
                const SizedBox(
                  height: 12,
                ),
                TextFormField(
                  initialValue: _role,
                  enabled: false,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Model role',
                  ),
                ),
                const SizedBox(
                  height: 12,
                ),
                _field(
                  _dataset,
                  'Training dataset key',
                ),
                _field(
                  _target,
                  'Target',
                ),
                _field(
                  _features,
                  'Features',
                  lines: 2,
                ),
                _field(
                  _numeric,
                  'Numeric features',
                  lines: 2,
                ),
                _field(
                  _categorical,
                  'Categorical features',
                  lines: 2,
                ),
                _field(
                  _preprocessingVersion,
                  'Preprocessing version',
                ),
                _field(
                  _hyperparameters,
                  'Hyperparameters JSON',
                  lines: 4,
                ),
                _field(
                  _secondaryMetrics,
                  'Secondary metrics',
                  lines: 2,
                ),
                _field(
                  _notes,
                  'Notes',
                  required: false,
                  lines: 3,
                ),
                const SizedBox(
                  height: 8,
                ),
                const Align(
                  alignment:
                      Alignment.centerLeft,
                  child: Text(
                    'Split',
                    style: TextStyle(
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Row(
                  children: [
                    Expanded(
                      child: _numberField(
                        'Training',
                        _training,
                        (value) =>
                            _training =
                                value,
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: _numberField(
                        'Validation',
                        _validation,
                        (value) =>
                            _validation =
                                value,
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: _numberField(
                        'Test',
                        _test,
                        (value) =>
                            _test =
                                value,
                      ),
                    ),
                  ],
                ),
                SwitchListTile(
                  contentPadding:
                      EdgeInsets.zero,
                  title: const Text(
                    'Stratify split',
                  ),
                  value: _stratify,
                  onChanged: (value) {
                    setState(() {
                      _stratify =
                          value;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child:
              const Text('Create draft'),
        ),
      ],
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    int lines = 1,
    bool required = true,
  }) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 12,
      ),
      child: TextFormField(
        controller: controller,
        maxLines: lines,
        decoration:
            InputDecoration(
          labelText: label,
        ),
        validator: (value) {
          if (required &&
              (value == null ||
                  value.trim().isEmpty)) {
            return '$label is required.';
          }

          return null;
        },
      ),
    );
  }

  Widget _numberField(
    String label,
    double value,
    ValueChanged<double> onChanged,
  ) {
    return TextFormField(
      initialValue:
          value.toString(),
      keyboardType:
          const TextInputType.numberWithOptions(
        decimal: true,
      ),
      decoration:
          InputDecoration(
        labelText: label,
      ),
      validator: (value) {
        final parsed =
            double.tryParse(
          value ?? '',
        );

        if (parsed == null ||
            parsed < 0 ||
            parsed > 1) {
          return '0–1';
        }

        onChanged(parsed);

        return null;
      },
    );
  }
}

class _TrainingConfigDialog
    extends StatefulWidget {
  const _TrainingConfigDialog({
    required this.specifications,
  });

  final List<ModelSpecificationModel>
      specifications;

  @override
  State<_TrainingConfigDialog>
      createState() =>
          _TrainingConfigDialogState();
}

class _TrainingConfigDialogState
    extends State<_TrainingConfigDialog> {
  final _key =
      TextEditingController();

  final _notes =
      TextEditingController();

  ModelSpecificationModel?
      _selected;

  @override
  void initState() {
    super.initState();

    final available = widget
        .specifications
        .where(
          (item) => !item.isArchived,
        )
        .toList();

    if (available.isNotEmpty) {
      _selected =
          available.first;
    }
  }

  void _submit() {
    final specification =
        _selected;

    if (_key.text.trim().isEmpty ||
        specification == null) {
      return;
    }

    final threshold =
        specification.thresholdTuning;

    Navigator.pop(
      context,
      {
        'configKey':
            _key.text.trim(),
        'algorithm':
            specification.algorithm,
        'modelSpecificationVersion':
            specification.version,
        'split':
            specification.split,
        'preprocessingVersion':
            specification
                .preprocessingVersion,
        'thresholdTuning': {
          'enabled':
              threshold['enabled'] ??
                  true,
          'minimumThreshold':
              threshold[
                      'minimumThreshold'] ??
                  .10,
          'maximumThreshold':
              threshold[
                      'maximumThreshold'] ??
                  .90,
          'step':
              threshold['step'] ??
                  .01,
          'minimumSensitivity':
              threshold[
                      'minimumSensitivity'] ??
                  .80,
        },
        'output': {
          'saveModel': true,
          'saveMetrics': true,
          'saveValidationPredictions':
              true,
          'saveTestPredictions':
              true,
        },
        'notes':
            _notes.text.trim().isEmpty
                ? null
                : _notes.text.trim(),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final available = widget
        .specifications
        .where(
          (item) => !item.isArchived,
        )
        .toList();

    return AlertDialog(
      title: const Text(
        'Create Training Configuration',
      ),
      content: SizedBox(
        width: 620,
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            TextField(
              controller: _key,
              decoration:
                  const InputDecoration(
                labelText:
                    'Configuration key',
              ),
            ),
            const SizedBox(
              height: 12,
            ),
            DropdownButtonFormField<
                ModelSpecificationModel>(
              initialValue:
                  _selected,
              decoration:
                  const InputDecoration(
                labelText:
                    'Model specification',
              ),
              items: [
                for (final item
                    in available)
                  DropdownMenuItem(
                    value: item,
                    child: Text(
                      '${item.specificationKey} v${item.version} · ${item.algorithm}',
                    ),
                  ),
              ],
              onChanged: (value) {
                setState(() {
                  _selected = value;
                });
              },
            ),
            const SizedBox(
              height: 12,
            ),
            const Text(
              'Split and preprocessing are inherited from the selected Model Specification because the backend requires an exact match.',
              style: TextStyle(
                fontSize: 11,
                color:
                    AppColors.textSecondary,
              ),
            ),
            const SizedBox(
              height: 12,
            ),
            TextField(
              controller: _notes,
              maxLines: 3,
              decoration:
                  const InputDecoration(
                labelText:
                    'Notes (optional)',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed:
              available.isEmpty
                  ? null
                  : _submit,
          child:
              const Text('Create draft'),
        ),
      ],
    );
  }
}

class _SpecificationCard
    extends StatelessWidget {
  const _SpecificationCard({
    required this.specification,
    required this.busy,
    required this.onDetails,
    this.onPublish,
    this.onArchive,
  });

  final ModelSpecificationModel
      specification;

  final bool busy;

  final VoidCallback onDetails;
  final VoidCallback? onPublish;
  final VoidCallback? onArchive;

  @override
  Widget build(BuildContext context) {
    return AdminSurface(
      padding:
          const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(
            Icons.tune_rounded,
            color:
                AppColors.primaryBright,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  specification.title,
                  style:
                      const TextStyle(
                    color:
                        AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  '${specification.specificationKey} · v${specification.version} · ${specification.algorithm} · ${specification.trainingDatasetKey}',
                  style:
                      const TextStyle(
                    color:
                        AppColors.textMuted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          _StatusBadge(
            status:
                specification.status,
          ),
          const SizedBox(width: 8),
          if (busy)
            const SizedBox(
              width: 28,
              height: 28,
              child:
                  CircularProgressIndicator(
                strokeWidth: 2,
              ),
            )
          else
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value ==
                    'details') {
                  onDetails();
                } else if (value ==
                    'publish') {
                  onPublish?.call();
                } else if (value ==
                    'archive') {
                  onArchive?.call();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'details',
                  child:
                      Text('View details'),
                ),
                if (onPublish != null)
                  const PopupMenuItem(
                    value: 'publish',
                    child: Text(
                      'Publish',
                    ),
                  ),
                if (onArchive != null)
                  const PopupMenuItem(
                    value: 'archive',
                    child: Text(
                      'Archive',
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _TrainingConfigCard
    extends StatelessWidget {
  const _TrainingConfigCard({
    required this.config,
    required this.busy,
    required this.onDetails,
    this.onPublish,
    this.onArchive,
  });

  final TrainingConfigModel config;
  final bool busy;

  final VoidCallback onDetails;
  final VoidCallback? onPublish;
  final VoidCallback? onArchive;

  @override
  Widget build(BuildContext context) {
    return AdminSurface(
      padding:
          const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(
            Icons.settings_suggest_outlined,
            color:
                AppColors.primaryBright,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  config.configKey,
                  style:
                      const TextStyle(
                    color:
                        AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  'v${config.version} · ${config.algorithm} · Model Spec v${config.modelSpecificationVersion} · ${config.preprocessingVersion}',
                  style:
                      const TextStyle(
                    color:
                        AppColors.textMuted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          _StatusBadge(
            status: config.status,
          ),
          const SizedBox(width: 8),
          if (busy)
            const SizedBox(
              width: 28,
              height: 28,
              child:
                  CircularProgressIndicator(
                strokeWidth: 2,
              ),
            )
          else
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value ==
                    'details') {
                  onDetails();
                } else if (value ==
                    'publish') {
                  onPublish?.call();
                } else if (value ==
                    'archive') {
                  onArchive?.call();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'details',
                  child:
                      Text('View details'),
                ),
                if (onPublish != null)
                  const PopupMenuItem(
                    value: 'publish',
                    child:
                        Text('Publish'),
                  ),
                if (onArchive != null)
                  const PopupMenuItem(
                    value: 'archive',
                    child:
                        Text('Archive'),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _SummaryBar
    extends StatelessWidget {
  const _SummaryBar({
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.onPressed,
  });

  final String title;
  final String subtitle;
  final String buttonLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AdminSurface(
      padding:
          const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style:
                      const TextStyle(
                    color:
                        AppColors.textPrimary,
                    fontWeight:
                        FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  subtitle,
                  style:
                      const TextStyle(
                    color:
                        AppColors.textMuted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          FilledButton.icon(
            onPressed: onPressed,
            icon: const Icon(
              Icons.add_rounded,
              size: 16,
            ),
            label: Text(
              buttonLabel,
            ),
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary
            .withValues(alpha: .09),
        borderRadius:
            BorderRadius.circular(99),
      ),
      child: Text(
        status,
        style: const TextStyle(
          color:
              AppColors.primaryBright,
          fontSize: 8,
          fontWeight:
              FontWeight.w800,
        ),
      ),
    );
  }
}

class _TabButton
    extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppColors.primary
              .withValues(alpha: .12)
          : Colors.transparent,
      borderRadius:
          BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(12),
        child: Padding(
          padding:
              const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 10,
          ),
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 17,
                color: selected
                    ? AppColors.primaryBright
                    : AppColors.textMuted,
              ),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  label,
                  overflow:
                      TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                    fontSize: 10,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingCard
    extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _ModelsSummarySkeleton(),
        SizedBox(height: 12),
        _ModelsItemSkeleton(),
        SizedBox(height: 10),
        _ModelsItemSkeleton(),
        SizedBox(height: 10),
        _ModelsItemSkeleton(),
      ],
    );
  }
}

class _ModelsSummarySkeleton
    extends StatelessWidget {
  const _ModelsSummarySkeleton();

  @override
  Widget build(BuildContext context) {
    return AdminSkeleton(
      child: SizedBox(
        width: double.infinity,
        child: AdminSurface(
          padding: const EdgeInsets.all(16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact =
                  constraints.maxWidth < 620;

              final info = Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  FractionallySizedBox(
                    widthFactor:
                        compact ? .62 : .30,
                    alignment:
                        Alignment.centerLeft,
                    child:
                        const AdminSkeletonBox(
                      height: 14,
                      radius: 7,
                    ),
                  ),
                  const SizedBox(height: 8),
                  FractionallySizedBox(
                    widthFactor:
                        compact ? .48 : .22,
                    alignment:
                        Alignment.centerLeft,
                    child:
                        const AdminSkeletonBox(
                      height: 10,
                      radius: 5,
                    ),
                  ),
                ],
              );

              final button = SizedBox(
                width: compact
                    ? double.infinity
                    : 150,
                child:
                    const AdminSkeletonBox(
                  height: 38,
                  radius: 10,
                ),
              );

              if (compact) {
                return Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    info,
                    const SizedBox(
                      height: 14,
                    ),
                    button,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(
                    child: info,
                  ),
                  const SizedBox(width: 14),
                  button,
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ModelsItemSkeleton
    extends StatelessWidget {
  const _ModelsItemSkeleton();

  @override
  Widget build(BuildContext context) {
    return AdminSkeleton(
      child: SizedBox(
        width: double.infinity,
        child: AdminSurface(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact =
                constraints.maxWidth < 640;

            const details = Row(
              children: [
                AdminSkeletonBox(
                  width: 24,
                  height: 24,
                  radius: 7,
                ),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      AdminSkeletonBox(
                        width: 220,
                        height: 13,
                        radius: 6,
                      ),
                      SizedBox(height: 8),
                      AdminSkeletonBox(
                        width: 310,
                        height: 10,
                        radius: 5,
                      ),
                    ],
                  ),
                ),
              ],
            );

            const trailing = Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AdminSkeletonBox(
                  width: 74,
                  height: 24,
                  radius: 12,
                ),
                SizedBox(width: 8),
                AdminSkeletonBox(
                  width: 32,
                  height: 32,
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
                  SizedBox(height: 14),
                  trailing,
                ],
              );
            }

            return const Row(
              children: [
                Expanded(
                  child: details,
                ),
                SizedBox(width: 14),
                trailing,
              ],
            );
          },
        ),
      ),
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
  Widget build(BuildContext context) {
    return AdminSurface(
      padding:
          const EdgeInsets.all(22),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color:
                AppColors.textMuted,
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign:
                TextAlign.center,
            style: const TextStyle(
              color:
                  AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(
              Icons.refresh_rounded,
            ),
            label:
                const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _EmptyCard
    extends StatelessWidget {
  const _EmptyCard({
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return AdminSurface(
      padding:
          const EdgeInsets.all(30),
      child: Center(
        child: Column(
          children: [
            const Icon(
              Icons.hub_outlined,
              color:
                  AppColors.textMuted,
              size: 28,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style:
                  const TextStyle(
                color:
                    AppColors.textPrimary,
                fontWeight:
                    FontWeight.w700,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              message,
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                color:
                    AppColors.textMuted,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}