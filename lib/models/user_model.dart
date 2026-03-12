class UserModel {
  final int? id; // backend field: user_id
  final String fullname; // backend field: fullname
  final String username; // backend field: username
  final String? password; // needed for create & update

  UserModel({
    this.id,
    required this.fullname,
    required this.username,
    this.password,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['user_id'] ?? json['id'], // backend returns user_id
      fullname: json['fullname'] ?? '',
      username: json['username'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{'fullname': fullname, 'username': username};
    // Only include password if provided
    if (password != null && password!.isNotEmpty) {
      map['password'] = password;
    }
    return map;
  }
}
