import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/providers.dart';
import '../../../shared/models/user_concentration.dart';

final userConcentrationProvider =
    FutureProvider.autoDispose<
        UserConcentrationData>(
  (ref) async {
    final dio =
        ref.watch(dioProvider);

    final response =
        await dio.get(
      '/analytics/demographics',
    );

    final body =
        response.data;

    if (body
        is! Map<String, dynamic>) {
      throw Exception(
        'Unexpected demographics response.',
      );
    }

    return UserConcentrationData
        .fromDemographics(
      body,
    );
  },
);