import 'package:digital_bank/features/auth/models/user.dart';
import 'package:equatable/equatable.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

final class UnknownAuth extends AuthState {
  const UnknownAuth();
}

final class AuthLoading extends AuthState {
  const AuthLoading();
}

final class Unauthenticated extends AuthState {
  const Unauthenticated();
}

final class Authenticated extends AuthState {
  const Authenticated({required this.user});

  final User user;

  @override
  List<Object> get props => [user];
}
