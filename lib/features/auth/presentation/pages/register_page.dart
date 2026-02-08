import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../bloc/auth_bloc.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // 1. Controllers cho 3 trường nhập liệu theo Figma
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(
        authRemoteDataSource: AuthRemoteDataSourceImpl(client: http.Client()),
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Đăng ký thành công! Vui lòng đăng nhập.")),
              );
              Navigator.pop(context); // Quay lại trang Login
            } else if (state is AuthFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
            }
          },
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  // Logo
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Image.asset(
                      'assets/images/logo_dhay.png',
                      height: 120,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Tiêu đề xanh chuẩn AppColors.primary
                  const Text(
                    "Đăng ký vào DHAY",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Chào mừng bạn! Vui lòng đăng ký thông tin tài khoản.",
                    style: TextStyle(
                      color: AppColors.greyText,
                      fontSize: 14,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 3 Trường nhập liệu theo thiết kế Figma
                  CustomTextField(
                    controller: _fullNameController,
                    hintText: "Nhập tên",
                    prefixIcon: const Icon(Icons.account_circle, size: 28),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _identifierController,
                    hintText: "Nhập tên tài khoản",
                    prefixIcon: const Icon(Icons.account_circle, size: 28),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _passwordController,
                    hintText: "Nhập mật khẩu",
                    prefixIcon: const Icon(Icons.lock, size: 28),
                    isPassword: true,
                  ),
                  const SizedBox(height: 32),

                  // Nút Đăng ký (Màu đen, bo góc theo Figma)
                  Center(
                    child: SizedBox(
                      width: 200,
                      height: 56,
                      child: BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          return ElevatedButton(
                            onPressed: state is AuthLoading
                                ? null
                                : () {
                              // 1. Validate cơ bản
                              if (_fullNameController.text.isEmpty ||
                                  _identifierController.text.isEmpty ||
                                  _passwordController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Vui lòng nhập đầy đủ thông tin")),
                                );
                                return;
                              }

                              // 2. Gửi Event Đăng ký tới AuthBloc
                              context.read<AuthBloc>().add(
                                RegisterSubmitted(
                                  fullName: _fullNameController.text.trim(),
                                  identifier: _identifierController.text.trim(),
                                  password: _passwordController.text.trim(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 5,
                            ),
                            child: state is AuthLoading
                                ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                                : const Text("Đăng ký",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Dòng chữ "Đã có tài khoản? Đăng nhập"
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Quay lại trang Login
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "Đã có tài khoản? ",
                              style: TextStyle(color: Colors.black54),
                            ),
                            TextSpan(
                              text: "Đăng nhập",
                              style: TextStyle(
                                color: Color(0xFF2A5EE1),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 100), // Khoảng cách để đẩy dòng From xuống dưới

                  // Footer From DHAY
                  const Center(
                    child: Text.rich(
                      TextSpan(
                        text: "From ",
                        style: TextStyle(color: Colors.black54),
                        children: [
                          TextSpan(
                            text: "DHAY",
                            style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}