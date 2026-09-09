class LabeledCount {
  const LabeledCount({required this.label, required this.count});

  final String label;
  final int count;
}

class ComorbidityCounts {
  const ComorbidityCounts({
    required this.hypertension,
    required this.diabetes,
    required this.heartCondition,
    required this.obesityHistory,
    required this.familyKidneyDisease,
  });

  final int hypertension;
  final int diabetes;
  final int heartCondition;
  final int obesityHistory;
  final int familyKidneyDisease;

  factory ComorbidityCounts.fromJson(Map<String, dynamic> json) {
    return ComorbidityCounts(
      hypertension: json['hypertension'] as int? ?? 0,
      diabetes: json['diabetes'] as int? ?? 0,
      heartCondition: json['heartCondition'] as int? ?? 0,
      obesityHistory: json['obesityHistory'] as int? ?? 0,
      familyKidneyDisease: json['familyKidneyDisease'] as int? ?? 0,
    );
  }
}

class Demographics {
  const Demographics({
    required this.ageBands,
    required this.sexBreakdown,
    required this.regionBreakdown,
    required this.ckdStageBreakdown,
    required this.comorbidities,
  });

  final List<LabeledCount> ageBands;
  final List<LabeledCount> sexBreakdown;
  final List<LabeledCount> regionBreakdown;
  final List<LabeledCount> ckdStageBreakdown;
  final ComorbidityCounts comorbidities;

  static List<LabeledCount> _parseList(
    List<dynamic> raw,
    String labelKey,
  ) {
    return raw.map((e) {
      final row = e as Map<String, dynamic>;
      final rawLabel = row[labelKey];
      return LabeledCount(
        label: rawLabel?.toString() ?? 'Unknown',
        count: row['count'] as int,
      );
    }).toList();
  }

  factory Demographics.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;

    return Demographics(
      ageBands: _parseList(data['ageBands'] as List, 'bucket'),
      sexBreakdown: _parseList(data['sexBreakdown'] as List, 'sex'),
      regionBreakdown: _parseList(data['regionBreakdown'] as List, 'region'),
      ckdStageBreakdown: _parseList(data['ckdStageBreakdown'] as List, 'stage'),
      comorbidities: ComorbidityCounts.fromJson(
        data['comorbidities'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}
