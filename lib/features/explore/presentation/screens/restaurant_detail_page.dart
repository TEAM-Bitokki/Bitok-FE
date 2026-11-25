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

class _RestaurantDetailPageState extends ConsumerState<RestaurantDetailPage> {
  static const _title = 'Restaurant Detail';

  RestaurantDetailResponse? _firstPage;
  final List<CheckedMenuItem> _moreMenus = [];
  String? _cursor;
  bool _hasMore = false;
  bool _loadingMore = false;

  Future<void> _loadMore() async {
    final cursor = _cursor;
    if (!_hasMore || _loadingMore || cursor == null) return;
    setState(() => _loadingMore = true);
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
      if (!mounted) return;
      setState(() {
        _moreMenus.addAll(response.checkedMenus);
        _cursor = response.page.nextCursor;
        _hasMore = response.page.hasMore;
        _loadingMore = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingMore = false);
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

    if (first != null && !identical(first, _firstPage)) {
      _firstPage = first;
      _moreMenus.clear();
      _cursor = first.page.nextCursor;
      _hasMore = first.page.hasMore;
      _loadingMore = false;
    }

    if (first == null) {
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
        for (final item in [...first.checkedMenus, ..._moreMenus])
          CheckedMenu(
            dishId: item.dishId,
            koreanName: item.nameKo,
            englishName: item.nameEn ?? item.nameKo,
          ),
      ],
      saved: ref
          .watch(savedRestaurantIdsProvider)
          .contains(restaurant.kakaoPlaceId),
      loadingMore: _loadingMore,
      onBack: widget.onBack,
      onToggleSaved: () => ref
          .read(savedRestaurantIdsProvider.notifier)
          .toggle(restaurant.kakaoPlaceId),
      onForYouTap: widget.onForYouTap,
      onMenuTap: widget.onMenuTap,
      onLoadMore: _loadMore,
    );
  }
}