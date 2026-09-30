class RiskGuidelineModel {
  const RiskGuidelineModel({
    required this.id,
    required this.guidelineKey,
    required this.version,
    required this.title,
    required this.description,
    required this.status,
    required this.raw,
    this.publishedAt,
    this.archivedAt,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String guidelineKey;
  final int version;
  final String title;
  final String description;
  final String status;

  final DateTime? publishedAt;
  final DateTime? archivedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Complete backend guideline document.
  ///
  /// The clinical/risk configuration is intentionally retained
  /// instead of being reduced to a fixed Flutter-side schema.
  /// This allows the admin UI to display the persisted guideline
  /// configuration without duplicating clinical thresholds.
  final Map<String, dynamic> raw;

  bool get isDraft =>
      status.toUpperCase() == 'DRAFT';

  bool get isPublished =>
      status.toUpperCase() == 'PUBLISHED';

  bool get isArchived =>
      status.toUpperCase() == 'ARCHIVED';

  factory RiskGuidelineModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return RiskGuidelineModel(
      id: _stringValue(
        json['id'] ?? json['_id'],
      ),
      guidelineKey: _stringValue(
        json['guidelineKey'] ??
            json['riskGuidelineKey'] ??
            json['key'],
      ),
      version: _intValue(
        json['version'],
      ),
      title: _stringValue(
        json['title'] ?? json['name'],
      ),
      description: _stringValue(
        json['description'],
      ),
      status: _stringValue(
        json['status'],
        fallback: 'DRAFT',
      ).toUpperCase(),
      publishedAt: _dateValue(
        json['publishedAt'],
      ),
      archivedAt: _dateValue(
        json['archivedAt'],
      ),
      createdAt: _dateValue(
        json['createdAt'],
      ),
      updatedAt: _dateValue(
        json['updatedAt'],
      ),
      raw: Map<String, dynamic>.from(
        json,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return Map<String, dynamic>.from(raw);
  }

  RiskGuidelineModel copyWith({
    String? id,
    String? guidelineKey,
    int? version,
    String? title,
    String? description,
    String? status,
    DateTime? publishedAt,
    DateTime? archivedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? raw,
  }) {
    return RiskGuidelineModel(
      id: id ?? this.id,
      guidelineKey:
          guidelineKey ?? this.guidelineKey,
      version: version ?? this.version,
      title: title ?? this.title,
      description:
          description ?? this.description,
      status: status ?? this.status,
      publishedAt:
          publishedAt ?? this.publishedAt,
      archivedAt:
          archivedAt ?? this.archivedAt,
      createdAt:
          createdAt ?? this.createdAt,
      updatedAt:
          updatedAt ?? this.updatedAt,
      raw: raw ?? this.raw,
    );
  }

  static String _stringValue(
    dynamic value, {
    String fallback = '',
  }) {
    if (value == null) {
      return fallback;
    }

    final result = value.toString().trim();

    if (result.isEmpty) {
      return fallback;
    }

    return result;
  }

  static int _intValue(
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
        ) ??
        0;
  }

  static DateTime? _dateValue(
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
}

class RiskGuidelineListResult {
  const RiskGuidelineListResult({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  final List<RiskGuidelineModel> items;

  final int page;
  final int limit;
  final int total;
  final int totalPages;

  factory RiskGuidelineListResult.fromJson(
    dynamic response,
  ) {
    if (response is List) {
      final items = _parseItems(
        response,
      );

      return RiskGuidelineListResult(
        items: items,
        page: 1,
        limit: items.length,
        total: items.length,
        totalPages: 1,
      );
    }

    if (response is! Map) {
      return const RiskGuidelineListResult(
        items: [],
        page: 1,
        limit: 0,
        total: 0,
        totalPages: 1,
      );
    }

    final json =
        Map<String, dynamic>.from(
      response,
    );

    final dynamic data =
        json['data'] ?? json['items'];

    if (data is List) {
      final items = _parseItems(
        data,
      );

      final pagination =
          json['pagination'] is Map
              ? Map<String, dynamic>.from(
                  json['pagination'] as Map,
                )
              : <String, dynamic>{};

      return RiskGuidelineListResult(
        items: items,
        page: _readInt(
          pagination['page'] ??
              json['page'],
          fallback: 1,
        ),
        limit: _readInt(
          pagination['limit'] ??
              json['limit'],
          fallback: items.length,
        ),
        total: _readInt(
          pagination['total'] ??
              json['total'],
          fallback: items.length,
        ),
        totalPages: _readInt(
          pagination['totalPages'] ??
              json['totalPages'],
          fallback: 1,
        ),
      );
    }

    if (data is Map) {
      final nested =
          Map<String, dynamic>.from(
        data,
      );

      final nestedItems =
          nested['items'] ??
          nested['guidelines'] ??
          nested['versions'];

      if (nestedItems is List) {
        final items = _parseItems(
          nestedItems,
        );

        return RiskGuidelineListResult(
          items: items,
          page: _readInt(
            nested['page'],
            fallback: 1,
          ),
          limit: _readInt(
            nested['limit'],
            fallback: items.length,
          ),
          total: _readInt(
            nested['total'],
            fallback: items.length,
          ),
          totalPages: _readInt(
            nested['totalPages'],
            fallback: 1,
          ),
        );
      }
    }

    final possibleItems =
        json['guidelines'] ??
        json['versions'];

    if (possibleItems is List) {
      final items = _parseItems(
        possibleItems,
      );

      return RiskGuidelineListResult(
        items: items,
        page: 1,
        limit: items.length,
        total: items.length,
        totalPages: 1,
      );
    }

    return const RiskGuidelineListResult(
      items: [],
      page: 1,
      limit: 0,
      total: 0,
      totalPages: 1,
    );
  }

  static List<RiskGuidelineModel>
      _parseItems(
    List<dynamic> values,
  ) {
    return values
        .whereType<Map>()
        .map(
          (item) =>
              RiskGuidelineModel.fromJson(
            Map<String, dynamic>.from(
              item,
            ),
          ),
        )
        .toList();
  }

  static int _readInt(
    dynamic value, {
    required int fallback,
  }) {
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
}