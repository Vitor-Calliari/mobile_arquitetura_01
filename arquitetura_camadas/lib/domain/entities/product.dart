class Product {
  final int id;
  final String title;
  final double price;
  final String thumbnail;
  final String description;
  final String category;

  const Product({
    required this.id,
    required this.title,
    required this.price,
    required this.thumbnail,
    required this.description,
    required this.category,
  });

  Product copyWith({
    int? id,
    String? title,
    double? price,
    String? thumbnail,
    String? description,
    String? category,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      price: price ?? this.price,
      thumbnail: thumbnail ?? this.thumbnail,
      description: description ?? this.description,
      category: category ?? this.category,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'price': price,
        'thumbnail': thumbnail,
        'description': description,
        'category': category,
      };
}
