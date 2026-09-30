import 'package:dio/dio.dart';

import '../../../shared/models/risk_guideline_model.dart';

class RiskGuidelineAdminService {
  const RiskGuidelineAdminService(
    this._dio,
  );

  final Dio _dio;

  static const String _basePath =
      '/guidelines/risk';

  Future<RiskGuidelineListResult>
      listGuidelines({
    int page = 1,
    int limit = 50,
    String? status,
    String? search,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'limit': limit,
    };

    if (status != null &&
        status.trim().isNotEmpty &&
        status.toUpperCase() != 'ALL') {
      query['status'] =
          status.trim().toUpperCase();
    }

    if (search != null &&
        search.trim().isNotEmpty) {
      query['search'] = search.trim();
    }

    final response = await _dio.get(
      _basePath,
      queryParameters: query,
    );

    return RiskGuidelineListResult.fromJson(
      response.data,
    );
  }

  Future<RiskGuidelineModel?>
      getPublishedGuideline() async {
    try {
      final response = await _dio.get(
        '$_basePath/published',
      );

      return _parseSingle(
        response.data,
      );
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        return null;
      }

      rethrow;
    }
  }

  Future<RiskGuidelineListResult>
      getHistory() async {
    final response = await _dio.get(
      '$_basePath/history',
    );

    return RiskGuidelineListResult.fromJson(
      response.data,
    );
  }

  Future<RiskGuidelineModel> getGuideline(
    String id,
  ) async {
    final response = await _dio.get(
      '$_basePath/$id',
    );

    final guideline =
        _parseSingle(
      response.data,
    );

    if (guideline == null) {
      throw StateError(
        'Risk guideline response did not contain a guideline.',
      );
    }

    return guideline;
  }

  Future<RiskGuidelineModel>
      createGuideline(
    Map<String, dynamic> payload,
  ) async {
    final response = await _dio.post(
      _basePath,
      data: payload,
    );

    final guideline =
        _parseSingle(
      response.data,
    );

    if (guideline == null) {
      throw StateError(
        'Risk guideline creation response did not contain a guideline.',
      );
    }

    return guideline;
  }

  Future<RiskGuidelineModel>
      createNewVersion({
    required String id,
    required Map<String, dynamic> payload,
  }) async {
    final response = await _dio.post(
      '$_basePath/$id/new-version',
      data: payload,
    );

    final guideline =
        _parseSingle(
      response.data,
    );

    if (guideline == null) {
      throw StateError(
        'New risk guideline version response did not contain a guideline.',
      );
    }

    return guideline;
  }

  Future<RiskGuidelineModel>
      updateGuideline({
    required String id,
    required Map<String, dynamic> payload,
  }) async {
    final response = await _dio.patch(
      '$_basePath/$id',
      data: payload,
    );

    final guideline =
        _parseSingle(
      response.data,
    );

    if (guideline == null) {
      throw StateError(
        'Risk guideline update response did not contain a guideline.',
      );
    }

    return guideline;
  }

  Future<RiskGuidelineModel>
      publishGuideline(
    String id,
  ) async {
    final response = await _dio.post(
      '$_basePath/$id/publish',
    );

    final guideline =
        _parseSingle(
      response.data,
    );

    if (guideline == null) {
      throw StateError(
        'Risk guideline publish response did not contain a guideline.',
      );
    }

    return guideline;
  }

  Future<RiskGuidelineModel>
      archiveGuideline(
    String id,
  ) async {
    final response = await _dio.post(
      '$_basePath/$id/archive',
    );

    final guideline =
        _parseSingle(
      response.data,
    );

    if (guideline == null) {
      throw StateError(
        'Risk guideline archive response did not contain a guideline.',
      );
    }

    return guideline;
  }

  Future<RiskGuidelineModel>
      rollbackGuideline(
    String id,
  ) async {
    final response = await _dio.post(
      '$_basePath/$id/rollback',
    );

    final guideline =
        _parseSingle(
      response.data,
    );

    if (guideline == null) {
      throw StateError(
        'Risk guideline rollback response did not contain a guideline.',
      );
    }

    return guideline;
  }

  RiskGuidelineModel? _parseSingle(
    dynamic response,
  ) {
    if (response is! Map) {
      return null;
    }

    final json =
        Map<String, dynamic>.from(
      response,
    );

    final dynamic candidate =
        json['data'] ??
        json['guideline'] ??
        json['riskGuideline'];

    if (candidate is Map) {
      final candidateJson =
          Map<String, dynamic>.from(
        candidate,
      );

      final nested =
          candidateJson['guideline'] ??
          candidateJson['riskGuideline'];

      if (nested is Map) {
        return RiskGuidelineModel.fromJson(
          Map<String, dynamic>.from(
            nested,
          ),
        );
      }

      return RiskGuidelineModel.fromJson(
        candidateJson,
      );
    }

    if (json.containsKey('_id') ||
        json.containsKey('id') ||
        json.containsKey('guidelineKey') ||
        json.containsKey(
          'riskGuidelineKey',
        )) {
      return RiskGuidelineModel.fromJson(
        json,
      );
    }

    return null;
  }
}