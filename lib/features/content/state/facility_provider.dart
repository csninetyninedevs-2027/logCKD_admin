import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/providers.dart';
import '../../../shared/models/facility.dart';

class FacilityListParams {
  const FacilityListParams({this.search = '', this.page = 1, this.limit = 25});

  final String search;
  final int page;
  final int limit;

  FacilityListParams copyWith({String? search, int? page}) {
    return FacilityListParams(
      search: search ?? this.search,
      page: page ?? this.page,
      limit: limit,
    );
  }
}

final facilityListParamsProvider = StateProvider.autoDispose<FacilityListParams>((ref) {
  return const FacilityListParams();
});

final facilityListProvider = FutureProvider.autoDispose<FacilityListPage>((ref) async {
  final dio = ref.watch(dioProvider);
  final params = ref.watch(facilityListParamsProvider);

  final response = await dio.get('/facilities', queryParameters: {
    if (params.search.isNotEmpty) 'q': params.search,
    'page': params.page,
    'limit': params.limit,
  });

  return FacilityListPage.fromJson(response.data as Map<String, dynamic>);
});

class FacilityActionsNotifier extends StateNotifier<AsyncValue<void>> {
  FacilityActionsNotifier(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;

  Future<bool> create(AdminFacility facility) => _run(() async {
        final dio = _ref.read(dioProvider);
        await dio.post('/facilities', data: facility.toJson());
      });

  Future<bool> update(int facilityNumber, AdminFacility facility) => _run(() async {
        final dio = _ref.read(dioProvider);
        await dio.patch('/facilities/$facilityNumber', data: facility.toJson());
      });

  Future<bool> delete(int facilityNumber) => _run(() async {
        final dio = _ref.read(dioProvider);
        await dio.delete('/facilities/$facilityNumber');
      });

  Future<bool> _run(Future<void> Function() action) async {
    state = const AsyncValue.loading();

    try {
      await action();
      _ref.invalidate(facilityListProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }
}

final facilityActionsProvider =
    StateNotifierProvider<FacilityActionsNotifier, AsyncValue<void>>((ref) {
  return FacilityActionsNotifier(ref);
});
