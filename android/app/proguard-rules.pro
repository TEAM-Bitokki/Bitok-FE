# 릴리즈 빌드의 R8 코드 축소·난독화 예외 규칙입니다.

# Kakao Map SDK: 네이티브 코드가 클래스를 이름으로 찾으므로 축소·난독화하면 지도 화면에서 앱이 종료됩니다.
# https://pub.dev/packages/kakao_map_sdk (Android Platform 2번 항목)
-keep class com.kakao.vectormap.** { *; }
-keep interface com.kakao.vectormap.**
