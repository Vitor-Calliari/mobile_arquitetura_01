import 'package:flutter/foundation.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';

sealed class ProductFormState {}

class ProductFormIdle extends ProductFormState {}

class ProductFormLoading extends ProductFormState {}

class ProductFormSuccess extends ProductFormState {
  final Product product;
  ProductFormSuccess(this.product);
}

class ProductFormError extends ProductFormState {
  final String message;
  ProductFormError(this.message);
}

class ProductFormViewModel extends ChangeNotifier {
  final ProductRepository _repository;
  final Product? editingProduct;

  ProductFormState _state = ProductFormIdle();
  ProductFormState get state => _state;

  bool get isEditing => editingProduct != null;

  ProductFormViewModel({
    required ProductRepository repository,
    this.editingProduct,
  }) : _repository = repository;

  Future<void> save({
    required String title,
    required String description,
    required double price,
    required String category,
    required String image,
  }) async {
    _state = ProductFormLoading();
    notifyListeners();

    try {
      final product = Product(
        id: editingProduct?.id ?? 0,
        title: title.trim(),
        description: description.trim(),
        price: price,
        category: category.trim(),
        image: image.trim().isEmpty
            ? 'https://fakestoreapi.com/img/placeholder.png'
            : image.trim(),
      );

      final result = isEditing
          ? await _repository.updateProduct(product)
          : await _repository.addProduct(product);

      _state = ProductFormSuccess(result);
    } catch (e) {
      _state = ProductFormError(
        isEditing
            ? 'Não foi possível atualizar o produto.'
            : 'Não foi possível criar o produto.',
      );
    }

    notifyListeners();
  }
}