import 'package:flutter/foundation.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';

sealed class AuthState {}

class AuthIdle extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final AuthUser user;
  AuthSuccess(this.user);
}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _repository;

  AuthState _state = AuthIdle();
  AuthState get state => _state;

  AuthViewModel(this._repository);

  Future<void> login(String username, String password) async {
    _state = AuthLoading();
    notifyListeners();

    try {
      final user = await _repository.login(username, password);
      _state = AuthSuccess(user);
    } catch (e) {
      _state = AuthError(e.toString());
    }

    notifyListeners();
  }
}
