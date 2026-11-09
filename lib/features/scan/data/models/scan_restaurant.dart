/// 메뉴판을 스캔할 식당 정보입니다.
class ScanRestaurant {
  const ScanRestaurant({
    required this.name,
    required this.category,
    required this.address,
  });

  final String name;
  final String category;
  final String address;
}
