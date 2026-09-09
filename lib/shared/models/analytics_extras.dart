class RiskCategoryCount {
  const RiskCategoryCount({
    required this.riskCategory,
    required this.count,
    required this.averageScore,
  });

  final String riskCategory;
  final int count;
  final double? averageScore;

  factory RiskCategoryCount.fromJson(Map<String, dynamic> json) {
    return RiskCategoryCount(
      riskCategory: json['riskCategory'] as String? ?? 'unknown',
      count: json['count'] as int,
      averageScore: (json['averageScore'] as num?)?.toDouble(),
    );
  }

  static List<RiskCategoryCount> listFromJson(Map<String, dynamic> json) {
    final data = json['data'] as List;
    return data
        .map((e) => RiskCategoryCount.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

class SignupTrendPoint {
  const SignupTrendPoint({required this.month, required this.count});

  final String month; // "YYYY-MM"
  final int count;

  factory SignupTrendPoint.fromJson(Map<String, dynamic> json) {
    return SignupTrendPoint(
      month: json['month'] as String,
      count: json['count'] as int,
    );
  }

  static List<SignupTrendPoint> listFromJson(Map<String, dynamic> json) {
    final data = json['data'] as List;
    return data
        .map((e) => SignupTrendPoint.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
