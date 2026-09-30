import 'package:dio/dio.dart';

import '../../../shared/models/training_config_model.dart';

class TrainingConfigAdminService {
  TrainingConfigAdminService(
    this._dio,
  );

  final Dio _dio;

  static const String _basePath =
      '/training-configs';

  Future<TrainingConfigListResult> listConfigs({
    int page = 1,
    int limit = 100,
    String? status,
    String? algorithm,
    String? search,
  }) async {
    final response = await _dio.get(
      _basePath,
      queryParameters: {
        'page': page,
        'limit': limit,
        if (status != null && status.isNotEmpty)
          'status': status,
        if (algorithm != null && algorithm.isNotEmpty)
          'algorithm': algorithm,
        if (search != null && search.trim().isNotEmpty)
          'search': search.trim(),
      },
    );

    return TrainingConfigListResult.fromJson(
      response.data,
    );
  }

  Future<TrainingConfigModel> getConfig(
    String id,
  ) async {
    final response = await _dio.get(
      '$_basePath/$id',
    );

    return _single(response.data);
  }

  Future<List<TrainingConfigModel>> getVersions(
    String configKey,
  ) async {
    final response = await _dio.get(
      '$_basePath/key/${Uri.encodeComponent(configKey)}',
    );

    final root = _map(response.data);

    final items =
        root['data'] is List ? root['data'] as List : const [];

    return items
        .whereType<Map>()
        .map(
          (item) => TrainingConfigModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList(growable: false);
  }

  Future<TrainingConfigModel> create(
    Map<String, dynamic> payload,
  ) async {
    final response = await _dio.post(
      _basePath,
      data: payload,
    );

    return _single(response.data);
  }

  Future<TrainingConfigModel> updateNotes({
    required String id,
    String? notes,
  }) async {
    final response = await _dio.patch(
      '$_basePath/$id',
      data: {
        'notes': notes,
      },
    );

    return _single(response.data);
  }

  Future<TrainingConfigModel> publish(
    String id,
  ) async {
    final response = await _dio.post(
      '$_basePath/$id/publish',
    );

    return _single(response.data);
  }

  Future<TrainingConfigModel> archive(
    String id,
  ) async {
    final response = await _dio.post(
      '$_basePath/$id/archive',
    );

    return _single(response.data);
  }

  TrainingConfigModel _single(
    dynamic value,
  ) {
    final root = _map(value);

    final data = root['data'];

    if (data is Map) {
      return TrainingConfigModel.fromJson(
        Map<String, dynamic>.from(data),
      );
    }

    return TrainingConfigModel.fromJson(root);
  }

  Map<String, dynamic> _map(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return <String, dynamic>{};
  }
}