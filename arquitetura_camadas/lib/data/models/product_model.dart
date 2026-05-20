import '../../domain/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.title,
    required super.price,
    required super.thumbnail,
    required super.description,
    required super.category,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      thumbnail: json['thumbnail'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? '',
    );
  }

  factory ProductModel.fromProduct(Product product) {
    return ProductModel(
      id: product.id,
      title: product.title,
      price: product.price,
      thumbnail: product.thumbnail,
      description: product.description,
      category: product.category,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'title': title,
        'price': price,
        'thumbnail': thumbnail,
        'description': description,
        'category': category,
      };
}
