class Receipt {
  final String id;
  final String orderId;
  final double total;
  final DateTime date;
  final List<String> items;

  Receipt({
    required this.id,
    required this.orderId,
    required this.total,
    required this.date,
    required this.items,
  });

  factory Receipt.fromJson(Map<String, dynamic> json) {
    return Receipt(
      id: json['id'].toString(), 
      orderId: json['order_id'].toString(), // fix snake_case key + int -> String
      total: (json['total'] as num).toDouble(),
      date: DateTime.parse(json['date']),
      items: (json['items'] as List)
          .map((e) => e['name'].toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "order_id": orderId,
        "total": total,
        "date": date.toIso8601String(),
        "items": items,
      };
}
