class HydrationGuidelineSource {
  const HydrationGuidelineSource({
    required this.organization,
    required this.publicationTitle,
    required this.publicationYear,
    required this.doi,
    required this.url,
    required this.notes,
    required this.raw,
  });

  final String organization;
  final String publicationTitle;
  final int? publicationYear;
  final String doi;
  final String url;
  final String notes;
  final Map<String, dynamic> raw;

  factory HydrationGuidelineSource.fromJson(
    Map<String, dynamic> json,
  ) {
    return HydrationGuidelineSource(
      organization:
          _asString(json['organization']),
      publicationTitle:
          _asString(json['publicationTitle']),
      publicationYear:
          _asInt(json['publicationYear']),
      doi:
          _asString(json['doi']),
      url:
          _asString(json['url']),
      notes:
          _asString(json['notes']),
      raw:
          Map<String, dynamic>.from(json),
    );
  }

  Map<String, dynamic> toPayload() {
    return {
      'organization':
          organization.trim().isEmpty
              ? null
              : organization.trim(),
      'publicationTitle':
          publicationTitle.trim().isEmpty
              ? null
              : publicationTitle.trim(),
      'publicationYear':
          publicationYear,
      'doi':
          doi.trim().isEmpty
              ? null
              : doi.trim(),
      'url':
          url.trim().isEmpty
              ? null
              : url.trim(),
      'notes':
          notes.trim().isEmpty
              ? null
              : notes.trim(),
    };
  }
}

class HydrationGuidelineRule {
  const HydrationGuidelineRule({
    required this.id,
    required this.version,
    required this.status,
    required this.title,
    required this.healthStatus,
    required this.sex,
    required this.minAge,
    required this.maxAge,
    required this.calculationMethod,
    required this.beverageAiMl,
    required this.plainWaterPercentage,
    required this.foodWaterPercentage,
    required this.ckdStage,
    required this.sources,
    required this.publishedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.raw,
  });

  final String id;
  final int version;
  final String status;
  final String title;
  final String healthStatus;
  final String? sex;
  final int? minAge;
  final int? maxAge;
  final String calculationMethod;
  final double? beverageAiMl;
  final double? plainWaterPercentage;
  final double? foodWaterPercentage;
  final String? ckdStage;
  final List<HydrationGuidelineSource> sources;
  final DateTime? publishedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic> raw;

  bool get isDraft =>
      status.toUpperCase() == 'DRAFT';

  bool get isPublished =>
      status.toUpperCase() == 'PUBLISHED';

  bool get isArchived =>
      status.toUpperCase() == 'ARCHIVED';

  factory HydrationGuidelineRule.fromJson(
    Map<String, dynamic> json,
  ) {
    final sourceItems =
        json['sources'];

    return HydrationGuidelineRule(
      id:
          _asString(
        json['id'] ?? json['_id'],
      ),
      version:
          _asInt(json['version']) ?? 0,
      status:
          _asString(json['status']).toUpperCase(),
      title:
          _asString(json['title']),
      healthStatus:
          _asString(json['healthStatus']),
      sex:
          _asNullableString(json['sex']),
      minAge:
          _asInt(json['minAge']),
      maxAge:
          _asInt(json['maxAge']),
      calculationMethod:
          _asString(json['calculationMethod']),
      beverageAiMl:
          _asDouble(json['beverageAiMl']),
      plainWaterPercentage:
          _asDouble(
        json['plainWaterPercentage'],
      ),
      foodWaterPercentage:
          _asDouble(
        json['foodWaterPercentage'],
      ),
      ckdStage:
          _asNullableString(json['ckdStage']),
      sources:
          sourceItems is List
              ? sourceItems
                  .whereType<Map>()
                  .map(
                    (item) =>
                        HydrationGuidelineSource
                            .fromJson(
                      Map<String, dynamic>.from(
                        item,
                      ),
                    ),
                  )
                  .toList()
              : const [],
      publishedAt:
          _asDateTime(json['publishedAt']),
      createdAt:
          _asDateTime(json['createdAt']),
      updatedAt:
          _asDateTime(json['updatedAt']),
      raw:
          Map<String, dynamic>.from(json),
    );
  }
}

