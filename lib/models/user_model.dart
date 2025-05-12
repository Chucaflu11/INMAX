class User {
  final String did;
  final String handle;
  final String email;
  final String? displayName;
  final String? avatar;

  User({
    required this.did,
    required this.handle,
    required this.email,
    this.displayName,
    this.avatar,
  });

  factory User.fromJson(Map json) {
    return User(
      did: json['did'] ?? '',
      handle: json['handle'] ?? '',
      email: json['email'] ?? '',
      displayName: json['displayName'],
      avatar: json['avatar'],
    );
  }

  Map toJson() {
    return {
      'did': did,
      'handle': handle,
      'email': email,
      'displayName': displayName,
      'avatar': avatar,
    };
  }
}
