import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';
import '../../core/network/api_client.dart';
import '../../core/sessions/session_manager.dart';
import '../../domain/entities/product.dart';

class ProductRemoteDataSource {
  static const _baseUrl = 'https://dummyjson.com';

  Map<String, String> get _authHeaders {
    final token = SessionManager.instance.currentUser?.accessToken ?? '';
    return {
      'Content-Type': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<ProductModel>> getProducts() async {
    return _safeRequest(() async {
      final response = await http
          .get(Uri.parse('$_baseUrl/products?limit=30'), headers: _authHeaders)
          .timeout(const Duration(seconds: 10));

      _assertSuccess(response);

      final Map<String, dynamic> body = json.decode(response.body);
      final List jsonList = body['products'] as List;
      return jsonList.map((e) => ProductModel.fromJson(e)).toList();
    });
  }

  Future<ProductModel> getProductById(int id) async {
    return _safeRequest(() async {
      final response = await http
          .get(Uri.parse('$_baseUrl/products/$id'), headers: _authHeaders)
          .timeout(const Duration(seconds: 10));

      _assertSuccess(response);
      return ProductModel.fromJson(json.decode(response.body));
    });
  }

  Future<ProductModel> addProduct(Product product) async {
    return _safeRequest(() async {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/products/add'),
            headers: _authHeaders,
            body: json.encode(ProductModel.fromProduct(product).toJson()),
          )
          .timeout(const Duration(seconds: 10));

      _assertSuccess(response);
      return ProductModel.fromJson(json.decode(response.body));
    });
  }

  Future<ProductModel> updateProduct(Product product) async {
    return _safeRequest(() async {
      final response = await http
          .put(
            Uri.parse('$_baseUrl/products/${product.id}'),
            headers: _authHeaders,
            body: json.encode(ProductModel.fromProduct(product).toJson()),
          )
          .timeout(const Duration(seconds: 10));

      _assertSuccess(response);
      return ProductModel.fromJson(json.decode(response.body));
    });
  }

  Future<void> deleteProduct(int id) async {
    return _safeRequest(() async {
      final response = await http
          .delete(
            Uri.parse('$_baseUrl/products/$id'),
            headers: _authHeaders,
          )
          .timeout(const Duration(seconds: 10));

      _assertSuccess(response);
    });
  }

  void _assertSuccess(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw NetworkException(
        'Erro do servidor (${response.statusCode}).',
        statusCode: response.statusCode,
      );
    }
  }

  Future<T> _safeRequest<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on SocketException {
      throw const NetworkException('Sem conexão com a internet.');
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw NetworkException('Erro inesperado: $e');
    }
  }
}
