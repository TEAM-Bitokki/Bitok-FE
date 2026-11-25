import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/location_service.dart';
import '../../data/models/restaurant_brief.dart';
import '../../data/models/restaurant_detail_response.dart';
import '../../data/repositories/explore_repository.dart';
import '../providers/restaurant_detail_provider.dart';
import '../providers/saved_restaurants_provider.dart';
import '../widgets/explore_status_screen.dart';
import 'restaurant_detail_screen.dart';

class RestaurantDetailPage extends ConsumerStatefulWidget {
  const RestaurantDetailPage({
    super.key,
    required this.restaurantId,
    this.onBack,
    this.onForYouTap,
    this.onMenuTap,
  });

  final int restaurantId;
  final VoidCallback? onBack;
  final VoidCallback? onForYouTap;
  final ValueChanged<CheckedMenu>? onMenuTap;

  @override
  ConsumerState<RestaurantDetailPage> createState() =>
      _RestaurantDetailPageState();
}

class _Paging {
  _Paging(this.first)
      : cursor = first.page.nextCursor,
        hasMore = first.page.hasMore;

  final RestaurantDetailResponse first;
  final List<CheckedMenuItem> more = [];
  String? cursor;
  bool hasMore;
  bool loading = false;
  bool failed = false;
}

class _RestaurantDetailPageState extends ConsumerState<RestaurantDetailPage> {
  static const _title = 'Restaurant Detail';

  _Paging? _paging;

  Future<void> _loadMore({bool retry = false}) async {
    final paging = _paging;
    if (paging == null || !paging.hasMore || paging.loading) return;
    if (paging.failed && !retry) return;
    final cursor = paging.cursor;
    if (cursor == null) return;

    setState(() {
      paging.loading = true;
      paging.failed = false;
    });
    final location = LocationService.cached;
    try {
      final response = await ref
          .read(exploreRepositoryProvider)
          .detail(
        widget.restaurantId,
        cursor: cursor,
        lat: location?.lat,
        lng: location?.lng,
      );
      if (!mounted || !identical(paging, _paging)) return;
      setState(() {
        paging.more.addAll(response.checkedMenus);
        paging.cursor = response.page.nextCursor;
        paging.hasMore = response.page.hasMore;
        paging.loading = false;
      });
    } catch (_) {
      if (!mounted || !identical(paging, _paging)) return;
      setState(() {
        paging.loading = false;
        paging.failed = true;
      });
    }
  }

  String _infoOf(RestaurantBrief restaurant) {
    final category = restaurant.category;
    final distance = restaurant.distanceM;
    return [
      if (category != null && category.isNotEmpty) category,
      if (distance != null)
        distance >= 1000
            ? '${(distance / 1000).toStringAsFixed(1)} km'
            : '${distance.round()} m',
    ].join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(restaurantDetailProvider(widget.restaurantId));
    final first = async.value;

    if (first != null && !identical(first, _paging?.first)) {
      _paging = _Paging(first);
    }

    final paging = _paging;
    if (first == null || paging == null) {
      if (async.hasError) {
        return ExploreErrorScreen(
          title: _title,
          onBack: widget.onBack,
          onRetry: () =>
              ref.invalidate(restaurantDetailProvider(widget.restaurantId)),
        );
      }
      return ExploreLoadingScreen(title: _title, onBack: widget.onBack);
    }

    final restaurant = first.restaurant;
    return RestaurantDetailScreen(
      name: restaurant.name,
      info: _infoOf(restaurant),
      menus: [
        for (final item in [...first.checkedMenus, ...paging.more])
          CheckedMenu(
            dishId: item.dishId,
            koreanName: item.nameKo,
            englishName: item.nameEn ?? item.nameKo,
          ),
      ],
      saved: ref
          .watch(savedRestaurantIdsProvider)
          .contains(restaurant.kakaoPlaceId),
      loadingMore: paging.loading,
      loadMoreFailed: paging.failed,
      onBack: widget.onBack,
      onToggleSaved: () => ref
          .read(savedRestaurantIdsProvider.notifier)
          .toggle(restaurant.kakaoPlaceId),
      onForYouTap: widget.onForYouTap,
      onMenuTap: widget.onMenuTap,
      onLoadMore: _loadMore,
      onRetryLoadMore: () => _loadMore(retry: true),
    );
  }
}