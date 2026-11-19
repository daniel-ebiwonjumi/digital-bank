import 'package:digital_bank/features/auth/bloc/auth_event.dart';
import 'package:digital_bank/features/auth/bloc/auth_state.dart';
import 'package:digital_bank/features/auth/data/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this.authRepository) : super(const UnknownAuth()) {
    on<AuthCheckRequested>(_onCheckAuthentication);
    on<AuthLoginRequested>(_onLogin);
    on<AuthRegisterRequested>(_onRegister);
    on<AuthLogoutRequested>(_onLogout);
  }
  final AuthRepository authRepository;
  Future<void> _onCheckAuthentication(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final user = await authRepository.getCurrentUser();
      emit(Authenticated(user: user));
    } catch (_) {
      try {
        await authRepository.logout();
      } catch (_) {}
      emit(const Unauthenticated());
    }
  }

  Future <void> _onLogin(AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final user = await authRepository.login(
        mobileNumberOrEmail: event.mobileNumberOrEmail,
        password: event.password,
      );
      emit(Authenticated(user: user));
    } catch (_) {
      emit(
        const Unauthenticated(),
      );
    }
  }

  Future<void> _onRegister(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await authRepository.login(
        mobileNumberOrEmail: event.mobileNumber,
        password: event.password,
      );
      emit(Authenticated(user: user));
    } catch (_) {
      emit(Unauthenticated());
    }
  }

  Future<void> _onLogout(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await authRepository.logout();
      emit(const Unauthenticated());
    } catch (_) {
       final user = await authRepository.getCurrentUser();
      emit(Authenticated(user: user));
    }
  }
}
