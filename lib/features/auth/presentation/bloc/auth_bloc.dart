import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Để dùng SharedPreferences
import 'package:flutter/foundation.dart'; // Để dùng debugPrint

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
            event.password,
        );
        debugPrint("Dữ liệu User trả về từ Login: ${user.toJson()}");
        // --- BẮT ĐẦU LƯU TOKEN Ở ĐÂY ---
        final prefs = await SharedPreferences.getInstance();
        if (user.token != null) {
          await prefs.setString('access_token', user.token!);
          debugPrint("✅ Đã lưu token vào máy: ${user.token}");
        }
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

    on<AppStarted>((event, emit) async {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token != null && token.isNotEmpty) {
        debugPrint("🔍 Đã tìm thấy token cũ, đang khôi phục phiên đăng nhập...");

        // PHẢI CÓ DÒNG EMIT NÀY:
        // Chúng ta tạo một UserModel giả với token đã có để đưa app vào trạng thái Success
        emit(AuthSuccess(UserModel(
            id: '0',
            fullName: 'User',
            email: '',
            token: token
        )));
      } else {
        debugPrint("🔍 Không tìm thấy token, yêu cầu đăng nhập.");
        emit(AuthInitial()); // Hoặc emit(AuthFailure("Chưa đăng nhập"))
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

class AppStarted extends AuthEvent {}