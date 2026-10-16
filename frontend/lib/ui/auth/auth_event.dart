import "package:equatable/equatable.dart";

sealed class AuthEvent extends Equatable {
const AuthEvent();

@override
List<Object?> props = [];
 }

final class AuthCheckRequested extends AuthEvent { 
const AuthCheckRequested();
}

final class AuthLoginRequested extends AuthEvent {
final String mobileNumberOrEmail;
final String password;

const AuthLoginRequested({
required this.mobileNumberOrEmail, required this.password
});

@override
List<Object?> props = [mobileNumberOrEmail, password];
}

final class AuthRegisterRequested extends AuthEvent {
final String mobileNumber;
final String password;

const AuthRegisterRequested({
required this.mobileNumber, required this.password
});

@override
List<Object?> props = [mobileNumber, password];
}

final class AuthLogoutRequested extends AuthEvent { 
const AuthLogoutRequested();
}

