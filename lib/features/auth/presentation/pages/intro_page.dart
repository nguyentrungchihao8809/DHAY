import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  bool _isTimerDone = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() async {
    // Đợi 3 giây để người dùng kịp nhìn thấy logo thương hiệu
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    _isTimerDone = true;
    _checkAndNavigate();
  }

  void _checkAndNavigate() {
    if (!_isTimerDone) return;
    final state = context.read<AuthBloc>().state;

    if (state is AuthSuccess) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (_isTimerDone) _checkAndNavigate();
      },
      child: Scaffold(
        backgroundColor: Colors.white, // Nền trắng sạch sẽ theo thiết kế
        body: SafeArea(
          child: Stack(
            children: [
              // 1. Hiển thị Logo chính ở giữa màn hình
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Image.asset(
                    'assets/images/logo_intro.jpg', // Đảm bảo file này khớp với pubspec.yaml
                    width: MediaQuery.of(context).size.width * 0.7,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              // 2. Footer "From DHAY" ở dưới cùng
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 40.0),
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(color: Colors.black, fontSize: 14),
                      children: [
                        TextSpan(text: "From "),
                        TextSpan(
                          text: "DHAY",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4A64FE), // Màu xanh đặc trưng của brand
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}