class Product {
  final int id;
  final String title;
  final double price;
  final String image;
  final String description;
  final String category;

  const Product({
    required this.id,
    required this.title,
    required this.price,
    required this.image,
    required this.description,
    required this.category,
  });

  Product copyWith({
    int? id,
    String? title,
    double? price,
    String? image,
    String? description,
    String? category,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      price: price ?? this.price,
      image: image ?? this.image,
      description: description ?? this.description,
      category: category ?? this.category,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'price': price,
        'image': image,
        'description': description,
        'category': category,
      };
}