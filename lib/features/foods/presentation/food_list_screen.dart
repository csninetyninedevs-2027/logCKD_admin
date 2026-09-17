import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/models/admin_food.dart';
import '../../../shared/utils/admin_input_validation.dart';
import '../../../shared/widgets/admin_responsive.dart';
import '../../../shared/widgets/food_list_skeleton.dart';
import '../state/food_provider.dart';

class FoodListScreen extends ConsumerStatefulWidget {
  const FoodListScreen({
    super.key,
  });

  @override
  ConsumerState<FoodListScreen> createState() =>
      _FoodListScreenState();
}

class _FoodListScreenState
    extends ConsumerState<FoodListScreen> {
  final _searchController =
      TextEditingController();
  final _tableScrollController =
      ScrollController();

  @override
  void dispose() {
    _searchController.dispose();
    _tableScrollController.dispose();
    super.dispose();
  }

  void _search() {
    final value =
        _searchController.text.trim();

    ref
        .read(
          foodListParamsProvider.notifier,
        )
        .update(
          (state) => state.copyWith(
            search: value,
            page: 1,
          ),
        );
  }

  void _clearFilters() {
    _searchController.clear();

    ref
        .read(
          foodListParamsProvider.notifier,
        )
        .state = const FoodListParams();
  }

  Future<void> _openFoodDialog({
    AdminFood? existing,
  }) async {
    final draft =
        await showDialog<FoodDraft>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return _FoodFormDialog(
          existing: existing,
        );
      },
    );

    if (draft == null) {
      return;
    }

    try {
      final notifier =
          ref.read(
        foodActionsProvider.notifier,
      );

      if (existing == null) {
        await notifier.createFood(
          draft,
        );
      } else {
        if (existing.id == null) {
          return;
        }

        await notifier.updateFood(
          existing.id!,
          draft,
        );
      }

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            existing == null
                ? 'Food added successfully.'
                : 'Food updated successfully.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            foodErrorMessage(error),
          ),
          backgroundColor:
              AppColors.danger,
        ),
      );
    }
  }

  Future<void> _deactivateFood(
    AdminFood food,
  ) async {
    if (food.id == null) {
      return;
    }

    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title:
              const Text('Deactivate food?'),
          content: Text(
            '"${food.name}" will stop appearing '
            'in the patient food search.\n\n'
            'Its MongoDB record will remain inactive.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(false);
              },
              child:
                  const Text('Cancel'),
            ),
            FilledButton(
              style:
                  FilledButton.styleFrom(
                backgroundColor:
                    AppColors.danger,
              ),
              onPressed: () {
                Navigator.of(context)
                    .pop(true);
              },
              child: const Text(
                'Deactivate',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await ref
          .read(
            foodActionsProvider.notifier,
          )
          .deactivateFood(
            food.id!,
          );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Food deactivated.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            foodErrorMessage(error),
          ),
          backgroundColor:
              AppColors.danger,
        ),
      );
    }
  }

  Future<void> _openBulkDialog() async {
    final result =
        await showDialog<BulkImportResponse>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const _BulkFoodDialog();
      },
    );

    if (result == null ||
        !mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          '${result.imported} imported, '
          '${result.skipped} skipped.',
        ),
      ),
    );
  }

  void _showDetails(
    AdminFood food,
  ) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return _FoodDetailsDialog(
          food: food,
        );
      },
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final foodsAsync =
        ref.watch(
      foodListProvider,
    );

    final params =
        ref.watch(
      foodListParamsProvider,
    );

    final actionState =
        ref.watch(
      foodActionsProvider,
    );

    return Padding(
        padding:
            AdminResponsive.pageInsets(context),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            AdminResponsiveHeader(
              heading: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Food Library',
                        style:
                            Theme.of(context)
                                .textTheme
                                .headlineLarge,
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        'Manage global foods and browse '
                        'reference food datasets.',
                        style:
                            Theme.of(context)
                                .textTheme
                                .bodySmall,
                      ),
                    ],
                  ),
              actions: [
                OutlinedButton.icon(
                  onPressed:
                      actionState.isLoading
                          ? null
                          : _openBulkDialog,
                  icon: const Icon(
                    Icons.data_object,
                  ),
                  label:
                      const Text('Bulk JSON'),
                ),
                ElevatedButton.icon(
                  onPressed:
                      actionState.isLoading
                          ? null
                          : () {
                              _openFoodDialog();
                            },
                  icon: const Icon(
                    Icons.add,
                  ),
                  label:
                      const Text('Add Food'),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Card(
              child: Padding(
                padding:
                    const EdgeInsets.all(14),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SizedBox(
                      width: AdminResponsive.actionWidth(
                        context,
                        maxWidth: 340,
                        additionalInsets: 28,
                      ),
                      child: TextField(
                        controller:
                            _searchController,
                        onSubmitted:
                            (_) => _search(),
                        decoration:
                            InputDecoration(
                          hintText:
                              'Search foods...',
                          prefixIcon:
                              const Icon(
                            Icons.search,
                          ),
                          suffixIcon:
                              IconButton(
                            onPressed:
                                _search,
                            icon:
                                const Icon(
                              Icons
                                  .arrow_forward,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: AdminResponsive.actionWidth(
                        context,
                        maxWidth: 220,
                        additionalInsets: 28,
                      ),
                      child:
                          DropdownButtonFormField<
                              String>(
                        value:
                            params.source,
                        decoration:
                            const InputDecoration(
                          labelText:
                              'Source',
                        ),
                        items:
                            const [
                          DropdownMenuItem(
                            value: 'all',
                            child: Text(
                              'All foods',
                            ),
                          ),
                          DropdownMenuItem(
                            value:
                                'foundation',
                            child: Text(
                              'USDA Foundation',
                            ),
                          ),
                          DropdownMenuItem(
                            value:
                                'filipino',
                            child: Text(
                              'Filipino foods',
                            ),
                          ),
                          DropdownMenuItem(
                            value:
                                'user_custom',
                            child: Text(
                              'User custom',
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'admin',
                            child: Text(
                              'Admin foods',
                            ),
                          ),
                        ],
                        onChanged:
                            (value) {
                          if (value ==
                              null) {
                            return;
                          }

                          ref
                              .read(
                                foodListParamsProvider
                                    .notifier,
                              )
                              .update(
                                (state) =>
                                    state
                                        .copyWith(
                                  source:
                                      value,
                                  page: 1,
                                ),
                              );
                        },
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed:
                          _clearFilters,
                      icon: const Icon(
                        Icons.clear,
                      ),
                      label:
                          const Text(
                        'Clear',
                      ),
                    ),
                    IconButton(
                      tooltip: 'Refresh',
                      onPressed: () {
                        ref.invalidate(
                          foodListProvider,
                        );
                      },
                      icon: const Icon(
                        Icons.refresh,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Expanded(
              child: foodsAsync.when(
                loading: () => const FoodListSkeleton(),
                error: (
                  error,
                  stackTrace,
                ) {
                  return Center(
                    child: Column(
                      mainAxisSize:
                          MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color:
                              AppColors.danger,
                          size: 42,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          foodErrorMessage(
                            error,
                          ),
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        OutlinedButton(
                          onPressed: () {
                            ref.invalidate(
                              foodListProvider,
                            );
                          },
                          child: const Text(
                            'Retry',
                          ),
                        ),
                      ],
                    ),
                  );
                },
                data: (page) {
                  if (page.foods.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize:
                            MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons
                                .restaurant_menu,
                            size: 48,
                            color: AppColors
                                .textSecondary,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text(
                            'No foods found',
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          OutlinedButton(
                            onPressed:
                                _clearFilters,
                            child:
                                const Text(
                              'Clear Filters',
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: [
                      Expanded(
                        child:
                            SingleChildScrollView(
                          child: Card(
                            clipBehavior:
                                Clip.antiAlias,
                            child: Scrollbar(
                              controller:
                                  _tableScrollController,
                              thumbVisibility:
                                  true,
                              scrollbarOrientation:
                                  ScrollbarOrientation.bottom,
                              child:
                                  SingleChildScrollView(
                                controller:
                                    _tableScrollController,
                                scrollDirection:
                                    Axis.horizontal,
                                child:
                                    DataTable(
                                columns:
                                    const [
                                  DataColumn(
                                    label: Text(
                                      'Food',
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Category',
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Energy',
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Sodium',
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Source',
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Status',
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Actions',
                                    ),
                                  ),
                                ],
                                rows: [
                                  for (final food
                                      in page.foods)
                                    DataRow(
                                      cells: [
                                        DataCell(
                                          SizedBox(
                                            width:
                                                280,
                                            child:
                                                Text(
                                              food.name,
                                              overflow:
                                                  TextOverflow
                                                      .ellipsis,
                                            ),
                                          ),
                                          onTap: () {
                                            _showDetails(
                                              food,
                                            );
                                          },
                                        ),
                                        DataCell(
                                          SizedBox(
                                            width:
                                                180,
                                            child:
                                                Text(
                                              food.category ??
                                                  '-',
                                              overflow:
                                                  TextOverflow
                                                      .ellipsis,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            food.nutrients
                                                        .energyKcal ==
                                                    null
                                                ? '-'
                                                : '${_formatNumber(food.nutrients.energyKcal)} kcal',
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            food.nutrients
                                                        .sodiumMg ==
                                                    null
                                                ? '-'
                                                : '${_formatNumber(food.nutrients.sodiumMg)} mg',
                                          ),
                                        ),
                                        DataCell(
                                          _SourceChip(
                                            sourceType:
                                                food.sourceType,
                                          ),
                                        ),
                                        DataCell(
                                          _StatusChip(
                                            food:
                                                food,
                                          ),
                                        ),
                                        DataCell(
                                          Row(
                                            mainAxisSize:
                                                MainAxisSize
                                                    .min,
                                            children: [
                                              IconButton(
                                                tooltip:
                                                    'Details',
                                                onPressed:
                                                    () {
                                                  _showDetails(
                                                    food,
                                                  );
                                                },
                                                icon:
                                                    const Icon(
                                                  Icons
                                                      .visibility_outlined,
                                                  size:
                                                      18,
                                                ),
                                              ),
                                              if (food
                                                  .editableByAdmin) ...[
                                                IconButton(
                                                  tooltip:
                                                      'Edit',
                                                  onPressed:
                                                      food.isActive
                                                          ? () {
                                                              _openFoodDialog(
                                                                existing: food,
                                                              );
                                                            }
                                                          : null,
                                                  icon:
                                                      const Icon(
                                                    Icons
                                                        .edit_outlined,
                                                    size:
                                                        18,
                                                  ),
                                                ),
                                                IconButton(
                                                  tooltip:
                                                      'Deactivate',
                                                  onPressed:
                                                      food.isActive
                                                          ? () {
                                                              _deactivateFood(
                                                                food,
                                                              );
                                                            }
                                                          : null,
                                                  color:
                                                      AppColors.danger,
                                                  icon:
                                                      const Icon(
                                                    Icons
                                                        .archive_outlined,
                                                    size:
                                                        18,
                                                  ),
                                                ),
                                              ],
                                            ],
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
                      const SizedBox(
                        height: 12,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Showing ${page.foods.length} '
                              'of ${page.total} foods',
                              style:
                                  Theme.of(context)
                                      .textTheme
                                      .bodySmall,
                            ),
                          ),
                          IconButton(
                            onPressed:
                                page.page > 1
                                    ? () {
                                        ref
                                            .read(
                                              foodListParamsProvider
                                                  .notifier,
                                            )
                                            .update(
                                              (state) =>
                                                  state
                                                      .copyWith(
                                                page:
                                                    state.page -
                                                        1,
                                              ),
                                            );
                                      }
                                    : null,
                            icon:
                                const Icon(
                              Icons
                                  .chevron_left,
                            ),
                          ),
                          Text(
                            'Page ${page.page} '
                            'of ${page.totalPages}',
                          ),
                          IconButton(
                            onPressed:
                                page.page <
                                        page.totalPages
                                    ? () {
                                        ref
                                            .read(
                                              foodListParamsProvider
                                                  .notifier,
                                            )
                                            .update(
                                              (state) =>
                                                  state
                                                      .copyWith(
                                                page:
                                                    state.page +
                                                        1,
                                              ),
                                            );
                                      }
                                    : null,
                            icon:
                                const Icon(
                              Icons
                                  .chevron_right,
                            ),
                          ),
                        ],
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

class _SourceChip
    extends StatelessWidget {
  const _SourceChip({
    required this.sourceType,
  });

  final String sourceType;

  @override
  Widget build(
    BuildContext context,
  ) {
    String label;
    Color color;

    switch (sourceType) {
      case 'foundation':
        label = 'USDA';
        color = AppColors.primary;
        break;

      case 'filipino':
        label = 'Filipino';
        color = AppColors.warning;
        break;

      case 'user_custom':
        label = 'User';
        color =
            AppColors.textSecondary;
        break;

      case 'admin':
        label = 'Admin';
        color = AppColors.success;
        break;

      default:
        label = 'Other';
        color =
            AppColors.textSecondary;
    }

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color:
            color.withValues(alpha: 0.1),
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight:
              FontWeight.w600,
        ),
      ),
    );
  }
}

class _StatusChip
    extends StatelessWidget {
  const _StatusChip({
    required this.food,
  });

  final AdminFood food;

  @override
  Widget build(
    BuildContext context,
  ) {
    if (food.sourceType !=
        'admin') {
      return const Text(
        'Reference',
        style: TextStyle(
          color:
              AppColors.textSecondary,
          fontSize: 12,
        ),
      );
    }

    final color =
        food.isActive
            ? AppColors.success
            : AppColors.danger;

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color:
            color.withValues(alpha: 0.1),
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Text(
        food.isActive
            ? 'Active'
            : 'Inactive',
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight:
              FontWeight.w600,
        ),
      ),
    );
  }
}

class _FoodFormDialog
    extends StatefulWidget {
  const _FoodFormDialog({
    this.existing,
  });

  final AdminFood? existing;

  @override
  State<_FoodFormDialog> createState() =>
      _FoodFormDialogState();
}

class _FoodFormDialogState
    extends State<_FoodFormDialog> {
  final _formKey =
      GlobalKey<FormState>();

  late final TextEditingController
      _nameController;

  late final TextEditingController
      _filipinoController;

  late final TextEditingController
      _categoryController;

  late final TextEditingController
      _energyController;

  late final TextEditingController
      _proteinController;

  late final TextEditingController
      _carbsController;

  late final TextEditingController
      _fatController;

  late final TextEditingController
      _sodiumController;

  late final TextEditingController
      _potassiumController;

  late final TextEditingController
      _cholesterolController;

  late final TextEditingController
      _fiberController;

  late final TextEditingController
      _sugarController;

  @override
  void initState() {
    super.initState();

    final food =
        widget.existing;

    _nameController =
        TextEditingController(
      text: food?.name ?? '',
    );

    _filipinoController =
        TextEditingController(
      text:
          food?.filipinoName ?? '',
    );

    _categoryController =
        TextEditingController(
      text:
          food?.category ?? '',
    );

    _energyController =
        TextEditingController(
      text: _numberText(
        food?.nutrients.energyKcal,
      ),
    );

    _proteinController =
        TextEditingController(
      text: _numberText(
        food?.nutrients.proteinG,
      ),
    );

    _carbsController =
        TextEditingController(
      text: _numberText(
        food?.nutrients
            .carbohydratesG,
      ),
    );

    _fatController =
        TextEditingController(
      text: _numberText(
        food?.nutrients.fatG,
      ),
    );

    _sodiumController =
        TextEditingController(
      text: _numberText(
        food?.nutrients.sodiumMg,
      ),
    );

    _potassiumController =
        TextEditingController(
      text: _numberText(
        food?.nutrients
            .potassiumMg,
      ),
    );

    _cholesterolController =
        TextEditingController(
      text: _numberText(
        food?.nutrients
            .cholesterolMg,
      ),
    );

    _fiberController =
        TextEditingController(
      text: _numberText(
        food?.nutrients.fiberG,
      ),
    );

    _sugarController =
        TextEditingController(
      text: _numberText(
        food?.nutrients.sugarG,
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _filipinoController.dispose();
    _categoryController.dispose();
    _energyController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _sodiumController.dispose();
    _potassiumController.dispose();
    _cholesterolController.dispose();
    _fiberController.dispose();
    _sugarController.dispose();

    super.dispose();
  }

  double? _parse(
    TextEditingController controller,
  ) {
    final text =
        controller.text.trim();

    if (text.isEmpty) {
      return null;
    }

    return double.tryParse(text);
  }

  String? _numberValidator(
    String? value, {
    required String field,
    required double max,
    required String unit,
    bool required = false,
  }) {
    return AdminInputValidation.boundedNumber(
      value,
      field: field,
      min: 0,
      max: max,
      required: required,
      unit: unit,
    );
  }

  void _submit() {
    if (!_formKey
        .currentState!
        .validate()) {
      return;
    }

    Navigator.of(context).pop(
      FoodDraft(
        name:
            _nameController.text
                .trim(),
        filipinoName:
            _emptyToNull(
          _filipinoController.text,
        ),
        category:
            _emptyToNull(
          _categoryController.text,
        ),
        nutrients:
            FoodNutrients(
          energyKcal:
              _parse(
            _energyController,
          ),
          proteinG:
              _parse(
            _proteinController,
          ),
          carbohydratesG:
              _parse(
            _carbsController,
          ),
          fatG:
              _parse(
            _fatController,
          ),
          sodiumMg:
              _parse(
            _sodiumController,
          ),
          potassiumMg:
              _parse(
            _potassiumController,
          ),
          cholesterolMg:
              _parse(
            _cholesterolController,
          ),
          fiberG:
              _parse(
            _fiberController,
          ),
          sugarG:
              _parse(
            _sugarController,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final editing =
        widget.existing != null;

    return AlertDialog(
      title: Text(
        editing
            ? 'Edit Food'
            : 'Add Food',
      ),
      content: SizedBox(
        width: 760,
        child:
            SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller:
                      _nameController,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Food name',
                  ),
                  inputFormatters:
                      AdminInputValidation.textFormatters(120),
                  validator: (value) =>
                      AdminInputValidation.requiredText(
                    value,
                    field: 'Food name',
                    minLength: 2,
                    maxLength: 120,
                  ),
                ),
                const SizedBox(
                  height: 12,
                ),
                Row(
                  children: [
                    Expanded(
                      child:
                          TextFormField(
                        controller:
                            _filipinoController,
                        inputFormatters:
                            AdminInputValidation.textFormatters(120),
                        decoration:
                            const InputDecoration(
                          labelText:
                              'Filipino name',
                        ),
                        validator: (value) =>
                            AdminInputValidation.optionalText(
                          value,
                          field: 'Filipino name',
                          minLength: 2,
                          maxLength: 120,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    Expanded(
                      child:
                          TextFormField(
                        controller:
                            _categoryController,
                        inputFormatters:
                            AdminInputValidation.textFormatters(60),
                        decoration:
                            const InputDecoration(
                          labelText:
                              'Category',
                        ),
                        validator: (value) =>
                            AdminInputValidation.optionalText(
                          value,
                          field: 'Category',
                          minLength: 2,
                          maxLength: 60,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  'Nutrients per serving',
                  style:
                      Theme.of(context)
                          .textTheme
                          .titleMedium,
                ),
                const SizedBox(
                  height: 12,
                ),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _NutrientField(
                      controller:
                          _energyController,
                      label: 'Energy',
                      unit: 'kcal',
                      validator:
                          (value) =>
                              _numberValidator(
                        value,
                        field: 'Energy',
                        max: 5000,
                        unit: 'kcal',
                        required: true,
                      ),
                    ),
                    _NutrientField(
                      controller:
                          _proteinController,
                      label: 'Protein',
                      unit: 'g',
                      validator:
                          (value) =>
                              _numberValidator(
                        value,
                        field: 'Protein',
                        max: 300,
                        unit: 'g',
                      ),
                    ),
                    _NutrientField(
                      controller:
                          _carbsController,
                      label:
                          'Carbohydrates',
                      unit: 'g',
                      validator:
                          (value) =>
                              _numberValidator(
                        value,
                        field: 'Carbohydrates',
                        max: 500,
                        unit: 'g',
                      ),
                    ),
                    _NutrientField(
                      controller:
                          _fatController,
                      label: 'Fat',
                      unit: 'g',
                      validator:
                          (value) =>
                              _numberValidator(
                        value,
                        field: 'Fat',
                        max: 300,
                        unit: 'g',
                      ),
                    ),
                    _NutrientField(
                      controller:
                          _sodiumController,
                      label: 'Sodium',
                      unit: 'mg',
                      validator:
                          (value) =>
                              _numberValidator(
                        value,
                        field: 'Sodium',
                        max: 10000,
                        unit: 'mg',
                      ),
                    ),
                    _NutrientField(
                      controller:
                          _potassiumController,
                      label:
                          'Potassium',
                      unit: 'mg',
                      validator:
                          (value) =>
                              _numberValidator(
                        value,
                        field: 'Potassium',
                        max: 10000,
                        unit: 'mg',
                      ),
                    ),
                    _NutrientField(
                      controller:
                          _cholesterolController,
                      label:
                          'Cholesterol',
                      unit: 'mg',
                      validator:
                          (value) =>
                              _numberValidator(
                        value,
                        field: 'Cholesterol',
                        max: 3000,
                        unit: 'mg',
                      ),
                    ),
                    _NutrientField(
                      controller:
                          _fiberController,
                      label: 'Fiber',
                      unit: 'g',
                      validator:
                          (value) =>
                              _numberValidator(
                        value,
                        field: 'Fiber',
                        max: 100,
                        unit: 'g',
                      ),
                    ),
                    _NutrientField(
                      controller:
                          _sugarController,
                      label: 'Sugar',
                      unit: 'g',
                      validator:
                          (value) =>
                              _numberValidator(
                        value,
                        field: 'Sugar',
                        max: 300,
                        unit: 'g',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context)
                .pop();
          },
          child:
              const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(
            editing
                ? 'Save Changes'
                : 'Add Food',
          ),
        ),
      ],
    );
  }
}

class _NutrientField
    extends StatelessWidget {
  const _NutrientField({
    required this.controller,
    required this.label,
    required this.unit,
    required this.validator,
  });

  final TextEditingController
      controller;

  final String label;
  final String unit;

  final FormFieldValidator<String>
      validator;

  @override
  Widget build(
    BuildContext context,
  ) {
    return SizedBox(
      width: 220,
      child: TextFormField(
        controller: controller,
        keyboardType:
            const TextInputType
                .numberWithOptions(
          decimal: true,
        ),
        inputFormatters:
            AdminInputValidation.decimalFormatters(
          maxIntegerDigits: 5,
          decimalPlaces: 2,
        ),
        decoration:
            InputDecoration(
          labelText: label,
          suffixText: unit,
        ),
        validator: validator,
      ),
    );
  }
}

class _BulkFoodDialog
    extends ConsumerStatefulWidget {
  const _BulkFoodDialog();

  @override
  ConsumerState<_BulkFoodDialog>
      createState() =>
          _BulkFoodDialogState();
}

class _BulkFoodDialogState
    extends ConsumerState<
        _BulkFoodDialog> {
  final _jsonController =
      TextEditingController();

  BulkValidationResponse?
      _validation;

  String? _errorMessage;

  bool _validating = false;
  bool _importing = false;

  static const exampleJson = '''
[
  {
    "name": "Example Admin Food",
    "category": "Test",
    "nutrientsPer100g": {
      "energyKcal": 120,
      "proteinG": 10,
      "carbohydratesG": 15,
      "fatG": 3,
      "sodiumMg": 200,
      "potassiumMg": 250
    }
  }
]
''';

  @override
  void dispose() {
    _jsonController.dispose();
    super.dispose();
  }

  dynamic _parseJson() {
    final value =
        _jsonController.text.trim();

    if (value.isEmpty) {
      throw const FormatException(
        'Paste JSON first.',
      );
    }

    return jsonDecode(value);
  }

  Future<void> _validate() async {
    dynamic payload;

    try {
      payload = _parseJson();
    } on FormatException catch (error) {
      setState(() {
        _errorMessage =
            error.message;
        _validation = null;
      });

      return;
    } catch (_) {
      setState(() {
        _errorMessage =
            'Invalid JSON.';
        _validation = null;
      });

      return;
    }

    setState(() {
      _validating = true;
      _errorMessage = null;
      _validation = null;
    });

    try {
      final result =
          await ref
              .read(
                foodActionsProvider
                    .notifier,
              )
              .validateBulk(
                payload,
              );

      if (!mounted) {
        return;
      }

      setState(() {
        _validation =
            result;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage =
            foodErrorMessage(
          error,
        );
      });
    } finally {
      if (mounted) {
        setState(() {
          _validating =
              false;
        });
      }
    }
  }

  Future<void> _import() async {
    if (_validation == null ||
        _validation!.valid == 0) {
      return;
    }

    dynamic payload;

    try {
      payload = _parseJson();
    } catch (_) {
      setState(() {
        _errorMessage =
            'JSON is invalid. Validate again.';
      });

      return;
    }

    setState(() {
      _importing = true;
      _errorMessage = null;
    });

    try {
      final result =
          await ref
              .read(
                foodActionsProvider
                    .notifier,
              )
              .importBulk(
                payload,
              );

      if (!mounted) {
        return;
      }

      Navigator.of(context)
          .pop(result);
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage =
            foodErrorMessage(
          error,
        );
      });
    } finally {
      if (mounted) {
        setState(() {
          _importing =
              false;
        });
      }
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return AlertDialog(
      title:
          const Text('Bulk JSON Import'),
      content: SizedBox(
        width: 850,
        height: 600,
        child: Column(
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Paste a JSON array, validate it, then import valid foods.',
                  ),
                ),
                TextButton(
                  onPressed: () {
                    _jsonController
                            .text =
                        exampleJson;

                    setState(() {
                      _validation =
                          null;
                      _errorMessage =
                          null;
                    });
                  },
                  child: const Text(
                    'Load Example',
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              flex: 3,
              child: TextField(
                controller:
                    _jsonController,
                expands: true,
                maxLines: null,
                minLines: null,
                style:
                    const TextStyle(
                  fontFamily:
                      'monospace',
                ),
                decoration:
                    const InputDecoration(
                  hintText:
                      'Paste JSON here...',
                ),
                onChanged: (_) {
                  if (_validation !=
                          null ||
                      _errorMessage !=
                          null) {
                    setState(() {
                      _validation =
                          null;
                      _errorMessage =
                          null;
                    });
                  }
                },
              ),
            ),
            if (_errorMessage !=
                null) ...[
              const SizedBox(
                height: 10,
              ),
              Container(
                width:
                    double.infinity,
                padding:
                    const EdgeInsets.all(
                  10,
                ),
                color: AppColors.danger
                    .withOpacity(
                  0.08,
                ),
                child: Text(
                  _errorMessage!,
                  style:
                      const TextStyle(
                    color:
                        AppColors.danger,
                  ),
                ),
              ),
            ],
            if (_validation !=
                null) ...[
              const SizedBox(
                height: 12,
              ),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      '${_validation!.total} total • '
                      '${_validation!.valid} valid • '
                      '${_validation!.invalid} invalid • '
                      '${_validation!.warnings} warnings',
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Expanded(
                      child:
                          ListView.builder(
                        itemCount:
                            _validation!
                                .items
                                .length,
                        itemBuilder:
                            (
                          context,
                          index,
                        ) {
                          final item =
                              _validation!
                                  .items[
                                      index];

                          return ListTile(
                            dense: true,
                            leading:
                                Icon(
                              item.valid
                                  ? Icons
                                      .check_circle_outline
                                  : Icons
                                      .error_outline,
                              color:
                                  item.valid
                                      ? AppColors
                                          .success
                                      : AppColors
                                          .danger,
                            ),
                            title: Text(
                              item.name ??
                                  'Row ${item.index + 1}',
                            ),
                            subtitle:
                                item.errors
                                        .isNotEmpty
                                    ? Text(
                                        item.errors.join(
                                          ' • ',
                                        ),
                                      )
                                    : item.warnings
                                            .isNotEmpty
                                        ? Text(
                                            item.warnings.join(
                                              ' • ',
                                            ),
                                          )
                                        : null,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed:
              _validating ||
                      _importing
                  ? null
                  : () {
                      Navigator.of(context)
                          .pop();
                    },
          child:
              const Text('Cancel'),
        ),
        OutlinedButton(
          onPressed:
              _validating ||
                      _importing
                  ? null
                  : _validate,
          child: Text(
            _validating
                ? 'Validating...'
                : 'Validate',
          ),
        ),
        FilledButton(
          onPressed:
              _validation != null &&
                      _validation!
                              .valid >
                          0 &&
                      !_validating &&
                      !_importing
                  ? _import
                  : null,
          child: Text(
            _importing
                ? 'Importing...'
                : _validation ==
                        null
                    ? 'Import'
                    : 'Import ${_validation!.valid}',
          ),
        ),
      ],
    );
  }
}

class _FoodDetailsDialog
    extends StatelessWidget {
  const _FoodDetailsDialog({
    required this.food,
  });

  final AdminFood food;

  @override
  Widget build(
    BuildContext context,
  ) {
    return AlertDialog(
      title: Text(
        food.name,
      ),
      content: SizedBox(
        width: 520,
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            _DetailRow(
              label: 'Filipino name',
              value:
                  food.filipinoName ??
                      '-',
            ),
            _DetailRow(
              label: 'Category',
              value:
                  food.category ?? '-',
            ),
            _DetailRow(
              label: 'Provider',
              value:
                  food.provider ?? '-',
            ),
            _DetailRow(
              label: 'Dataset',
              value:
                  food.dataset ?? '-',
            ),
            _DetailRow(
              label: 'FDC ID',
              value:
                  food.fdcId
                          ?.toString() ??
                      '-',
            ),
            const Divider(),
            _DetailRow(
              label: 'Energy',
              value:
                  _withUnit(
                food.nutrients
                    .energyKcal,
                'kcal',
              ),
            ),
            _DetailRow(
              label: 'Protein',
              value:
                  _withUnit(
                food.nutrients
                    .proteinG,
                'g',
              ),
            ),
            _DetailRow(
              label:
                  'Carbohydrates',
              value:
                  _withUnit(
                food.nutrients
                    .carbohydratesG,
                'g',
              ),
            ),
            _DetailRow(
              label: 'Fat',
              value:
                  _withUnit(
                food.nutrients.fatG,
                'g',
              ),
            ),
            _DetailRow(
              label: 'Sodium',
              value:
                  _withUnit(
                food.nutrients
                    .sodiumMg,
                'mg',
              ),
            ),
            _DetailRow(
              label: 'Potassium',
              value:
                  _withUnit(
                food.nutrients
                    .potassiumMg,
                'mg',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context)
                .pop();
          },
          child:
              const Text('Close'),
        ),
      ],
    );
  }
}

class _DetailRow
    extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 5,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 145,
            child: Text(
              label,
              style:
                  Theme.of(context)
                      .textTheme
                      .bodySmall,
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}

String? _emptyToNull(
  String value,
) {
  final cleaned =
      value.trim();

  if (cleaned.isEmpty) {
    return null;
  }

  return cleaned;
}

String _numberText(
  double? value,
) {
  if (value == null) {
    return '';
  }

  return _formatNumber(value);
}

String _formatNumber(
  double? value,
) {
  if (value == null) {
    return '-';
  }

  if (value ==
      value.roundToDouble()) {
    return value
        .toInt()
        .toString();
  }

  return value.toStringAsFixed(2);
}

String _withUnit(
  double? value,
  String unit,
) {
  if (value == null) {
    return '-';
  }

  return '${_formatNumber(value)} $unit';
}
