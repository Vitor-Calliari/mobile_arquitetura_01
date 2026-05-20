import '../../domain/entities/auth_user.dart'; 

class SessionManager {
  SessionManager._();
  static final SessionManager instance = SessionManager._();

  AuthUser? _currentUser;

  AuthUser? get currentUser => _currentUser;

  bool get isAuthenticated => _currentUser != null;

  void save(AuthUser user) => _currentUser = user;

  void clear() => _currentUser = null;
}
