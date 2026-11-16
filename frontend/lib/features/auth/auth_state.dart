import 'package:digital_bank/features/auth/user.dart';
import 'package:equatable/equatable.dart';

sealed class AuthState extends Equatable {
const AuthState();

@override
List<Object> props = [];
}

final class UnknownAuth extends AuthState {
  const UnknownAuth();
}

final class AuthLoading extends AuthBloc{
  const AuthLoading();
}

final class Unauthenticated extends AuthState{
  Unauthenticated();
}

final class Authenticated extends AuthState {
  const Authenticated({this.user});

  final User user;
List <Object> props = [user]
}