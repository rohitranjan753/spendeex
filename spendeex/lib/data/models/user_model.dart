class UserModel {
  final String id;
  final String name;
  final String email;
  final String? photoURL;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.photoURL,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      photoURL: json['photoURL'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'photoURL': photoURL,
    };
  }
}
