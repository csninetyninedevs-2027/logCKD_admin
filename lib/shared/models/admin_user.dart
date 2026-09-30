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
    required this.accessMode,
    required this.agreementAccepted,
    required this.profileSetupComplete,
    required this.isActive,
    required this.createdAt,
    required this.lastLoginAt,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String email;

  /// Profile fields are intentionally stored as empty strings in the
  /// admin model when the backend returns null.
  ///
  /// Awareness-only accounts are valid accounts even when they never
  /// completed profile setup.
  final String sex;
  final String region;
  final String province;
  final String cityMunicipality;
  final String healthStatus;
  final String? ckdStage;

  /// full
  /// awareness_only
  final String accessMode;

  final bool agreementAccepted;
  final bool profileSetupComplete;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  String get fullName {
    final name = '$firstName $lastName'.trim();

    if (name.isNotEmpty) {
      return name;
    }

    if (email.isNotEmpty) {
      return email;
    }

    return 'Unnamed user';
  }

  bool get isAwarenessOnly =>
      accessMode == 'awareness_only';

  bool get hasFullAccess =>
      accessMode == 'full';

  factory AdminUserSummary.fromJson(
    Map<String, dynamic> json,
  ) {
    return AdminUserSummary(
      id: _stringValue(
        json['_id'] ?? json['id'],
      ),
      firstName:
          _stringValue(json['firstName']),
      lastName:
          _stringValue(json['lastName']),
      email:
          _stringValue(json['email']),
      sex:
          _stringValue(json['sex']),
      region:
          _stringValue(json['region']),
      province:
          _stringValue(json['province']),
      cityMunicipality:
          _stringValue(
        json['cityMunicipality'],
      ),
      healthStatus:
          _stringValue(
        json['healthStatus'],
      ),
      ckdStage:
          _nullableStringValue(
        json['ckdStage'],
      ),
      accessMode:
          _normalizeAccessMode(
        json['accessMode'],
      ),
      agreementAccepted:
          json['agreementAccepted']
                  as bool? ??
              false,
      profileSetupComplete:
          json['profileSetupComplete']
                  as bool? ??
              false,
      isActive:
          json['isActive']
                  as bool? ??
              true,
      createdAt:
          _requiredDateTime(
        json['createdAt'],
        fieldName: 'createdAt',
      ),
      lastLoginAt:
          _nullableDateTime(
        json['lastLoginAt'],
      ),
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

  factory UserListPage.fromJson(
    Map<String, dynamic> json,
  ) {
    final rawUsers =
        json['data'];

    return UserListPage(
      total:
          _intValue(json['total']),
      page:
          _intValue(
        json['page'],
        fallback: 1,
      ),
      limit:
          _intValue(
        json['limit'],
        fallback: 25,
      ),
      users: rawUsers is List
          ? rawUsers
              .whereType<Map>()
              .map(
                (entry) =>
                    AdminUserSummary
                        .fromJson(
                  Map<String, dynamic>.from(
                    entry,
                  ),
                ),
              )
              .toList()
          : const [],
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

  factory ActivitySummary.fromJson(
    Map<String, dynamic> json,
  ) {
    return ActivitySummary(
      foodLogCount:
          _intValue(
        json['foodLogCount'],
      ),
      waterLogCount:
          _intValue(
        json['waterLogCount'],
      ),
      activityCount:
          _intValue(
        json['activityCount'],
      ),
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

  final Map<String, dynamic>?
      latestRiskAssessment;

  final Map<String, dynamic>?
      latestCheckup;

  final ActivitySummary activitySummary;

  factory AdminUserDetail.fromJson(
    Map<String, dynamic> json,
  ) {
    final rawData =
        json['data'];

    if (rawData is! Map) {
      throw const FormatException(
        'User detail response did not contain data.',
      );
    }

    final data =
        Map<String, dynamic>.from(
      rawData,
    );

    final rawUser =
        data['user'];

    if (rawUser is! Map) {
      throw const FormatException(
        'User detail response did not contain a user.',
      );
    }

    final userJson =
        Map<String, dynamic>.from(
      rawUser,
    );

    return AdminUserDetail(
      user:
          AdminUserSummary.fromJson(
        userJson,
      ),
      rawUserJson:
          userJson,
      latestRiskAssessment:
          _nullableMap(
        data['latestRiskAssessment'],
      ),
      latestCheckup:
          _nullableMap(
        data['latestCheckup'],
      ),
      activitySummary:
          ActivitySummary.fromJson(
        _nullableMap(
              data['activitySummary'],
            ) ??
            const {},
      ),
    );
  }
}

String _stringValue(
  dynamic value,
) {
  return value
          ?.toString()
          .trim() ??
      '';
}

String? _nullableStringValue(
  dynamic value,
) {
  final text =
      _stringValue(value);

  return text.isEmpty
      ? null
      : text;
}

String _normalizeAccessMode(
  dynamic value,
) {
  final mode =
      _stringValue(value)
          .toLowerCase();

  if (mode ==
      'awareness_only') {
    return 'awareness_only';
  }

  // Existing accounts created before accessMode was introduced
  // should continue to behave as full-access admin records.
  return 'full';
}

int _intValue(
  dynamic value, {
  int fallback = 0,
}) {
  if (value is int) {
    return value;
  }

  if (value is num) {
    return value.toInt();
  }

  return int.tryParse(
        value?.toString() ?? '',
      ) ??
      fallback;
}

DateTime _requiredDateTime(
  dynamic value, {
  required String fieldName,
}) {
  final parsed =
      DateTime.tryParse(
    value?.toString() ?? '',
  );

  if (parsed == null) {
    throw FormatException(
      'User response contained an invalid $fieldName.',
    );
  }

  return parsed;
}

DateTime? _nullableDateTime(
  dynamic value,
) {
  if (value == null) {
    return null;
  }

  final text =
      value.toString().trim();

  if (text.isEmpty) {
    return null;
  }

  return DateTime.tryParse(text);
}

Map<String, dynamic>? _nullableMap(
  dynamic value,
) {
  if (value is! Map) {
    return null;
  }

  return Map<String, dynamic>.from(
    value,
  );
}