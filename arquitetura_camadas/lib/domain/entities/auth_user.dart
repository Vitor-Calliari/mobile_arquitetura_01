class AuthUser {
  final int id;
  final String username;
  final String firstName;
  final String lastName;
  final String email;
  final String image;
  final String accessToken;

  const AuthUser({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.image,
    required this.accessToken,
  });

  String get fullName => '$firstName $lastName';
}
