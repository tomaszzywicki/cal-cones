class UserAuthModel {
  final String uid;
  final String email;

  UserAuthModel({required this.uid, required this.email});

  Map<String, dynamic> toJson() {
    return {'uid': uid, 'email': email};
  }
}
