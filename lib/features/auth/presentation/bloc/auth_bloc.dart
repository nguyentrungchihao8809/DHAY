import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/models/user_model.dart';

// --- 1. STATES ---
abstract class AuthState {}
class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthSuccess extends AuthState {
  final UserModel user;
  AuthSuccess(this.user);
}
class AuthFailure extends AuthState {
  final String message;
  AuthFailure(this.message);
}

// --- 2. EVENTS ---
abstract class AuthEvent {}
class LoginSubmitted extends AuthEvent {
  final String identifier;
  final String password;
  LoginSubmitted(this.identifier, this.password);
}

// --- 3. BLOC ---
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRemoteDataSource authRemoteDataSource;

  AuthBloc({required this.authRemoteDataSource}) : super(AuthInitial()) {
    on<LoginSubmitted>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await authRemoteDataSource.login(
            event.identifier,
            event.password
        );
        emit(AuthSuccess(user));
      } catch (e) {
        emit(AuthFailure("Đăng nhập thất bại: ${e.toString()}"));
      }
    });
    on<RegisterSubmitted>((event, emit) async {
      emit(AuthLoading()); // Hiển thị vòng xoay loading
      try {
        // Gọi hàm register từ DataSource
        final user = await authRemoteDataSource.register(
          event.fullName,
          event.identifier,
          event.password,
        );
        emit(AuthSuccess(user)); // Đăng ký thành công
      } catch (e) {
        emit(AuthFailure("Đăng ký thất bại: ${e.toString()}"));
      }
    });
  }
}
// Trong file auth_bloc.dart
class RegisterSubmitted extends AuthEvent {
  final String fullName;
  final String identifier;
  final String password;

  RegisterSubmitted({
    required this.fullName,
    required this.identifier,
    required this.password,
  });
}