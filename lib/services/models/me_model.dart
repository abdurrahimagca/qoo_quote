class UserMe {
  final String id;
  final int? age;
  final String? gender;
  final bool isPrivate;
  final String? name;
  final String? profilePictureUrl;
  final String username;

  UserMe({
    required this.id,
    this.age,
    this.gender,
    required this.isPrivate,
    this.name,
    this.profilePictureUrl,
    required this.username,
  });

  factory UserMe.fromJson(Map<String, dynamic> json) {
    return UserMe(
      id: json['id'] as String,
      age: json['age'] as int?,
      gender: json['gender'] as String?,
      isPrivate: json['isPrivate'] as bool,
      name: json['name'] as String?,
      profilePictureUrl: json['profilePictureUrl'] as String?,
      username: json['username'] as String,
    );
  }
}
