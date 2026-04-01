import 'package:flutter/foundation.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import 'product_state.dart';

class ProductViewModel extends ChangeNotifier {
  final ProductRepository _repository;

  ProductState _state = ProductLoading();
  ProductState get state => _state;

  ProductViewModel(this._repository);

  Future<void> loadProducts() async {
    _state = ProductLoading();
    notifyListeners();

    try {
      final products = await _repository.getProducts();
      _state = ProductSuccess(products: products);
    } catch (e) {
      final cached = await _tryGetCached();
      _state = ProductError(
        message: _humanReadableError(e),
        cachedProducts: cached,
      );
    }

    notifyListeners();
  }

  Future<void> deleteProduct(int id) async {
    final previous = _state;

    if (_state case ProductSuccess(products: final list)) {
      _state = ProductSuccess(
        products: list.where((p) => p.id != id).toList(),
      );
      notifyListeners();
    }

    try {
      await _repository.deleteProduct(id);
    } catch (e) {
      _state = previous;
      notifyListeners();
      rethrow;
    }
  }

  void upsertProduct(Product product) {
    if (_state case ProductSuccess(products: final list)) {
      final exists = list.any((p) => p.id == product.id);
      final updated = exists
          ? list.map((p) => p.id == product.id ? product : p).toList()
          : [...list, product];

      _state = ProductSuccess(products: updated);
      notifyListeners();
    }
  }

  Future<List<Product>?> _tryGetCached() async {
    try {
      return await _repository.getCachedProducts();
    } catch (_) {
      return null;
    }
  }

  String _humanReadableError(Object e) {
    final msg = e.toString();
    if (msg.contains('SocketException') ||
        msg.contains('Connection refused') ||
        msg.contains('Failed host lookup')) {
      return 'Sem conexão com a internet.';
    }
    if (msg.contains('TimeoutException')) {
      return 'A requisição demorou muito. Tente novamente.';
    }
    return 'Não foi possível carregar os produtos. Tente novamente.';
  }
}