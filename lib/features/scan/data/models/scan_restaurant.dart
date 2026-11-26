/// 메뉴판을 스캔할 식당 정보입니다.
class ScanRestaurant {
  const ScanRestaurant({
    required this.name,
    required this.category,
    required this.address,
    this.restaurantId,
  });

  /// 서버에 등록된 식당 id입니다. POST /api/scans에 restaurant_id로 보냅니다.
  final int? restaurantId;

  final String name;
  final String category;
  final String address;
}
