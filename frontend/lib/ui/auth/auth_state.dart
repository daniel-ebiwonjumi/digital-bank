import "package:equatable/equatable.dart";
import "digital_bank/frontend/data/repositories/user.dart";

enum AuthStatus {
loading,
authenticated,
unauthenticated,
}

class AuthState extends Equatable {
final AuthStatus status;
final User? user;
final String? error;

const AuthState({this.status == AuthStatus.loading, this.user, this.error});

bool get isAuthenticated => status == AuthStatus.isAuthenticated;

@override
List<Object?> props = [status, user, error];
}