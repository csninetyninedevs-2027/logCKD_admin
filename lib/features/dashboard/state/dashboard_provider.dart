import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/providers.dart';
import '../../../shared/models/analytics_extras.dart';
import '../../../shared/models/dashboard_food_summary.dart';
import '../../../shared/models/dashboard_summary.dart';
import '../../../shared/models/demographics.dart';

final dashboardSummaryProvider =
    FutureProvider.autoDispose<
        DashboardSummary>(
  (ref) async {
    final dio =
        ref.watch(
      dioProvider,
    );

    final response =
        await dio.get(
      '/dashboard/summary',
    );

    return DashboardSummary.fromJson(
      Map<String, dynamic>.from(
        response.data as Map,
      ),
    );
  },
);

final demographicsProvider =
    FutureProvider.autoDispose<
        Demographics>(
  (ref) async {
    final dio =
        ref.watch(
      dioProvider,
    );

    final response =
        await dio.get(
      '/analytics/demographics',
    );

    return Demographics.fromJson(
      Map<String, dynamic>.from(
        response.data as Map,
      ),
    );
  },
);

final riskDistributionProvider =
    FutureProvider.autoDispose<
        List<RiskCategoryCount>>(
  (ref) async {
    final dio =
        ref.watch(
      dioProvider,
    );

    final response =
        await dio.get(
      '/analytics/risk-distribution',
    );

    return RiskCategoryCount
        .listFromJson(
      Map<String, dynamic>.from(
        response.data as Map,
      ),
    );
  },
);

final signupTrendMonthsProvider =
    StateProvider<int>(
  (ref) => 12,
);

final signupTrendProvider =
    FutureProvider.autoDispose.family<
        List<SignupTrendPoint>, int>(
  (ref, months) async {
    final dio =
        ref.watch(
      dioProvider,
    );

    final safeMonths =
        months.clamp(1, 36);

    final response =
        await dio.get(
      '/analytics/signup-trend',
      queryParameters: {
        'months': safeMonths,
      },
    );

    return SignupTrendPoint
        .listFromJson(
      Map<String, dynamic>.from(
        response.data as Map,
      ),
    );
  },
);

final dashboardFoodSummaryProvider =
    FutureProvider.autoDispose<
        DashboardFoodSummary>(
  (ref) async {
    final dio =
        ref.watch(
      dioProvider,
    );

    final response =
        await dio.get(
      '/foods/status',
    );

    return DashboardFoodSummary
        .fromJson(
      Map<String, dynamic>.from(
        response.data as Map,
      ),
    );
  },
);