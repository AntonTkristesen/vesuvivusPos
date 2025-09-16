class MenuItemModel {
    final int id;
    final String name;
    final String category;
    final double price;
    final bool isAvailable;

    MenuItemModel({
        required this.id,
        required this.name,
        required this.category,
        required this.price,
        required this.isAvailable,
    });

    factory MenuItemModel.fromJson(Map<String, dynamic> j) => MenuItemModel(
            id: int.parse(j['id'].toString()),
            name: j['name'],
            category: j['category'],
            price: double.parse(j['price'].toString()),
            isAvailable: j['is_available'].toString() == '1' || j['is_available'] == true,
        );
}
