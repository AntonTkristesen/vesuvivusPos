import './order.dart';

class User {
    final int id;
    final String name;
    final String email;
    List<OrderModel>? orders;

    User({required this.id, required this.name, required this.email, this.orders});

    factory User.fromJson(Map<String, dynamic> j) =>
        User(id: int.parse(j['id'].toString()), name: j['name'], email: j['email'], orders: (j['orders'] as List).map((e) => OrderModel.fromJson(e)).toList());
}
