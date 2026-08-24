class User {
  final String id;
  final String email;
  final String mobileNumber;
  final String? name;
  User({required this.id, required this.email, required this.mobileNumber, this.name});

  factory User.fromMap(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      mobileNumber: json['mobileNumber'] as String,
      name: json['name'] as String?,
    );
  }
}
