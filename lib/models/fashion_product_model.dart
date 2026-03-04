class FashionProduct {
  final String id;
  final String name;
  final double price;
  final String image;
  final String category;
  final String description;
  final int quantity;

  const FashionProduct({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.category,
    required this.description,
    required this.quantity,
  });

  factory FashionProduct.fromFirestore(Map<String, dynamic> data, String id) {
    final imageValue =
        ((data['image'] as String?) ??
                (data['imageURL'] as String?) ??
                (data['imageUrl'] as String?) ??
                (data['image_url'] as String?) ??
                (data['hinh_anh'] as String?) ??
                '')
            .trim();
    final descriptionValue =
        (data['description'] as String?) ??
        (data['moTa'] as String?) ??
        (data['desc'] as String?) ??
        '';
    final quantityValue =
        (data['quantity'] as num?)?.toInt() ??
        (data['soLuong'] as num?)?.toInt() ??
        int.tryParse('${data['quantity'] ?? data['soLuong'] ?? ''}') ??
        0;

    return FashionProduct(
      id: id,
      name: data['name'] as String? ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      image: imageValue,
      category: data['category'] as String? ?? '',
      description: descriptionValue,
      quantity: quantityValue,
    );
  }
}
