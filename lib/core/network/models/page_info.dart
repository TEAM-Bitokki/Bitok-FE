// 서버의 커서 페이지네이션 정보 {"next_cursor": "...", "has_more": true}
// (서버 스키마 이름은 Page지만, Flutter의 Page 클래스와 겹치지 않게 PageInfo로 둡니다.)
//
// 다음 페이지 요청:
// - hasMore가 false면 더 요청하지 마세요. (마지막 페이지는 nextCursor가 null)
// - hasMore가 true일 때만 query에 {'cursor': page.nextCursor} 를 넘기세요.
// - 첫 페이지는 cursor를 아예 넣지 않습니다.
class PageInfo {
  const PageInfo({required this.hasMore, this.nextCursor});

  final bool hasMore;
  final String? nextCursor;

  factory PageInfo.fromJson(Map<String, dynamic> json) => PageInfo(
    hasMore: json['has_more'] as bool,
    nextCursor: json['next_cursor'] as String?,
  );
}
