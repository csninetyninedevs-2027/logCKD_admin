import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/providers.dart';
import '../../../shared/models/admin_user.dart';

class UserListParams {
  const UserListParams({this.search = '', this.page = 1, this.limit = 25});

  final String search;
  final int page;
  final int limit;

  UserListParams copyWith({String? search, int? page}) {
    return UserListParams(
      search: search ?? this.search,
      page: page ?? this.page,
      limit: limit,
    );
  }
}

final userListParamsProvider = StateProvider.autoDispose<UserListParams>((ref) {
  return const UserListParams();
});

final userListProvider = FutureProvider.autoDispose<UserListPage>((ref) async {
  final dio = ref.watch(dioProvider);
  final params = ref.watch(userListParamsProvider);

  final response = await dio.get('/users', queryParameters: {
    if (params.search.isNotEmpty) 'search': params.search,
    'page': params.page,
    'limit': params.limit,
  });

  return UserListPage.fromJson(response.data as Map<String, dynamic>);
});

final userDetailProvider =
    FutureProvider.autoDispose.family<AdminUserDetail, String>((ref, userId) async {
  final dio = ref.watch(dioProvider);
  final response = await dio.get('/users/$userId');
  return AdminUserDetail.fromJson(response.data as Map<String, dynamic>);
});

class UserActionsNotifier extends StateNotifier<AsyncValue<void>> {
  UserActionsNotifier(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;

  Future<bool> setActiveStatus(String userId, bool isActive) async {
    state = const AsyncValue.loading();

    try {
      final dio = _ref.read(dioProvider);
      await dio.patch('/users/$userId/status', data: {'isActive': isActive});

      _ref.invalidate(userDetailProvider(userId));
      _ref.invalidate(userListProvider);

      state = const AsyncValue.data(null);
      return true;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }
}

final userActionsProvider =
    StateNotifierProvider<UserActionsNotifier, AsyncValue<void>>((ref) {
  return UserActionsNotifier(ref);
});
