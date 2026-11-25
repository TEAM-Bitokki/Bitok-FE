import 'package:json_annotation/json_annotation.dart';

part 'personalized_menu_item.g.dart';

@JsonSerializable(createToJson: false)
class PersonalizedMenuItem {
  const PersonalizedMenuItem({
    required this.dishId,
    required this.nameKo,
    required this.verdict,
    this.nameEn,
    this.analysisId,
  });

  factory PersonalizedMenuItem.fromJson(Map<String, dynamic> json) =>
      _$PersonalizedMenuItemFromJson(json);

  final int dishId;
  final String nameKo;
  final String? nameEn;
  final int? analysisId;
  final String verdict;
}