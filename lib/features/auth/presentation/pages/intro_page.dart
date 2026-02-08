import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart'; // Đảm bảo đường dẫn này đúng với project của bạn

// --- ĐÂY LÀ PHẦN BẠN ĐANG THIẾU ---
class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}
// ----------------------------------

class _IntroPageState extends State<IntroPage> {
  bool _isTimerDone = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() async {
    // Đợi đúng 3 giây
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    _isTimerDone = true;
    _checkAndNavigate();
  }

  void _checkAndNavigate() {
    // Chỉ chuyển hướng khi Timer đã xong
    if (!_isTimerDone) return;

    final state = context.read<AuthBloc>().state;

    if (state is AuthSuccess) {
      debugPrint("✅ Đã có token, vào HOME");
      Navigator.pushReplacementNamed(context, '/home');
    } else if (state is AuthInitial || state is AuthFailure) {
      debugPrint("❌ Không có token hoặc lỗi, vào LOGIN");
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      // Lắng nghe sự thay đổi trạng thái (đề phòng trường hợp AppStarted chạy lâu hơn 3s)
      listener: (context, state) {
        if (_isTimerDone) {
          _checkAndNavigate();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF4A64FE),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.directions_car, size: 100, color: Colors.white),
              const SizedBox(height: 24),
              const Text(
                "GHEP XE NEW",
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              const CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}