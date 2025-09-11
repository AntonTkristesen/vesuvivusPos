import './order.dart';

class User {
  final int id;
  final String name;
  final String email;
  List<OrderModel>? orders;

  User({required this.id, required this.name, required this.email, this.orders});

  User copyWith({List<OrderModel>? orders}) {
    return User(
      id: id,
      name: name,
      email: email,
      orders: orders ?? this.orders,
    );
  }
}
