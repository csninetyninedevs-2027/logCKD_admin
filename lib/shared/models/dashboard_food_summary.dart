class DashboardFoodSummary {
  const DashboardFoodSummary({
    required this.foundationFoods,
    required this.filipinoFoods,
    required this.customFoods,
    required this.adminFoods,
    required this.totalFoods,
  });

  final int foundationFoods;
  final int filipinoFoods;
  final int customFoods;
  final int adminFoods;
  final int totalFoods;

  int get curatedFoods =>
      filipinoFoods +
      adminFoods;

  factory DashboardFoodSummary.fromJson(
    Map<String, dynamic> json,
  ) {
    final rawDatasets =
        json['datasets'];

    final datasets =
        rawDatasets is Map
            ? Map<String, dynamic>.from(
                rawDatasets,
              )
            : <String, dynamic>{};

    return DashboardFoodSummary(
      foundationFoods:
          (datasets['foundationFoods']
                  as num?)
              ?.toInt() ??
          0,

      filipinoFoods:
          (datasets['filipinoFoods']
                  as num?)
              ?.toInt() ??
          0,

      customFoods:
          (datasets['customFoods']
                  as num?)
              ?.toInt() ??
          0,

      adminFoods:
          (datasets['adminFoods']
                  as num?)
              ?.toInt() ??
          0,

      totalFoods:
          (json['totalLoadedFoods']
                  as num?)
              ?.toInt() ??
          0,
    );
  }
}