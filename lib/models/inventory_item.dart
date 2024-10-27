// lib/models/inventory_item.dart
class InventoryItem {
  final int id;
  final String name;
  final String category;
  final int quantity;
  final double price;

  InventoryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.price,
  });

  // JSONからInventoryItemオブジェクトを生成
  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      quantity: json['quantity'],
      price: json['price'].toDouble(),
    );
  }
}
