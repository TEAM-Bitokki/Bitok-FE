// data/models: 서버 응답(JSON)을 앱에서 다루는 객체로 매핑하는 데이터 모델을 둡니다.
// 예: datasources가 로그인 응답을 이 모델로 파싱하고, repositories가 이를
// presentation 계층에 전달합니다.
class UserModel {
  const UserModel({required this.id, required this.email});

  final String id;
  final String email;

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        email: json['email'] as String,
      );
}
