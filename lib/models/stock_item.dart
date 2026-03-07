class StockItem {
  StockItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.costPrice,
    required this.sellingPrice,
  });

  final String id;
  final String name;
  final int quantity;
  final double costPrice;
  final double sellingPrice;

  factory StockItem.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0;
      return 0;
    }

    int toInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v) ?? double.tryParse(v)?.toInt() ?? 0;
      return 0;
    }

    return StockItem(
      id: '${json['id']}',
      name: (json['name'] ?? '').toString(),
      quantity: toInt(json['quantity']),
      costPrice: toDouble(json['cost_price']),
      sellingPrice: toDouble(json['selling_price']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'cost_price': costPrice,
      'selling_price': sellingPrice,
    };
  }
}
