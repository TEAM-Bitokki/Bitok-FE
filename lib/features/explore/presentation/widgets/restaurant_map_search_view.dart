import 'package:flutter/material.dart';

import '../../../../common/widgets/bitok_search_field.dart';
import '../../../../common/widgets/bitok_text_field.dart';
import '../../../../core/design_system/bitok_colors.dart';
import '../models/map_restaurant.dart';
import 'restaurant_map_view.dart';
import 'restaurant_row.dart';

class RestaurantMapSearchView extends StatefulWidget {
  const RestaurantMapSearchView({
    super.key,
    required this.restaurants,
    required this.previewBuilder,
    this.onMyLocationTap,
  });

  final List<MapRestaurant> restaurants;

  /// 선택된 식당의 미리보기 카드를 만듭니다.
  final Widget Function(BuildContext context, MapRestaurant restaurant)
  previewBuilder;

  final VoidCallback? onMyLocationTap;

  @override
  State<RestaurantMapSearchView> createState() =>
      _RestaurantMapSearchViewState();
}

class _RestaurantMapSearchViewState extends State<RestaurantMapSearchView> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  bool _searching = false;
  MapRestaurant? _selected;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _searching = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  List<MapRestaurant> get _results {
    final query = _controller.text.trim().toLowerCase();
    if (query.isEmpty) return widget.restaurants;
    return widget.restaurants
        .where(
          (r) =>
      r.name.toLowerCase().contains(query) ||
          r.address.toLowerCase().contains(query),
    )
        .toList();
  }

  void _select(MapRestaurant restaurant) {
    setState(() => _selected = restaurant);
    _controller.text = restaurant.name;
    _focusNode.unfocus();
  }

  void _clearSelection() {
    setState(() => _selected = null);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selected;

    return Stack(
      children: [
        Positioned.fill(
          child: _searching
              ? _ResultList(results: _results, onTap: _select)
              : RestaurantMapView(
            restaurants: widget.restaurants,
            selectedId: selected?.id,
            onRestaurantTap: _select,
            onMapTap: _clearSelection,
            onMyLocationTap: widget.onMyLocationTap,
            sheet: selected == null
                ? null
                : widget.previewBuilder(context, selected),
          ),
        ),
        Positioned(
          top: 12,
          left: 24,
          right: 24,
          child: BitokSearchField(
            controller: _controller,
            focusNode: _focusNode,
            hintText: 'Search restaurants',
            variant: _searching
                ? BitokTextFieldVariant.grey
                : BitokTextFieldVariant.white,
            onChanged: (_) => setState(() {}),
          ),
        ),
      ],
    );
  }
}

class _ResultList extends StatelessWidget {
  const _ResultList({required this.results, required this.onTap});

  final List<MapRestaurant> results;
  final ValueChanged<MapRestaurant> onTap;

  @override
  Widget build(BuildContext context) {
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