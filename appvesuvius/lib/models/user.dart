class User {
  final int id;
  final String name;
  final String email;

  User({required this.id, required this.name, required this.email});

  factory User.fromJson(Map<String, dynamic> j) =>
      User(id: int.parse(j['id'].toString()), name: j['name'], email: j['email']);
}
