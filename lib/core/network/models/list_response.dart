import 'page_info.dart';

/// 항목을 Map에서 모델로 바꾸는 함수. 보통 `SomeModel.fromJson`을 그대로 넘깁니다.
typedef JsonItemParser<T> = T Function(Map<String, dynamic> json);

List<T> _parseItems<T>(Map<String, dynamic> json, JsonItemParser<T> parseItem) =>
    (json['items'] as List)
        .map((item) => parseItem(item as Map<String, dynamic>))
        .toList();

/// `{"items": [...]}` 형태의 목록 응답.
///
/// 해당 API: restaurants/nearby·checked·search, saved-restaurants(GET),
/// ingredients/search, restaurants/{id}/menus/for-you
///
/// ```dart
/// final res = ApiClient.decode(
///   await _api.get('/api/restaurants/search', query: {'q': q}),
///   (json) => ListResponse.fromJson(json, RestaurantBrief.fromJson),
/// );
/// ```
class ListResponse<T> {
  const ListResponse({required this.items});

  final List<T> items;

  factory ListResponse.fromJson(
    Map<String, dynamic> json,
    JsonItemParser<T> parseItem,
  ) => ListResponse(items: _parseItems(json, parseItem));
}

/// `{"items": [...], "page": {"next_cursor", "has_more"}}` 형태의 커서 페이지 응답.
///
/// 해당 API: GET /api/my-checks
/// (식당 상세는 항목 키가 checked_menus라서 PageInfo만 따로 씁니다.)
class PagedResponse<T> {
  const PagedResponse({required this.items, required this.page});

  final List<T> items;
  final PageInfo page;

  factory PagedResponse.fromJson(
    Map<String, dynamic> json,
    JsonItemParser<T> parseItem,
  ) => PagedResponse(
    items: _parseItems(json, parseItem),
    page: PageInfo.fromJson(json['page'] as Map<String, dynamic>),
  );
}
