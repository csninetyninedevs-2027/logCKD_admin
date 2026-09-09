class HealthStatusCount {
  const HealthStatusCount({
    required this.healthStatus,
    required this.count,
  });

  final String healthStatus;
  final int count;

  factory HealthStatusCount.fromJson(
    Map<String, dynamic> json,
  ) {
    return HealthStatusCount(
      healthStatus:
          json['healthStatus']
                  ?.toString() ??
              'unknown',

      count:
          (json['count'] as num?)
                  ?.toInt() ??
              0,
    );
  }
}

class DashboardSummary {
  const DashboardSummary({
    required this.totalUsers,
    required this.newUsersThisMonth,
    required this.activeUsers,
    required this.totalFacilities,
    required this.mappedFacilities,
    required this.checkupsThisMonth,
    required this.healthStatusBreakdown,
  });

  final int totalUsers;
  final int newUsersThisMonth;
  final int activeUsers;

  final int totalFacilities;
  final int mappedFacilities;

  final int checkupsThisMonth;

  final List<HealthStatusCount>
      healthStatusBreakdown;

  double get facilityMapCoverage {
    if (totalFacilities <= 0) {
      return 0;
    }

    return mappedFacilities /
        totalFacilities *
        100;
  }

  factory DashboardSummary.fromJson(
    Map<String, dynamic> json,
  ) {
    final rawData =
        json['data'];

    final data =
        rawData is Map
            ? Map<String, dynamic>.from(
                rawData,
              )
            : <String, dynamic>{};

    final rawHealth =
        data['healthStatusBreakdown'];

    final health =
        <HealthStatusCount>[];

    if (rawHealth is List) {
      for (final item
          in rawHealth) {
        if (item is Map) {
          health.add(
            HealthStatusCount.fromJson(
              Map<String, dynamic>.from(
                item,
              ),
            ),
          );
        }
      }
    }

    return DashboardSummary(
      totalUsers:
          (data['totalUsers']
                  as num?)
              ?.toInt() ??
          0,

      newUsersThisMonth:
          (data['newUsersThisMonth']
                  as num?)
              ?.toInt() ??
          0,

      activeUsers:
          (data['activeUsers']
                  as num?)
              ?.toInt() ??
          0,

      totalFacilities:
          (data['totalFacilities']
                  as num?)
              ?.toInt() ??
          0,

      mappedFacilities:
          (data['mappedFacilities']
                  as num?)
              ?.toInt() ??
          0,

      checkupsThisMonth:
          (data['checkupsThisMonth']
                  as num?)
              ?.toInt() ??
          0,

      healthStatusBreakdown:
          health,
    );
  }
}