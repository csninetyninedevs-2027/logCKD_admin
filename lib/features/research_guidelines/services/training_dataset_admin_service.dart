import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../../shared/models/training_dataset_model.dart';

class TrainingDatasetAdminService {
  TrainingDatasetAdminService(
    this._dio,
  );

  final Dio _dio;

  static const String _basePath =
      '/training-datasets';

  Future<TrainingDatasetListResult>
      listDatasets() async {
    final response = await _dio.get(
      _basePath,
    );

    return TrainingDatasetListResult.fromJson(
      response.data,
    );
  }

  Future<TrainingDatasetModel>
      getDataset(
    String id,
  ) async {
    final response = await _dio.get(
      '$_basePath/$id',
    );

    return _parseDataset(
      response.data,
    );
  }

  Future<TrainingDatasetListResult>
      getVersions(
    String datasetKey,
  ) async {
    final response = await _dio.get(
      '$_basePath/key/${Uri.encodeComponent(datasetKey)}',
    );

    return TrainingDatasetListResult.fromJson(
      response.data,
    );
  }

  Future<TrainingDatasetUploadResult>
      validateUpload({
    required Uint8List bytes,
    required String fileName,
    bool includeValidRecords = false,
  }) async {
    final formData = FormData.fromMap({
      'dataset': MultipartFile.fromBytes(
        bytes,
        filename: fileName,
      ),
      'includeValidRecords':
          includeValidRecords.toString(),
    });

    try {
      final response = await _dio.post(
        '$_basePath/upload/validate',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      return TrainingDatasetUploadResult.fromJson(
        response.data,
      );
    } on DioException catch (error) {
      if (error.response?.statusCode == 422 &&
          error.response?.data != null) {
        return TrainingDatasetUploadResult.fromJson(
          error.response!.data,
        );
      }

      rethrow;
    }
  }

  Future<TrainingDatasetModel>
      confirmImport({
    required TrainingDatasetStagingInfo staging,
    required String datasetKey,
    required String name,
    required String version,
    required String datasetRole,
    required Map<String, dynamic> source,
    required List<String> intendedUses,
    required String preprocessingVersion,
    String? notes,
  }) async {
    final response = await _dio.post(
      '$_basePath/upload/confirm',
      data: {
        'stagingToken': staging.token,
        'storedName': staging.storedName,
        'datasetKey': datasetKey.trim(),
        'name': name.trim(),
        'version': version.trim(),
        'datasetRole':
            datasetRole.trim().toUpperCase(),
        'source': source,
        'intendedUses': intendedUses,
        'preprocessingVersion':
            preprocessingVersion.trim(),
        'notes': notes?.trim().isEmpty == true
            ? null
            : notes?.trim(),
      },
    );

    return _parseDataset(
      response.data,
    );
  }

  Future<TrainingDatasetModel> activate(
    String id,
  ) async {
    final response = await _dio.post(
      '$_basePath/$id/activate',
    );

    return _parseDataset(
      response.data,
    );
  }

  Future<TrainingDatasetModel> deactivate(
    String id,
  ) async {
    final response = await _dio.post(
      '$_basePath/$id/deactivate',
    );

    return _parseDataset(
      response.data,
    );
  }

  Future<TrainingDatasetModel> archive(
    String id,
  ) async {
    final response = await _dio.post(
      '$_basePath/$id/archive',
    );

    return _parseDataset(
      response.data,
    );
  }

  TrainingDatasetModel _parseDataset(
    dynamic value,
  ) {
    dynamic data = value;

    if (data is Map) {
      data =
          data['data'] ??
          data['dataset'] ??
          data;
    }

    if (data is Map &&
        data['dataset'] is Map) {
      data = data['dataset'];
    }

    if (data is! Map) {
      throw const FormatException(
        'Training dataset response did not contain a dataset.',
      );
    }

    return TrainingDatasetModel.fromJson(
      Map<String, dynamic>.from(
        data,
      ),
    );
  }
}