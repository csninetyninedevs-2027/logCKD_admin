class TrainingRunModel {
  const TrainingRunModel({
    required this.id,
    required this.runId,
    required this.algorithm,
    required this.modelRole,
    required this.status,
    required this.modelSpecificationVersion,
    required this.trainingConfigVersion,
    required this.preprocessingVersion,
    required this.datasetKey,
    required this.datasetVersion,
    required this.recordCounts,
    required this.classDistribution,
    required this.splitFractions,
    required this.randomState,
    required this.finalTestMetrics,
    required this.thresholdSearch,
    required this.softwareVersions,
    required this.raw,
    this.decisionThreshold,
    this.comparisonMetrics,
    this.modelArtifactPath,
    this.metricsArtifactPath,
    this.validationPredictionsPath,
    this.testPredictionsPath,
    this.featureImportancePath,
    this.modelArtifactSha256,
    this.modelArtifactSizeBytes,
    this.startedAt,
    this.completedAt,
    this.errorMessage,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String runId;

  final String algorithm;
  final String modelRole;
  final String status;

  final int modelSpecificationVersion;
  final int trainingConfigVersion;
  final String preprocessingVersion;

  final String datasetKey;
  final String datasetVersion;

  final Map<String, dynamic> recordCounts;
  final Map<String, dynamic> classDistribution;
  final Map<String, dynamic> splitFractions;

  final int randomState;

  final double? decisionThreshold;

  final Map<String, dynamic> finalTestMetrics;
  final List<dynamic> thresholdSearch;
  final dynamic comparisonMetrics;

  final String? modelArtifactPath;
  final String? metricsArtifactPath;
  final String? validationPredictionsPath;
  final String? testPredictionsPath;
  final String? featureImportancePath;

  final String? modelArtifactSha256;
  final int? modelArtifactSizeBytes;

  final Map<String, dynamic> softwareVersions;

  final DateTime? startedAt;
  final DateTime? completedAt;

  final String? errorMessage;
  final String? notes;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  final Map<String, dynamic> raw;

  bool get isPending =>
      status == 'PENDING';

  bool get isRunning =>
      status == 'RUNNING';

  bool get isSucceeded =>
      status == 'SUCCEEDED';

  bool get isFailed =>
      status == 'FAILED';

  bool get canStart =>
      isPending;

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

  static List<dynamic> _list(
    dynamic value,
  ) {
    if (value is List) {
      return List<dynamic>.from(value);
    }

    return const [];
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

  static DateTime? _date(
    dynamic value,
  ) {
    if (value == null) {
      return null;
    }

    return DateTime.tryParse(
      value.toString(),
    );
  }

  factory TrainingRunModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return TrainingRunModel(
      id: (json['id'] ??
              json['_id'] ??
              '')
          .toString(),
      runId:
          (json['runId'] ?? '')
              .toString(),
      algorithm:
          (json['algorithm'] ?? '')
              .toString(),
      modelRole:
          (json['modelRole'] ?? '')
              .toString(),
      status:
          (json['status'] ?? 'PENDING')
              .toString()
              .toUpperCase(),
      modelSpecificationVersion:
          _integer(
        json['modelSpecificationVersion'],
      ),
      trainingConfigVersion:
          _integer(
        json['trainingConfigVersion'],
      ),
      preprocessingVersion:
          (json['preprocessingVersion'] ??
                  '')
              .toString(),
      datasetKey:
          (json['datasetKey'] ?? '')
              .toString(),
      datasetVersion:
          (json['datasetVersion'] ?? '')
              .toString(),
      recordCounts:
          _map(json['recordCounts']),
      classDistribution:
          _map(json['classDistribution']),
      splitFractions:
          _map(json['splitFractions']),
      randomState:
          _integer(json['randomState']),
      decisionThreshold:
          _double(
        json['decisionThreshold'],
      ),
      finalTestMetrics:
          _map(
        json['finalTestMetrics'],
      ),
      thresholdSearch:
          _list(
        json['thresholdSearch'],
      ),
      comparisonMetrics:
          json['comparisonMetrics'],
      modelArtifactPath:
          json['modelArtifactPath']
              ?.toString(),
      metricsArtifactPath:
          json['metricsArtifactPath']
              ?.toString(),
      validationPredictionsPath:
          json['validationPredictionsPath']
              ?.toString(),
      testPredictionsPath:
          json['testPredictionsPath']
              ?.toString(),
      featureImportancePath:
          json['featureImportancePath']
              ?.toString(),
      modelArtifactSha256:
          json['modelArtifactSha256']
              ?.toString(),
      modelArtifactSizeBytes:
          json['modelArtifactSizeBytes'] ==
                  null
              ? null
              : _integer(
                  json[
                      'modelArtifactSizeBytes'],
                ),
      softwareVersions:
          _map(
        json['softwareVersions'],
      ),
      startedAt:
          _date(json['startedAt']),
      completedAt:
          _date(json['completedAt']),
      errorMessage:
          json['errorMessage']
              ?.toString(),
      notes:
          json['notes']?.toString(),
      createdAt:
          _date(json['createdAt']),
      updatedAt:
          _date(json['updatedAt']),
      raw:
          Map<String, dynamic>.from(
        json,
      ),
    );
  }
}

class TrainingRunListResult {
  const TrainingRunListResult({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  final List<TrainingRunModel> items;

  final int page;
  final int limit;
  final int total;
  final int totalPages;

  factory TrainingRunListResult.fromJson(
    dynamic value,
  ) {
    final root =
        value is Map
            ? Map<String, dynamic>.from(
                value,
              )
            : <String, dynamic>{};

    final rawItems =
        root['data'] is List
            ? root['data'] as List
            : const [];

    final pagination =
        root['pagination'] is Map
            ? Map<String, dynamic>.from(
                root['pagination'],
              )
            : <String, dynamic>{};

    int number(
      dynamic value, [
      int fallback = 0,
    ]) {
      return int.tryParse(
            (value ?? fallback)
                .toString(),
          ) ??
          fallback;
    }

    return TrainingRunListResult(
      items: rawItems
          .whereType<Map>()
          .map(
            (item) =>
                TrainingRunModel
                    .fromJson(
              Map<String, dynamic>.from(
                item,
              ),
            ),
          )
          .toList(
            growable: false,
          ),
      page:
          number(
        pagination['page'],
        1,
      ),
      limit:
          number(
        pagination['limit'],
        20,
      ),
      total:
          number(
        pagination['total'],
      ),
      totalPages:
          number(
        pagination['totalPages'],
      ),
    );
  }
}

class TrainingDatasetChoice {
  const TrainingDatasetChoice({
    required this.datasetKey,
    required this.version,
    required this.status,
    required this.datasetRole,
    required this.preprocessingVersion,
    required this.recordCount,
    required this.raw,
  });

  final String datasetKey;
  final String version;
  final String status;
  final String datasetRole;
  final String preprocessingVersion;
  final int recordCount;

  final Map<String, dynamic> raw;

  bool get isEligible =>
      status == 'ACTIVE' &&
      datasetRole == 'TRAINING';

  factory TrainingDatasetChoice.fromJson(
    Map<String, dynamic> json,
  ) {
    return TrainingDatasetChoice(
      datasetKey:
          (json['datasetKey'] ?? '')
              .toString(),
      version:
          (json['version'] ?? '')
              .toString(),
      status:
          (json['status'] ?? '')
              .toString()
              .toUpperCase(),
      datasetRole:
          (json['datasetRole'] ?? '')
              .toString()
              .toUpperCase(),
      preprocessingVersion:
          (json['preprocessingVersion'] ??
                  '')
              .toString(),
      recordCount:
          int.tryParse(
                (json['recordCount'] ?? 0)
                    .toString(),
              ) ??
              0,
      raw:
          Map<String, dynamic>.from(
        json,
      ),
    );
  }
}