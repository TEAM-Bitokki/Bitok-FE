import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart';

// data/repositories: datasources를 조합해 presentation 계층이 쓰기 편한 형태로
// 데이터를 노출합니다. 원격/로컬 등 여러 datasource를 함께 써야 할 때 이곳에서 조율합니다.
// 예: presentation/providers의 LoginNotifier가 이 repository를 호출합니다.
class AuthRepository {
  AuthRepository(this._remoteDataSource);

  final AuthRemoteDataSource _remoteDataSource;

  Future<UserModel> login({required String email, required String password}) {
    return _remoteDataSource.login(email: email, password: password);
  }
}
