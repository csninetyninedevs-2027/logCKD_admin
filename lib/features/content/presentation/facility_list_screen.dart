import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/models/facility.dart';
import '../../../shared/utils/admin_input_validation.dart';
import '../../../shared/widgets/admin_responsive.dart';
import '../state/facility_provider.dart';

class FacilityListScreen extends ConsumerStatefulWidget {
  const FacilityListScreen({super.key});

  @override
  ConsumerState<FacilityListScreen> createState() => _FacilityListScreenState();
}

class _FacilityListScreenState extends ConsumerState<FacilityListScreen> {
  final _searchController = TextEditingController();
  final _tableScrollController = ScrollController();

  @override
  void dispose() {
    _searchController.dispose();
    _tableScrollController.dispose();
    super.dispose();
  }

  void _onSearchSubmitted(String value) {
    ref.read(facilityListParamsProvider.notifier).update(
          (state) => state.copyWith(search: value.trim(), page: 1),
        );
  }

  Future<void> _openFacilityDialog({AdminFacility? existing}) async {
    final result = await showDialog<AdminFacility>(
      context: context,
      builder: (context) => _FacilityFormDialog(existing: existing),
    );

    if (result == null) return;
    if (!mounted) return;

    final notifier = ref.read(facilityActionsProvider.notifier);
    final success = existing == null
        ? await notifier.create(result)
        : await notifier.update(existing.facilityNumber, result);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? (existing == null ? 'Facility created' : 'Facility updated')
              : 'Action failed. Facility number may already be in use.',
        ),
      ),
    );
  }

  Future<void> _confirmDelete(AdminFacility facility) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete facility?'),
        content: Text('This permanently removes "${facility.name}". This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!mounted) return;

    final success =
        await ref.read(facilityActionsProvider.notifier).delete(facility.facilityNumber);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? 'Facility deleted' : 'Delete failed')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final facilitiesAsync = ref.watch(facilityListProvider);
    final params = ref.watch(facilityListParamsProvider);

    return Padding(
        padding: AdminResponsive.pageInsets(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AdminResponsiveHeader(
              heading: Text(
                'Facilities',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              actions: [
                SizedBox(
                  width: AdminResponsive.actionWidth(context, maxWidth: 280),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search by name',
                      prefixIcon: Icon(Icons.search, size: 20),
                    ),
                    onSubmitted: _onSearchSubmitted,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _openFacilityDialog(),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Facility'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: facilitiesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(child: Text('Failed to load facilities: $error')),
                data: (page) {
                  if (page.facilities.isEmpty) {
                    return const Center(child: Text('No facilities found'));
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Card(
                            clipBehavior: Clip.antiAlias,
                            child: Scrollbar(
                              controller: _tableScrollController,
                              thumbVisibility: true,
                              scrollbarOrientation: ScrollbarOrientation.bottom,
                              child: LayoutBuilder(
                                builder: (context, constraints) =>
                                    SingleChildScrollView(
                                  controller: _tableScrollController,
                                  scrollDirection: Axis.horizontal,
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      minWidth: constraints.maxWidth,
                                    ),
                                    child: DataTable(
                                      columns: const [
                                        DataColumn(label: Text('#')),
                                        DataColumn(label: Text('Name')),
                                        DataColumn(label: Text('Province')),
                                        DataColumn(label: Text('City/Municipality')),
                                        DataColumn(label: Text('Mapped')),
                                        DataColumn(label: Text('Actions')),
                                      ],
                                      rows: [
                                        for (final facility in page.facilities)
                                          DataRow(cells: [
                                            DataCell(Text(facility.facilityNumber.toString())),
                                            DataCell(Text(facility.name)),
                                            DataCell(Text(facility.province ?? '-')),
                                            DataCell(Text(facility.cityMunicipality ?? '-')),
                                            DataCell(
                                              Icon(
                                                facility.latitude != null
                                                    ? Icons.check_circle
                                                    : Icons.remove_circle_outline,
                                                size: 18,
                                                color: facility.latitude != null
                                                    ? AppColors.success
                                                    : AppColors.textSecondary,
                                              ),
                                            ),
                                            DataCell(Row(
                                              children: [
                                                IconButton(
                                                  icon: const Icon(Icons.edit_outlined, size: 18),
                                                  onPressed: () => _openFacilityDialog(
                                                    existing: facility,
                                                  ),
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.delete_outline, size: 18),
                                                  color: AppColors.danger,
                                                  onPressed: () => _confirmDelete(facility),
                                                ),
                                              ],
                                            )),
                                          ]),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          Text(
                            'Showing ${page.facilities.length} of ${page.total} facilities',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.chevron_left),
                                onPressed: params.page > 1
                                    ? () => ref
                                        .read(facilityListParamsProvider.notifier)
                                        .update((s) => s.copyWith(page: s.page - 1))
                                    : null,
                              ),
                              Text('Page ${page.page}'),
                              IconButton(
                                icon: const Icon(Icons.chevron_right),
                                onPressed: page.page * page.limit < page.total
                                    ? () => ref
                                        .read(facilityListParamsProvider.notifier)
                                        .update((s) => s.copyWith(page: s.page + 1))
                                    : null,
                              ),
                            ],
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

class _FacilityFormDialog extends StatefulWidget {
  const _FacilityFormDialog({this.existing});
  final AdminFacility? existing;

  @override
  State<_FacilityFormDialog> createState() => _FacilityFormDialogState();
}

class _FacilityFormDialogState extends State<_FacilityFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _facilityNumberController;
  late final TextEditingController _nameController;
  late final TextEditingController _regionController;
  late final TextEditingController _provinceController;
  late final TextEditingController _cityController;
  late final TextEditingController _latController;
  late final TextEditingController _lngController;

  @override
  void initState() {
    super.initState();
    final f = widget.existing;
    _facilityNumberController =
        TextEditingController(text: f?.facilityNumber.toString() ?? '');
    _nameController = TextEditingController(text: f?.name ?? '');
    _regionController = TextEditingController(text: f?.region ?? '');
    _provinceController = TextEditingController(text: f?.province ?? '');
    _cityController = TextEditingController(text: f?.cityMunicipality ?? '');
    _latController = TextEditingController(text: f?.latitude?.toString() ?? '');
    _lngController = TextEditingController(text: f?.longitude?.toString() ?? '');
  }

  @override
  void dispose() {
    _facilityNumberController.dispose();
    _nameController.dispose();
    _regionController.dispose();
    _provinceController.dispose();
    _cityController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.of(context).pop(
      AdminFacility(
        facilityNumber: int.parse(_facilityNumberController.text.trim()),
        name: _nameController.text.trim(),
        region: _regionController.text.trim().isEmpty ? null : _regionController.text.trim(),
        province:
            _provinceController.text.trim().isEmpty ? null : _provinceController.text.trim(),
        cityMunicipality:
            _cityController.text.trim().isEmpty ? null : _cityController.text.trim(),
        latitude: double.tryParse(_latController.text.trim()),
        longitude: double.tryParse(_lngController.text.trim()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Facility' : 'Add Facility'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _facilityNumberController,
                  enabled: !isEditing,
                  keyboardType: TextInputType.number,
                  inputFormatters: AdminInputValidation.integerFormatters(maxDigits: 9),
                  decoration: const InputDecoration(
                    labelText: 'Facility Number',
                    helperText: 'Whole number · 1–999,999,999',
                  ),
                  validator: (value) => AdminInputValidation.boundedInteger(
                    value,
                    field: 'Facility number',
                    min: 1,
                    max: 999999999,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nameController,
                  inputFormatters: AdminInputValidation.textFormatters(150),
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) => AdminInputValidation.requiredText(
                    value,
                    field: 'Name',
                    minLength: 2,
                    maxLength: 150,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _regionController,
                  inputFormatters: AdminInputValidation.textFormatters(100),
                  decoration: const InputDecoration(labelText: 'Region (optional)'),
                  validator: (value) => AdminInputValidation.optionalText(
                    value,
                    field: 'Region',
                    minLength: 2,
                    maxLength: 100,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _provinceController,
                  inputFormatters: AdminInputValidation.textFormatters(100),
                  decoration: const InputDecoration(labelText: 'Province (optional)'),
                  validator: (value) => AdminInputValidation.optionalText(
                    value,
                    field: 'Province',
                    minLength: 2,
                    maxLength: 100,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _cityController,
                  inputFormatters: AdminInputValidation.textFormatters(100),
                  decoration: const InputDecoration(labelText: 'City/Municipality (optional)'),
                  validator: (value) => AdminInputValidation.optionalText(
                    value,
                    field: 'City/Municipality',
                    minLength: 2,
                    maxLength: 100,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _latController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                        inputFormatters: AdminInputValidation.decimalFormatters(
                          maxIntegerDigits: 2,
                          decimalPlaces: 6,
                          allowNegative: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Latitude (optional)',
                          helperText: '-90 to 90',
                        ),
                        validator: (value) => AdminInputValidation.coordinate(
                          value,
                          field: 'Latitude',
                          min: -90,
                          max: 90,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _lngController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                        inputFormatters: AdminInputValidation.decimalFormatters(
                          maxIntegerDigits: 3,
                          decimalPlaces: 6,
                          allowNegative: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Longitude (optional)',
                          helperText: '-180 to 180',
                        ),
                        validator: (value) => AdminInputValidation.coordinate(
                          value,
                          field: 'Longitude',
                          min: -180,
                          max: 180,
                        ),
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
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(isEditing ? 'Save' : 'Create'),
        ),
      ],
    );
  }
}
