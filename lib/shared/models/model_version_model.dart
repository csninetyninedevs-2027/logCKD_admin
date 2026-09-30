class ModelVersionModel {
  const ModelVersionModel({
    required this.version,
    required this.name,
    required this.algorithm,
    required this.modelRole,
    required this.status,
    required this.trainingRunId,
    required this.modelSpecificationVersion,
    required this.trainingConfigVersion,
    required this.preprocessingVersion,
    required this.datasetKey,
    required this.datasetVersion,
    required this.features,
    required this.target,
    required this.affectsRiskScore,
    required this.finalTestMetrics,
    required this.recordCounts,
    required this.softwareVersions,
    required this.raw,
    this.id,
    this.decisionThreshold,
    this.comparisonMetrics,
    this.artifactPath,
    this.metricsPath,
    this.validationPredictionsPath,
    this.testPredictionsPath,
    this.featureImportancePath,
    this.artifactSha256,
    this.artifactSizeBytes,
    this.randomState,
    this.activatedAt,
    this.archivedAt,
    this.createdAt,
    this.updatedAt,
    this.notes,
  });

  final String? id;

  final String version;
  final String name;

  final String algorithm;
  final String modelRole;
  final String status;

  final String trainingRunId;

  final int modelSpecificationVersion;
  final int trainingConfigVersion;

  final String preprocessingVersion;

  final String datasetKey;
  final String datasetVersion;

  final List<String> features;
  final String target;

  final double? decisionThreshold;
  final bool affectsRiskScore;

  final Map<String, dynamic> finalTestMetrics;
  final dynamic comparisonMetrics;

  final String? artifactPath;
  final String? metricsPath;
  final String? validationPredictionsPath;
  final String? testPredictionsPath;
  final String? featureImportancePath;

  final String? artifactSha256;
  final int? artifactSizeBytes;

  final int? randomState;

  final Map<String, dynamic> recordCounts;
  final Map<String, dynamic> softwareVersions;

  final DateTime? activatedAt;
  final DateTime? archivedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  final String? notes;

  final Map<String, dynamic> raw;

  bool get isCandidate =>
      status == 'CANDIDATE';

  bool get isActive =>
      status == 'ACTIVE';

  bool get isInactive =>
      status == 'INACTIVE';

  bool get isArchived =>
      status == 'ARCHIVED';

  bool get canActivate =>
      isCandidate || isInactive;

  static Map<String, dynamic> _map(
    dynamic value,
  ) {
    if (value is Map<String, dynamic>) {
      return Map<String, dynamic>.from(
        value,
      );
    }

    if (value is Map) {
      return value.map(
        (key, value) => MapEntry(
          key.toString(),
          value,
        ),
      );
    }

    return <String, dynamic>{};
  }

  static List<String> _strings(
    dynamic value,
  ) {
    if (value is! List) {
      return const [];
    }

    return value
        .map(
          (item) => item.toString(),
        )
        .toList(
          growable: false,
        );
  }

  static int _integer(
    dynamic value, [
    int fallback = 0,
  ]) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        fallback;
  }

  static double? _double(
    dynamic value,
  ) {
    if (value == null) {
      return null;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
      value.toString(),
    );
  }

  static bool _boolean(
    dynamic value,
  ) {
    if (value is bool) {
      return value;
    }

    if (value is num) {
      return value != 0;
    }

    final normalized =
        value
            ?.toString()
            .trim()
            .toLowerCase();

    return normalized == 'true' ||
        normalized == '1' ||
        normalized == 'yes';
  }

  static DateTime? _date(
    dynamic value,
  ) {
    if (value == null ||
        value.toString().trim().isEmpty) {
      return null;
    }

    return DateTime.tryParse(
      value.toString(),
    );
  }

  factory ModelVersionModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ModelVersionModel(
      id: (json['id'] ??
              json['_id'])
          ?.toString(),
      version:
          (json['version'] ?? '')
              .toString(),
      name:
          (json['name'] ?? '')
              .toString(),
      algorithm:
          (json['algorithm'] ?? '')
              .toString()
              .toLowerCase(),
      modelRole:
          (json['modelRole'] ??
                  json['model_role'] ??
                  '')
              .toString(),
      status:
          (json['status'] ?? '')
              .toString()
              .toUpperCase(),
      trainingRunId:
          (json['trainingRunId'] ??
                  json['training_run_id'] ??
                  '')
              .toString(),
      modelSpecificationVersion:
          _integer(
        json['modelSpecificationVersion'] ??
            json[
                'model_specification_version'],
      ),
      trainingConfigVersion:
          _integer(
        json['trainingConfigVersion'] ??
            json[
                'training_config_version'],
      ),
      preprocessingVersion:
          (json['preprocessingVersion'] ??
                  json[
                      'preprocessing_version'] ??
                  '')
              .toString(),
      datasetKey:
          (json['datasetKey'] ??
                  json['dataset_key'] ??
                  '')
              .toString(),
      datasetVersion:
          (json['datasetVersion'] ??
                  json['dataset_version'] ??
                  '')
              .toString(),
      features:
          _strings(
        json['features'],
      ),
      target:
          (json['target'] ?? '')
              .toString(),
      decisionThreshold:
          _double(
        json['decisionThreshold'] ??
            json['decision_threshold'],
      ),
      affectsRiskScore:
          _boolean(
        json['affectsRiskScore'] ??
            json['affects_risk_score'],
      ),
      finalTestMetrics:
          _map(
        json['finalTestMetrics'] ??
            json['final_test_metrics'],
      ),
      comparisonMetrics:
          json['comparisonMetrics'] ??
              json['comparison_metrics'],
      artifactPath:
          (json['artifactPath'] ??
                  json['artifact_path'])
              ?.toString(),
      metricsPath:
          (json['metricsPath'] ??
                  json['metrics_path'])
              ?.toString(),
      validationPredictionsPath:
          (json[
                      'validationPredictionsPath'] ??
                  json[
                      'validation_predictions_path'])
              ?.toString(),
      testPredictionsPath:
          (json['testPredictionsPath'] ??
                  json[
                      'test_predictions_path'])
              ?.toString(),
      featureImportancePath:
          (json['featureImportancePath'] ??
                  json[
                      'feature_importance_path'])
              ?.toString(),
      artifactSha256:
          (json['artifactSha256'] ??
                  json['artifact_sha256'])
              ?.toString(),
      artifactSizeBytes:
          (json['artifactSizeBytes'] ??
                      json[
                          'artifact_size_bytes']) ==
                  null
              ? null
              : _integer(
                  json['artifactSizeBytes'] ??
                      json[
                          'artifact_size_bytes'],
                ),
      randomState:
          (json['randomState'] ??
                      json['random_state']) ==
                  null
              ? null
              : _integer(
                  json['randomState'] ??
                      json['random_state'],
                ),
      recordCounts:
          _map(
        json['recordCounts'] ??
            json['record_counts'],
      ),
      softwareVersions:
          _map(
        json['softwareVersions'] ??
            json['software_versions'],
      ),
      activatedAt:
          _date(
        json['activatedAt'] ??
            json['activated_at'],
      ),
      archivedAt:
          _date(
        json['archivedAt'] ??
            json['archived_at'],
      ),
      createdAt:
          _date(
        json['createdAt'] ??
            json['created_at'],
      ),
      updatedAt:
          _date(
        json['updatedAt'] ??
            json['updated_at'],
      ),
      notes:
          json['notes']?.toString(),
      raw:
          Map<String, dynamic>.from(
        json,
      ),
    );
  }
}

class ModelRegistryListResult {
  const ModelRegistryListResult({
    required this.items,
    required this.raw,
  });

  final List<ModelVersionModel> items;
  final Map<String, dynamic> raw;

  factory ModelRegistryListResult.fromJson(
    dynamic value,
  ) {
    final root =
        value is Map
            ? Map<String, dynamic>.from(
                value,
              )
            : <String, dynamic>{};

    dynamic payload =
        root['data'] ?? root;

    List<dynamic> values =
        const [];

    if (payload is List) {
      values = payload;
    } else if (payload is Map) {
      final map =
          Map<String, dynamic>.from(
            payload,
          );

      final nested =
          map['models'] ??
          map['versions'] ??
          map['items'] ??
          map['data'];

      if (nested is List) {
        values = nested;
      }
    }

    return ModelRegistryListResult(
      items: values
          .whereType<Map>()
          .map(
            (item) =>
                ModelVersionModel.fromJson(
              Map<String, dynamic>.from(
                item,
              ),
            ),
          )
          .toList(
            growable: false,
          ),
      raw: root,
    );
  }
}