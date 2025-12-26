import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String email;
  final String name;
  final String token;
  final String role;
  final bool? isVerified;

  const User({
    required this.id,
    required this.email,
    required this.name,
    required this.token,
    required this.role,
    this.isVerified,
  });

  @override
  List<Object?> get props => [id, email, name, token, role, isVerified];
}
