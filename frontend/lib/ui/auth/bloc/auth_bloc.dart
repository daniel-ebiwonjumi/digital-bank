import 'package:digital_bank/data/repositories/auth_repository/auth_repository.dart';
import 'package:digital_bank/ui/auth/bloc/auth_event.dart';
import 'package:digital_bank/ui/auth/bloc/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  AuthBloc(this.authRepository) : super(AuthState(status: AuthStatus.loading)) {
    on<AuthCheckRequested>(_onCheckAuthentication);
    on<AuthLoginRequested>(_onLogin);
    on<AuthRegisterRequested>(_onRegister);
    on<AuthLogoutRequested>(_onLogout);
  }

  Future<void> _onCheckAuthentication(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState(status: AuthStatus.loading));

    try {
      final user = await authRepository.getCurrentUser();
      emit(AuthState(status: AuthStatus.authenticated, user: user));
    } catch (_) {
      try {
        await authRepository.logout();
      } catch (_) {
        //I need to find out why the logout isn't happening. It might be
        //because the user is already logged out
      }
      emit(AuthState(status: AuthStatus.unauthenticated));
    }
  }

  Future _onLogin(AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthState(status: AuthStatus.loading));

    try {
      final user = await authRepository.login(
        mobileNumberOrEmail: event.mobileNumberOrEmail,
        password: event.password,
      );
      emit(AuthState(status: AuthStatus.authenticated, user: user));
    } catch (_) {
      emit(
        AuthState(status: AuthStatus.authenticated, error: 'Unable to login'),
      );
    }
  }

  Future _onRegister(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthState(status: AuthStatus.loading));

    try {
      final user = await authRepository.login(
        mobileNumberOrEmail: event.mobileNumber,
        password: event.password,
      );
      emit(AuthState(status: AuthStatus.authenticated, user: user));
    } catch (_) {
      emit(
        AuthState(
          status: AuthStatus.authenticated,
          error: 'Unable to Register',
        ),
      );
    }
  }

  Future<void> _onLogout(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthState(status: AuthStatus.loading));
    try {
      await authRepository.logout();
      emit(AuthState(status: AuthStatus.unauthenticated));
    } catch (_) {
      emit(
        AuthState(
          status: AuthStatus.authenticated,
          error: 'Failed to logout, please try again',
        ),
      );
    }
  }
}
