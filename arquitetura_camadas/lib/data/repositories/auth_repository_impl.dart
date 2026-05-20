import '../../core/sessions/session_manager.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<AuthUser> login(String username, String password) async {
    final user = await remoteDataSource.login(username, password);
    SessionManager.instance.save(user);
    return user;
  }
}
