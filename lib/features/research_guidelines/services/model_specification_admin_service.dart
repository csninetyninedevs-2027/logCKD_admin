import 'package:dio/dio.dart';

import '../../../shared/models/model_specification_model.dart';

class ModelSpecificationAdminService {
  ModelSpecificationAdminService(
    this._dio,
  );

  final Dio _dio;

  static const String _basePath =
      '/model-specifications';

  Future<ModelSpecificationListResult>
      listSpecifications({
    int page = 1,
    int limit = 100,
    String? status,
    String? algorithm,
    String? modelRole,
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
        if (modelRole != null && modelRole.isNotEmpty)
          'modelRole': modelRole,
        if (search != null && search.trim().isNotEmpty)
          'search': search.trim(),
      },
    );

    return ModelSpecificationListResult.fromJson(
      response.data,
    );
  }

  Future<ModelSpecificationModel> getSpecification(
    String id,
  ) async {
    final response = await _dio.get(
      '$_basePath/$id',
    );

    return _single(response.data);
  }

  Future<List<ModelSpecificationModel>> getVersions(
    String specificationKey,
  ) async {
    final response = await _dio.get(
      '$_basePath/key/${Uri.encodeComponent(specificationKey)}',
    );

    final root = _map(response.data);

    final items =
        root['data'] is List ? root['data'] as List : const [];

    return items
        .whereType<Map>()
        .map(
          (item) => ModelSpecificationModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList(growable: false);
  }

  Future<ModelSpecificationModel> create(
    Map<String, dynamic> payload,
  ) async {
    final response = await _dio.post(
      _basePath,
      data: payload,
    );

    return _single(response.data);
  }

  Future<ModelSpecificationModel> updateDocumentation({
    required String id,
    required Map<String, dynamic> payload,
  }) async {
    final response = await _dio.patch(
      '$_basePath/$id',
      data: payload,
    );

    return _single(response.data);
  }

  Future<ModelSpecificationModel> publish(
    String id,
  ) async {
    final response = await _dio.post(
      '$_basePath/$id/publish',
    );

    return _single(response.data);
  }

  Future<ModelSpecificationModel> archive(
    String id,
  ) async {
    final response = await _dio.post(
      '$_basePath/$id/archive',
    );

    return _single(response.data);
  }

  ModelSpecificationModel _single(
    dynamic value,
  ) {
    final root = _map(value);

    final data = root['data'];

    if (data is Map) {
      return ModelSpecificationModel.fromJson(
        Map<String, dynamic>.from(data),
      );
    }

    return ModelSpecificationModel.fromJson(root);
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