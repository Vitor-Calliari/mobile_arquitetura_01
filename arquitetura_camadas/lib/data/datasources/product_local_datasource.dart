import '../../domain/entities/product.dart';
import '../models/product_model.dart';

class ProductLocalDataSource {
  List<ProductModel>? _cachedProducts;

  bool get hasCache => _cachedProducts != null && _cachedProducts!.isNotEmpty;

  Future<List<ProductModel>> getCachedProducts() async {
    final cache = _cachedProducts;
    if (cache == null || cache.isEmpty) {
      throw Exception('Nenhum dado em cache disponível.');
    }
    return cache;
  }

  Future<void> saveProducts(List<ProductModel> products) async {
    _cachedProducts = List.of(products);
  }

  Future<void> addProductToCache(Product product) async {
    _cachedProducts ??= [];
    _cachedProducts!.add(ProductModel.fromProduct(product));
  }

  Future<void> updateProductInCache(Product product) async {
    if (_cachedProducts == null) return;
    final index = _cachedProducts!.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _cachedProducts![index] = ProductModel.fromProduct(product);
    }
  }

  Future<void> deleteProductFromCache(int id) async {
    _cachedProducts?.removeWhere((p) => p.id == id);
  }
}
