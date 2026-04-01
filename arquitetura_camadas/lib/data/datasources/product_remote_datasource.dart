import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';
import '../../core/network/api_client.dart';
import '../../domain/entities/product.dart';

class ProductRemoteDataSource {
  static const _baseUrl = 'https://fakestoreapi.com/products';

  Future<List<ProductModel>> getProducts() async {
    return _safeRequest(() async {
      final response = await http
          .get(Uri.parse(_baseUrl))
          .timeout(const Duration(seconds: 10));

      _assertSuccess(response);

      final List jsonList = json.decode(response.body);
      return jsonList.map((e) => ProductModel.fromJson(e)).toList();
    });
  }

  Future<ProductModel> addProduct(Product product) async {
    return _safeRequest(() async {
      final response = await http
          .post(
            Uri.parse(_baseUrl),
            headers: {'Content-Type': 'application/json'},
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
            Uri.parse('$_baseUrl/${product.id}'),
            headers: {'Content-Type': 'application/json'},
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
          .delete(Uri.parse('$_baseUrl/$id'))
          .timeout(const Duration(seconds: 10));

      _assertSuccess(response);
    });
  }

  void _assertSuccess(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw NetworkException(
        'Erro do servidor (código ${response.statusCode}).',
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