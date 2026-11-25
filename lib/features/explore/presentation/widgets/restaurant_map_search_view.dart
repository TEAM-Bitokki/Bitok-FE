import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/widgets/bitok_search_field.dart';
import '../../../../common/widgets/bitok_text_field.dart';
import '../../../../core/design_system/bitok_colors.dart';
import '../../../../core/design_system/bitok_text_styles.dart';
import '../../../../core/services/location_service.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../data/repositories/restaurant_repository.dart';
import '../models/map_restaurant.dart';
import '../providers/nearby_restaurants_provider.dart';
import 'restaurant_map_view.dart';
import 'restaurant_row.dart';

class RestaurantMapSearchView extends ConsumerStatefulWidget {
  const RestaurantMapSearchView({
    super.key,
    required this.previewBuilder,
    this.checkedOnly = false,
    this.onMyLocationTap,
  });

  final Widget Function(BuildContext context, MapRestaurant restaurant)
  previewBuilder;

  final bool checkedOnly;

  final VoidCallback? onMyLocationTap;

  @override
  ConsumerState<RestaurantMapSearchView> createState() =>
      _RestaurantMapSearchViewState();
}

class _RestaurantMapSearchViewState
    extends ConsumerState<RestaurantMapSearchView> {
  static const _debounceDuration = Duration(milliseconds: 400);
  static const _maxQueryLength = 100;

  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  Timer? _debounce;
  int _requestId = 0;
  List<MapRestaurant> _searchResults = const [];
  bool _searchLoading = false;
  bool _searchFailed = false;

  MapCenter? _center;
  List<MapRestaurant> _lastNearby = const [];

  bool _searching = false;
  MapRestaurant? _selected;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus && !_searching) {
        setState(() => _searching = true);
        _onQueryChanged(_controller.text);
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  double _round(double value) => (value * 1000).round() / 1000;

  void _onCenterChanged(MapCenter center) {
    final rounded = (lat: _round(center.lat), lng: _round(center.lng));
    if (rounded == _center) return;
    setState(() => _center = rounded);
  }

  void _onQueryChanged(String text) {
    _debounce?.cancel();
    final requestId = ++_requestId;
    var query = text.trim();
    if (query.isEmpty) {
      setState(() {
        _searchResults = const [];
        _searchLoading = false;
        _searchFailed = false;
      });
      return;
    }
    if (query.length > _maxQueryLength) {
      query = query.substring(0, _maxQueryLength);
    }
    setState(() {
      _searchResults = const [];
      _searchLoading = true;
      _searchFailed = false;
    });
    _debounce = Timer(_debounceDuration, () => _runSearch(query, requestId));
  }

  Future<void> _runSearch(String query, int requestId) async {
    final location = _center ?? LocationService.cached;
    try {
      final briefs = await ref
          .read(restaurantRepositoryProvider)
          .search(query, lat: location?.lat, lng: location?.lng);
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _searchResults = [
          for (final brief in briefs) MapRestaurant.fromBrief(brief),
        ];
        _searchLoading = false;
      });
    } catch (_) {
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _searchResults = const [];
        _searchLoading = false;
        _searchFailed = true;
      });
    }
  }

  void _select(MapRestaurant restaurant) {
    setState(() {
      _selected = restaurant;
      _searching = false;
    });
    _controller.text = restaurant.name;
    _focusNode.unfocus();
  }

  void _closeSearch() {
    setState(() => _searching = false);
    _controller.text = _selected?.name ?? '';
    _focusNode.unfocus();
  }

  void _clearSelection() {
    setState(() => _selected = null);
    _controller.clear();
    _onQueryChanged('');
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selected;
    final nearby = ref.watch(
      nearbyRestaurantsProvider((
        center: _center,
        checkedOnly: widget.checkedOnly,
      )),
    );
    final fetched = nearby.value;
    if (fetched != null) _lastNearby = fetched;
    final nearbyRestaurants = _lastNearby;
    final markers =
        selected == null || nearbyRestaurants.any((r) => r.id == selected.id)
        ? nearbyRestaurants
        : [...nearbyRestaurants, selected];

    final showNearby = _controller.text.trim().isEmpty;
    final results = showNearby ? nearbyRestaurants : _searchResults;
    final loading = showNearby ? nearby.isLoading : _searchLoading;
    final failed = showNearby ? nearby.hasError : _searchFailed;

    return PopScope(
      canPop: !_searching,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _closeSearch();
      },
      child: Stack(
        children: [
          Positioned.fill(
            child: RestaurantMapView(
              restaurants: markers,
              selectedId: selected?.id,
              onRestaurantTap: _select,
              onMapTap: _clearSelection,
              onMyLocationTap: widget.onMyLocationTap,
              onCenterChanged: _onCenterChanged,
              sheet: selected == null
                  ? null
                  : widget.previewBuilder(context, selected),
            ),
          ),
          if (_searching)
            Positioned.fill(
              child: _ResultList(
                results: results,
                loading: loading,
                failed: failed,
                onTap: _select,
              ),
            ),
          Positioned(
            top: 12,
            left: 24,
            right: 24,
            child: BitokSearchField(
              controller: _controller,
              focusNode: _focusNode,
              hintText: AppLocalizations.of(context).exploreSearchHint,
              variant: _searching
                  ? BitokTextFieldVariant.grey
                  : BitokTextFieldVariant.white,
              onChanged: _onQueryChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultList extends StatelessWidget {
  const _ResultList({
    required this.results,
    required this.loading,
    required this.failed,
    required this.onTap,
  });

  final List<MapRestaurant> results;
  final bool loading;
  final bool failed;
  final ValueChanged<MapRestaurant> onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (results.isEmpty) {
      final Widget message;
      if (loading) {
        message = const CircularProgressIndicator();
      } else if (failed) {
        message = Text(
          l10n.errorLoadFailed,
          style: BitokTextStyles.body2.copyWith(color: BitokColors.grey0),
        );
      } else {
        message = Text(
          l10n.exploreNoResults,
          style: BitokTextStyles.body2.copyWith(color: BitokColors.grey0),
        );
      }
      return ColoredBox(
        color: BitokColors.white,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 120, 24, 24),
          child: Align(alignment: Alignment.topCenter, child: message),
        ),
      );
    }

    return ColoredBox(
      color: BitokColors.white,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(24, 84, 24, 24),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        itemCount: results.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) => RestaurantRow(
          restaurant: results[index],
          onTap: () => onTap(results[index]),
        ),
      ),
    );
  }
}
