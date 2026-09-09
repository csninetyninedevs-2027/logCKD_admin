import 'package:latlong2/latlong.dart';

class PhilippineRegionPoint {
  const PhilippineRegionPoint({
    required this.canonicalName,
    required this.position,
  });

  final String canonicalName;
  final LatLng position;
}

String _normalizeRegion(
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

const _regionPoints =
    <String, PhilippineRegionPoint>{
  'ncr':
      PhilippineRegionPoint(
    canonicalName:
        'National Capital Region (NCR)',
    position:
        LatLng(
      14.6091,
      121.0223,
    ),
  ),

  'car':
      PhilippineRegionPoint(
    canonicalName:
        'Cordillera Administrative Region (CAR)',
    position:
        LatLng(
      16.4023,
      120.5960,
    ),
  ),

  'region i':
      PhilippineRegionPoint(
    canonicalName:
        'Region I (Ilocos Region)',
    position:
        LatLng(
      16.0832,
      120.6200,
    ),
  ),

  'region ii':
      PhilippineRegionPoint(
    canonicalName:
        'Region II (Cagayan Valley)',
    position:
        LatLng(
      17.6132,
      121.7270,
    ),
  ),

  'region iii':
      PhilippineRegionPoint(
    canonicalName:
        'Region III (Central Luzon)',
    position:
        LatLng(
      15.4828,
      120.7120,
    ),
  ),

  'region iv a':
      PhilippineRegionPoint(
    canonicalName:
        'Region IV-A (CALABARZON)',
    position:
        LatLng(
      14.1659,
      121.3530,
    ),
  ),

  'mimaropa':
      PhilippineRegionPoint(
    canonicalName:
        'MIMAROPA Region',
    position:
        LatLng(
      12.7503,
      121.3430,
    ),
  ),

  'region v':
      PhilippineRegionPoint(
    canonicalName:
        'Region V (Bicol Region)',
    position:
        LatLng(
      13.4210,
      123.4130,
    ),
  ),

  'region vi':
      PhilippineRegionPoint(
    canonicalName:
        'Region VI (Western Visayas)',
    position:
        LatLng(
      10.7202,
      122.5621,
    ),
  ),

  'nir':
      PhilippineRegionPoint(
    canonicalName:
        'Negros Island Region (NIR)',
    position:
        LatLng(
      10.25,
      123.00,
    ),
  ),

  'region vii':
      PhilippineRegionPoint(
    canonicalName:
        'Region VII (Central Visayas)',
    position:
        LatLng(
      10.3157,
      123.8854,
    ),
  ),

  'region viii':
      PhilippineRegionPoint(
    canonicalName:
        'Region VIII (Eastern Visayas)',
    position:
        LatLng(
      11.2443,
      125.0030,
    ),
  ),

  'region ix':
      PhilippineRegionPoint(
    canonicalName:
        'Region IX (Zamboanga Peninsula)',
    position:
        LatLng(
      7.8292,
      123.4370,
    ),
  ),

  'region x':
      PhilippineRegionPoint(
    canonicalName:
        'Region X (Northern Mindanao)',
    position:
        LatLng(
      8.0202,
      124.6857,
    ),
  ),

  'region xi':
      PhilippineRegionPoint(
    canonicalName:
        'Region XI (Davao Region)',
    position:
        LatLng(
      7.1907,
      125.4553,
    ),
  ),

  'region xii':
      PhilippineRegionPoint(
    canonicalName:
        'Region XII (SOCCSKSARGEN)',
    position:
        LatLng(
      6.2707,
      124.6857,
    ),
  ),

  'region xiii':
      PhilippineRegionPoint(
    canonicalName:
        'Region XIII (Caraga)',
    position:
        LatLng(
      8.9456,
      125.5319,
    ),
  ),

  'barmm':
      PhilippineRegionPoint(
    canonicalName:
        'Bangsamoro Autonomous Region in Muslim Mindanao (BARMM)',
    position:
        LatLng(
      7.2167,
      124.2500,
    ),
  ),
};

PhilippineRegionPoint?
    resolvePhilippineRegion(
  String region,
) {
  final value =
      _normalizeRegion(
    region,
  );

  if (value.isEmpty) {
    return null;
  }

  if (value == 'ncr' ||
      value.contains(
        'national capital region',
      )) {
    return _regionPoints[
        'ncr'];
  }

  if (value == 'car' ||
      value.contains(
        'cordillera administrative region',
      )) {
    return _regionPoints[
        'car'];
  }

  if (value == 'nir' ||
      value.contains(
        'negros island region',
      )) {
    return _regionPoints[
        'nir'];
  }

  if (value.contains(
    'mimaropa',
  )) {
    return _regionPoints[
        'mimaropa'];
  }

  if (value.contains(
        'barmm',
      ) ||
      value.contains(
        'bangsamoro autonomous region',
      )) {
    return _regionPoints[
        'barmm'];
  }

  if (value.contains(
    'region xiii',
  )) {
    return _regionPoints[
        'region xiii'];
  }

  if (value.contains(
    'region xii',
  )) {
    return _regionPoints[
        'region xii'];
  }

  if (value.contains(
    'region xi',
  )) {
    return _regionPoints[
        'region xi'];
  }

  if (value == 'region x' ||
      value.startsWith(
        'region x ',
      )) {
    return _regionPoints[
        'region x'];
  }

  if (value.contains(
    'region ix',
  )) {
    return _regionPoints[
        'region ix'];
  }

  if (value.contains(
    'region viii',
  )) {
    return _regionPoints[
        'region viii'];
  }

  if (value.contains(
    'region vii',
  )) {
    return _regionPoints[
        'region vii'];
  }

  if (value.contains(
    'region vi',
  )) {
    return _regionPoints[
        'region vi'];
  }

  if (value == 'region v' ||
      value.startsWith(
        'region v ',
      )) {
    return _regionPoints[
        'region v'];
  }

  if (value.contains(
        'region iv a',
      ) ||
      value.contains(
        'calabarzon',
      )) {
    return _regionPoints[
        'region iv a'];
  }

  if (value.contains(
        'region iv b',
      ) ||
      value.contains(
        'mimaropa',
      )) {
    return _regionPoints[
        'mimaropa'];
  }

  if (value.contains(
    'region iii',
  )) {
    return _regionPoints[
        'region iii'];
  }

  if (value.contains(
    'region ii',
  )) {
    return _regionPoints[
        'region ii'];
  }

  if (value == 'region i' ||
      value.startsWith(
        'region i ',
      )) {
    return _regionPoints[
        'region i'];
  }

  return null;
}