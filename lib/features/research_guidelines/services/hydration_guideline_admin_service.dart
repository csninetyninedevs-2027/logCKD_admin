import 'package:dio/dio.dart';

import '../../../shared/models/hydration_guideline_model.dart';

class HydrationGuidelineAdminService {
  const HydrationGuidelineAdminService(
    this._dio,
  );

  final Dio _dio;

  static const String _basePath =
      '/guidelines/hydration';

  Future<HydrationGuidelineVersionListResult>
      listVersions() async {
    final response =
        await _dio.get(
      _basePath,
    );

    return HydrationGuidelineVersionListResult
        .fromJson(
      response.data,
    );
  }

  Future<HydrationGuidelineVersionListResult>
      getHistory() async {
    final response =
        await _dio.get(
      '$_basePath/history',
    );

    return HydrationGuidelineVersionListResult
        .fromJson(
      response.data,
    );
  }

  Future<HydrationGuidelineVersion?>
      getPublishedVersion() async {
    final response =
        await _dio.get(
      '$_basePath/published',
    );

    return _parseVersion(
      response.data,
    );
  }

  Future<HydrationGuidelineVersion>
      getVersion(
    int version,
  ) async {
    final response =
        await _dio.get(
      '$_basePath/$version',
    );

    final result =
        _parseVersion(
      response.data,
    );

    if (result == null) {
      throw StateError(
        'Hydration guideline response did not contain a version.',
      );
    }

    return result;
  }

  Future<HydrationGuidelineVersion>
      createNewVersion(
    int sourceVersion,
  ) async {
    final response =
        await _dio.post(
      '$_basePath/$sourceVersion/new-version',
    );

    final result =
        _parseVersion(
      response.data,
    );

    if (result == null) {
      throw StateError(
        'New hydration guideline version response did not contain a version.',
      );
    }

    return result;
  }

  Future<HydrationGuidelineRule>
      updateRule({
    required String ruleId,
    required Map<String, dynamic> payload,
  }) async {
    final response =
        await _dio.patch(
      '$_basePath/rules/${Uri.encodeComponent(ruleId)}',
      data: payload,
    );

    final result =
        _parseRule(
      response.data,
    );

    if (result == null) {
      throw StateError(
        'Hydration guideline update response did not contain a rule.',
      );
    }

    return result;
  }

  Future<void> publishVersion(
    int version,
  ) async {
    await _dio.post(
      '$_basePath/$version/publish',
    );
  }

  Future<void> archiveVersion(
    int version,
  ) async {
    await _dio.post(
      '$_basePath/$version/archive',
    );
  }

  Future<void> rollbackVersion(
    int version,
  ) async {
    await _dio.post(
      '$_basePath/$version/rollback',
    );
  }

  HydrationGuidelineVersion?
      _parseVersion(
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
          root['version'] ??
          root['guideline'];
    }

    if (payload == null) {
      return null;
    }

    if (payload is! Map) {
      return null;
    }

    return HydrationGuidelineVersion
        .fromJson(
      Map<String, dynamic>.from(
        payload,
      ),
    );
  }

  HydrationGuidelineRule? _parseRule(
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
          root['rule'];
    }

    if (payload is! Map) {
      return null;
    }

    return HydrationGuidelineRule
        .fromJson(
      Map<String, dynamic>.from(
        payload,
      ),
    );
  }
}
