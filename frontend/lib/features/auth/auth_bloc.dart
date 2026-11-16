import 'package:digital_bank/features/auth/auth_event.dart';
import 'package:digital_bank/features/auth/auth_repository.dart';
import 'package:digital_bank/features/auth/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  AuthBloc(this.authRepository) : super(UnknownAuth()) {
    on<AuthCheckRequested>(_onCheckAuthentication)
    on<AuthLoginRequested>(_onLogin);
    on<AuthRegisterRequested>(_onRegister);
    on<AuthLogoutRequested>(_onLogout);
  }
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
                                                          } catch (_){}
                                          emit(Unauthenticated());
                                         }
                                      }

  Future _onLogin(AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.login(
        mobileNumberOrEmail: event.mobileNumberOrEmail,
        password: event.password,
      );
      emit(Authenticated(user: user));
    } catch (_) {
      emit(
        Unauthenticated(),
      );
    }
  }

  Future _onRegister(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
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
    emit(AuthLoading());
    try {
      await authRepository.logout();
      emit(Unauthenticated());
    } catch (_) {
      emit(Authenticated(user: user));
    }
  }
}
