/// TODO: API 연동 시 `RestaurantBrief`(kakao_place_id, lat, lng, checked_menu_count ...)로 교체합니다.
class MapRestaurant {
  const MapRestaurant({
    required this.id,
    required this.name,
    required this.category,
    required this.address,
    required this.menuCount,
    required this.lat,
    required this.lng,
    this.imageUrl,
  });

  final String id;
  final String name;
  final String category;
  final String address;

  final int menuCount;

  final double lat;
  final double lng;

  /// 식당 대표 이미지 URL입니다. 서버에서 받으며, 없으면 상세 화면에 자리 박스를 보여줍니다.
  final String? imageUrl;
}

/// id로 식당을 찾습니다. 없으면 null입니다.
/// TODO: 식당 상세 API 연동 시 서버 조회로 교체합니다.
MapRestaurant? findMapRestaurant(String id) {
  for (final restaurant in mapRestaurantSamples) {
    if (restaurant.id == id) return restaurant;
  }
  return null;
}

const List<MapRestaurant> mapRestaurantSamples = [
  MapRestaurant(
    id: 'jayeondo',
    name: 'Jayeondo Sogeumppang',
    category: 'Bakery',
    address: '31 Myeongdong 8-gil, Jung-gu',
    menuCount: 4,
    lat: 37.5640,
    lng: 126.9838,
  ),
  MapRestaurant(
    id: 'myeongdong-kyoja',
    name: 'Myeongdong Kyoja',
    category: 'Korean Restaurant',
    address: '29 Myeongdong 10-gil, Jung-gu',
    menuCount: 9,
    lat: 37.5629,
    lng: 126.9853,
  ),
];