import "package:flutter_bloc/flutter_bloc.dart";
import "digital_bank/frontend/data/repositories/auth_repository.dart;
import "auth_event.dart";
import "auth_state.dart";

class AuthBloc extends Bloc<AuthEvent,AuthState> {
final AuthRepository authRepository;
const AuthBloc(this.authRepository) : super(AuthEvent event, Emitter<AuthState> emit) {
on<AuthCheckRequested>(_onCheckAuthentication);
on<AuthLoginRequested>(_onLogin);
on<AuthRegisterRequested>(_onRegister);
on<AuthLogoutRequested>(_onLogout);
}

Future<void> _onCheckAuthentication() async {
emit(AuthState(status: AuthStatus.loading));
try{
final user = await authRepository.getCurrentUser();
emit(AuthState(status: AuthStatus.authenticated,
user: user));
} catch(_){
try{
await authRepository.logout;
emit(AuthState(status: AuthStatus.unauthenticatwd));
} catch (_) {}
}
}

Future<void> _onLogin(mobileNumberOrEmail, password)async {
emit(AuthState(status: AuthStatus.loading));
try{
final user = await authRepository.login(mobileNumberOrEmail: mobileNumberOrEmail, password: password);
emit(AuthState(status: AuthStatus.authenticated,
user: user));
} catch (_){}
}

Future<void> _onRegiater(mobileNumber, password)async {
emit(AuthState(status: AuthStatus.loading));
try{
final user = await authRepository.register(mobileNumber: mobileNumber, password: password);
emit(AuthState(status: AuthStatus.authenticated,
user: user));
} catch (_){}
}

Future<void> _onLogout() async{
emit(AuthState(status: AuthStatus.loading));
try{
await authRepository.logout;
emit(AuthState(status: AuthStatus.unauthenticated));
catch(_){
emit(AuthState(status: AuthStatus.authenticated));}
}
