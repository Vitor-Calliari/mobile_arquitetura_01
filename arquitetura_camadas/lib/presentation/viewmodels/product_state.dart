import '../../domain/entities/product.dart';

sealed class ProductState {}

class ProductLoading extends ProductState {}

class ProductSuccess extends ProductState {
  final List<Product> products;
  final bool fromCache;

  ProductSuccess({required this.products, this.fromCache = false});
}

class ProductError extends ProductState {
  final String message;
  final List<Product>? cachedProducts;

  ProductError({required this.message, this.cachedProducts});

  bool get hasCachedData =>
      cachedProducts != null && cachedProducts!.isNotEmpty;
}