class MenuItemModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final String imageUrl;
  final bool isAvailable;
  final int prepTimeMinutes;

  const MenuItemModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.imageUrl,
    required this.isAvailable,
    required this.prepTimeMinutes,
  });

  // converts Firestore document into a MenuItemModel object
  factory MenuItemModel.fromFirestore(Map<String, dynamic> data, String id) {
    return MenuItemModel(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      category: data['category'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      isAvailable: data['isAvailable'] ?? true,
      prepTimeMinutes: data['prepTimeMinutes'] ?? 5,
    );
  }
}