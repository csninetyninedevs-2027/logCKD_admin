class TrainingDatasetModel {
  const TrainingDatasetModel({
    required this.id,
    required this.datasetKey,
    required this.name,
    required this.version,
    required this.status,
    required this.datasetRole,
    required this.source,
    required this.fileFormat,
    required this.recordCount,
    required this.features,
    required this.target,
    required this.intendedUses,
    required this.preprocessingVersion,
    required this.artifactSha256,
    required this.artifactSizeBytes,
    required this.notes,
    required this.activatedAt,
    required this.archivedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.raw,
  });

  final String id;
  final String datasetKey;
  final String name;
  final String version;
  final String status;
  final String datasetRole;

  final Map<String, dynamic> source;

  final String fileFormat;
  final int? recordCount;

  final List<String> features;
  final String target;
  final List<String> intendedUses;

  final String preprocessingVersion;

  final String? artifactSha256;
  final int? artifactSizeBytes;
  final String? notes;

  final DateTime? activatedAt;
  final DateTime? archivedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  final Map<String, dynamic> raw;

  bool get isActive =>
      status.toUpperCase() == 'ACTIVE';

  bool get isInactive =>
      status.toUpperCase() == 'INACTIVE';

  bool get isArchived =>
      status.toUpperCase() == 'ARCHIVED';

  factory TrainingDatasetModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return TrainingDatasetModel(
      id: _string(
        json['id'] ?? json['_id'],
      ),
      datasetKey: _string(
        json['datasetKey'],
      ),
      name: _string(
        json['name'],
      ),
      version: _string(
        json['version'],
      ),
      status: _string(
        json['status'],
      ),
      datasetRole: _string(
        json['datasetRole'],
      ),
      source: _map(
        json['source'],
      ),
      fileFormat: _string(
        json['fileFormat'],
      ),
      recordCount: _integer(
        json['recordCount'],
      ),
      features: _strings(
        json['features'],
      ),
      target: _string(
        json['target'],
      ),
      intendedUses: _strings(
        json['intendedUses'],
      ),
      preprocessingVersion: _string(
        json['preprocessingVersion'],
      ),
      artifactSha256: _nullableString(
        json['artifactSha256'],
      ),
      artifactSizeBytes: _integer(
        json['artifactSizeBytes'],
      ),
      notes: _nullableString(
        json['notes'],
      ),
      activatedAt: _date(
        json['activatedAt'],
      ),
      archivedAt: _date(
        json['archivedAt'],
      ),
      createdAt: _date(
        json['createdAt'],
      ),
      updatedAt: _date(
        json['updatedAt'],
      ),
      raw: Map<String, dynamic>.from(
        json,
      ),
    );
  }
}

class TrainingDatasetListResult {
  const TrainingDatasetListResult({
    required this.items,
  });

  final List<TrainingDatasetModel> items;

  factory TrainingDatasetListResult.fromJson(
    dynamic value,
  ) {
    dynamic source = value;

    if (source is Map) {
      source =
          source['data'] ??
          source['items'] ??
          source['datasets'] ??
          source;
    }

    if (source is Map) {
      source =
          source['items'] ??
          source['datasets'] ??
          source['data'];
    }

    if (source is! List) {
      return const TrainingDatasetListResult(
        items: [],
      );
    }

    return TrainingDatasetListResult(
      items: source
          .whereType<Map>()
          .map(
            (item) =>
                TrainingDatasetModel.fromJson(
              Map<String, dynamic>.from(
                item,
              ),
            ),
          )
          .toList(),
    );
  }
}

class TrainingDatasetValidationSummary {
  const TrainingDatasetValidationSummary({
    required this.totalRows,
    required this.validRows,
    required this.invalidRows,
  });

  final int totalRows;
  final int validRows;
  final int invalidRows;

  factory TrainingDatasetValidationSummary.fromJson(
    dynamic value,
  ) {
    final json = _map(value);

    return TrainingDatasetValidationSummary(
      totalRows:
          _integer(json['totalRows']) ?? 0,
      validRows:
          _integer(json['validRows']) ?? 0,
      invalidRows:
          _integer(json['invalidRows']) ?? 0,
    );
  }
}

class TrainingDatasetRowError {
  const TrainingDatasetRowError({
    required this.rowNumber,
    required this.errors,
  });

  final int? rowNumber;
  final List<TrainingDatasetFieldError> errors;

  factory TrainingDatasetRowError.fromJson(
    dynamic value,
  ) {
    final json = _map(value);

    final rawErrors =
        json['errors'] is List
            ? json['errors'] as List
            : const [];

    return TrainingDatasetRowError(
      rowNumber: _integer(
        json['rowNumber'],
      ),
      errors: rawErrors
          .map(
            TrainingDatasetFieldError.fromJson,
          )
          .toList(),
    );
  }
}

class TrainingDatasetFieldError {
  const TrainingDatasetFieldError({
    required this.field,
    required this.message,
    required this.errorType,
    required this.value,
  });

  final String field;
  final String message;
  final String errorType;
  final dynamic value;

