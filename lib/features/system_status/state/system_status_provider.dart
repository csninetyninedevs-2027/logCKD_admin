import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/providers.dart';
import '../../../shared/models/system_status.dart';

final systemStatusProvider =
    FutureProvider.autoDispose<SystemStatusData>(
  (ref) async {
    final dio = ref.watch(
      dioProvider,
    );

    final response = await dio.get(
      '/system/services',
    );

    final raw = response.data;

    if (raw is! Map) {
      throw Exception(
        'Unexpected system status response.',
      );
    }

    return SystemStatusData.fromJson(
      Map<String, dynamic>.from(
        raw,
      ),
    );
  },
);

String systemStatusErrorMessage(
  Object error,
) {
  if (error is DioException) {
    final data =
        error.response?.data;

    if (data is Map) {
      final message =
          data['message'] ??
          data['error'];

      if (message != null) {
        return message.toString();
      }
    }

    if (error.type ==
            DioExceptionType.connectionTimeout ||
        error.type ==
            DioExceptionType.receiveTimeout) {
      return 'The status request timed out.';
    }

    if (error.type ==
        DioExceptionType.connectionError) {
      return 'Unable to reach the admin backend.';
    }
  }

  return 'Unable to load system status.';
}