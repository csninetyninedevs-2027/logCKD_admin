import 'package:dio/dio.dart';

import '../../../shared/models/model_version_model.dart';

class ModelRegistryAdminService {
  ModelRegistryAdminService(
    this._dio,
  );

  final Dio _dio;

  // The Node admin router mounts the model registry at:
  // /api/admin/models
  //
  // ApiClient already includes /api/admin in its base URL,
  // so this service only uses the route suffix.
  static const String _basePath =
      '/models';

  Future<ModelRegistryListResult>
      listModels() async {
    final response =
        await _dio.get(
      _basePath,
    );

    return ModelRegistryListResult
        .fromJson(
      response.data,
    );
  }

  Future<ModelVersionModel?> getActiveModel({
    String? algorithm,
  }) async {
    final response =
        await _dio.get(
      '$_basePath/active',
      queryParameters: {
        if (algorithm != null &&
            algorithm.trim().isNotEmpty)
          'algorithm':
              algorithm.trim(),
      },
    );

    return _parseModel(
      response.data,
    );
  }

  Future<ModelVersionModel?> getModel(
    String modelVersion,
  ) async {
    final response =
        await _dio.get(
      '$_basePath/${Uri.encodeComponent(modelVersion)}',
    );

    return _parseModel(
      response.data,
    );
  }

  Future<dynamic> activateModel(
    String modelVersion,
  ) async {
    final response =
        await _dio.post(
      '$_basePath/${Uri.encodeComponent(modelVersion)}/activate',
    );

    return response.data;
  }

  Future<dynamic> rollback({
    required String algorithm,
    String? targetModelVersion,
  }) async {
    final response =
        await _dio.post(
      '$_basePath/rollback',
      data: {
        'algorithm': algorithm,
        if (targetModelVersion != null &&
            targetModelVersion
                .trim()
                .isNotEmpty)
          'targetModelVersion':
              targetModelVersion.trim(),
      },
    );

    return response.data;
  }

  ModelVersionModel? _parseModel(
    dynamic value,
  ) {
    if (value is! Map) {
      return null;
    }

    final root =
        Map<String, dynamic>.from(
          value,
        );

    dynamic payload =
        root['data'] ?? root;

    if (payload == null) {
      return null;
    }

    if (payload is Map) {
      final map =
          Map<String, dynamic>.from(
            payload,
          );

      final nested =
          map['model'] ??
          map['modelVersion'] ??
          map['activeModel'];

      if (nested is Map) {
        return ModelVersionModel.fromJson(
          Map<String, dynamic>.from(
            nested,
          ),
        );
      }

      if (map['version'] != null) {
        return ModelVersionModel.fromJson(
          map,
        );
      }
    }

    return null;
  }
}