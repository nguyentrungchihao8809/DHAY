import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

// Import dựa trên đúng Tree FE của em
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/models/social_login_request.dart';
import '../../data/models/user_model.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
final GoogleSignIn _googleSignIn = GoogleSignIn();

// --- 2. EVENTS ---
abstract class AuthEvent {}

class LoginSubmitted extends AuthEvent {
  final String identifier;
  final String password;
  LoginSubmitted(this.identifier, this.password);
}

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

class GoogleLoginSubmitted extends AuthEvent {}

class AppStarted extends AuthEvent {}

class LogoutRequested extends AuthEvent {}

// --- 3. BLOC ---
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRemoteDataSource authRemoteDataSource;

  AuthBloc({required this.authRemoteDataSource}) : super(AuthInitial()) {

    // Đăng nhập Local
    on<LoginSubmitted>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await authRemoteDataSource.login(
          event.identifier,
          event.password,
        );
        await _handleAuthSuccess(user, emit);
      } catch (e) {
        emit(AuthFailure("Đăng nhập thất bại: ${e.toString()}"));
      }
    });

    // Đăng ký
    on<RegisterSubmitted>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await authRemoteDataSource.register(
          event.fullName,
          event.identifier,
          event.password,
        );
        await _handleAuthSuccess(user, emit);
      } catch (e) {
        emit(AuthFailure("Đăng ký thất bại: ${e.toString()}"));
      }
    });

    // Đăng nhập Google
    on<GoogleLoginSubmitted>((event, emit) async {
      emit(AuthLoading());
      try {
        final GoogleSignIn googleSignIn = GoogleSignIn();
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

        if (googleUser == null) {
          emit(AuthInitial());
          return;
        }

        final request = SocialLoginRequest(
          email: googleUser.email,
          fullName: googleUser.displayName ?? "User",
          avatarUrl: googleUser.photoUrl,
          identifier: googleUser.id,
          provider: 'GOOGLE', // Enum phía Backend
        );

        final user = await authRemoteDataSource.socialLogin(request);
        await _handleAuthSuccess(user, emit);
      } catch (e) {
        debugPrint("Google Error: $e");
        emit(AuthFailure("Không thể đăng nhập bằng Google"));
      }
    });

    // Khởi tạo App
    on<AppStarted>((event, emit) async {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token != null && token.isNotEmpty) {
        emit(AuthSuccess(UserModel(
            id: '0',
            fullName: 'User',
            email: '',
            token: token
        )));
      } else {
        emit(AuthInitial());
      }
    });

    // Logout
    // Trong phần on<LogoutRequested>
    on<LogoutRequested>((event, emit) async {
      try {
        // 1. Thoát Google
        await _googleSignIn.signOut();

        // 2. Xóa Token trong máy
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('access_token');

        // 3. Trả về trạng thái chưa đăng nhập
        emit(AuthInitial());
      } catch (e) {
        print("Logout error: $e");
      }
    });
  }

  // --- PRIVATE METHODS ---

  // Hàm helper để tránh lặp lại logic lưu token và emit Success
  Future<void> _handleAuthSuccess(UserModel user, Emitter<AuthState> emit) async {
    if (user.token != null && user.token!.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', user.token!);
      debugPrint("✅ Token đã lưu: ${user.token}");
    }
    emit(AuthSuccess(user));
  }
}