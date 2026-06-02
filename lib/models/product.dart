class Product {
  final int id;
  final String name;
  final int price;
  final String category;
  final int stock;
  final String description;
  final String imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.stock,
    required this.description,
    required this.imageUrl,
  });

  // Formatted price for existing UI binding
  String get formattedPrice => 'Rp $price';

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      price: json['price'],
      category: json['category'],
      stock: json['stock'] ?? 0,
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'category': category,
      'stock': stock,
      'description': description,
      'image_url': imageUrl,
    };
  }
}
