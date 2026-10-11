import 'package:flutter/material.dart';

// TODO: HOME-01 디자인(헤더, Check a menu 카드, Recent Checks 목록)을 구현합니다.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(child: Text('Home')),
      ),
    );
  }
}
