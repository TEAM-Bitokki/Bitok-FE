import 'package:flutter/material.dart';

import '../../../../common/widgets/bitok_button.dart';
import '../../../../common/widgets/bitok_header.dart';
import '../../../../core/design_system/bitok_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../models/map_restaurant.dart';
import '../widgets/restaurant_map_search_view.dart';
import '../widgets/restaurant_preview_card.dart';

/// 식당을 검색하거나 지도에서 골라 Select 로 확정합니다.
class RestaurantSelectScreen extends StatefulWidget {
  const RestaurantSelectScreen({super.key, this.onBack, this.onSelect});

  final VoidCallback? onBack;
  final Future<void> Function(MapRestaurant restaurant)? onSelect;

  @override
  State<RestaurantSelectScreen> createState() => _RestaurantSelectScreenState();
}

class _RestaurantSelectScreenState extends State<RestaurantSelectScreen> {
  bool _submitting = false;

  Future<void> _select(MapRestaurant restaurant) async {
    final onSelect = widget.onSelect;
    if (_submitting || onSelect == null) return;
    setState(() => _submitting = true);
    try {
      await onSelect(restaurant);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).errorLoadFailed),
          ),
        );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BitokColors.white,
      appBar: BitokHeader.sub(
        title: 'Restaurant Select',
        onBack: widget.onBack ?? () => Navigator.maybePop(context),
      ),
      body: RestaurantMapSearchView(
        previewBuilder: (context, restaurant) => RestaurantPreviewCard(
          restaurant: restaurant,
          footer: BitokButton(
            label: 'Select',
            onPressed: () => _select(restaurant),
          ),
        ),
      ),
    );
  }
}