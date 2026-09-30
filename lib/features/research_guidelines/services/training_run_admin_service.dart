import 'package:dio/dio.dart';

import '../../../shared/models/training_run_model.dart';

class TrainingRunAdminService {
  TrainingRunAdminService(
    this._dio,
  );

  final Dio _dio;

  static const String _basePath =
      '/training-runs';

  Future<TrainingRunListResult>
      listRuns({
    int page = 1,
    int limit = 100,
    String? status,
    String? algorithm,
    String? datasetKey,
    String? search,
  }) async {
    final response =
        await _dio.get(
      _basePath,
      queryParameters: {
        'page': page,
        'limit': limit,
        if (status != null &&
            status.isNotEmpty)
          'status': status,
        if (algorithm != null &&
            algorithm.isNotEmpty)
          'algorithm': algorithm,
        if (datasetKey != null &&
            datasetKey.isNotEmpty)
          'datasetKey': datasetKey,
        if (search != null &&
            search.trim().isNotEmpty)
          'search': search.trim(),
      },
    );

    return TrainingRunListResult
        .fromJson(
      response.data,
    );
  }

  Future<TrainingRunModel> getRun(
    String identifier,
  ) async {
    final response =
        await _dio.get(
      '$_basePath/${Uri.encodeComponent(identifier)}',
    );

    return _single(
      response.data,
    );
  }

  Future<TrainingRunModel> createRun({
    required String algorithm,
    required String datasetKey,
    required String datasetVersion,
    required int modelSpecificationVersion,
    required int trainingConfigVersion,
    String? notes,
  }) async {
    final response =
        await _dio.post(
      _basePath,
      data: {
        'algorithm': algorithm,
        'datasetKey': datasetKey,
        'datasetVersion':
            datasetVersion,
        'modelSpecificationVersion':
            modelSpecificationVersion,
        'trainingConfigVersion':
            trainingConfigVersion,
        if (notes != null &&
            notes.trim().isNotEmpty)
          'notes': notes.trim(),
      },
    );

    return _single(
      response.data,
    );
  }

  Future<TrainingRunModel> startRun(
    String identifier,
  ) async {
    final response =
        await _dio.post(
      '$_basePath/${Uri.encodeComponent(identifier)}/train',
    );

    return _single(
      response.data,
    );
  }

  Future<List<TrainingDatasetChoice>>
      listActiveTrainingDatasets() async {
    final response =
        await _dio.get(
      '/training-datasets',
      queryParameters: {
        'status': 'ACTIVE',
        'datasetRole': 'TRAINING',
        'limit': 100,
      },
    );

    final root =
        _map(response.data);

    final rawData =
        root['data'];

    List<dynamic> values =
        const [];

    if (rawData is List) {
      values = rawData;
    } else if (rawData is Map) {
      final nested =
          rawData['items'] ??
          rawData['datasets'] ??
          rawData['data'];

      if (nested is List) {
        values = nested;
      }
    }

    return values
        .whereType<Map>()
        .map(
          (item) =>
              TrainingDatasetChoice
                  .fromJson(
            Map<String, dynamic>.from(
              item,
            ),
          ),
        )
        .where(
          (item) =>
              item.isEligible,
        )
        .toList(
          growable: false,
        );
  }

  TrainingRunModel _single(
    dynamic value,
  ) {
    final root =
        _map(value);

    final data =
        root['data'];

    if (data is Map) {
      return TrainingRunModel.fromJson(
        Map<String, dynamic>.from(
          data,
        ),
      );
    }

    return TrainingRunModel.fromJson(
      root,
    );
  }

  Map<String, dynamic> _map(
    dynamic value,
  ) {
    if (value
        is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(
        value,
      );
    }

    return <String, dynamic>{};
  }
}