class AppUser {
  const AppUser({required this.id, required this.email, this.name});

  final String id;
  final String email;
  final String? name;

  String get displayName => name ?? email.split('@').first;
}
