class AdminFacility {
  const AdminFacility({
    required this.facilityNumber,
    required this.name,
    required this.region,
    required this.province,
    required this.cityMunicipality,
    required this.latitude,
    required this.longitude,
  });

  final int facilityNumber;
  final String name;
  final String? region;
  final String? province;
  final String? cityMunicipality;
  final double? latitude;
  final double? longitude;

  factory AdminFacility.fromJson(Map<String, dynamic> json) {
    return AdminFacility(
      facilityNumber: json['facilityNumber'] as int,
      name: json['name'] as String,
      region: json['region'] as String?,
      province: json['province'] as String?,
      cityMunicipality: json['cityMunicipality'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'facilityNumber': facilityNumber,
      'name': name,
      'region': region,
      'province': province,
      'cityMunicipality': cityMunicipality,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

class FacilityListPage {
  const FacilityListPage({
    required this.total,
    required this.page,
    required this.limit,
    required this.facilities,
  });

  final int total;
  final int page;
  final int limit;
  final List<AdminFacility> facilities;

  factory FacilityListPage.fromJson(Map<String, dynamic> json) {
    return FacilityListPage(
      total: json['total'] as int,
      page: json['page'] as int,
      limit: json['limit'] as int,
      facilities: (json['data'] as List)
          .map((e) => AdminFacility.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
