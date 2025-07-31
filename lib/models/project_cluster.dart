class RealEstateProject {
  final String id;
  final String name;
  final double lat;
  final double lng;
  final String city;

  RealEstateProject({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.city,
  });
}

final List<RealEstateProject> projects = [
  RealEstateProject(
    id: '1',
    name: 'Sunset Towers',
    lat: 30.0444,
    lng: 31.2357,
    city: 'Cairo',
  ),
  RealEstateProject(
    id: '2',
    name: 'Nile View',
    lat: 30.0626,
    lng: 31.2497,
    city: 'Cairo',
  ),
  RealEstateProject(
    id: '3',
    name: 'Golden Heights',
    lat: 30.0334,
    lng: 31.2336,
    city: 'Cairo',
  ),
  RealEstateProject(
    id: '4',
    name: 'Marina Plaza',
    lat: 31.2001,
    lng: 29.9187,
    city: 'Alexandria',
  ),
  RealEstateProject(
    id: '5',
    name: 'Seaside Resort',
    lat: 31.1975,
    lng: 29.9097,
    city: 'Alexandria',
  ),
  RealEstateProject(
    id: '6',
    name: 'Red Sea Paradise',
    lat: 27.2579,
    lng: 33.8116,
    city: 'Hurghada',
  ),
  RealEstateProject(
    id: '7',
    name: 'Luxor Gardens',
    lat: 25.6872,
    lng: 32.6396,
    city: 'Luxor',
  ),
  RealEstateProject(
    id: '8',
    name: 'Aswan Residences',
    lat: 24.0889,
    lng: 32.8998,
    city: 'Aswan',
  ),
];