  factory TrainingDatasetFieldError.fromJson(
    dynamic value,
  ) {
    final json = _map(value);

    return TrainingDatasetFieldError(
      field: _string(
        json['field'],
      ),
      message: _string(
        json['message'],
      ),
      errorType: _string(
        json['errorType'],
      ),
      value: json['value'],
    );
  }
}

class TrainingDatasetValidationResult {
  const TrainingDatasetValidationResult({
    required this.valid,
    required this.summary,
    required this.modelColumns,
    required this.auxiliaryColumns,
    required this.datasetErrors,
    required this.rowErrors,
    required this.raw,
  });

  final bool valid;
  final TrainingDatasetValidationSummary summary;

  final List<String> modelColumns;
  final List<String> auxiliaryColumns;
  final List<String> datasetErrors;

  final List<TrainingDatasetRowError> rowErrors;

  final Map<String, dynamic> raw;

  factory TrainingDatasetValidationResult.fromJson(
    dynamic value,
  ) {
    final json = _map(value);

    final rawDatasetErrors =
        json['datasetErrors'] is List
            ? json['datasetErrors'] as List
            : const [];

    final rawRowErrors =
        json['rowErrors'] is List
            ? json['rowErrors'] as List
            : const [];

    return TrainingDatasetValidationResult(
      valid: json['valid'] == true,
      summary:
          TrainingDatasetValidationSummary.fromJson(
        json['summary'],
      ),
      modelColumns: _strings(
        json['modelColumns'] ??
            json['columns'],
      ),
      auxiliaryColumns: _strings(
        json['auxiliaryColumns'],
      ),
      datasetErrors: rawDatasetErrors
          .map((item) {
            if (item is Map) {
              final mapped =
                  Map<String, dynamic>.from(
                item,
              );

              return _string(
                mapped['message'] ?? item,
              );
            }

            return item.toString();
          })
          .toList(),
      rowErrors: rawRowErrors
          .map(
            TrainingDatasetRowError.fromJson,
          )
          .toList(),
      raw: json,
    );
  }
}

class TrainingDatasetStagingInfo {
  const TrainingDatasetStagingInfo({
    required this.token,
    required this.storedName,
    required this.originalName,
    required this.fileFormat,
    required this.sizeBytes,
    required this.artifactSha256,
  });

  final String token;
  final String storedName;
  final String originalName;
  final String fileFormat;
  final int sizeBytes;
  final String artifactSha256;

  factory TrainingDatasetStagingInfo.fromJson(
    dynamic value,
  ) {
    final json = _map(value);

    return TrainingDatasetStagingInfo(
      token: _string(
        json['token'],
      ),
      storedName: _string(
        json['storedName'],
      ),
      originalName: _string(
        json['originalName'],
      ),
      fileFormat: _string(
        json['fileFormat'],
      ),
      sizeBytes:
          _integer(json['sizeBytes']) ?? 0,
      artifactSha256: _string(
        json['artifactSha256'],
      ),
    );
  }
}

class TrainingDatasetUploadResult {
  const TrainingDatasetUploadResult({
    required this.valid,
    required this.staging,
    required this.validation,
  });

  final bool valid;
  final TrainingDatasetStagingInfo? staging;
  final TrainingDatasetValidationResult validation;

  bool get canConfirm =>
      valid &&
      staging != null &&
      staging!.token.isNotEmpty &&
      staging!.storedName.isNotEmpty;

  factory TrainingDatasetUploadResult.fromJson(
    dynamic value,
  ) {
    final root = _map(value);
    final data = _map(
      root['data'] ?? root,
    );

    final stagingJson = _map(
      data['staging'],
    );

    return TrainingDatasetUploadResult(
      valid: data['valid'] == true,
      staging: stagingJson.isEmpty
          ? null
          : TrainingDatasetStagingInfo
              .fromJson(
              stagingJson,
            ),
      validation:
          TrainingDatasetValidationResult
              .fromJson(
        data['validation'],
      ),
    );
  }
}

Map<String, dynamic> _map(
  dynamic value,
) {
  if (value is Map<String, dynamic>) {
    return value;
  }

  if (value is Map) {
    return Map<String, dynamic>.from(
      value,
    );
  }

  return <String, dynamic>{};
}

String _string(
  dynamic value,
) {
  if (value == null) {
    return '';
  }

  return value.toString().trim();
}

String? _nullableString(
  dynamic value,
) {
  final result = _string(value);

  return result.isEmpty ? null : result;
}

int? _integer(
  dynamic value,
) {
  if (value is int) {
    return value;
  }

  if (value is num) {
    return value.toInt();
  }

  return int.tryParse(
    value?.toString() ?? '',
  );
}

List<String> _strings(
  dynamic value,
) {
  if (value is! List) {
    return const [];
  }

  return value
      .map(_string)
      .where(
        (item) => item.isNotEmpty,
      )
      .toList();
}

DateTime? _date(
  dynamic value,
) {
  if (value == null) {
    return null;
  }

  return DateTime.tryParse(
    value.toString(),
  );
}