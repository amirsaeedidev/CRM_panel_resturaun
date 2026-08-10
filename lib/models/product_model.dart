class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? discountedPrice;
  final String categoryId;
  final int stock;
  final String imageUrl;
  final String status; // 'active', 'inactive', 'out_of_stock'
  final bool isPopular;
  final double? rating;
  final int? reviewCount;
  final DateTime createdAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.discountedPrice,
    required this.categoryId,
    required this.stock,
    required this.imageUrl,
    required this.status,
    this.isPopular = false,
    this.rating,
    this.reviewCount,
    required this.createdAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      price: (json['price'] as num).toDouble(),
      discountedPrice: json['discounted_price'] != null 
          ? (json['discounted_price'] as num).toDouble() 
          : null,
      categoryId: json['category_id'] as String,
      stock: json['stock'] as int? ?? 0,
      imageUrl: json['image_url'] as String? ?? '',
      status: json['status'] as String? ?? 'active',
      isPopular: json['is_popular'] as bool? ?? false,
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      reviewCount: json['review_count'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'discounted_price': discountedPrice,
      'category_id': categoryId,
      'stock': stock,
      'image_url': imageUrl,
      'status': status,
      'is_popular': isPopular,
      'rating': rating,
      'review_count': reviewCount,
      'created_at': createdAt.toIso8601String(),
    };
  }

  ProductModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    double? discountedPrice,
    String? categoryId,
    int? stock,
    String? imageUrl,
    String? status,
    bool? isPopular,
    double? rating,
    int? reviewCount,
    DateTime? createdAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      discountedPrice: discountedPrice ?? this.discountedPrice,
      categoryId: categoryId ?? this.categoryId,
      stock: stock ?? this.stock,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
      isPopular: isPopular ?? this.isPopular,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}