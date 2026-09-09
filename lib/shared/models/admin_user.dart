class AdminUserSummary {
  const AdminUserSummary({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.sex,
    required this.region,
    required this.province,
    required this.cityMunicipality,
    required this.healthStatus,
    required this.ckdStage,
    required this.isActive,
    required this.createdAt,
    required this.lastLoginAt,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String sex;
  final String region;
  final String province;
  final String cityMunicipality;
  final String healthStatus;
  final String? ckdStage;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  String get fullName => '$firstName $lastName';

  factory AdminUserSummary.fromJson(Map<String, dynamic> json) {
    return AdminUserSummary(
      id: json['_id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      sex: json['sex'] as String,
      region: json['region'] as String,
      province: json['province'] as String,
      cityMunicipality: json['cityMunicipality'] as String,
      healthStatus: json['healthStatus'] as String,
      ckdStage: json['ckdStage'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'] as String)
          : null,
    );
  }
}

class UserListPage {
  const UserListPage({
    required this.total,
    required this.page,
    required this.limit,
    required this.users,
  });

  final int total;
  final int page;
  final int limit;
  final List<AdminUserSummary> users;

  factory UserListPage.fromJson(Map<String, dynamic> json) {
    return UserListPage(
      total: json['total'] as int,
      page: json['page'] as int,
      limit: json['limit'] as int,
      users: (json['data'] as List)
          .map((e) => AdminUserSummary.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ActivitySummary {
  const ActivitySummary({
    required this.foodLogCount,
    required this.waterLogCount,
    required this.activityCount,
  });

  final int foodLogCount;
  final int waterLogCount;
  final int activityCount;

  factory ActivitySummary.fromJson(Map<String, dynamic> json) {
    return ActivitySummary(
      foodLogCount: json['foodLogCount'] as int? ?? 0,
      waterLogCount: json['waterLogCount'] as int? ?? 0,
      activityCount: json['activityCount'] as int? ?? 0,
    );
  }
}

class AdminUserDetail {
  const AdminUserDetail({
    required this.user,
    required this.rawUserJson,
    required this.latestRiskAssessment,
    required this.latestCheckup,
    required this.activitySummary,
  });

  final AdminUserSummary user;

  /// Full raw user document, in case you need fields not
  /// modeled in [AdminUserSummary] (e.g. BMI, comorbidities,
  /// family history) without adding a new class for every field.
  final Map<String, dynamic> rawUserJson;

  final Map<String, dynamic>? latestRiskAssessment;
  final Map<String, dynamic>? latestCheckup;
  final ActivitySummary activitySummary;

  factory AdminUserDetail.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final userJson = data['user'] as Map<String, dynamic>;

    return AdminUserDetail(
      user: AdminUserSummary.fromJson(userJson),
      rawUserJson: userJson,
      latestRiskAssessment:
          data['latestRiskAssessment'] as Map<String, dynamic>?,
      latestCheckup: data['latestCheckup'] as Map<String, dynamic>?,
      activitySummary: ActivitySummary.fromJson(
        data['activitySummary'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}
