import "package:equatable/equatable.dart";
import "package:digital_bank/data/repositories/user.dart";

enum AuthStatus {
loading,
authenticated,
unauthenticated,
}

class AuthState extends Equatable {
final AuthStatus status;
final User? user;
final String? error;

const AuthState({this.status = AuthStatus.loading, this.user, this.error});

bool get isAuthenticated => status == AuthStatus.authenticated;

@override
List<Object?> get props => [status, user, error];
}