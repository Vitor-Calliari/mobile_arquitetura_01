import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_local_datasource.dart';
import '../datasources/product_remote_datasource.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;
  final ProductLocalDataSource localDataSource;

  ProductRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<List<Product>> getProducts() async {
    try {
      final products = await remoteDataSource.getProducts();
      await localDataSource.saveProducts(products);
      return products;
    } catch (_) {
      if (localDataSource.hasCache) return localDataSource.getCachedProducts();
      rethrow;
    }
  }

  @override
  Future<List<Product>> getCachedProducts() {
    return localDataSource.getCachedProducts();
  }

  @override
  Future<Product> addProduct(Product product) async {
    final created = await remoteDataSource.addProduct(product);
    await localDataSource.addProductToCache(created);
    return created;
  }

  @override
  Future<Product> updateProduct(Product product) async {
    final updated = await remoteDataSource.updateProduct(product);
    await localDataSource.updateProductInCache(updated);
    return updated;
  }

  @override
  Future<void> deleteProduct(int id) async {
    await remoteDataSource.deleteProduct(id);
    await localDataSource.deleteProductFromCache(id);
  }
}