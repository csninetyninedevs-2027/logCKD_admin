class SystemServiceStatus {
  const SystemServiceStatus({
    required this.id,
    required this.name,
    required this.status,
    required this.reachable,
    required this.responseTimeMs,
    required this.httpStatus,
    required this.url,
    required this.healthPath,
    required this.checkedAt,
    required this.message,
    required this.uptimeSeconds,
    required this.environment,
    required this.nodeVersion,
    required this.errorCode,
  });

  final String id;
  final String name;
  final String status;

  final bool reachable;

  final int? responseTimeMs;
  final int? httpStatus;

  final String? url;
  final String? healthPath;

  final DateTime? checkedAt;

  final String? message;

  final int? uptimeSeconds;

  final String? environment;
  final String? nodeVersion;
  final String? errorCode;

  bool get isOnline =>
      status == 'online';

  factory SystemServiceStatus.fromJson(
    Map<String, dynamic> json,
  ) {
    return SystemServiceStatus(
      id:
          json['id']?.toString() ??
          'unknown',

      name:
          json['name']?.toString() ??
          'Unknown Service',

      status:
          json['status']
                  ?.toString()
                  .toLowerCase() ??
              'unknown',

      reachable:
          json['reachable'] == true,

      responseTimeMs:
          (json['responseTimeMs']
                  as num?)
              ?.toInt(),

      httpStatus:
          (json['httpStatus']
                  as num?)
              ?.toInt(),

      url:
          json['url']?.toString(),

      healthPath:
          json['healthPath']
              ?.toString(),

      checkedAt:
          DateTime.tryParse(
        json['checkedAt']
                ?.toString() ??
            '',
      ),

      message:
          json['message']?.toString(),

      uptimeSeconds:
          (json['uptimeSeconds']
                  as num?)
              ?.toInt(),

      environment:
          json['environment']
              ?.toString(),

      nodeVersion:
          json['nodeVersion']
              ?.toString(),

      errorCode:
          json['errorCode']
              ?.toString(),
    );
  }
}

class SystemStatusSummary {
  const SystemStatusSummary({
    required this.total,
    required this.online,
    required this.offline,
    required this.degraded,
    required this.notConfigured,
  });

  final int total;
  final int online;
  final int offline;
  final int degraded;
  final int notConfigured;

  int get issues =>
      offline +
      degraded +
      notConfigured;

  factory SystemStatusSummary.fromJson(
    Map<String, dynamic> json,
  ) {
    return SystemStatusSummary(
      total:
          (json['total'] as num?)
                  ?.toInt() ??
              0,

      online:
          (json['online'] as num?)
                  ?.toInt() ??
              0,

      offline:
          (json['offline'] as num?)
                  ?.toInt() ??
              0,

      degraded:
          (json['degraded'] as num?)
                  ?.toInt() ??
              0,

      notConfigured:
          (json['notConfigured']
                  as num?)
              ?.toInt() ??
          0,
    );
  }

  factory SystemStatusSummary.fromServices(
    List<SystemServiceStatus>
        services,
  ) {
    var online = 0;
    var offline = 0;
    var degraded = 0;
    var notConfigured = 0;

    for (final service
        in services) {
      switch (service.status) {
        case 'online':
          online++;
          break;

        case 'offline':
          offline++;
          break;

        case 'degraded':
          degraded++;
          break;

        case 'not_configured':
          notConfigured++;
          break;
      }
    }

    return SystemStatusSummary(
      total: services.length,
      online: online,
      offline: offline,
      degraded: degraded,
      notConfigured:
          notConfigured,
    );
  }
}

class SystemStatusData {
  const SystemStatusData({
    required this.checkedAt,
    required this.summary,
    required this.services,
  });

  final DateTime? checkedAt;

  final SystemStatusSummary
      summary;

  final List<SystemServiceStatus>
      services;

  factory SystemStatusData.fromJson(
    Map<String, dynamic> json,
  ) {
    Map<String, dynamic> payload =
        json;

    final nested =
        json['data'];

    if (nested is Map) {
      payload =
          Map<String, dynamic>.from(
        nested,
      );
    }

    final rawServices =
        payload['services'];

    final services =
        <SystemServiceStatus>[];

    if (rawServices is List) {
      for (final raw
          in rawServices) {
        if (raw is Map) {
          services.add(
            SystemServiceStatus
                .fromJson(
              Map<String, dynamic>.from(
                raw,
              ),
            ),
          );
        }
      }
    }

    final rawSummary =
        payload['summary'];

    final summary =
        rawSummary is Map
            ? SystemStatusSummary
                .fromJson(
                Map<String, dynamic>.from(
                  rawSummary,
                ),
              )
            : SystemStatusSummary
                .fromServices(
                services,
              );

    return SystemStatusData(
      checkedAt:
          DateTime.tryParse(
        payload['checkedAt']
                ?.toString() ??
            '',
      ),

      summary: summary,

      services: services,
    );
  }
}