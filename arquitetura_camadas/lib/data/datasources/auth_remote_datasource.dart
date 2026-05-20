import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/auth_user_model.dart';
import '../../core/network/api_client.dart';

class AuthRemoteDataSource {
  static const _baseUrl = 'https://dummyjson.com';

  Future<AuthUserModel> login(String username, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'username': username,
              'password': password,
              'expiresInMins': 60,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return AuthUserModel.fromJson(json.decode(response.body));
      } else if (response.statusCode == 400 || response.statusCode == 401) {
        throw const NetworkException(
          'Usuário ou senha inválidos.',
          statusCode: 401,
        );
      } else {
        throw NetworkException(
          'Erro do servidor (${response.statusCode}).',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw const NetworkException('Sem conexão com a internet.');
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw NetworkException('Erro inesperado: $e');
    }
  }
}
