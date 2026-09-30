class ModelSpecificationModel {
  const ModelSpecificationModel({
    required this.id,
    required this.specificationKey,
    required this.version,
    required this.title,
    required this.description,
    required this.status,
    required this.algorithm,
    required this.modelRole,
    required this.target,
    required this.features,
    required this.numericFeatures,
    required this.categoricalFeatures,
    required this.split,
    required this.preprocessing,
    required this.preprocessingVersion,
    required this.hyperparameters,
    required this.thresholdTuning,
    required this.trainingDatasetKey,
    required this.raw,
    this.notes,
    this.publishedAt,
    this.archivedAt,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String specificationKey;
  final int version;
  final String title;
  final String description;
  final String status;
  final String algorithm;
  final String modelRole;
  final String target;

  final List<String> features;
  final List<String> numericFeatures;
  final List<String> categoricalFeatures;

  final Map<String, dynamic> split;
  final Map<String, dynamic> preprocessing;
  final String preprocessingVersion;
  final Map<String, dynamic> hyperparameters;
  final Map<String, dynamic> thresholdTuning;

  final String trainingDatasetKey;
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

  static List<String> _strings(dynamic value) {
    if (value is! List) {
      return const [];
    }

    return value
        .map((item) => item.toString().trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }

  static DateTime? _date(dynamic value) {
    if (value == null) {
      return null;
    }

    return DateTime.tryParse(
      value.toString(),
    );
  }

  factory ModelSpecificationModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ModelSpecificationModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      specificationKey:
          (json['specificationKey'] ?? '').toString(),
      version: int.tryParse(
            (json['version'] ?? 0).toString(),
          ) ??
          0,
      title: (json['title'] ?? '').toString(),
      description:
          (json['description'] ?? '').toString(),
      status:
          (json['status'] ?? 'DRAFT').toString().toUpperCase(),
      algorithm:
          (json['algorithm'] ?? '').toString(),
      modelRole:
          (json['modelRole'] ?? '').toString(),
      target:
          (json['target'] ?? '').toString(),
      features:
          _strings(json['features']),
      numericFeatures:
          _strings(json['numericFeatures']),
      categoricalFeatures:
          _strings(json['categoricalFeatures']),
      split:
          _map(json['split']),
      preprocessing:
          _map(json['preprocessing']),
      preprocessingVersion:
          (json['preprocessingVersion'] ?? '').toString(),
      hyperparameters:
          _map(json['hyperparameters']),
      thresholdTuning:
          _map(json['thresholdTuning']),
      trainingDatasetKey:
          (json['trainingDatasetKey'] ?? '').toString(),
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

class ModelSpecificationListResult {
  const ModelSpecificationListResult({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  final List<ModelSpecificationModel> items;
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  factory ModelSpecificationListResult.fromJson(
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

    return ModelSpecificationListResult(
      items: rawItems
          .whereType<Map>()
          .map(
            (item) => ModelSpecificationModel.fromJson(
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