class Transaction {
  Transaction({
    required this.id,
    required this.itemName,
    required this.quantity,
    required this.amount,
    required this.timestamp,
    required this.entryMethod,
  });

  final String id;
  final String itemName;
  final int quantity;
  final double amount;
  final DateTime timestamp;
  final String entryMethod; 

  factory Transaction.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0;
      return 0;
    }

    int toInt(dynamic v) {
      if (v == null) return 1;
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v) ?? double.tryParse(v)?.toInt() ?? 1;
      return 1;
    }

    final createdAt = json['created_at'] ?? json['timestamp'];
    final item = json['item'];
    final inferredItemName = (item is Map)
        ? (item['name'] ?? item['item_name'] ?? item['title'])
        : null;
    return Transaction(
      id: '${json['id']}',
      itemName: (json['item_name'] ?? json['itemName'] ?? inferredItemName ?? '')
          .toString(),
      quantity: toInt(json['quantity']),
      amount: toDouble(json['amount']),
      timestamp: createdAt is String
          ? DateTime.parse(createdAt)
          : (createdAt is DateTime ? createdAt : DateTime.now()),
      entryMethod: (json['method'] ?? json['entry_method'] ?? json['entryMethod'] ?? 'tap')
          .toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'item_name': itemName,
      'quantity': quantity,
      'amount': amount,
      'created_at': timestamp.toIso8601String(),
      'method': entryMethod,
    };
  }
}
