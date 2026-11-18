import 'package:bitok/core/network/models/list_response.dart';
import 'package:flutter_test/flutter_test.dart';

class _Item {
  const _Item(this.id);
  final int id;
  factory _Item.fromJson(Map<String, dynamic> json) => _Item(json['id'] as int);
}

void main() {
  test('ListResponse parses items', () {
    final res = ListResponse.fromJson({
      'items': [
        {'id': 1},
        {'id': 2},
      ],
    }, _Item.fromJson);
    expect(res.items.map((e) => e.id), [1, 2]);
  });

  test('ListResponse parses empty items', () {
    expect(ListResponse.fromJson({'items': []}, _Item.fromJson).items, isEmpty);
  });

  test('PagedResponse parses items and page', () {
    final res = PagedResponse.fromJson({
      'items': [
        {'id': 7},
      ],
      'page': {'next_cursor': 'eyJpZCI6MTIzfQ==', 'has_more': true},
    }, _Item.fromJson);
    expect(res.items.single.id, 7);
    expect(res.page.hasMore, isTrue);
    expect(res.page.nextCursor, 'eyJpZCI6MTIzfQ==');
  });

  test('PagedResponse last page keeps items and has null cursor', () {
    final res = PagedResponse.fromJson({
      'items': [
        {'id': 9},
      ],
      'page': {'next_cursor': null, 'has_more': false},
    }, _Item.fromJson);
    expect(res.items.single.id, 9);
    expect(res.page.hasMore, isFalse);
    expect(res.page.nextCursor, isNull);
  });
}
