import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/admin_page_header.dart';
import '../../../shared/widgets/admin_responsive.dart';
import '../../../shared/widgets/admin_reveal.dart';
import '../../../shared/widgets/admin_surface.dart';

import 'screens/hydration_guidelines_screen.dart';
import 'screens/model_registry_screen.dart';
import 'screens/models_screen.dart';
import 'screens/risk_guidelines_screen.dart';
import 'screens/training_data_screen.dart';
import 'screens/training_runs_screen.dart';

enum _ResearchSection {
  guidelines,
  trainingData,
  models,
}

enum _ResearchPage {
  overview,
  hydrationGuidelines,
  riskGuidelines,
  trainingData,
  trainingRuns,
  modelSpecifications,
  trainingConfigs,
  modelRegistry,
}

class ResearchGuidelinesScreen
    extends StatefulWidget {
  const ResearchGuidelinesScreen({
    super.key,
  });

  @override
  State<ResearchGuidelinesScreen>
      createState() =>
          _ResearchGuidelinesScreenState();
}

class _ResearchGuidelinesScreenState
    extends State<ResearchGuidelinesScreen> {
  _ResearchSection _selected =
      _ResearchSection.guidelines;

  _ResearchPage _page =
      _ResearchPage.overview;

  void _openHydrationGuidelines() {
    setState(() {
      _selected =
          _ResearchSection.guidelines;

      _page =
          _ResearchPage.hydrationGuidelines;
    });
  }

  void _openRiskGuidelines() {
    setState(() {
      _selected =
          _ResearchSection.guidelines;

      _page =
          _ResearchPage.riskGuidelines;
    });
  }

  void _openTrainingData() {
    setState(() {
      _selected =
          _ResearchSection.trainingData;

      _page =
          _ResearchPage.trainingData;
    });
  }

  void _openTrainingRuns() {
    setState(() {
      _selected =
          _ResearchSection.trainingData;

      _page =
          _ResearchPage.trainingRuns;
    });
  }

  void _openModelSpecifications() {
    setState(() {
      _selected =
          _ResearchSection.models;

      _page =
          _ResearchPage.modelSpecifications;
    });
  }

  void _openTrainingConfigs() {
    setState(() {
      _selected =
          _ResearchSection.models;

      _page =
          _ResearchPage.trainingConfigs;
    });
  }

  void _openModelRegistry() {
    setState(() {
      _selected =
          _ResearchSection.models;

      _page =
          _ResearchPage.modelRegistry;
    });
  }

  void _backToOverview() {
    setState(() {
      _page =
          _ResearchPage.overview;
    });
  }

  void _selectSection(
    _ResearchSection section,
  ) {
    setState(() {
      _selected = section;

      _page =
          _ResearchPage.overview;
    });
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return SingleChildScrollView(
      padding:
          AdminResponsive.pageInsets(
        context,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const AdminReveal(
            child: AdminPageHeader(
              eyebrow:
                  'Clinical configuration',
              title:
                  'Research & Guidelines',
              subtitle:
                  'Manage clinical guidance, research datasets, training configuration, and machine-learning model lifecycle for log.CKD.',
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          AdminReveal(
            delay:
                const Duration(
              milliseconds: 70,
            ),
            child:
                _ResearchNavigation(
              selected:
                  _selected,
              onSelected:
                  _selectSection,
            ),
          ),
          const SizedBox(
            height: 22,
          ),
          AdminReveal(
            delay:
                const Duration(
              milliseconds: 120,
            ),
            child:
                AnimatedSwitcher(
              duration:
                  const Duration(
                milliseconds: 220,
              ),
              child:
                  _buildContent(),
            ),
          ),
          const SizedBox(
            height: 32,
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_page ==
        _ResearchPage
            .hydrationGuidelines) {
      return HydrationGuidelinesScreen(
        key: const ValueKey(
          'hydration-guidelines',
        ),
        onBack:
            _backToOverview,
      );
    }

    if (_page ==
        _ResearchPage
            .riskGuidelines) {
      return RiskGuidelinesScreen(
        key: const ValueKey(
          'risk-guidelines',
        ),
        onBack:
            _backToOverview,
      );
    }

    if (_page ==
        _ResearchPage.trainingData) {
      return TrainingDataScreen(
        key: const ValueKey(
          'training-data',
        ),
        onBack:
            _backToOverview,
      );
    }

    if (_page ==
        _ResearchPage.trainingRuns) {
      return TrainingRunsScreen(
        key: const ValueKey(
          'training-runs',
        ),
        onBack:
            _backToOverview,
      );
    }

    if (_page ==
        _ResearchPage
            .modelSpecifications) {
      return ModelsScreen(
        key: const ValueKey(
          'model-specifications',
        ),
        initialView:
            ModelsView.specifications,
        onBack:
            _backToOverview,
      );
    }

    if (_page ==
        _ResearchPage.trainingConfigs) {
      return ModelsScreen(
        key: const ValueKey(
          'training-configurations',
        ),
        initialView:
            ModelsView.trainingConfigs,
        onBack:
            _backToOverview,
      );
    }

    if (_page ==
        _ResearchPage.modelRegistry) {
      return ModelRegistryScreen(
        key: const ValueKey(
          'model-registry',
        ),
        onBack:
            _backToOverview,
      );
    }

    switch (_selected) {
      case _ResearchSection.guidelines:
        return _GuidelinesOverview(
          key: const ValueKey(
            'guidelines',
          ),
          onOpenHydrationGuidelines:
              _openHydrationGuidelines,
          onOpenRiskGuidelines:
              _openRiskGuidelines,
        );

      case _ResearchSection.trainingData:
        return _TrainingOverview(
          key: const ValueKey(
            'training',
          ),
          onOpenTrainingData:
              _openTrainingData,
          onOpenTrainingRuns:
              _openTrainingRuns,
        );

      case _ResearchSection.models:
        return _ModelsOverview(
          key: const ValueKey(
            'models',
          ),
          onOpenModelSpecifications:
              _openModelSpecifications,
          onOpenTrainingConfigs:
              _openTrainingConfigs,
          onOpenModelRegistry:
              _openModelRegistry,
        );
    }
  }
}

class _ResearchNavigation
    extends StatelessWidget {
  const _ResearchNavigation({
    required this.selected,
    required this.onSelected,
  });

  final _ResearchSection selected;

  final ValueChanged<_ResearchSection>
      onSelected;

  @override
  Widget build(
    BuildContext context,
  ) {
    return AdminSurface(
      padding:
          const EdgeInsets.all(6),
      child: LayoutBuilder(
        builder: (
          context,
          constraints,
        ) {
          final compact =
              constraints.maxWidth <
                  620;

          final buttons = [
            _NavigationButton(
              icon:
                  Icons.menu_book_outlined,
              label:
                  'Guidelines',
              selected:
                  selected ==
                      _ResearchSection
                          .guidelines,
              onTap: () {
                onSelected(
                  _ResearchSection
                      .guidelines,
                );
              },
            ),
            _NavigationButton(
              icon:
                  Icons.dataset_outlined,
              label:
                  'Training Data',
              selected:
                  selected ==
                      _ResearchSection
                          .trainingData,
              onTap: () {
                onSelected(
                  _ResearchSection
                      .trainingData,
                );
              },
            ),
            _NavigationButton(
              icon:
                  Icons.hub_outlined,
              label: 'Models',
              selected:
                  selected ==
                      _ResearchSection
                          .models,
              onTap: () {
                onSelected(
                  _ResearchSection
                      .models,
                );
              },
            ),
          ];

          if (compact) {
            return Column(
              children: [
                for (
                  var index = 0;
                  index <
                      buttons.length;
                  index++
                ) ...[
                  buttons[index],
                  if (index !=
                      buttons.length -
                          1)
                    const SizedBox(
                      height: 5,
                    ),
                ],
              ],
            );
          }

          return Row(
            children: [
              for (final button
                  in buttons)
                Expanded(
                  child:
                      button,
                ),
            ],
          );
        },
      ),
    );
  }
}

class _NavigationButton
    extends StatelessWidget {
  const _NavigationButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 2,
      ),
      child: Material(
        color: selected
            ? AppColors.primary
                .withValues(
                  alpha: .12,
                )
            : Colors.transparent,
        borderRadius:
            BorderRadius.circular(
          12,
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius:
              BorderRadius.circular(
            12,
          ),
          child:
              AnimatedContainer(
            duration:
                const Duration(
              milliseconds: 180,
            ),
            padding:
                const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 13,
            ),
            decoration:
                BoxDecoration(
              borderRadius:
                  BorderRadius.circular(
                12,
              ),
              border:
                  Border.all(
                color: selected
                    ? AppColors
                        .primaryBright
                        .withValues(
                          alpha:
                              .24,
                        )
                    : Colors
                        .transparent,
              ),
            ),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment
                      .center,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: selected
                      ? AppColors
                          .primaryBright
                      : AppColors
                          .textMuted,
                ),
                const SizedBox(
                  width: 9,
                ),
                Flexible(
                  child: Text(
                    label,
                    overflow:
                        TextOverflow
                            .ellipsis,
                    style:
                        TextStyle(
                      color: selected
                          ? AppColors
                              .textPrimary
                          : AppColors
                              .textSecondary,
                      fontSize: 12,
                      fontWeight:
                          selected
                              ? FontWeight
                                  .w700
                              : FontWeight
                                  .w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GuidelinesOverview
    extends StatelessWidget {
  const _GuidelinesOverview({
    super.key,
    required this.onOpenHydrationGuidelines,
    required this.onOpenRiskGuidelines,
  });

  final VoidCallback
      onOpenHydrationGuidelines;

  final VoidCallback
      onOpenRiskGuidelines;

  @override
  Widget build(
    BuildContext context,
  ) {
    return _SectionLayout(
      eyebrow:
          'GUIDELINE MANAGEMENT',
      title:
          'Clinical guidance',
      description:
          'Maintain versioned guidance used by log.CKD without embedding clinical thresholds directly into the admin interface.',
      children: [
        _ModuleCard(
          icon:
              Icons.water_drop_outlined,
          title:
              'Hydration Guidelines',
          description:
              'Manage hydration calculation rules, ranges, source metadata, and published versions.',
          status: 'Available',
          enabled: true,
          onTap:
              onOpenHydrationGuidelines,
          actionLabel:
              'Manage hydration',
        ),
        _ModuleCard(
          icon:
              Icons.monitor_heart_outlined,
          title:
              'Risk Assessment Guidelines',
          description:
              'Manage risk thresholds, bands, modifiers, recommendation configuration, and guideline versions.',
          status: 'Available',
          enabled: true,
          onTap:
              onOpenRiskGuidelines,
        ),
      ],
    );
  }
}

class _TrainingOverview
    extends StatelessWidget {
  const _TrainingOverview({
    super.key,
    required this.onOpenTrainingData,
    required this.onOpenTrainingRuns,
  });

  final VoidCallback
      onOpenTrainingData;

  final VoidCallback
      onOpenTrainingRuns;

  @override
  Widget build(
    BuildContext context,
  ) {
    return _SectionLayout(
      eyebrow:
          'DATA & TRAINING',
      title:
          'Training workspace',
      description:
          'Review dataset provenance and validation before using approved data in controlled model-training runs.',
      children: [
        _ModuleCard(
          icon:
              Icons.storage_outlined,
          title:
              'Dataset Registry',
          description:
              'Review registered datasets, provenance, record counts, versions, and activation status.',
          status: 'Dataset',
          onTap:
              onOpenTrainingData,
          actionLabel:
              'Manage datasets',
        ),
        _ModuleCard(
          icon:
              Icons.upload_file_outlined,
          title:
              'Upload Dataset',
          description:
              'Upload CSV or XLSX research data, validate its schema, review errors, and confirm import.',
          status: 'Import',
          onTap:
              onOpenTrainingData,
          actionLabel:
              'Upload & validate',
        ),
        _ModuleCard(
          icon:
              Icons.play_circle_outline_rounded,
          title:
              'Training Runs',
          description:
              'Create controlled candidate-training runs from approved datasets, specifications, and configurations.',
          status: 'Training',
          onTap:
              onOpenTrainingRuns,
          actionLabel:
              'Manage training runs',
        ),
      ],
    );
  }
}

class _ModelsOverview
    extends StatelessWidget {
  const _ModelsOverview({
    super.key,
    required
        this.onOpenModelSpecifications,
    required
        this.onOpenTrainingConfigs,
    required
        this.onOpenModelRegistry,
  });

  final VoidCallback
      onOpenModelSpecifications;

  final VoidCallback
      onOpenTrainingConfigs;

  final VoidCallback
      onOpenModelRegistry;

  @override
  Widget build(
    BuildContext context,
  ) {
    return _SectionLayout(
      eyebrow:
          'MODEL GOVERNANCE',
      title:
          'Model lifecycle',
      description:
          'Control specifications, training configuration, candidate evaluation, activation, and rollback from one workspace.',
      children: [
        _ModuleCard(
          icon:
              Icons.tune_rounded,
          title:
              'Model Specifications',
          description:
              'Manage versioned feature contracts, algorithms, hyperparameters, preprocessing, and threshold strategy.',
          status:
              'Specification',
          onTap:
              onOpenModelSpecifications,
          actionLabel:
              'Manage specifications',
        ),
        _ModuleCard(
          icon:
              Icons.settings_suggest_outlined,
          title:
              'Training Configurations',
          description:
              'Manage reproducible split, preprocessing, threshold-tuning, and output configuration.',
          status:
              'Configuration',
          onTap:
              onOpenTrainingConfigs,
          actionLabel:
              'Manage configurations',
        ),
        _ModuleCard(
          icon:
              Icons.account_tree_outlined,
          title:
              'Model Registry',
          description:
              'Inspect candidate and active models, provenance and metrics, then activate or roll back safely.',
          status:
              'Registry',
          onTap:
              onOpenModelRegistry,
          actionLabel:
              'Open registry',
        ),
      ],
    );
  }
}

class _SectionLayout
    extends StatelessWidget {
  const _SectionLayout({
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.children,
  });

  final String eyebrow;
  final String title;
  final String description;

  final List<Widget> children;

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
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            eyebrow,
            style:
                const TextStyle(
              color:
                  AppColors
                      .primaryBright,
              fontSize: 9,
              fontWeight:
                  FontWeight.w800,
              letterSpacing:
                  1.15,
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            title,
            style:
                const TextStyle(
              color:
                  AppColors
                      .textPrimary,
              fontSize: 21,
              fontWeight:
                  FontWeight.w800,
              letterSpacing: -.4,
            ),
          ),
          const SizedBox(
            height: 6,
          ),
          ConstrainedBox(
            constraints:
                const BoxConstraints(
              maxWidth: 760,
            ),
            child: Text(
              description,
              style:
                  const TextStyle(
                color:
                    AppColors
                        .textSecondary,
                fontSize: 11,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(
            height: 22,
          ),
          LayoutBuilder(
            builder: (
              context,
              constraints,
            ) {
              final width =
                  constraints
                      .maxWidth;

              final columns =
                  width >= 1050
                      ? 3
                      : width >=
                              650
                          ? 2
                          : 1;

              const gap =
                  12.0;

              final itemWidth =
                  (width -
                          gap *
                              (columns -
                                  1)) /
                      columns;

              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (final child
                      in children)
                    SizedBox(
                      width:
                          itemWidth,
                      child:
                          child,
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

class _ModuleCard
    extends StatefulWidget {
  const _ModuleCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.status,
    this.enabled = true,
    this.onTap,
    this.actionLabel =
        'Manage guidelines',
  });

  final IconData icon;

  final String title;
  final String description;
  final String status;

  final bool enabled;

  final VoidCallback? onTap;

  final String actionLabel;

  @override
  State<_ModuleCard>
      createState() =>
          _ModuleCardState();
}

class _ModuleCardState
    extends State<_ModuleCard> {
  bool _hovered = false;

  @override
  Widget build(
    BuildContext context,
  ) {
    final interactive =
        widget.enabled &&
        widget.onTap != null;

    return MouseRegion(
      onEnter: interactive
          ? (_) {
              setState(() {
                _hovered =
                    true;
              });
            }
          : null,
      onExit: interactive
          ? (_) {
              setState(() {
                _hovered =
                    false;
              });
            }
          : null,
      cursor: interactive
          ? SystemMouseCursors
              .click
          : SystemMouseCursors
              .basic,
      child:
          AnimatedContainer(
        duration:
            const Duration(
          milliseconds: 170,
        ),
        constraints:
            const BoxConstraints(
          minHeight: 190,
        ),
        decoration:
            BoxDecoration(
          color: _hovered
              ? AppColors.surface
                  .withValues(
                    alpha: .88,
                  )
              : AppColors.surface
                  .withValues(
                    alpha: .58,
                  ),
          borderRadius:
              BorderRadius.circular(
            15,
          ),
          border:
              Border.all(
            color: _hovered
                ? AppColors.primary
                    .withValues(
                      alpha: .26,
                    )
                : AppColors.border,
          ),
        ),
        child: Material(
          color:
              Colors.transparent,
          borderRadius:
              BorderRadius.circular(
            15,
          ),
          child: InkWell(
            onTap: interactive
                ? widget.onTap
                : null,
            borderRadius:
                BorderRadius.circular(
              15,
            ),
            child: Padding(
              padding:
                  const EdgeInsets.all(
                18,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
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
                            11,
                          ),
                          border:
                              Border.all(
                            color:
                                AppColors
                                    .primaryBright
                                    .withValues(
                              alpha:
                                  .13,
                            ),
                          ),
                        ),
                        child:
                            Icon(
                          widget.icon,
                          size: 18,
                          color: widget
                                  .enabled
                              ? AppColors
                                  .primaryBright
                              : AppColors
                                  .textMuted,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration:
                            BoxDecoration(
                          color: widget
                                  .enabled
                              ? AppColors
                                  .primary
                                  .withValues(
                                    alpha:
                                        .08,
                                  )
                              : AppColors
                                  .surface,
                          borderRadius:
                              BorderRadius
                                  .circular(
                            99,
                          ),
                        ),
                        child: Text(
                          widget.status
                              .toUpperCase(),
                          style:
                              TextStyle(
                            color: widget
                                    .enabled
                                ? AppColors
                                    .primaryBright
                                : AppColors
                                    .textMuted,
                            fontSize:
                                7.5,
                            fontWeight:
                                FontWeight
                                    .w800,
                            letterSpacing:
                                .8,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Text(
                    widget.title,
                    style:
                        TextStyle(
                      color: widget
                              .enabled
                          ? AppColors
                              .textPrimary
                          : AppColors
                              .textMuted,
                      fontSize: 14,
                      fontWeight:
                          FontWeight
                              .w700,
                    ),
                  ),
                  const SizedBox(
                    height: 7,
                  ),
                  Text(
                    widget.description,
                    style:
                        const TextStyle(
                      color:
                          AppColors
                              .textMuted,
                      fontSize: 10.5,
                      height: 1.5,
                    ),
                  ),
                 if (interactive) ...[
                    const SizedBox(
                      height: 18,
                    ),
                    Row(
                      children: [
                        Text(
                          widget
                              .actionLabel,
                          style:
                              const TextStyle(
                            color:
                                AppColors
                                    .primaryBright,
                            fontSize:
                                9.5,
                            fontWeight:
                                FontWeight
                                    .w700,
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        const Icon(
                          Icons
                              .arrow_forward_rounded,
                          size: 14,
                          color:
                              AppColors
                                  .primaryBright,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}