class HydrationGuidelineVersionSummary {
  const HydrationGuidelineVersionSummary({
    required this.version,
    required this.status,
    required this.publishedAt,
    required this.ruleCount,
    required this.raw,
  });

  final int version;
  final String status;
  final DateTime? publishedAt;
  final int ruleCount;
  final Map<String, dynamic> raw;

  bool get isDraft =>
      status.toUpperCase() == 'DRAFT';

  bool get isPublished =>
      status.toUpperCase() == 'PUBLISHED';

  bool get isArchived =>
      status.toUpperCase() == 'ARCHIVED';

  bool get canRollback =>
      isArchived && publishedAt != null;

  factory HydrationGuidelineVersionSummary.fromJson(
    Map<String, dynamic> json,
  ) {
    final rules =
        json['rules'];

    return HydrationGuidelineVersionSummary(
      version:
          _asInt(json['version']) ?? 0,
      status:
          _asString(json['status']).toUpperCase(),
      publishedAt:
          _asDateTime(json['publishedAt']),
      ruleCount:
          _asInt(json['ruleCount']) ??
              (rules is List
                  ? rules.length
                  : 0),
      raw:
          Map<String, dynamic>.from(json),
    );
  }
}

class HydrationGuidelineVersion {
  const HydrationGuidelineVersion({
    required this.version,
    required this.status,
    required this.publishedAt,
    required this.rules,
    required this.raw,
  });

  final int version;
  final String status;
  final DateTime? publishedAt;
  final List<HydrationGuidelineRule> rules;
  final Map<String, dynamic> raw;

  bool get isDraft =>
      status.toUpperCase() == 'DRAFT';

  bool get isPublished =>
      status.toUpperCase() == 'PUBLISHED';

  bool get isArchived =>
      status.toUpperCase() == 'ARCHIVED';

  bool get canRollback =>
      isArchived && publishedAt != null;

  factory HydrationGuidelineVersion.fromJson(
    Map<String, dynamic> json,
  ) {
    final ruleItems =
        json['rules'];

    return HydrationGuidelineVersion(
      version:
          _asInt(json['version']) ?? 0,
      status:
          _asString(json['status']).toUpperCase(),
      publishedAt:
          _asDateTime(json['publishedAt']),
      rules:
          ruleItems is List
              ? ruleItems
                  .whereType<Map>()
                  .map(
                    (item) =>
                        HydrationGuidelineRule
                            .fromJson(
                      Map<String, dynamic>.from(
                        item,
                      ),
                    ),
                  )
                  .toList()
              : const [],
      raw:
          Map<String, dynamic>.from(json),
    );
  }
}

class HydrationGuidelineVersionListResult {
  const HydrationGuidelineVersionListResult({
    required this.items,
  });

  final List<HydrationGuidelineVersionSummary>
      items;

  factory HydrationGuidelineVersionListResult.fromJson(
    dynamic response,
  ) {
    dynamic payload = response;

    if (response is Map) {
      final root =
          Map<String, dynamic>.from(
        response,
      );

      payload =
          root['data'] ??
          root['items'] ??
          root['versions'];
    }

    if (payload is! List) {
      return const HydrationGuidelineVersionListResult(
        items: [],
      );
    }

    return HydrationGuidelineVersionListResult(
      items:
          payload
              .whereType<Map>()
              .map(
                (item) =>
                    HydrationGuidelineVersionSummary
                        .fromJson(
                  Map<String, dynamic>.from(
                    item,
                  ),
                ),
              )
              .toList(),
    );
  }
}

String _asString(
  dynamic value,
) {
  if (value == null) {
    return '';
  }

  return value.toString();
}

String? _asNullableString(
  dynamic value,
) {
  if (value == null) {
    return null;
  }

  final text =
      value.toString().trim();

  return text.isEmpty
      ? null
      : text;
}

int? _asInt(
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

double? _asDouble(
  dynamic value,
) {
  if (value is double) {
    return value;
  }

  if (value is num) {
    return value.toDouble();
  }

  return double.tryParse(
    value?.toString() ?? '',
  );
}

DateTime? _asDateTime(
  dynamic value,
) {
  if (value == null) {
    return null;
  }

  if (value is DateTime) {
    return value;
  }

  return DateTime.tryParse(
    value.toString(),
  );
}
