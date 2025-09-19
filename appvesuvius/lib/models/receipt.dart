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

    Map<String, dynamic> toJson() => {
        "id": id,
        "orderId": orderId,
        "total": total,
        "date": date.toIso8601String(),
        "items": items,
    };
}
