class TrainingConfigModel {
  const TrainingConfigModel({
    required this.id,
    required this.configKey,
    required this.version,
    required this.status,
    required this.algorithm,
    required this.modelSpecificationVersion,
    required this.split,
    required this.preprocessingVersion,
    required this.thresholdTuning,
    required this.output,
    required this.raw,
    this.notes,
    this.publishedAt,
    this.archivedAt,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String configKey;
  final int version;
  final String status;
  final String algorithm;
  final int modelSpecificationVersion;

  final Map<String, dynamic> split;
  final String preprocessingVersion;
  final Map<String, dynamic> thresholdTuning;
  final Map<String, dynamic> output;

  final String? notes;

  final DateTime? publishedAt;
  final DateTime? archivedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  final Map<String, dynamic> raw;

  bool get isDraft => status == 'DRAFT';
  bool get isPublished => status == 'PUBLISHED';
  bool get isArchived => status == 'ARCHIVED';

  static Map<String, dynamic> _map(dynamic value) {
    if (value is Map<String, dynamic>) {
      return Map<String, dynamic>.from(value);
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

  static DateTime? _date(dynamic value) {
    if (value == null) {
      return null;
    }

    return DateTime.tryParse(
      value.toString(),
    );
  }

  factory TrainingConfigModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return TrainingConfigModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      configKey:
          (json['configKey'] ?? '').toString(),
      version: int.tryParse(
            (json['version'] ?? 0).toString(),
          ) ??
          0,
      status:
          (json['status'] ?? 'DRAFT').toString().toUpperCase(),
      algorithm:
          (json['algorithm'] ?? '').toString(),
      modelSpecificationVersion:
          int.tryParse(
                (json['modelSpecificationVersion'] ?? 0)
                    .toString(),
              ) ??
              0,
      split:
          _map(json['split']),
      preprocessingVersion:
          (json['preprocessingVersion'] ?? '').toString(),
      thresholdTuning:
          _map(json['thresholdTuning']),
      output:
          _map(json['output']),
      notes: json['notes']?.toString(),
      publishedAt:
          _date(json['publishedAt']),
      archivedAt:
          _date(json['archivedAt']),
      createdAt:
          _date(json['createdAt']),
      updatedAt:
          _date(json['updatedAt']),
      raw: Map<String, dynamic>.from(json),
    );
  }
}

class TrainingConfigListResult {
  const TrainingConfigListResult({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  final List<TrainingConfigModel> items;
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  factory TrainingConfigListResult.fromJson(
    dynamic value,
  ) {
    final root = value is Map
        ? Map<String, dynamic>.from(value)
        : <String, dynamic>{};

    final rawItems =
        root['data'] is List ? root['data'] as List : const [];

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
            (value ?? fallback).toString(),
          ) ??
          fallback;
    }

    return TrainingConfigListResult(
      items: rawItems
          .whereType<Map>()
          .map(
            (item) => TrainingConfigModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(growable: false),
      page: number(pagination['page'], 1),
      limit: number(pagination['limit'], 20),
      total: number(pagination['total']),
      totalPages:
          number(pagination['totalPages']),
    );
  }
}