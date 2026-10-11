import 'package:flutter/material.dart';

// TODO: EXP-01 디자인(헤더, 지도, 검색창, 위치 마커)을 구현합니다.
class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(child: Text('Explore')),
      ),
    );
  }
}
