import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/providers.dart';
import '../../../shared/models/admin_food.dart';

class FoodListParams {
  const FoodListParams({
    this.search = '',
    this.source = 'all',
    this.page = 1,
    this.limit = 25,
  });

  final String search;
  final String source;
  final int page;
  final int limit;

  FoodListParams copyWith({
    String? search,
    String? source,
    int? page,
  }) {
    return FoodListParams(
      search: search ?? this.search,
      source: source ?? this.source,
      page: page ?? this.page,
      limit: limit,
    );
  }
}

final foodListParamsProvider =
    StateProvider.autoDispose<FoodListParams>((ref) {
  return const FoodListParams();
});

final foodListProvider =
    FutureProvider.autoDispose<FoodListPage>((ref) async {
  final dio = ref.watch(dioProvider);
  final params = ref.watch(foodListParamsProvider);

  final response = await dio.get(
    '/foods',
    queryParameters: {
      if (params.search.isNotEmpty) 'q': params.search,
      'source': params.source,
      'page': params.page,
      'limit': params.limit,
    },
  );

  return FoodListPage.fromJson(
    response.data as Map<String, dynamic>,
  );
});

class FoodActionsNotifier
    extends StateNotifier<AsyncValue<void>> {
  FoodActionsNotifier(this._ref)
      : super(const AsyncValue.data(null));

  final Ref _ref;

  Future<AdminFood> createFood(
    FoodDraft draft,
  ) async {
    state = const AsyncValue.loading();

    try {
      final dio = _ref.read(dioProvider);

      final response = await dio.post(
        '/foods',
        data: draft.toJson(),
      );

      final food = AdminFood.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );

      _ref.invalidate(foodListProvider);

      state = const AsyncValue.data(null);

      return food;
    } catch (error, stackTrace) {
      state = AsyncValue.error(
        error,
        stackTrace,
      );

      rethrow;
    }
  }

  Future<AdminFood> updateFood(
    String id,
    FoodDraft draft,
  ) async {
    state = const AsyncValue.loading();

    try {
      final dio = _ref.read(dioProvider);

      final response = await dio.patch(
        '/foods/$id',
        data: draft.toJson(),
      );

      final food = AdminFood.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );

      _ref.invalidate(foodListProvider);

      state = const AsyncValue.data(null);

      return food;
    } catch (error, stackTrace) {
      state = AsyncValue.error(
        error,
        stackTrace,
      );

      rethrow;
    }
  }

  Future<AdminFood> deactivateFood(
    String id,
  ) async {
    state = const AsyncValue.loading();

    try {
      final dio = _ref.read(dioProvider);

      final response = await dio.delete(
        '/foods/$id',
      );

      final food = AdminFood.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );

      _ref.invalidate(foodListProvider);

      state = const AsyncValue.data(null);

      return food;
    } catch (error, stackTrace) {
      state = AsyncValue.error(
        error,
        stackTrace,
      );

      rethrow;
    }
  }

  Future<BulkValidationResponse> validateBulk(
    dynamic payload,
  ) async {
    state = const AsyncValue.loading();

    try {
      final dio = _ref.read(dioProvider);

      final response = await dio.post(
        '/foods/bulk/validate',
        data: payload,
      );

      final result =
          BulkValidationResponse.fromJson(
        response.data as Map<String, dynamic>,
      );

      state = const AsyncValue.data(null);

      return result;
    } catch (error, stackTrace) {
      state = AsyncValue.error(
        error,
        stackTrace,
      );

      rethrow;
    }
  }

  Future<BulkImportResponse> importBulk(
    dynamic payload,
  ) async {
    state = const AsyncValue.loading();

    try {
      final dio = _ref.read(dioProvider);

      final response = await dio.post(
        '/foods/bulk',
        data: payload,
      );

      final result =
          BulkImportResponse.fromJson(
        response.data as Map<String, dynamic>,
      );

      _ref.invalidate(foodListProvider);

      state = const AsyncValue.data(null);

      return result;
    } catch (error, stackTrace) {
      state = AsyncValue.error(
        error,
        stackTrace,
      );

      rethrow;
    }
  }
}

final foodActionsProvider =
    StateNotifierProvider<
        FoodActionsNotifier,
        AsyncValue<void>>((ref) {
  return FoodActionsNotifier(ref);
});

String foodErrorMessage(
  Object error,
) {
  if (error is DioException) {
    final data = error.response?.data;

    if (data is Map<String, dynamic>) {
      final message =
          data['message'] ?? data['error'];

      if (message != null &&
          message.toString().trim().isNotEmpty) {
        return message.toString();
      }
    }

    if (error.type ==
            DioExceptionType.connectionTimeout ||
        error.type ==
            DioExceptionType.receiveTimeout) {
      return 'The request timed out. Please try again.';
    }

    if (error.type ==
        DioExceptionType.connectionError) {
      return 'Unable to reach the backend.';
    }
  }

  return 'Something went wrong. Please try again.';
}
