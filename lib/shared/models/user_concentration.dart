class UserConcentration {
  const UserConcentration({
    required this.region,
    required this.count,
  });

  final String region;
  final int count;

  factory UserConcentration.fromJson(
    Map<String, dynamic> json,
  ) {
    return UserConcentration(
      region:
          (json['region'] ??
                  json['name'] ??
                  json['_id'] ??
                  'Unknown')
              .toString(),
      count:
          (json['count'] as num?)
                  ?.toInt() ??
              0,
    );
  }
}

class UserConcentrationData {
  const UserConcentrationData({
    required this.totalUsers,
    required this.regions,
  });

  final int totalUsers;

  final List<UserConcentration>
      regions;

  factory UserConcentrationData.fromDemographics(
    Map<String, dynamic> json,
  ) {
    // Your backend returns:
    //
    // {
    //   "data": {
    //     "regionBreakdown": [...]
    //   }
    // }
    //
    // Still support a direct regionBreakdown
    // response in case the API changes later.

    Map<String, dynamic> source =
        json;

    final nestedData =
        json['data'];

    if (nestedData
        is Map<String, dynamic>) {
      source = nestedData;
    } else if (nestedData is Map) {
      source =
          Map<String, dynamic>.from(
        nestedData,
      );
    }

    final rawRegions =
        source['regionBreakdown'];

    final mergedCounts =
        <String, int>{};

    if (rawRegions is List) {
      for (final raw
          in rawRegions) {
        if (raw is! Map) {
          continue;
        }

        final item =
            UserConcentration
                .fromJson(
          Map<String, dynamic>.from(
            raw,
          ),
        );

        if (item.count <= 0) {
          continue;
        }

        final canonicalRegion =
            canonicalizeRegionName(
          item.region,
        );

        if (canonicalRegion ==
            null) {
          continue;
        }

        mergedCounts[
            canonicalRegion] =
            (mergedCounts[
                    canonicalRegion] ??
                0) +
            item.count;
      }
    }

    final regions =
        mergedCounts.entries
            .map(
              (entry) =>
                  UserConcentration(
                region: entry.key,
                count: entry.value,
              ),
            )
            .toList();

    regions.sort(
      (a, b) =>
          b.count.compareTo(
        a.count,
      ),
    );

    final totalUsers =
        regions.fold<int>(
      0,
      (
        total,
        item,
      ) =>
          total + item.count,
    );

    return UserConcentrationData(
      totalUsers: totalUsers,
      regions: regions,
    );
  }
}

String _normalizeRegionText(
  String value,
) {
  return value
      .trim()
      .toLowerCase()
      .replaceAll(
        RegExp(r'[^a-z0-9]+'),
        ' ',
      )
      .replaceAll(
        RegExp(r'\s+'),
        ' ',
      )
      .trim();
}

String? canonicalizeRegionName(
  String rawRegion,
) {
  final value =
      _normalizeRegionText(
    rawRegion,
  );

  if (value.isEmpty) {
    return null;
  }

  // National Capital Region
  if (value == 'ncr' ||
      value.contains(
        'national capital region',
      )) {
    return 'National Capital Region (NCR)';
  }

  // CAR
  if (value == 'car' ||
      value.contains(
        'cordillera administrative region',
      )) {
    return 'Cordillera Administrative Region (CAR)';
  }

  // BARMM
  if (value.contains('barmm') ||
      value.contains(
        'bangsamoro autonomous region',
      )) {
    return 'Bangsamoro Autonomous Region in Muslim Mindanao (BARMM)';
  }

  // NIR
  if (value.contains(
        'negros island region',
      ) ||
      value == 'nir') {
    return 'Negros Island Region (NIR)';
  }

  // MIMAROPA
  if (value.contains(
    'mimaropa',
  )) {
    return 'MIMAROPA Region';
  }

  // Important:
  // test longer roman numerals first.

  if (value.contains(
    'region xiii',
  )) {
    return 'Region XIII (Caraga)';
  }

  if (value.contains(
    'region xii',
  )) {
    return 'Region XII (SOCCSKSARGEN)';
  }

  if (value.contains(
    'region xi',
  )) {
    return 'Region XI (Davao Region)';
  }

  if (value == 'region x' ||
      value.startsWith(
        'region x ',
      )) {
    return 'Region X (Northern Mindanao)';
  }

  if (value.contains(
    'region ix',
  )) {
    return 'Region IX (Zamboanga Peninsula)';
  }

  if (value.contains(
    'region viii',
  )) {
    return 'Region VIII (Eastern Visayas)';
  }

  if (value.contains(
    'region vii',
  )) {
    return 'Region VII (Central Visayas)';
  }

  if (value.contains(
    'region vi',
  )) {
    return 'Region VI (Western Visayas)';
  }

  if (value == 'region v' ||
      value.startsWith(
        'region v ',
      )) {
    return 'Region V (Bicol Region)';
  }

  if (value.contains(
        'region iv a',
      ) ||
      value.contains(
        'calabarzon',
      )) {
    return 'Region IV-A (CALABARZON)';
  }

  if (value.contains(
        'region iv b',
      ) ||
      value.contains(
        'mimaropa',
      )) {
    return 'MIMAROPA Region';
  }

  if (value.contains(
    'region iii',
  )) {
    return 'Region III (Central Luzon)';
  }

  if (value.contains(
    'region ii',
  )) {
    return 'Region II (Cagayan Valley)';
  }

  if (value == 'region i' ||
      value.startsWith(
        'region i ',
      )) {
    return 'Region I (Ilocos Region)';
  }

  // Keep unknown names instead of
  // throwing them away.
  return rawRegion.trim();
}