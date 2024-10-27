// lib/screens/inventory_screen.dart
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/inventory_item.dart';
import '../widgets/main_layout.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({Key? key}) : super(key: key);

  @override
  _InventoryScreenState createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  List<InventoryItem> inventoryItems = [];

  @override
  void initState() {
    super.initState();
    loadInventoryData();
  }

  // JSONデータを読み込み、InventoryItemリストに変換
  Future<void> loadInventoryData() async {
    final String jsonString =
        await rootBundle.loadString('assets/data/inventory_data.json');
    final List<dynamic> jsonData = json.decode(jsonString);
    setState(() {
      inventoryItems =
          jsonData.map((item) => InventoryItem.fromJson(item)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Inventory List',
      child: ListView.builder(
        itemCount: inventoryItems.length,
        itemBuilder: (context, index) {
          final item = inventoryItems[index];
          return ListTile(
            title: Text(item.name),
            subtitle: Text('Category: ${item.category}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () => setState(() => item.quantity =
                      (item.quantity - 1).clamp(0, item.quantity)),
                ),
                Text('Quantity: ${item.quantity}'),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => setState(() => item.quantity += 1),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
