enum ParsedCommandType { sale, purchase, unknown }

class ParsedCommand {
  ParsedCommand({
    required this.raw,
    required this.type,
    required this.source,
    this.itemName,
    this.quantity,
    this.amount,
  });

  final String raw;
  final ParsedCommandType type;
  final String source; // tap, text, voice
  final String? itemName;
  final int? quantity;
  final double? amount;

  String get typeLabel {
    switch (type) {
      case ParsedCommandType.sale:
        return 'Sale';
      case ParsedCommandType.purchase:
        return 'Purchase';
      case ParsedCommandType.unknown:
        return 'Unknown';
    }
  }

  String get humanSummary {
    if (type == ParsedCommandType.sale && itemName != null) {
      final qty = quantity ?? 1;
      return 'Recorded sale: $qty x $itemName';
    }
    if (type == ParsedCommandType.purchase && itemName != null) {
      final qty = quantity ?? 1;
      return 'Recorded stock in: $qty x $itemName';
    }
    return 'Recorded activity';
  }
}

ParsedCommand parseCommand(String input, {required String source}) {
  final lower = input.toLowerCase();
  final tokens = lower.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();

  ParsedCommandType type = ParsedCommandType.unknown;
  if (tokens.isNotEmpty) {
    if (tokens.first == 'sold') {
      type = ParsedCommandType.sale;
    } else if (tokens.first == 'bought' || tokens.first == 'buy') {
      type = ParsedCommandType.purchase;
    }
  }

  int? quantity;
  double? amount;
  String? itemName;

  // Extract numbers: first is quantity, last is amount (if different).
  final numericValues = <int>[];
  for (final t in tokens) {
    final value = int.tryParse(t.replaceAll(RegExp(r'[^0-9]'), ''));
    if (value != null) {
      numericValues.add(value);
    }
  }

  if (numericValues.isNotEmpty) {
    quantity = numericValues.first;
    if (numericValues.length > 1) {
      amount = numericValues.last.toDouble();
    }
  }

  // Determine item name: words between verb and amount-ish tokens.
  if (tokens.length >= 2) {
    int startIndex = 1;
    int endIndex = tokens.length;

    // Exclude trailing number-like tokens.
    while (endIndex > startIndex &&
        tokens[endIndex - 1].contains(RegExp(r'\d'))) {
      endIndex--;
    }

    if (endIndex > startIndex) {
      itemName = tokens.sublist(startIndex, endIndex).join(' ');
      // Clean trailing words like "stock"
      itemName = itemName.replaceAll(RegExp(r'\bstock\b'), '').trim();
    }
  }

  // Defaults
  quantity ??= 1;

  return ParsedCommand(
    raw: input,
    type: type,
    source: source,
    itemName: itemName?.isEmpty == true ? null : itemName,
    quantity: quantity,
    amount: amount,
  );
}

